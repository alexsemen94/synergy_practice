unit TourismSystem.DataModule;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Comp.UI, FireDAC.Stan.StorageJSON,
  System.Generics.Collections, TourismSystem.Models;

type
  TTourismSystemDataModule = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysMSSQLDriverLink: TFDPhysMSSQLDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    
    // Запросы для туров
    qryTours: TFDQuery;
    qryToursByCountry: TFDQuery;
    qryToursByType: TFDQuery;
    
    // Запросы для клиентов
    qryClients: TFDQuery;
    qryClientByEmail: TFDQuery;
    
    // Запросы для бронирований
    qryBookings: TFDQuery;
    qryBookingsByClient: TFDQuery;
    qryBookingsByTour: TFDQuery;
    
    // Запросы для справочников
    qryCountries: TFDQuery;
    qryCities: TFDQuery;
    qryHotels: TFDQuery;
    qryTourTypes: TFDQuery;
    
    // Запросы для статистики
    qryStatistics: TFDQuery;
    qryMonthlyBookings: TFDQuery;
    qryTopDestinations: TFDQuery;
    
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConnectionString: string;
    
    procedure InitializeConnection;
    procedure CreateTablesIfNotExist;
    procedure InsertInitialData;
    
  public
    // Методы для работы с турами
    function GetAllTours: TObjectList<TTour>;
    function GetTourByID(ID: Integer): TTour;
    function GetToursByCountry(CountryID: Integer): TObjectList<TTour>;
    function GetToursByType(TourTypeID: Integer): TObjectList<TTour>;
    function CreateTour(Tour: TTour): TTour;
    function UpdateTour(Tour: TTour): Boolean;
    function DeleteTour(ID: Integer): Boolean;
    
    // Методы для работы с клиентами
    function GetAllClients: TObjectList<TClient>;
    function GetClientByID(ID: Integer): TClient;
    function GetClientByEmail(Email: string): TClient;
    function CreateClient(Client: TClient): TClient;
    function UpdateClient(Client: TClient): Boolean;
    function DeleteClient(ID: Integer): Boolean;
    
    // Методы для работы с бронированиями
    function GetAllBookings: TObjectList<TBooking>;
    function GetBookingByID(ID: Integer): TBooking;
    function GetBookingsByClient(ClientID: Integer): TObjectList<TBooking>;
    function GetBookingsByTour(TourID: Integer): TObjectList<TBooking>;
    function CreateBooking(Booking: TBooking): TBooking;
    function UpdateBooking(Booking: TBooking): Boolean;
    function DeleteBooking(ID: Integer): Boolean;
    
    // Методы для работы со справочниками
    function GetAllCountries: TObjectList<TCountry>;
    function GetAllCities: TObjectList<TCity>;
    function GetAllHotels: TObjectList<THotel>;
    function GetAllTourTypes: TObjectList<TTourType>;
    
    // Методы для статистики
    function GetStatistics: TStatistics;
    function GetMonthlyBookings: TArray<Integer>;
    function GetTopDestinations: TArray<string>;
    
    // Утилиты
    function ExecuteScalar(const SQL: string): Variant;
    function ExecuteNonQuery(const SQL: string): Integer;
    function IsConnected: Boolean;
    
    property ConnectionString: string read FConnectionString write FConnectionString;
  end;

var
  TourismSystemDataModule: TTourismSystemDataModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TTourismSystemDataModule.DataModuleCreate(Sender: TObject);
begin
  InitializeConnection;
  CreateTablesIfNotExist;
  InsertInitialData;
end;

procedure TTourismSystemDataModule.DataModuleDestroy(Sender: TObject);
begin
  if FDConnection.Connected then
    FDConnection.Connected := False;
end;

procedure TTourismSystemDataModule.InitializeConnection;
begin
  // Настройка подключения к MS SQL Server
  FConnectionString := 'Driver={SQL Server};' +
                      'Server=localhost;' +
                      'Database=TourismDB;' +
                      'Trusted_Connection=yes;' +
                      'MultipleActiveResultSets=True;';
  
  FDConnection.Params.Clear;
  FDConnection.Params.Add(FConnectionString);
  
  try
    FDConnection.Connected := True;
  except
    on E: Exception do
      raise Exception.Create('Failed to connect to database: ' + E.Message);
  end;
end;

procedure TTourismSystemDataModule.CreateTablesIfNotExist;
const
  CreateCountriesSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''Countries'' AND xtype=''U'') ' +
    'CREATE TABLE Countries (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'Name NVARCHAR(100) NOT NULL, ' +
    'Code NVARCHAR(3) NOT NULL, ' +
    'Description NVARCHAR(500), ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE()' +
    ')';
    
  CreateCitiesSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''Cities'' AND xtype=''U'') ' +
    'CREATE TABLE Cities (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'Name NVARCHAR(100) NOT NULL, ' +
    'CountryID INT NOT NULL, ' +
    'Description NVARCHAR(500), ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE(), ' +
    'FOREIGN KEY (CountryID) REFERENCES Countries(ID)' +
    ')';
    
  CreateHotelsSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''Hotels'' AND xtype=''U'') ' +
    'CREATE TABLE Hotels (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'Name NVARCHAR(200) NOT NULL, ' +
    'CityID INT NOT NULL, ' +
    'Stars INT DEFAULT 3, ' +
    'Address NVARCHAR(500), ' +
    'Description NVARCHAR(1000), ' +
    'ContactPhone NVARCHAR(20), ' +
    'ContactEmail NVARCHAR(100), ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE(), ' +
    'FOREIGN KEY (CityID) REFERENCES Cities(ID)' +
    ')';
    
  CreateTourTypesSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''TourTypes'' AND xtype=''U'') ' +
    'CREATE TABLE TourTypes (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'Name NVARCHAR(100) NOT NULL, ' +
    'Description NVARCHAR(500), ' +
    'Icon NVARCHAR(50), ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE()' +
    ')';
    
  CreateToursSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''Tours'' AND xtype=''U'') ' +
    'CREATE TABLE Tours (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'Name NVARCHAR(200) NOT NULL, ' +
    'TourTypeID INT NOT NULL, ' +
    'CountryID INT NOT NULL, ' +
    'CityID INT NOT NULL, ' +
    'HotelID INT NOT NULL, ' +
    'Duration INT NOT NULL, ' +
    'Price DECIMAL(10,2) NOT NULL, ' +
    'MaxTourists INT NOT NULL, ' +
    'StartDate DATE NOT NULL, ' +
    'EndDate DATE NOT NULL, ' +
    'Description NVARCHAR(2000), ' +
    'ImageURL NVARCHAR(500), ' +
    'IsActive BIT DEFAULT 1, ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE(), ' +
    'FOREIGN KEY (TourTypeID) REFERENCES TourTypes(ID), ' +
    'FOREIGN KEY (CountryID) REFERENCES Countries(ID), ' +
    'FOREIGN KEY (CityID) REFERENCES Cities(ID), ' +
    'FOREIGN KEY (HotelID) REFERENCES Hotels(ID)' +
    ')';
    
  CreateClientsSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''Clients'' AND xtype=''U'') ' +
    'CREATE TABLE Clients (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'FirstName NVARCHAR(100) NOT NULL, ' +
    'LastName NVARCHAR(100) NOT NULL, ' +
    'Email NVARCHAR(100) NOT NULL UNIQUE, ' +
    'Phone NVARCHAR(20), ' +
    'Passport NVARCHAR(20), ' +
    'BirthDate DATE, ' +
    'RegistrationDate DATE DEFAULT GETDATE(), ' +
    'IsActive BIT DEFAULT 1, ' +
    'Notes NVARCHAR(1000), ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE()' +
    ')';
    
  CreateBookingsSQL = 
    'IF NOT EXISTS (SELECT * FROM sysobjects WHERE name=''Bookings'' AND xtype=''U'') ' +
    'CREATE TABLE Bookings (' +
    'ID INT IDENTITY(1,1) PRIMARY KEY, ' +
    'TourID INT NOT NULL, ' +
    'ClientID INT NOT NULL, ' +
    'BookingDate DATE DEFAULT GETDATE(), ' +
    'TouristsCount INT NOT NULL, ' +
    'TotalPrice DECIMAL(10,2) NOT NULL, ' +
    'Status NVARCHAR(50) DEFAULT ''Pending'', ' +
    'PaymentStatus NVARCHAR(50) DEFAULT ''Pending'', ' +
    'Notes NVARCHAR(1000), ' +
    'CreatedAt DATETIME DEFAULT GETDATE(), ' +
    'UpdatedAt DATETIME DEFAULT GETDATE(), ' +
    'FOREIGN KEY (TourID) REFERENCES Tours(ID), ' +
    'FOREIGN KEY (ClientID) REFERENCES Clients(ID)' +
    ')';
begin
  try
    ExecuteNonQuery(CreateCountriesSQL);
    ExecuteNonQuery(CreateCitiesSQL);
    ExecuteNonQuery(CreateHotelsSQL);
    ExecuteNonQuery(CreateTourTypesSQL);
    ExecuteNonQuery(CreateToursSQL);
    ExecuteNonQuery(CreateClientsSQL);
    ExecuteNonQuery(CreateBookingsSQL);
  except
    on E: Exception do
      raise Exception.Create('Failed to create tables: ' + E.Message);
  end;
end;

procedure TTourismSystemDataModule.InsertInitialData;
const
  InsertCountriesSQL = 
    'IF NOT EXISTS (SELECT * FROM Countries WHERE Code = ''RUS'') ' +
    'INSERT INTO Countries (Name, Code, Description) VALUES ' +
    '(''Россия'', ''RUS'', ''Крупнейшая страна в мире''), ' +
    '(''Турция'', ''TUR'', ''Популярное направление для отдыха''), ' +
    '(''Египет'', ''EGY'', ''Страна пирамид и Красного моря''), ' +
    '(''Таиланд'', ''THA'', ''Страна улыбок и экзотики'')';
    
  InsertTourTypesSQL = 
    'IF NOT EXISTS (SELECT * FROM TourTypes WHERE Name = ''Пляжный отдых'') ' +
    'INSERT INTO TourTypes (Name, Description, Icon) VALUES ' +
    '(''Пляжный отдых'', ''Отдых на море с проживанием в отеле'', ''beach''), ' +
    '(''Экскурсионный тур'', ''Познавательные поездки по городам'', ''city''), ' +
    '(''Горнолыжный тур'', ''Отдых в горах с катанием на лыжах'', ''ski''), ' +
    '(''Лечебный тур'', ''Оздоровительные программы'', ''health'')';
begin
  try
    ExecuteNonQuery(InsertCountriesSQL);
    ExecuteNonQuery(InsertTourTypesSQL);
  except
    on E: Exception do
      // Игнорируем ошибки при вставке данных
  end;
end;

// Методы для работы с турами
function TTourismSystemDataModule.GetAllTours: TObjectList<TTour>;
var
  Tour: TTour;
begin
  Result := TObjectList<TTour>.Create(True);
  
  qryTours.Close;
  qryTours.SQL.Text := 
    'SELECT t.*, tt.Name as TourTypeName, c.Name as CountryName, ' +
    'ci.Name as CityName, h.Name as HotelName ' +
    'FROM Tours t ' +
    'JOIN TourTypes tt ON t.TourTypeID = tt.ID ' +
    'JOIN Countries c ON t.CountryID = c.ID ' +
    'JOIN Cities ci ON t.CityID = ci.ID ' +
    'JOIN Hotels h ON t.HotelID = h.ID ' +
    'WHERE t.IsActive = 1 ' +
    'ORDER BY t.CreatedAt DESC';
  qryTours.Open;
  
  while not qryTours.Eof do
  begin
    Tour := TTour.Create;
    Tour.ID := qryTours.FieldByName('ID').AsInteger;
    Tour.Name := qryTours.FieldByName('Name').AsString;
    Tour.TourType := qryTours.FieldByName('TourTypeName').AsString;
    Tour.Country := qryTours.FieldByName('CountryName').AsString;
    Tour.City := qryTours.FieldByName('CityName').AsString;
    Tour.Hotel := qryTours.FieldByName('HotelName').AsString;
    Tour.Duration := qryTours.FieldByName('Duration').AsInteger;
    Tour.Price := qryTours.FieldByName('Price').AsCurrency;
    Tour.MaxTourists := qryTours.FieldByName('MaxTourists').AsInteger;
    Tour.StartDate := qryTours.FieldByName('StartDate').AsDateTime;
    Tour.EndDate := qryTours.FieldByName('EndDate').AsDateTime;
    Tour.Description := qryTours.FieldByName('Description').AsString;
    Tour.ImageURL := qryTours.FieldByName('ImageURL').AsString;
    Tour.IsActive := qryTours.FieldByName('IsActive').AsBoolean;
    
    Result.Add(Tour);
    qryTours.Next;
  end;
  
  qryTours.Close;
end;

function TTourismSystemDataModule.GetTourByID(ID: Integer): TTour;
begin
  Result := nil;
  
  qryTours.Close;
  qryTours.SQL.Text := 
    'SELECT t.*, tt.Name as TourTypeName, c.Name as CountryName, ' +
    'ci.Name as CityName, h.Name as HotelName ' +
    'FROM Tours t ' +
    'JOIN TourTypes tt ON t.TourTypeID = tt.ID ' +
    'JOIN Countries c ON t.CountryID = c.ID ' +
    'JOIN Cities ci ON t.CityID = ci.ID ' +
    'JOIN Hotels h ON t.HotelID = h.ID ' +
    'WHERE t.ID = :ID AND t.IsActive = 1';
  qryTours.ParamByName('ID').AsInteger := ID;
  qryTours.Open;
  
  if not qryTours.Eof then
  begin
    Result := TTour.Create;
    Result.ID := qryTours.FieldByName('ID').AsInteger;
    Result.Name := qryTours.FieldByName('Name').AsString;
    Result.TourType := qryTours.FieldByName('TourTypeName').AsString;
    Result.Country := qryTours.FieldByName('CountryName').AsString;
    Result.City := qryTours.FieldByName('CityName').AsString;
    Result.Hotel := qryTours.FieldByName('HotelName').AsString;
    Result.Duration := qryTours.FieldByName('Duration').AsInteger;
    Result.Price := qryTours.FieldByName('Price').AsCurrency;
    Result.MaxTourists := qryTours.FieldByName('MaxTourists').AsInteger;
    Result.StartDate := qryTours.FieldByName('StartDate').AsDateTime;
    Result.EndDate := qryTours.FieldByName('EndDate').AsDateTime;
    Result.Description := qryTours.FieldByName('Description').AsString;
    Result.ImageURL := qryTours.FieldByName('ImageURL').AsString;
    Result.IsActive := qryTours.FieldByName('IsActive').AsBoolean;
  end;
  
  qryTours.Close;
end;

function TTourismSystemDataModule.CreateTour(Tour: TTour): TTour;
var
  InsertSQL: string;
  TourID: Integer;
begin
  InsertSQL := 
    'INSERT INTO Tours (Name, TourTypeID, CountryID, CityID, HotelID, ' +
    'Duration, Price, MaxTourists, StartDate, EndDate, Description, ImageURL, IsActive) ' +
    'VALUES (:Name, :TourTypeID, :CountryID, :CityID, :HotelID, ' +
    ':Duration, :Price, :MaxTourists, :StartDate, :EndDate, :Description, :ImageURL, :IsActive); ' +
    'SELECT SCOPE_IDENTITY() as ID';
  
  try
    qryTours.Close;
    qryTours.SQL.Text := InsertSQL;
    qryTours.ParamByName('Name').AsString := Tour.Name;
    qryTours.ParamByName('TourTypeID').AsInteger := Tour.TourTypeID;
    qryTours.ParamByName('CountryID').AsInteger := Tour.CountryID;
    qryTours.ParamByName('CityID').AsInteger := Tour.CityID;
    qryTours.ParamByName('HotelID').AsInteger := Tour.HotelID;
    qryTours.ParamByName('Duration').AsInteger := Tour.Duration;
    qryTours.ParamByName('Price').AsCurrency := Tour.Price;
    qryTours.ParamByName('MaxTourists').AsInteger := Tour.MaxTourists;
    qryTours.ParamByName('StartDate').AsDate := Tour.StartDate;
    qryTours.ParamByName('EndDate').AsDate := Tour.EndDate;
    qryTours.ParamByName('Description').AsString := Tour.Description;
    qryTours.ParamByName('ImageURL').AsString := Tour.ImageURL;
    qryTours.ParamByName('IsActive').AsBoolean := Tour.IsActive;
    
    qryTours.Open;
    TourID := qryTours.FieldByName('ID').AsInteger;
    qryTours.Close;
    
    Result := GetTourByID(TourID);
  except
    on E: Exception do
      raise Exception.Create('Failed to create tour: ' + E.Message);
  end;
end;

function TTourismSystemDataModule.UpdateTour(Tour: TTour): Boolean;
const
  UpdateSQL = 
    'UPDATE Tours SET ' +
    'Name = :Name, TourTypeID = :TourTypeID, CountryID = :CountryID, ' +
    'CityID = :CityID, HotelID = :HotelID, Duration = :Duration, ' +
    'Price = :Price, MaxTourists = :MaxTourists, StartDate = :StartDate, ' +
    'EndDate = :EndDate, Description = :Description, ImageURL = :ImageURL, ' +
    'IsActive = :IsActive, UpdatedAt = GETDATE() ' +
    'WHERE ID = :ID';
begin
  try
    qryTours.Close;
    qryTours.SQL.Text := UpdateSQL;
    qryTours.ParamByName('ID').AsInteger := Tour.ID;
    qryTours.ParamByName('Name').AsString := Tour.Name;
    qryTours.ParamByName('TourTypeID').AsInteger := Tour.TourTypeID;
    qryTours.ParamByName('CountryID').AsInteger := Tour.CountryID;
    qryTours.ParamByName('CityID').AsInteger := Tour.CityID;
    qryTours.ParamByName('HotelID').AsInteger := Tour.HotelID;
    qryTours.ParamByName('Duration').AsInteger := Tour.Duration;
    qryTours.ParamByName('Price').AsCurrency := Tour.Price;
    qryTours.ParamByName('MaxTourists').AsInteger := Tour.MaxTourists;
    qryTours.ParamByName('StartDate').AsDate := Tour.StartDate;
    qryTours.ParamByName('EndDate').AsDate := Tour.EndDate;
    qryTours.ParamByName('Description').AsString := Tour.Description;
    qryTours.ParamByName('ImageURL').AsString := Tour.ImageURL;
    qryTours.ParamByName('IsActive').AsBoolean := Tour.IsActive;
    
    qryTours.ExecSQL;
    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      raise Exception.Create('Failed to update tour: ' + E.Message);
    end;
  end;
end;

function TTourismSystemDataModule.DeleteTour(ID: Integer): Boolean;
const
  DeleteSQL = 'UPDATE Tours SET IsActive = 0, UpdatedAt = GETDATE() WHERE ID = :ID';
begin
  try
    qryTours.Close;
    qryTours.SQL.Text := DeleteSQL;
    qryTours.ParamByName('ID').AsInteger := ID;
    qryTours.ExecSQL;
    Result := True;
  except
    on E: Exception do
    begin
      Result := False;
      raise Exception.Create('Failed to delete tour: ' + E.Message);
    end;
  end;
end;

// Методы для работы с клиентами
function TTourismSystemDataModule.GetAllClients: TObjectList<TClient>;
var
  Client: TClient;
begin
  Result := TObjectList<TClient>.Create(True);
  
  qryClients.Close;
  qryClients.SQL.Text := 
    'SELECT * FROM Clients WHERE IsActive = 1 ORDER BY CreatedAt DESC';
  qryClients.Open;
  
  while not qryClients.Eof do
  begin
    Client := TClient.Create;
    Client.ID := qryClients.FieldByName('ID').AsInteger;
    Client.FirstName := qryClients.FieldByName('FirstName').AsString;
    Client.LastName := qryClients.FieldByName('LastName').AsString;
    Client.Email := qryClients.FieldByName('Email').AsString;
    Client.Phone := qryClients.FieldByName('Phone').AsString;
    Client.Passport := qryClients.FieldByName('Passport').AsString;
    Client.BirthDate := qryClients.FieldByName('BirthDate').AsDateTime;
    Client.RegistrationDate := qryClients.FieldByName('RegistrationDate').AsDateTime;
    Client.IsActive := qryClients.FieldByName('IsActive').AsBoolean;
    Client.Notes := qryClients.FieldByName('Notes').AsString;
    
    Result.Add(Client);
    qryClients.Next;
  end;
  
  qryClients.Close;
end;

function TTourismSystemDataModule.CreateClient(Client: TClient): TClient;
var
  InsertSQL: string;
  ClientID: Integer;
begin
  InsertSQL := 
    'INSERT INTO Clients (FirstName, LastName, Email, Phone, Passport, ' +
    'BirthDate, RegistrationDate, IsActive, Notes) ' +
    'VALUES (:FirstName, :LastName, :Email, :Phone, :Passport, ' +
    ':BirthDate, :RegistrationDate, :IsActive, :Notes); ' +
    'SELECT SCOPE_IDENTITY() as ID';
  
  try
    qryClients.Close;
    qryClients.SQL.Text := InsertSQL;
    qryClients.ParamByName('FirstName').AsString := Client.FirstName;
    qryClients.ParamByName('LastName').AsString := Client.LastName;
    qryClients.ParamByName('Email').AsString := Client.Email;
    qryClients.ParamByName('Phone').AsString := Client.Phone;
    qryClients.ParamByName('Passport').AsString := Client.Passport;
    qryClients.ParamByName('BirthDate').AsDate := Client.BirthDate;
    qryClients.ParamByName('RegistrationDate').AsDate := Client.RegistrationDate;
    qryClients.ParamByName('IsActive').AsBoolean := Client.IsActive;
    qryClients.ParamByName('Notes').AsString := Client.Notes;
    
    qryClients.Open;
    ClientID := qryClients.FieldByName('ID').AsInteger;
    qryClients.Close;
    
    Result := GetClientByID(ClientID);
  except
    on E: Exception do
      raise Exception.Create('Failed to create client: ' + E.Message);
  end;
end;

function TTourismSystemDataModule.GetClientByID(ID: Integer): TClient;
begin
  Result := nil;
  
  qryClients.Close;
  qryClients.SQL.Text := 'SELECT * FROM Clients WHERE ID = :ID AND IsActive = 1';
  qryClients.ParamByName('ID').AsInteger := ID;
  qryClients.Open;
  
  if not qryClients.Eof then
  begin
    Result := TClient.Create;
    Result.ID := qryClients.FieldByName('ID').AsInteger;
    Result.FirstName := qryClients.FieldByName('FirstName').AsString;
    Result.LastName := qryClients.FieldByName('LastName').AsString;
    Result.Email := qryClients.FieldByName('Email').AsString;
    Result.Phone := qryClients.FieldByName('Phone').AsString;
    Result.Passport := qryClients.FieldByName('Passport').AsString;
    Result.BirthDate := qryClients.FieldByName('BirthDate').AsDateTime;
    Result.RegistrationDate := qryClients.FieldByName('RegistrationDate').AsDateTime;
    Result.IsActive := qryClients.FieldByName('IsActive').AsBoolean;
    Result.Notes := qryClients.FieldByName('Notes').AsString;
  end;
  
  qryClients.Close;
end;

// Методы для работы с бронированиями
function TTourismSystemDataModule.GetAllBookings: TObjectList<TBooking>;
var
  Booking: TBooking;
begin
  Result := TObjectList<TBooking>.Create(True);
  
  qryBookings.Close;
  qryBookings.SQL.Text := 
    'SELECT b.*, t.Name as TourName, c.FirstName + '' '' + c.LastName as ClientName ' +
    'FROM Bookings b ' +
    'JOIN Tours t ON b.TourID = t.ID ' +
    'JOIN Clients c ON b.ClientID = c.ID ' +
    'ORDER BY b.CreatedAt DESC';
  qryBookings.Open;
  
  while not qryBookings.Eof do
  begin
    Booking := TBooking.Create;
    Booking.ID := qryBookings.FieldByName('ID').AsInteger;
    Booking.TourID := qryBookings.FieldByName('TourID').AsInteger;
    Booking.TourName := qryBookings.FieldByName('TourName').AsString;
    Booking.ClientID := qryBookings.FieldByName('ClientID').AsInteger;
    Booking.ClientName := qryBookings.FieldByName('ClientName').AsString;
    Booking.BookingDate := qryBookings.FieldByName('BookingDate').AsDateTime;
    Booking.TouristsCount := qryBookings.FieldByName('TouristsCount').AsInteger;
    Booking.TotalPrice := qryBookings.FieldByName('TotalPrice').AsCurrency;
    Booking.Status := qryBookings.FieldByName('Status').AsString;
    Booking.PaymentStatus := qryBookings.FieldByName('PaymentStatus').AsString;
    Booking.Notes := qryBookings.FieldByName('Notes').AsString;
    
    Result.Add(Booking);
    qryBookings.Next;
  end;
  
  qryBookings.Close;
end;

function TTourismSystemDataModule.CreateBooking(Booking: TBooking): TBooking;
var
  InsertSQL: string;
  BookingID: Integer;
begin
  InsertSQL := 
    'INSERT INTO Bookings (TourID, ClientID, BookingDate, TouristsCount, ' +
    'TotalPrice, Status, PaymentStatus, Notes) ' +
    'VALUES (:TourID, :ClientID, :BookingDate, :TouristsCount, ' +
    ':TotalPrice, :Status, :PaymentStatus, :Notes); ' +
    'SELECT SCOPE_IDENTITY() as ID';
  
  try
    qryBookings.Close;
    qryBookings.SQL.Text := InsertSQL;
    qryBookings.ParamByName('TourID').AsInteger := Booking.TourID;
    qryBookings.ParamByName('ClientID').AsInteger := Booking.ClientID;
    qryBookings.ParamByName('BookingDate').AsDate := Booking.BookingDate;
    qryBookings.ParamByName('TouristsCount').AsInteger := Booking.TouristsCount;
    qryBookings.ParamByName('TotalPrice').AsCurrency := Booking.TotalPrice;
    qryBookings.ParamByName('Status').AsString := Booking.Status;
    qryBookings.ParamByName('PaymentStatus').AsString := Booking.PaymentStatus;
    qryBookings.ParamByName('Notes').AsString := Booking.Notes;
    
    qryBookings.Open;
    BookingID := qryBookings.FieldByName('ID').AsInteger;
    qryBookings.Close;
    
    Result := GetBookingByID(BookingID);
  except
    on E: Exception do
      raise Exception.Create('Failed to create booking: ' + E.Message);
  end;
end;

function TTourismSystemDataModule.GetBookingByID(ID: Integer): TBooking;
begin
  Result := nil;
  
  qryBookings.Close;
  qryBookings.SQL.Text := 
    'SELECT b.*, t.Name as TourName, c.FirstName + '' '' + c.LastName as ClientName ' +
    'FROM Bookings b ' +
    'JOIN Tours t ON b.TourID = t.ID ' +
    'JOIN Clients c ON b.ClientID = c.ID ' +
    'WHERE b.ID = :ID';
  qryBookings.ParamByName('ID').AsInteger := ID;
  qryBookings.Open;
  
  if not qryBookings.Eof then
  begin
    Result := TBooking.Create;
    Result.ID := qryBookings.FieldByName('ID').AsInteger;
    Result.TourID := qryBookings.FieldByName('TourID').AsInteger;
    Result.TourName := qryBookings.FieldByName('TourName').AsString;
    Result.ClientID := qryBookings.FieldByName('ClientID').AsInteger;
    Result.ClientName := qryBookings.FieldByName('ClientName').AsString;
    Result.BookingDate := qryBookings.FieldByName('BookingDate').AsDateTime;
    Result.TouristsCount := qryBookings.FieldByName('TouristsCount').AsInteger;
    Result.TotalPrice := qryBookings.FieldByName('TotalPrice').AsCurrency;
    Result.Status := qryBookings.FieldByName('Status').AsString;
    Result.PaymentStatus := qryBookings.FieldByName('PaymentStatus').AsString;
    Result.Notes := qryBookings.FieldByName('Notes').AsString;
  end;
  
  qryBookings.Close;
end;

// Методы для справочников
function TTourismSystemDataModule.GetAllCountries: TObjectList<TCountry>;
var
  Country: TCountry;
begin
  Result := TObjectList<TCountry>.Create(True);
  
  qryCountries.Close;
  qryCountries.SQL.Text := 'SELECT * FROM Countries ORDER BY Name';
  qryCountries.Open;
  
  while not qryCountries.Eof do
  begin
    Country := TCountry.Create;
    Country.ID := qryCountries.FieldByName('ID').AsInteger;
    Country.Name := qryCountries.FieldByName('Name').AsString;
    Country.Code := qryCountries.FieldByName('Code').AsString;
    Country.Description := qryCountries.FieldByName('Description').AsString;
    
    Result.Add(Country);
    qryCountries.Next;
  end;
  
  qryCountries.Close;
end;

function TTourismSystemDataModule.GetAllCities: TObjectList<TCity>;
var
  City: TCity;
begin
  Result := TObjectList<TCity>.Create(True);
  
  qryCities.Close;
  qryCities.SQL.Text := 
    'SELECT ci.*, c.Name as CountryName ' +
    'FROM Cities ci ' +
    'JOIN Countries c ON ci.CountryID = c.ID ' +
    'ORDER BY ci.Name';
  qryCities.Open;
  
  while not qryCities.Eof do
  begin
    City := TCity.Create;
    City.ID := qryCities.FieldByName('ID').AsInteger;
    City.Name := qryCities.FieldByName('Name').AsString;
    City.CountryID := qryCities.FieldByName('CountryID').AsInteger;
    City.CountryName := qryCities.FieldByName('CountryName').AsString;
    City.Description := qryCities.FieldByName('Description').AsString;
    
    Result.Add(City);
    qryCities.Next;
  end;
  
  qryCities.Close;
end;

function TTourismSystemDataModule.GetAllHotels: TObjectList<THotel>;
var
  Hotel: THotel;
begin
  Result := TObjectList<THotel>.Create(True);
  
  qryHotels.Close;
  qryHotels.SQL.Text := 
    'SELECT h.*, ci.Name as CityName, c.Name as CountryName ' +
    'FROM Hotels h ' +
    'JOIN Cities ci ON h.CityID = ci.ID ' +
    'JOIN Countries c ON ci.CountryID = c.ID ' +
    'ORDER BY h.Name';
  qryHotels.Open;
  
  while not qryHotels.Eof do
  begin
    Hotel := THotel.Create;
    Hotel.ID := qryHotels.FieldByName('ID').AsInteger;
    Hotel.Name := qryHotels.FieldByName('Name').AsString;
    Hotel.CityID := qryHotels.FieldByName('CityID').AsInteger;
    Hotel.CityName := qryHotels.FieldByName('CityName').AsString;
    Hotel.CountryName := qryHotels.FieldByName('CountryName').AsString;
    Hotel.Stars := qryHotels.FieldByName('Stars').AsInteger;
    Hotel.Address := qryHotels.FieldByName('Address').AsString;
    Hotel.Description := qryHotels.FieldByName('Description').AsString;
    Hotel.ContactPhone := qryHotels.FieldByName('ContactPhone').AsString;
    Hotel.ContactEmail := qryHotels.FieldByName('ContactEmail').AsString;
    
    Result.Add(Hotel);
    qryHotels.Next;
  end;
  
  qryHotels.Close;
end;

function TTourismSystemDataModule.GetAllTourTypes: TObjectList<TTourType>;
var
  TourType: TTourType;
begin
  Result := TObjectList<TTourType>.Create(True);
  
  qryTourTypes.Close;
  qryTourTypes.SQL.Text := 'SELECT * FROM TourTypes ORDER BY Name';
  qryTourTypes.Open;
  
  while not qryTourTypes.Eof do
  begin
    TourType := TTourType.Create;
    TourType.ID := qryTourTypes.FieldByName('ID').AsInteger;
    TourType.Name := qryTourTypes.FieldByName('Name').AsString;
    TourType.Description := qryTourTypes.FieldByName('Description').AsString;
    TourType.Icon := qryTourTypes.FieldByName('Icon').AsString;
    
    Result.Add(TourType);
    qryTourTypes.Next;
  end;
  
  qryTourTypes.Close;
end;

// Методы для статистики
function TTourismSystemDataModule.GetStatistics: TStatistics;
begin
  Result := TStatistics.Create;
  
  try
    qryStatistics.Close;
    qryStatistics.SQL.Text := 
      'SELECT ' +
      '(SELECT COUNT(*) FROM Tours WHERE IsActive = 1) as TotalTours, ' +
      '(SELECT COUNT(*) FROM Clients WHERE IsActive = 1) as TotalClients, ' +
      '(SELECT COUNT(*) FROM Bookings) as TotalBookings, ' +
      '(SELECT ISNULL(SUM(TotalPrice), 0) FROM Bookings) as TotalRevenue, ' +
      '(SELECT ISNULL(AVG(Price), 0) FROM Tours WHERE IsActive = 1) as AverageTourPrice';
    qryStatistics.Open;
    
    if not qryStatistics.Eof then
    begin
      Result.TotalTours := qryStatistics.FieldByName('TotalTours').AsInteger;
      Result.TotalClients := qryStatistics.FieldByName('TotalClients').AsInteger;
      Result.TotalBookings := qryStatistics.FieldByName('TotalBookings').AsInteger;
      Result.TotalRevenue := qryStatistics.FieldByName('TotalRevenue').AsCurrency;
      Result.AverageTourPrice := qryStatistics.FieldByName('AverageTourPrice').AsCurrency;
    end;
    
    qryStatistics.Close;
    
    // Получаем популярные направления
    qryTopDestinations.Close;
    qryTopDestinations.SQL.Text := 
      'SELECT TOP 5 c.Name as CountryName, COUNT(b.ID) as BookingCount ' +
      'FROM Countries c ' +
      'JOIN Cities ci ON c.ID = ci.CountryID ' +
      'JOIN Hotels h ON ci.ID = h.CityID ' +
      'JOIN Tours t ON h.ID = t.HotelID ' +
      'JOIN Bookings b ON t.ID = b.TourID ' +
      'GROUP BY c.Name ' +
      'ORDER BY COUNT(b.ID) DESC';
    qryTopDestinations.Open;
    
    var Destinations: TArray<string>;
    SetLength(Destinations, 0);
    
    while not qryTopDestinations.Eof do
    begin
      SetLength(Destinations, Length(Destinations) + 1);
      Destinations[High(Destinations)] := qryTopDestinations.FieldByName('CountryName').AsString;
      qryTopDestinations.Next;
    end;
    
    Result.TopDestinations := Destinations;
    qryTopDestinations.Close;
    
  except
    on E: Exception do
      raise Exception.Create('Failed to get statistics: ' + E.Message);
  end;
end;

// Утилиты
function TTourismSystemDataModule.ExecuteScalar(const SQL: string): Variant;
begin
  try
    qryTours.Close;
    qryTours.SQL.Text := SQL;
    qryTours.Open;
    
    if not qryTours.Eof then
      Result := qryTours.Fields[0].Value
    else
      Result := Null;
      
    qryTours.Close;
  except
    on E: Exception do
      raise Exception.Create('ExecuteScalar failed: ' + E.Message);
  end;
end;

function TTourismSystemDataModule.ExecuteNonQuery(const SQL: string): Integer;
begin
  try
    qryTours.Close;
    qryTours.SQL.Text := SQL;
    qryTours.ExecSQL;
    Result := qryTours.RowsAffected;
  except
    on E: Exception do
      raise Exception.Create('ExecuteNonQuery failed: ' + E.Message);
  end;
end;

function TTourismSystemDataModule.IsConnected: Boolean;
begin
  Result := FDConnection.Connected;
end;

// Заглушки для нереализованных методов
function TTourismSystemDataModule.GetToursByCountry(CountryID: Integer): TObjectList<TTour>;
begin
  Result := TObjectList<TTour>.Create(True);
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.GetToursByType(TourTypeID: Integer): TObjectList<TTour>;
begin
  Result := TObjectList<TTour>.Create(True);
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.GetClientByEmail(Email: string): TClient;
begin
  Result := nil;
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.UpdateClient(Client: TClient): Boolean;
begin
  Result := False;
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.DeleteClient(ID: Integer): Boolean;
begin
  Result := False;
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.GetBookingsByClient(ClientID: Integer): TObjectList<TBooking>;
begin
  Result := TObjectList<TBooking>.Create(True);
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.GetBookingsByTour(TourID: Integer): TObjectList<TBooking>;
begin
  Result := TObjectList<TBooking>.Create(True);
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.UpdateBooking(Booking: TBooking): Boolean;
begin
  Result := False;
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.DeleteBooking(ID: Integer): Boolean;
begin
  Result := False;
  // Реализация будет добавлена позже
end;

function TTourismSystemDataModule.GetMonthlyBookings: TArray<Integer>;
begin
  SetLength(Result, 12);
  // Реализация будет добавлена позже
end;

end.
