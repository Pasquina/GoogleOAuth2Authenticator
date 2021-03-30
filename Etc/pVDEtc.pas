unit pVDEtc;

interface

uses
  System.Classes;

Type
  TAppIDValues = record
    Vendor: String;
    App: String;
    LogFile: String;
  end;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TVDEtc = class(TComponent)
  private
    FVendor: String;
    FApp: String;
    FLogFile: String;
    procedure SetVendor(const Value: String);
    procedure SetApp(const Value: String);
    procedure SetLogFile(const Value: String);
  private const
    RAppIDValues: TAppIDValues = (Vendor: 'VyDevSoft'; App: 'QBTools'; LogFile: 'QBCube.log');
  protected
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Vendor: String read FVendor write SetVendor;
    property App: String read FApp write SetApp;
    property LogFile: String read FLogFile write SetLogFile;
  end;

implementation

{ TEtc }

constructor TVDEtc.Create(AOwner: TComponent);
begin
  inherited;
  Vendor := RAppIDValues.Vendor;
  App := RAppIDValues.App;
  LogFile := RAppIDValues.LogFile;
end;

procedure TVDEtc.SetApp(const Value: String);
begin
  FApp := Value;
end;

procedure TVDEtc.SetLogFile(const Value: String);
begin
  FLogFile := Value;
end;

procedure TVDEtc.SetVendor(const Value: String);
begin
  FVendor := Value;
end;

end.
