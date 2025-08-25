unit TourismSystem.WebModule;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Web.WebReq,
  System.JSON, System.NetEncoding, System.Generics.Collections,
  TourismSystem.Controllers, TourismSystem.Models;

type
  TTourismSystemWebModule = class(TWebModule)
    procedure WebModuleDefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleToursAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleClientsAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleBookingsAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure WebModuleStatisticsAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    FTourController: TTourController;
    FClientController: TClientController;
    FBookingController: TBookingController;
    
    function GetRequestJSON(Request: TWebRequest): TJSONObject;
    procedure SendJSONResponse(Response: TWebResponse; JSON: TJSONObject; StatusCode: Integer = 200);
    procedure SendErrorResponse(Response: TWebResponse; ErrorMessage: string; StatusCode: Integer = 400);
    procedure SetCORSHeaders(Response: TWebResponse);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  WebModuleClass: TComponentClass = TTourismSystemWebModule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

constructor TTourismSystemWebModule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTourController := TTourController.Create;
  FClientController := TClientController.Create;
  FBookingController := TBookingController.Create;
end;

destructor TTourismSystemWebModule.Destroy;
begin
  FTourController.Free;
  FClientController.Free;
  FBookingController.Free;
  inherited;
end;

procedure TTourismSystemWebModule.WebModuleDefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  JSON: TJSONObject;
begin
  SetCORSHeaders(Response);
  
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('message', 'Tourism System Web API');
    JSON.AddPair('version', '1.0.0');
    JSON.AddPair('status', 'running');
    JSON.AddPair('timestamp', DateTimeToStr(Now));
    
    SendJSONResponse(Response, JSON);
    Handled := True;
  finally
    JSON.Free;
  end;
end;

procedure TTourismSystemWebModule.WebModuleToursAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  JSON: TJSONObject;
  Tours: TObjectList<TTour>;
  i: Integer;
begin
  SetCORSHeaders(Response);
  
  try
    case Request.MethodType of
      mtGet:
        begin
          Tours := FTourController.GetAllTours;
          try
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('count', TJSONNumber.Create(Tours.Count));
            
            var ToursArray := TJSONArray.Create;
            for i := 0 to Tours.Count - 1 do
            begin
              var TourObj := TJSONObject.Create;
              TourObj.AddPair('id', TJSONNumber.Create(Tours[i].ID));
              TourObj.AddPair('name', Tours[i].Name);
              TourObj.AddPair('type', Tours[i].TourType);
              TourObj.AddPair('country', Tours[i].Country);
              TourObj.AddPair('city', Tours[i].City);
              TourObj.AddPair('hotel', Tours[i].Hotel);
              TourObj.AddPair('duration', TJSONNumber.Create(Tours[i].Duration));
              TourObj.AddPair('price', TJSONNumber.Create(Tours[i].Price));
              TourObj.AddPair('maxTourists', TJSONNumber.Create(Tours[i].MaxTourists));
              TourObj.AddPair('startDate', DateToStr(Tours[i].StartDate));
              TourObj.AddPair('endDate', DateToStr(Tours[i].EndDate));
              TourObj.AddPair('description', Tours[i].Description);
              ToursArray.AddElement(TourObj);
            end;
            JSON.AddPair('tours', ToursArray);
            
            SendJSONResponse(Response, JSON);
          finally
            JSON.Free;
          end;
        end;
        
      mtPost:
        begin
          var RequestJSON := GetRequestJSON(Request);
          try
            var Tour := FTourController.CreateTour(RequestJSON);
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('message', 'Tour created successfully');
            JSON.AddPair('tourId', TJSONNumber.Create(Tour.ID));
            
            SendJSONResponse(Response, JSON);
          finally
            RequestJSON.Free;
          end;
        end;
        
      mtPut:
        begin
          var RequestJSON := GetRequestJSON(Request);
          try
            var TourID := RequestJSON.GetValue('id').AsInteger;
            var Tour := FTourController.UpdateTour(TourID, RequestJSON);
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('message', 'Tour updated successfully');
            
            SendJSONResponse(Response, JSON);
          finally
            RequestJSON.Free;
          end;
        end;
        
      mtDelete:
        begin
          var TourID := StrToIntDef(Request.QueryFields.Values['id'], 0);
          if TourID > 0 then
          begin
            FTourController.DeleteTour(TourID);
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('message', 'Tour deleted successfully');
            
            SendJSONResponse(Response, JSON);
          end
          else
            SendErrorResponse(Response, 'Invalid tour ID', 400);
        end;
    end;
    
    Handled := True;
  except
    on E: Exception do
      SendErrorResponse(Response, E.Message, 500);
  end;
end;

procedure TTourismSystemWebModule.WebModuleClientsAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  JSON: TJSONObject;
  Clients: TObjectList<TClient>;
  i: Integer;
begin
  SetCORSHeaders(Response);
  
  try
    case Request.MethodType of
      mtGet:
        begin
          Clients := FClientController.GetAllClients;
          try
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('count', TJSONNumber.Create(Clients.Count));
            
            var ClientsArray := TJSONArray.Create;
            for i := 0 to Clients.Count - 1 do
            begin
              var ClientObj := TJSONObject.Create;
              ClientObj.AddPair('id', TJSONNumber.Create(Clients[i].ID));
              ClientObj.AddPair('firstName', Clients[i].FirstName);
              ClientObj.AddPair('lastName', Clients[i].LastName);
              ClientObj.AddPair('email', Clients[i].Email);
              ClientObj.AddPair('phone', Clients[i].Phone);
              ClientObj.AddPair('passport', Clients[i].Passport);
              ClientObj.AddPair('birthDate', DateToStr(Clients[i].BirthDate));
              ClientObj.AddPair('registrationDate', DateToStr(Clients[i].RegistrationDate));
              ClientsArray.AddElement(ClientObj);
            end;
            JSON.AddPair('clients', ClientsArray);
            
            SendJSONResponse(Response, JSON);
          finally
            JSON.Free;
          end;
        end;
        
      mtPost:
        begin
          var RequestJSON := GetRequestJSON(Request);
          try
            var Client := FClientController.CreateClient(RequestJSON);
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('message', 'Client created successfully');
            JSON.AddPair('clientId', TJSONNumber.Create(Client.ID));
            
            SendJSONResponse(Response, JSON);
          finally
            RequestJSON.Free;
          end;
        end;
    end;
    
    Handled := True;
  except
    on E: Exception do
      SendErrorResponse(Response, E.Message, 500);
  end;
end;

procedure TTourismSystemWebModule.WebModuleBookingsAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  JSON: TJSONObject;
  Bookings: TObjectList<TBooking>;
  i: Integer;
begin
  SetCORSHeaders(Response);
  
  try
    case Request.MethodType of
      mtGet:
        begin
          Bookings := FBookingController.GetAllBookings;
          try
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('count', TJSONNumber.Create(Bookings.Count));
            
            var BookingsArray := TJSONArray.Create;
            for i := 0 to Bookings.Count - 1 do
            begin
              var BookingObj := TJSONObject.Create;
              BookingObj.AddPair('id', TJSONNumber.Create(Bookings[i].ID));
              BookingObj.AddPair('tourId', TJSONNumber.Create(Bookings[i].TourID));
              BookingObj.AddPair('clientId', TJSONNumber.Create(Bookings[i].ClientID));
              BookingObj.AddPair('bookingDate', DateToStr(Bookings[i].BookingDate));
              BookingObj.AddPair('touristsCount', TJSONNumber.Create(Bookings[i].TouristsCount));
              BookingObj.AddPair('totalPrice', TJSONNumber.Create(Bookings[i].TotalPrice));
              BookingObj.AddPair('status', Bookings[i].Status);
              BookingsArray.AddElement(BookingObj);
            end;
            JSON.AddPair('bookings', BookingsArray);
            
            SendJSONResponse(Response, JSON);
          finally
            JSON.Free;
          end;
        end;
        
      mtPost:
        begin
          var RequestJSON := GetRequestJSON(Request);
          try
            var Booking := FBookingController.CreateBooking(RequestJSON);
            JSON := TJSONObject.Create;
            JSON.AddPair('success', TJSONBool.Create(True));
            JSON.AddPair('message', 'Booking created successfully');
            JSON.AddPair('bookingId', TJSONNumber.Create(Booking.ID));
            
            SendJSONResponse(Response, JSON);
          finally
            RequestJSON.Free;
          end;
        end;
    end;
    
    Handled := True;
  except
    on E: Exception do
      SendErrorResponse(Response, E.Message, 500);
  end;
end;

procedure TTourismSystemWebModule.WebModuleStatisticsAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  JSON: TJSONObject;
  Stats: TStatistics;
begin
  SetCORSHeaders(Response);
  
  try
    Stats := FTourController.GetStatistics;
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('success', TJSONBool.Create(True));
      JSON.AddPair('totalTours', TJSONNumber.Create(Stats.TotalTours));
      JSON.AddPair('totalClients', TJSONNumber.Create(Stats.TotalClients));
      JSON.AddPair('totalBookings', TJSONNumber.Create(Stats.TotalBookings));
      JSON.AddPair('totalRevenue', TJSONNumber.Create(Stats.TotalRevenue));
      JSON.AddPair('averageTourPrice', TJSONNumber.Create(Stats.AverageTourPrice));
      JSON.AddPair('mostPopularCountry', Stats.MostPopularCountry);
      JSON.AddPair('mostPopularHotel', Stats.MostPopularHotel);
      
      SendJSONResponse(Response, JSON);
    finally
      JSON.Free;
    end;
    
    Handled := True;
  except
    on E: Exception do
      SendErrorResponse(Response, E.Message, 500);
  end;
end;

function TTourismSystemWebModule.GetRequestJSON(Request: TWebRequest): TJSONObject;
var
  Content: string;
begin
  Content := Request.Content;
  if Content = '' then
    raise Exception.Create('Empty request content');
    
  Result := TJSONObject.ParseJSONValue(Content) as TJSONObject;
  if not Assigned(Result) then
    raise Exception.Create('Invalid JSON format');
end;

procedure TTourismSystemWebModule.SendJSONResponse(Response: TWebResponse; JSON: TJSONObject; StatusCode: Integer);
begin
  Response.StatusCode := StatusCode;
  Response.ContentType := 'application/json';
  Response.Content := JSON.ToString;
end;

procedure TTourismSystemWebModule.SendErrorResponse(Response: TWebResponse; ErrorMessage: string; StatusCode: Integer);
var
  ErrorJSON: TJSONObject;
begin
  ErrorJSON := TJSONObject.Create;
  try
    ErrorJSON.AddPair('success', TJSONBool.Create(False));
    ErrorJSON.AddPair('error', ErrorMessage);
    ErrorJSON.AddPair('statusCode', TJSONNumber.Create(StatusCode));
    
    SendJSONResponse(Response, ErrorJSON, StatusCode);
  finally
    ErrorJSON.Free;
  end;
end;

procedure TTourismSystemWebModule.SetCORSHeaders(Response: TWebResponse);
begin
  Response.CustomHeaders.Values['Access-Control-Allow-Origin'] := '*';
  Response.CustomHeaders.Values['Access-Control-Allow-Methods'] := 'GET, POST, PUT, DELETE, OPTIONS';
  Response.CustomHeaders.Values['Access-Control-Allow-Headers'] := 'Content-Type, Authorization';
end;

end.
