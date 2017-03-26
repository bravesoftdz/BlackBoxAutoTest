object OptionForm: TOptionForm
  Left = 577
  Top = 321
  BorderStyle = bsDialog
  Caption = 'Option'
  ClientHeight = 162
  ClientWidth = 327
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
  object chk1: TCheckBox
    Left = 24
    Top = 24
    Width = 129
    Height = 17
    Caption = #33258#21160#20445#23384'Log'
    TabOrder = 0
  end
  object edt1: TEdit
    Left = 88
    Top = 48
    Width = 169
    Height = 21
    TabOrder = 1
  end
  object btn1: TButton
    Left = 264
    Top = 44
    Width = 57
    Height = 25
    Caption = #26356#25913
    TabOrder = 2
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 120
    Top = 128
    Width = 75
    Height = 25
    Caption = #30830#35748
    TabOrder = 3
  end
  object CheckBox1: TCheckBox
    Left = 40
    Top = 48
    Width = 49
    Height = 17
    Caption = #35774#22791
    TabOrder = 4
  end
  object CheckBox2: TCheckBox
    Left = 40
    Top = 83
    Width = 49
    Height = 17
    Caption = #36890#35759
    TabOrder = 5
  end
  object Edit1: TEdit
    Left = 88
    Top = 80
    Width = 169
    Height = 21
    TabOrder = 6
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 264
    Top = 77
    Width = 57
    Height = 25
    Caption = #26356#25913
    TabOrder = 7
  end
  object dlgSave1: TSaveDialog
    Left = 216
  end
end
