program AuthTest;

uses
  Vcl.Forms,
  fmAuthTest in 'fmAuthTest.pas' {fAuthTest};

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfAuthTest, fAuthTest);
  Application.Run;
end.
