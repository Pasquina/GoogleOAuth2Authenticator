unit fmVDLogger;

interface

uses VCL.Forms, System.Classes, System.SysUtils, VCL.ComCtrls, VCL.StdCtrls, VCL.Controls;

type
  tgLogger = Class(TCustomForm)
  private
    FStatusBar: TStatusBar;
    FMemo: TMemo;
    procedure SetStatusBar(const Value: TStatusBar);
    procedure SetMemo(const Value: TMemo);
    property Memo: TMemo read FMemo write SetMemo;
    property StatusBar: TStatusBar read FStatusBar write SetStatusBar;
    procedure OnCloseEvent(Sender: TObject; var Action: TCloseAction);
  protected
  public
    class function CreateLog(AOwner: TComponent; ALogFileName: TFileName): tgLogger;
  End;

implementation

uses
  System.Types, Winapi.Windows;

{ tgLogger }

class function tgLogger.CreateLog(AOwner: TComponent; ALogFileName: TFileName): tgLogger;
var
  LScreen: TRect;
  LLogger: tgLogger;
  LLogFile: TFileStream;                       // Log File Access
begin
  LLogger := tgLogger.CreateNew(AOwner);       // create the form without .dfm

  { Establish all components at run time }

  with LLogger do
    begin
      // SystemParametersInfo(SPI_GETWORKAREA, 0, @LScreen, 0);
      OnClose := OnCloseEvent;                 // set the on close event
      SetBounds(30, 30, 700, 700);             // X, Y, Width, Height
      Caption := 'Log File Display';           // form caption

      StatusBar := TStatusBar.Create(LLogger); // simple status bar
      StatusBar.Parent := LLogger;             // parent required for display
      StatusBar.SimplePanel := True;           // simple panel has one panel
      StatusBar.SimpleText := ALogFileName;    // show the log file name in status bar
      StatusBar.AlignWithMargins := True;      // leave a smidge at the border

      Memo := TMemo.Create(LLogger);           // create the memo to show the log file
      Memo.Parent := LLogger;                  // parent rquired for display
      Memo.Align := TAlign.alClient;           // take all the space
      Memo.ScrollBars := ssBoth;               // allow for really wide content
      Memo.ReadOnly := True;                   // there's no modifying provided
      Memo.WordWrap := False;                  // turn off word wrap (see scroll bars)
      Memo.AlignWithMargins := True;           // more space for the memo

      LLogFile := TFileStream.Create(ALogFileName, fmOpenRead); // open the inpus
      try
        Memo.Lines.LoadFromStream(LLogFile, TEncoding.UTF8); // load the memo lines
      finally
        LLogFile.Free;                         // free the file resource
      end;
    end;
  Result := LLogger;                           // return the form object to caller
end;

procedure tgLogger.OnCloseEvent(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;            // free the form resource
  ModalResult := mrCancel;     // return cancel
end;

procedure tgLogger.SetMemo(const Value: TMemo);
begin
  FMemo := Value;
end;

procedure tgLogger.SetStatusBar(const Value: TStatusBar);
begin
  FStatusBar := Value;
end;

end.
