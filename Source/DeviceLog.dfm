object LogForm: TLogForm
  Left = 359
  Top = 22
  Width = 1024
  Height = 768
  Caption = #35774#22791#36890#20449#36816#34892#35760#24405
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object stat1: TStatusBar
    Left = 0
    Top = 698
    Width = 1016
    Height = 19
    Panels = <>
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1016
    Height = 698
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = #36890#20449#25968#25454
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 1008
        Height = 670
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Arial Narrow'
        Font.Style = []
        Lines.Strings = (
          'Memo1')
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = #35774#22791#25968#25454
      ImageIndex = 1
      object Memo2: TMemo
        Left = 0
        Top = 0
        Width = 1008
        Height = 670
        Align = alClient
        Lines.Strings = (
          'Memo2')
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object MainMenu1: TMainMenu
    Left = 272
    Top = 72
    object N1: TMenuItem
      Caption = #25991#20214
    end
    object N2: TMenuItem
      Caption = #25805#20316
      object N5: TMenuItem
        Caption = #35774#22791#25968#25454
        object N7: TMenuItem
          Caption = #25171#24320#20018#21475
          OnClick = N7Click
        end
        object N8: TMenuItem
          Caption = #20851#38381#20018#21475
          OnClick = N8Click
        end
        object N12: TMenuItem
          Caption = #28165#31354#25968#25454
          OnClick = N12Click
        end
        object N13: TMenuItem
          Caption = #20445#23384#25968#25454
          OnClick = N13Click
        end
      end
      object N6: TMenuItem
        Caption = #36890#20449#25968#25454
        object N9: TMenuItem
          Caption = #25171#24320#20018#21475
          OnClick = N9Click
        end
        object N10: TMenuItem
          Caption = #20851#38381#20018#21475
          OnClick = N10Click
        end
        object N14: TMenuItem
          Caption = #28165#31354#25968#25454
          OnClick = N14Click
        end
        object N15: TMenuItem
          Caption = #20445#23384#25968#25454
          OnClick = N15Click
        end
      end
    end
    object N11: TMenuItem
      Caption = #36873#39033
      OnClick = N11Click
    end
  end
  object dlgSave1: TSaveDialog
    Left = 356
    Top = 72
  end
  object Comm1: TComm
    CommName = 'COM2'
    BaudRate = 9600
    ParityCheck = False
    Outx_CtsFlow = False
    Outx_DsrFlow = False
    DtrControl = DtrEnable
    DsrSensitivity = False
    TxContinueOnXoff = True
    Outx_XonXoffFlow = False
    Inx_XonXoffFlow = False
    ReplaceWhenParityError = False
    IgnoreNullChar = False
    RtsControl = RtsEnable
    XonLimit = 500
    XoffLimit = 500
    ByteSize = _8
    Parity = None
    StopBits = _1
    XonChar = #17
    XoffChar = #19
    ReplacedChar = #0
    ReadIntervalTimeout = 100
    ReadTotalTimeoutMultiplier = 0
    ReadTotalTimeoutConstant = 0
    WriteTotalTimeoutMultiplier = 0
    WriteTotalTimeoutConstant = 0
    OnReceiveData = Comm1ReceiveData
    Left = 260
    Top = 184
  end
  object Comm2: TComm
    CommName = 'COM2'
    BaudRate = 9600
    ParityCheck = False
    Outx_CtsFlow = False
    Outx_DsrFlow = False
    DtrControl = DtrEnable
    DsrSensitivity = False
    TxContinueOnXoff = True
    Outx_XonXoffFlow = False
    Inx_XonXoffFlow = False
    ReplaceWhenParityError = False
    IgnoreNullChar = False
    RtsControl = RtsEnable
    XonLimit = 500
    XoffLimit = 500
    ByteSize = _8
    Parity = None
    StopBits = _1
    XonChar = #17
    XoffChar = #19
    ReplacedChar = #0
    ReadIntervalTimeout = 100
    ReadTotalTimeoutMultiplier = 0
    ReadTotalTimeoutConstant = 0
    WriteTotalTimeoutMultiplier = 0
    WriteTotalTimeoutConstant = 0
    OnReceiveData = Comm2ReceiveData
    Left = 316
    Top = 184
  end
end
