object fAuthTest: TfAuthTest
  Left = 0
  Top = 0
  Caption = 'Auth Test'
  ClientHeight = 412
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cbMain: TCategoryButtons
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 145
    Height = 387
    Align = alLeft
    ButtonFlow = cbfVertical
    ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boVerticalCategoryCaptions]
    Categories = <
      item
        Caption = 'Logger Tests'
        Color = 15466474
        Collapsed = False
        Items = <
          item
            Action = aShowLogFilePath
          end
          item
            Action = aShowLogFileName
          end
          item
            Action = aAddLines
          end
          item
            Action = aAddStringList
          end
          item
            Action = aDisplayLogfile
          end
          item
            Action = aCycleLogFile
          end>
      end>
    RegularButtonColor = clWhite
    SelectedButtonColor = 15132390
    TabOrder = 0
  end
  object spMain: TStackPanel
    AlignWithMargins = True
    Left = 154
    Top = 3
    Width = 478
    Height = 387
    Align = alClient
    ControlCollection = <
      item
        Control = Label1
      end
      item
        Control = eFirstLine
      end
      item
        Control = Label2
      end
      item
        Control = eSecondLine
      end
      item
        Control = Label3
      end
      item
        Control = meAddLines
        HorizontalPositioning = sphpFill
        VerticalPositioning = spvpFill
      end>
    HorizontalPositioning = sphpFill
    Padding.Left = 3
    Padding.Top = 3
    Padding.Right = 3
    Padding.Bottom = 3
    TabOrder = 1
    object Label1: TLabel
      Left = 4
      Top = 4
      Width = 470
      Height = 13
      Caption = 'First Line to Add to Logfile'
    end
    object eFirstLine: TEdit
      Left = 4
      Top = 19
      Width = 470
      Height = 21
      TabOrder = 0
      TextHint = 'Enter First Line to Add to Logfile'
    end
    object Label2: TLabel
      Left = 4
      Top = 42
      Width = 470
      Height = 13
      Caption = 'Second Line to Add to Logfile'
    end
    object eSecondLine: TEdit
      Left = 4
      Top = 57
      Width = 470
      Height = 21
      TabOrder = 1
      TextHint = 'Enter Second Line to Add to Logfile'
    end
    object Label3: TLabel
      Left = 4
      Top = 80
      Width = 470
      Height = 13
      Caption = 'Memo Lines to Add to Logfile'
    end
    object meAddLines: TMemo
      Left = 4
      Top = 95
      Width = 470
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 2
      WordWrap = False
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 393
    Width = 635
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object etcMain: TVDEtc
    Vendor = 'VyDevSoft'
    App = 'QBTools'
    LogFile = 'QBCube.log'
    Left = 520
    Top = 360
  end
  object logMain: TVDLogger
    Etc = etcMain
    Left = 576
    Top = 360
  end
  object amMain: TActionManager
    Left = 464
    Top = 360
    StyleName = 'Platform Default'
    object aShowLogFileName: TAction
      Category = 'Logger'
      Caption = 'Show Log File Name'
      OnExecute = aShowLogFileNameExecute
    end
    object aShowLogFilePath: TAction
      Category = 'Logger'
      Caption = 'Show Log File Path'
      OnExecute = aShowLogFilePathExecute
    end
    object aAddLines: TAction
      Category = 'Logger'
      Caption = 'Add Multiple Lines'
      OnExecute = aAddLinesExecute
    end
    object aAddStringList: TAction
      Category = 'Logger'
      Caption = 'Add Memo Lines'
      OnExecute = aAddStringListExecute
    end
    object aDisplayLogfile: TAction
      Category = 'Logger'
      Caption = 'Display the Logfile'
      OnExecute = aDisplayLogfileExecute
    end
    object aCycleLogFile: TAction
      Category = 'Logger'
      Caption = 'Cycle Log File'
      OnExecute = aCycleLogFileExecute
    end
  end
end
