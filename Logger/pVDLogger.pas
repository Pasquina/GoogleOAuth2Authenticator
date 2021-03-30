unit pVDLogger;

interface

uses
  System.SysUtils, System.IOUtils, System.Classes, {fgMemoDisplay,} WinAPI.Windows,
  pVDEtc;

type
  TLogSource = (lsUtility, lsDiscovery, lsAuthenticate, lsTokenExchange, lsTokenRefresh);
  TLogSources = set of TLogSource;
  SLogSource = String;

  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TVDLogger = class(TComponent)
  private
    FLogFileName: TFileName;
    FLogFile: TFileStream;
    FLogFilePath: TFilename;
    FEtc: TVDEtc;
    procedure SetLogFileName(const Value: TFileName);
    procedure SetLogFile(const Value: TFileStream);
    procedure SetLogFilePath(const Value: TFilename);
    procedure SetEtc(const Value: TVDEtc);
    procedure CalcLogFileLocs(const AEtc: TVDEtc);
    property LogFile: TFileStream read FLogFile write SetLogFile;
    property LogFilePath: TFilename read FLogFilePath write SetLogFilePath;
  protected
    property LogFileName: TFileName read FLogFileName write SetLogFileName;
    function FormatLogHeader(const ATimeStamp: TDateTime;
  ALogSource: TLogSource): String;
  public
    procedure LogText(const ALogSource: TLogSource; const AMsgText: TStrings);
    procedure LogLine(const ALogSource: TLogSource; const AMsgLine: array of String);
    procedure ShowLog;
    function CycleLogfile: Boolean;
    constructor Create(AOwner: TComponent);  override;
  published
    property Etc: TVDEtc read FEtc write SetEtc;
  end;

const

  SLogSources: array [TLogSource] of String = ('Utility', 'Discovery Document', 'Authenticate', 'Token Exchange', 'Token Refresh');

implementation

uses
  System.DateUtils;

{ TVDLogger }

procedure TVDLogger.CalcLogFileLocs(const AEtc: TVDEtc);
begin
  if Assigned(AEtc) then
  with AEtc do
  begin
    LogFilePath := TPath.Combine(TPath.Combine(GetHomePath, Vendor), App);
    LogFileName := TPath.Combine(LogFilePath, LogFile);
  end;
end;

constructor TVDLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CalcLogFileLocs(Etc);
end;

{ To start a new log file the old file is simply renamed with the current timestamp.
  The next attempt to make a log entry will simply create a new log file. }

function TVDLogger.CycleLogfile: Boolean;
var
  LNewName: TFileName;
  LBasicFilename: TFileName;
  LFormatSettings: TFormatSettings;
begin
  LBasicFilename := TPath.GetFileNameWithoutExtension(LogFileName);
  LFormatSettings := TFormatSettings.Create;
  LFormatSettings.DateSeparator := '-';
  LFormatSettings.TimeSeparator := '-';
  LFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  LFormatSettings.LongTimeFormat := 'hh-nn-ss';
  LBasicFilename := DateTimeToStr(Now(), LFormatSettings) + ' ' + LBasicFilename + '.log';
  LNewName := TPath.Combine(LogFilePath, LBasicFilename);
  if RenameFile(LogFileName, LNewName) then
    Result := True
  else
    Result := False;
end;

function TVDLogger.FormatLogHeader(const ATimeStamp: TDateTime;
  ALogSource: TLogSource): String;
const
  LLogHeaderMask: String = '**** %s; Source: %s';
begin
  Result := Format(LLogHeaderMask, [DateToISO8601(ATimeStamp, False), SLogSources[ALogSource]]);
end;

{ Logging a series of single lines causes a stringlist to be built. Then the LogText procedure is
  invoked that will add a header line and save the completed entry to the log file. }

procedure TVDLogger.LogLine(const ALogSource: TLogSource; const AMsgLine: array of String);
var
  LMessageList: TStringList;
  LMessageLine: String;
begin
  LMessageList := TStringList.Create;
  try
    for LMessageLine in AMsgLine do
      LMessageList.Add(LMessageLine);
    LogText(ALogSource, LMessageList);
  finally
    LMessageList.Free;
  end;
end;

procedure TVDLogger.LogText(const ALogSource: TLogSource; const AMsgText: TStrings);
var
  LMode: Word;
  LMsgTimeStamp: String;
begin
  if not FileExists(LogFileName) then
    begin
      ForceDirectories(LogFilePath);
      LMode := fmCreate;
    end
    else
      LMode := fmOpenReadWrite;
  LogFile := TFileStream.Create(LogFileName, LMode or fmShareDenyWrite);
  try
    LogFile.Seek(0, soFromEnd);
    LMsgTimeStamp := FormatLogHeader(Now(), ALogSource);
    AMsgText.Insert(0, LMsgTimeStamp);
    AMsgText.SaveToStream(LogFile, TEncoding.UTF8);
  finally
    LogFile.Free;
  end;
end;

procedure TVDLogger.SetEtc(const Value: TVDEtc);
begin
  FEtc := Value;
end;

procedure TVDLogger.SetLogFile(const Value: TFileStream);
begin
  FLogFile := Value;
end;

procedure TVDLogger.SetLogFileName(const Value: TFileName);
begin
  FLogFileName := Value;
end;

procedure TVDLogger.SetLogFilePath(const Value: TFilename);
begin
  FLogFilePath := Value;
end;

{ Display the current log file in a read-only memo box. The current log
  file name is stored as a property of the class. }

procedure TVDLogger.ShowLog;
//var
//  LgMemoDisplay: TgMemoDisplay;                   // pointer to the form for display
begin
//  if FileExists(LogFileName) then                 // first make sure we actually have a log file
//    begin
//      LgMemoDisplay := TgMemoDisplay.CreateAux(Self, LogFileName); // create the window
//      LgMemoDisplay.Show;                         // show triggers the log file retrieval
//    end
//  else
//    ShowMessage('There is no current log file.'); // inform the user if there is no current log file
end;

end.
