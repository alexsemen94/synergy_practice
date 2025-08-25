unit TourismSystem.Models;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.JSON, System.DateUtils;

type
  // Базовая модель для всех сущностей
  TBaseModel = class
  private
    FID: Integer;
    FCreatedAt: TDateTime;
    FUpdatedAt: TDateTime;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    
    property ID: Integer read FID write FID;
    property CreatedAt: TDateTime read FCreatedAt write FCreatedAt;
    property UpdatedAt: TDateTime read FUpdatedAt write FUpdatedAt;
  end;

  // Модель страны
  TCountry = class(TBaseModel)
  private
    FName: string;
    FCode: string;
    FDescription: string;
  public
    constructor Create; override;
    
    property Name: string read FName write FName;
    property Code: string read FCode write FCode;
    property Description: string read FDescription write FDescription;
  end;

  // Модель города
  TCity = class(TBaseModel)
  private
    FName: string;
    FCountryID: Integer;
    FCountryName: string;
    FDescription: string;
  public
    constructor Create; override;
    
    property Name: string read FName write FName;
    property CountryID: Integer read FCountryID write FCountryID;
    property CountryName: string read FCountryName write FCountryName;
    property Description: string read FDescription write FDescription;
  end;

  // Модель отеля
  THotel = class(TBaseModel)
  private
    FName: string;
    FCityID: Integer;
    FCityName: string;
    FCountryName: string;
    FStars: Integer;
    FAddress: string;
    FDescription: string;
    FContactPhone: string;
    FContactEmail: string;
  public
    constructor Create; override;
    
    property Name: string read FName write FName;
    property CityID: Integer read FCityID write FCityID;
    property CityName: string read FCityName write FCityName;
    property CountryName: string read FCountryName write FCountryName;
    property Stars: Integer read FStars write FStars;
    property Address: string read FAddress write FAddress;
    property Description: string read FDescription write FDescription;
    property ContactPhone: string read FContactPhone write FContactPhone;
    property ContactEmail: string read FContactEmail write FContactEmail;
  end;

  // Модель типа тура
  TTourType = class(TBaseModel)
  private
    FName: string;
    FDescription: string;
    FIcon: string;
  public
    constructor Create; override;
    
    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Icon: string read FIcon write FIcon;
  end;

  // Модель тура
  TTour = class(TBaseModel)
  private
    FName: string;
    FTourTypeID: Integer;
    FTourType: string;
    FCountryID: Integer;
    FCountry: string;
    FCityID: Integer;
    FCity: string;
    FHotelID: Integer;
    FHotel: string;
    FDuration: Integer;
    FPrice: Currency;
    FMaxTourists: Integer;
    FStartDate: TDate;
    FEndDate: TDate;
    FDescription: string;
    FImageURL: string;
    FIsActive: Boolean;
  public
    constructor Create; override;
    
    property Name: string read FName write FName;
    property TourTypeID: Integer read FTourTypeID write FTourTypeID;
    property TourType: string read FTourType write FTourType;
    property CountryID: Integer read FCountryID write FCountryID;
    property Country: string read FCountry write FCountry;
    property CityID: Integer read FCityID write FCityID;
    property City: string read FCity write FCity;
    property HotelID: Integer read FHotelID write FHotelID;
    property Hotel: string read FHotel write FHotel;
    property Duration: Integer read FDuration write FDuration;
    property Price: Currency read FPrice write FPrice;
    property MaxTourists: Integer read FMaxTourists write FMaxTourists;
    property StartDate: TDate read FStartDate write FStartDate;
    property EndDate: TDate read FEndDate write FEndDate;
    property Description: string read FDescription write FDescription;
    property ImageURL: string read FImageURL write FImageURL;
    property IsActive: Boolean read FIsActive write FIsActive;
  end;

  // Модель клиента
  TClient = class(TBaseModel)
  private
    FFirstName: string;
    FLastName: string;
    FEmail: string;
    FPhone: string;
    FPassport: string;
    FBirthDate: TDate;
    FRegistrationDate: TDate;
    FIsActive: Boolean;
    FNotes: string;
  public
    constructor Create; override;
    
    property FirstName: string read FFirstName write FFirstName;
    property LastName: string read FLastName write FLastName;
    property Email: string read FEmail write FEmail;
    property Phone: string read FPhone write FPhone;
    property Passport: string read FPassport write FPassport;
    property BirthDate: TDate read FBirthDate write FBirthDate;
    property RegistrationDate: TDate read FRegistrationDate write FRegistrationDate;
    property IsActive: Boolean read FIsActive write FIsActive;
    property Notes: string read FNotes write FNotes;
    
    function FullName: string;
  end;

  // Модель бронирования
  TBooking = class(TBaseModel)
  private
    FTourID: Integer;
    FTourName: string;
    FClientID: Integer;
    FClientName: string;
    FBookingDate: TDate;
    FTouristsCount: Integer;
    FTotalPrice: Currency;
    FStatus: string;
    FPaymentStatus: string;
    FNotes: string;
  public
    constructor Create; override;
    
    property TourID: Integer read FTourID write FTourID;
    property TourName: string read FTourName write FTourName;
    property ClientID: Integer read FClientID write FClientID;
    property ClientName: string read FClientName write FClientName;
    property BookingDate: TDate read FBookingDate write FBookingDate;
    property TouristsCount: Integer read FTouristsCount write FTouristsCount;
    property TotalPrice: Currency read FTotalPrice write FTotalPrice;
    property Status: string read FStatus write FStatus;
    property PaymentStatus: string read FPaymentStatus write FPaymentStatus;
    property Notes: string read FNotes write FNotes;
  end;

  // Модель статистики
  TStatistics = class
  private
    FTotalTours: Integer;
    FTotalClients: Integer;
    FTotalBookings: Integer;
    FTotalRevenue: Currency;
    FAverageTourPrice: Currency;
    FMostPopularCountry: string;
    FMostPopularHotel: string;
    FMonthlyBookings: TArray<Integer>;
    FTopDestinations: TArray<string>;
  public
    constructor Create;
    destructor Destroy; override;
    
    property TotalTours: Integer read FTotalTours write FTotalTours;
    property TotalClients: Integer read FTotalClients write FTotalClients;
    property TotalBookings: Integer read FTotalBookings write FTotalBookings;
    property TotalRevenue: Currency read FTotalRevenue write FTotalRevenue;
    property AverageTourPrice: Currency read FAverageTourPrice write FAverageTourPrice;
    property MostPopularCountry: string read FMostPopularCountry write FMostPopularCountry;
    property MostPopularHotel: string read FMostPopularHotel write FMostPopularHotel;
    property MonthlyBookings: TArray<Integer> read FMonthlyBookings write FMonthlyBookings;
    property TopDestinations: TArray<string> read FTopDestinations write FTopDestinations;
  end;

  // Модель пользователя системы
  TUser = class(TBaseModel)
  private
    FUsername: string;
    FPassword: string;
    FEmail: string;
    FFullName: string;
    FRole: string;
    FIsActive: Boolean;
    FLastLogin: TDateTime;
  public
    constructor Create; override;
    
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
    property Email: string read FEmail write FEmail;
    property FullName: string read FFullName write FFullName;
    property Role: string read FRole write FRole;
    property IsActive: Boolean read FIsActive write FIsActive;
    property LastLogin: TDateTime read FLastLogin write FLastLogin;
  end;

implementation

{ TBaseModel }

constructor TBaseModel.Create;
begin
  inherited Create;
  FCreatedAt := Now;
  FUpdatedAt := Now;
end;

destructor TBaseModel.Destroy;
begin
  inherited;
end;

{ TCountry }

constructor TCountry.Create;
begin
  inherited Create;
  FName := '';
  FCode := '';
  FDescription := '';
end;

{ TCity }

constructor TCity.Create;
begin
  inherited Create;
  FName := '';
  FCountryID := 0;
  FCountryName := '';
  FDescription := '';
end;

{ THotel }

constructor THotel.Create;
begin
  inherited Create;
  FName := '';
  FCityID := 0;
  FCityName := '';
  FCountryName := '';
  FStars := 0;
  FAddress := '';
  FDescription := '';
  FContactPhone := '';
  FContactEmail := '';
end;

{ TTourType }

constructor TTourType.Create;
begin
  inherited Create;
  FName := '';
  FDescription := '';
  FIcon := '';
end;

{ TTour }

constructor TTour.Create;
begin
  inherited Create;
  FName := '';
  FTourTypeID := 0;
  FTourType := '';
  FCountryID := 0;
  FCountry := '';
  FCityID := 0;
  FCity := '';
  FHotelID := 0;
  FHotel := '';
  FDuration := 0;
  FPrice := 0;
  FMaxTourists := 0;
  FStartDate := Date;
  FEndDate := Date;
  FDescription := '';
  FImageURL := '';
  FIsActive := True;
end;

{ TClient }

constructor TClient.Create;
begin
  inherited Create;
  FFirstName := '';
  FLastName := '';
  FEmail := '';
  FPhone := '';
  FPassport := '';
  FBirthDate := Date;
  FRegistrationDate := Date;
  FIsActive := True;
  FNotes := '';
end;

function TClient.FullName: string;
begin
  Result := FFirstName + ' ' + FLastName;
end;

{ TBooking }

constructor TBooking.Create;
begin
  inherited Create;
  FTourID := 0;
  FTourName := '';
  FClientID := 0;
  FClientName := '';
  FBookingDate := Date;
  FTouristsCount := 0;
  FTotalPrice := 0;
  FStatus := 'Pending';
  FPaymentStatus := 'Pending';
  FNotes := '';
end;

{ TStatistics }

constructor TStatistics.Create;
begin
  inherited Create;
  FTotalTours := 0;
  FTotalClients := 0;
  FTotalBookings := 0;
  FTotalRevenue := 0;
  FAverageTourPrice := 0;
  FMostPopularCountry := '';
  FMostPopularHotel := '';
  SetLength(FMonthlyBookings, 12);
  SetLength(FTopDestinations, 5);
end;

destructor TStatistics.Destroy;
begin
  inherited;
end;

{ TUser }

constructor TUser.Create;
begin
  inherited Create;
  FUsername := '';
  FPassword := '';
  FEmail := '';
  FFullName := '';
  FRole := 'User';
  FIsActive := True;
  FLastLogin := 0;
end;

end.
