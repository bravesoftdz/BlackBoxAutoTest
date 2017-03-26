object FormCardSet: TFormCardSet
  Left = 631
  Top = 219
  BorderStyle = bsDialog
  Caption = #27169#25311#21345#35774#32622
  ClientHeight = 435
  ClientWidth = 517
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 21
    Top = 34
    Width = 36
    Height = 13
    Caption = #20018#21475#65306
  end
  object Lbl2: TLabel
    Left = 328
    Top = 16
    Width = 185
    Height = 17
    AutoSize = False
  end
  object Label1: TLabel
    Left = 303
    Top = 16
    Width = 24
    Height = 13
    Caption = #24635#25968
  end
  object cbbPort: TComboBox
    Left = 62
    Top = 28
    Width = 91
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbbPortChange
  end
  object chk1: TCheckBox
    Left = 64
    Top = 64
    Width = 97
    Height = 17
    Caption = #33258#21160#36830#25509
    TabOrder = 1
  end
  object btnCfgOK: TButton
    Left = 31
    Top = 95
    Width = 65
    Height = 20
    Caption = #30830#23450' '
    TabOrder = 2
    OnClick = btnCfgOKClick
  end
  object btnCfgCancel: TButton
    Left = 119
    Top = 93
    Width = 65
    Height = 20
    Caption = #21462#28040
    TabOrder = 3
    OnClick = btnCfgCancelClick
  end
  object btn1: TButton
    Left = 160
    Top = 29
    Width = 25
    Height = 17
    Caption = 'R'
    TabOrder = 4
    OnClick = btn1Click
  end
  object ListBox1: TListBox
    Left = 304
    Top = 40
    Width = 185
    Height = 369
    ItemHeight = 13
    TabOrder = 5
  end
  object Button1: TButton
    Left = 216
    Top = 32
    Width = 65
    Height = 25
    Caption = #23548#20837#21345#21015#34920
    TabOrder = 6
    OnClick = Button1Click
  end
  object OpenDialog1: TOpenDialog
    Left = 208
    Top = 152
  end
end
