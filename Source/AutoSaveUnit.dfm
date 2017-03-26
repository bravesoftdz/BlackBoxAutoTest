object autoSaveForm: TautoSaveForm
  Left = 481
  Top = 185
  BorderStyle = bsDialog
  Caption = 'Auto Save'
  ClientHeight = 236
  ClientWidth = 375
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 152
    Top = 132
    Width = 72
    Height = 13
    Caption = #20998#38047#33258#21160#20445#23384
  end
  object Label2: TLabel
    Left = 72
    Top = 57
    Width = 228
    Height = 13
    Caption = #33258#21160#20445#23384#36335#24452#65288#20026#31354#26102#20445#23384#22312#31243#24207#36335#24452#19979#65289
  end
  object AutoSavechk: TCheckBox
    Left = 48
    Top = 32
    Width = 177
    Height = 17
    Caption = #33258#21160#20445#23384#27979#35797#35760#24405
    Checked = True
    Enabled = False
    State = cbChecked
    TabOrder = 0
  end
  object Edt2: TEdit
    Left = 72
    Top = 80
    Width = 201
    Height = 21
    ReadOnly = True
    TabOrder = 1
  end
  object edt1: TEdit
    Left = 72
    Top = 128
    Width = 73
    Height = 21
    TabOrder = 2
    Text = '5'
    OnChange = edt1Change
    OnKeyPress = edt1KeyPress
  end
  object Button1: TButton
    Left = 284
    Top = 77
    Width = 33
    Height = 25
    Caption = '...'
    TabOrder = 3
    OnClick = Button1Click
  end
  object tmr1: TTimer
    Enabled = False
    Interval = 300000
    OnTimer = tmr1Timer
    Left = 280
    Top = 128
  end
end
