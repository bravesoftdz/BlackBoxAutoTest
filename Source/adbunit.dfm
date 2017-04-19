object AdbSetForm: TAdbSetForm
  Left = 524
  Top = 309
  BorderStyle = bsDialog
  Caption = 'adb'#35774#32622
  ClientHeight = 182
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 14
    Top = 48
    Width = 59
    Height = 13
    Caption = 'Android SDK'
  end
  object edt1: TEdit
    Left = 16
    Top = 72
    Width = 209
    Height = 21
    TabOrder = 0
  end
  object btn1: TButton
    Left = 232
    Top = 68
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 1
    OnClick = btn1Click
  end
  object dlgOpen1: TOpenDialog
    Left = 216
    Top = 112
  end
end
