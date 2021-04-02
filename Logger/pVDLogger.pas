unit pVDLogger;

interface

uses
  System.SysUtils, System.IOUtils, System.Classes, {fgMemoDisplay,} WinAPI.Windows,
  pVDEtc;

type
  TLogSource = (lsUtility, lsDiscovery, lsAuthenticate, lsTokenExchange, lsTokenRefresh);
  TLogSources = set of TLogSource;
  SLogSource = String;

  ELogFileError = class(Exception);
  ELogFileNoParams = class(ELogFileError);

  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TVDLogger = class(TComponent)
  private
    FLogFileName: TFileName;
    FLogFile: TFileStream;
    FLogFilePath: TFileName;
    FEtc: TVDEtc;
    procedure SetLogFileName(const Value: TFileName);
    procedure SetLogFile(const Value: TFileStream);
    procedure SetLogFilePath(const Value: TFileName);
    procedure SetEtc(const Value: TVDEtc);
    procedure CalcLogFileLocs(const AEtc: TVDEtc);
    property LogFile: TFileStream read FLogFile write SetLogFile;
  protected
    function FormatLogHeader(const ATimeStamp: TDateTime; ALogSource: TLogSource): String;
    procedure Loaded; override;
  public
    procedure LogStrings(const ALogSource: TLogSource; const AMsgText: TStringList); overload;
    procedure LogStrings(const ALogSource: TLogSource; const AMsgText: TStrings); overload;
    procedure LogLine(const ALogSource: TLogSource; const AMsgLine: array of String);
    procedure ShowLog;
    function CycleLogfile: Boolean;
    function GetLogFilePath: TFileName;
    function GetLogFileName: TFileName;
    property LogFileName: TFileName read GetLogFileName write SetLogFileName;
    property LogFilePath: TFileName read GetLogFilePath write SetLogFilePath;
    constructor Create(AOwner: TComponent); override;
  published
    property Etc: TVDEtc read FEtc write SetEtc;
  end;

const

  SLogSources: array [TLogSource] of String = ('Utility', 'Discovery Document', 'Authenticate', 'Token Exchange', 'Token Refresh');

implementation

uses
  System.DateUtils, VCL.Dialogs, VCL.Forms, fmVDLogger;

{ TVDLogger }

{ Application constants are universally specified in the Etc component. This
  retrieves the values for the log path and file name for ongoing use. }

procedure TVDLogger.CalcLogFileLocs(const AEtc: TVDEtc);
begin
  try
    if not Assigned(AEtc) then                   // be sure Etc component is assigned
      raise ELogFileNoParams.Create('Missing reference to Etc component.');
    with AEtc do                                 // need Vendor, App and Filename
      begin                                      // create the filename and path
        LogFilePath := TPath.Combine(TPath.Combine(GetHomePath, Vendor), App);
        LogFileName := TPath.Combine(LogFilePath, LogFile);
      end;
  except
    on E: ELogFileNoParams do                    // missing etc component
      MessageDlg(E.Message, mtError, [mbOK], 0); // inform tdhe usere
  end;
end;

constructor TVDLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);                      // not much to see here
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

{ Formatting the log source converts the enumeration received to a readable string. The
  Timestamp is formatted as an ISO8601 date and time. }

function TVDLogger.FormatLogHeader(const ATimeStamp: TDateTime; ALogSource: TLogSource): String;
const
  LLogHeaderMask: String = '**** %s; Source: %s';        // format string
begin                                                    // is this thread safe?
  Result := Format(LLogHeaderMask, [DateToISO8601(ATimeStamp, False), SLogSources[ALogSource]]);
end;

function TVDLogger.GetLogFileName: TFileName;
begin
  Result := FLogFileName;                                // return the log filename already determined
end;

function TVDLogger.GetLogFilePath: TFileName;
begin
  Result := FLogFilePath;                                // return the log path already determined
end;

{ Now that all components have been loaded we can obtain the full path and file
  name of the log file from the Etc component. }

procedure TVDLogger.Loaded;
begin
  Inherited;
  CalcLogFileLocs(Etc);                                  // obtain and save the log file path and file name
end;

{ Logging a series of single lines causes a stringlist to be built. Then the LogText procedure is
  invoked that will add a header line and save the completed entry to the log file. }

procedure TVDLogger.LogLine(const ALogSource: TLogSource; const AMsgLine: array of String);
var
  LMessageList: TStringList;                             // work list
  LMessageLine: String;                                  // for iteration
begin
  LMessageList := TStringList.Create;                    // create the work list
  try
    for LMessageLine in AMsgLine do                      // prdocess each line of the input arrayi
      LMessageList.Add(LMessageLine);                    // add the line to the stringlist
    LogStrings(ALogSource, LMessageList);                   // invoke the log list procedure
  finally
    LMessageList.Free;                                   // return the resource
  end;
end;

{ This overload is intended primarily as a workaround for handling TMemo lines, that
  are actually TMemoStrings, not TStrings. TMemoStrings do not handle TrailingLineBreak
  correctly (it is completely ignored). Hence we need to build a real TStringList
  for submission tdo the LogStrings Routine. }

procedure TVDLogger.LogStrings(const ALogSource: TLogSource;
  const AMsgText: TStrings);
var
  LStringList: TStringList;              // string list to receive input lines
begin
  LStringList := TStringList.Create;     // create the string list
  try
    LStringList.Assign(AMsgText);        // assign the input lines to the stringlist
    LogStrings(ALogSource, LStringList); // invoke the logging routine using the new list
  finally
    LStringList.Free;                    // return resources after all done
  end;
end;

{ General purpose routine that logs a stringlist. Note that the so-called TStrings of a TMemo
  are not suitable for this routine. The overloaded method that accepts TStrings should be used
  instead. }

procedure TVDLogger.LogStrings(const ALogSource: TLogSource; const AMsgText: TStringList);
var
  LMode: Word;                                           // log file mode
  LMsgTimeStamp: String;                                 // time stamp appended as first line
begin
  if not FileExists(LogFileName) then                    // check for presence of existing log file
    begin
      ForceDirectories(LogFilePath);                     // if no file, ensure the path exists
      LMode := fmCreate;                                 // create the file since none exists
    end
  else
    LMode := fmOpenReadWrite;                            // if file exists, simply append

  LogFile := TFileStream.Create(LogFileName, LMode or fmShareDenyWrite); // create the stream writer
  try
    LogFile.Seek(0, soFromEnd);                          // position at the end of the file
    LMsgTimeStamp := FormatLogHeader(Now(), ALogSource); // format the timestamp (local time)
    AMsgText.Insert(0, LMsgTimeStamp);                   // insert the timestamp as the first line
    AMsgText.SaveToStream(LogFile, TEncoding.UTF8);      // write the completed set of lines to the log
  finally
    LogFile.Free;                                        // return resources
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

procedure TVDLogger.SetLogFilePath(const Value: TFileName);
begin
  FLogFilePath := Value;
end;

{ Display the current log file in a read-only memo box. The current log
  file name is stored as a property of the class. }

procedure TVDLogger.ShowLog;
var
  LgMemoDisplay: tgLogger;                           // pointer to the form for display
begin
  if FileExists(LogFileName) then                 // first make sure we actually have a log file
    begin
      LgMemoDisplay := tgLogger.CreateLog(Self, LogFileName);
//      LgMemoDisplay := TgMemoDisplay.CreateAux(Self, LogFileName); // create the window
      LgMemoDisplay.Show;                         // show triggers the log file retrieval
    end
  else
    ShowMessage('There is no current log file.'); // inform the user if there is no current log file
end;

end.
