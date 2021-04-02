unit fmAuthTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, pVDLogger, pVDEtc, Vcl.StdCtrls,
  System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan,
  Vcl.CategoryButtons, Vcl.ExtCtrls, Vcl.WinXPanels, Vcl.ComCtrls, System.UITypes;

type
  TfAuthTest = class(TForm)
    etcMain: TVDEtc;
    logMain: TVDLogger;
    cbMain: TCategoryButtons;
    amMain: TActionManager;
    aShowLogFileName: TAction;
    aShowLogFilePath: TAction;
    aAddLines: TAction;
    spMain: TStackPanel;
    Label1: TLabel;
    eFirstLine: TEdit;
    Label2: TLabel;
    eSecondLine: TEdit;
    Label3: TLabel;
    meAddLines: TMemo;
    aAddStringList: TAction;
    aDisplayLogfile: TAction;
    StatusBar1: TStatusBar;
    aCycleLogFile: TAction;
    procedure aShowLogFileNameExecute(Sender: TObject);
    procedure aShowLogFilePathExecute(Sender: TObject);
    procedure aAddLinesExecute(Sender: TObject);
    procedure aAddStringListExecute(Sender: TObject);
    procedure aDisplayLogfileExecute(Sender: TObject);
    procedure aCycleLogFileExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAuthTest: TfAuthTest;

implementation

{$R *.dfm}

procedure TfAuthTest.aAddLinesExecute(Sender: TObject);
begin
  logMain.LogLine(TLogSource.lsUtility, [eFirstLine.Text, eSecondLine.Text]);
end;

procedure TfAuthTest.aAddStringListExecute(Sender: TObject);
begin
  logMain.LogStrings(TLogSource.lsUtility, meAddLines.Lines);
end;

procedure TfAuthTest.aCycleLogFileExecute(Sender: TObject);
begin
  if logMain.CycleLogfile then
    ShowMessage('Logfile Cycle Successful')
  else
    ShowMessage('Logfile Cycle Failed');
end;

procedure TfAuthTest.aDisplayLogfileExecute(Sender: TObject);
begin
  logMain.ShowLog;
end;

procedure TfAuthTest.aShowLogFileNameExecute(Sender: TObject);
begin
  MessageDlg(logMain.GetLogFileName, mtInformation, [mbOK], 0);
end;

procedure TfAuthTest.aShowLogFilePathExecute(Sender: TObject);
begin
  MessageDlg(logMain.GetLogFilePath, mtInformation, [mbOK], 0);
end;

end.
