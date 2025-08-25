program TourismSystem;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Web.WebBroker,
  Web.WebReq,
  TourismSystem.WebModule in 'TourismSystem.WebModule.pas' {WebModule: TWebModule},
  TourismSystem.DataModule in 'TourismSystem.DataModule.pas' {DataModule: TDataModule},
  TourismSystem.Models in 'TourismSystem.Models.pas',
  TourismSystem.Services in 'TourismSystem.Services.pas',
  TourismSystem.Controllers in 'TourismSystem.Controllers.pas';

{$R *.RES}

begin
  WebRequestHandler.WebModuleClass := TTourismSystemWebModule;
  WebRequestHandler.RegisterWebModuleClass(TTourismSystemWebModule);
  WebReq.WebRequestHandlerProc := WebRequestHandler.HandleRequest;
  
  try
    WriteLn('Tourism System Web Application Starting...');
    WriteLn('Press Enter to stop the server');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
end.
