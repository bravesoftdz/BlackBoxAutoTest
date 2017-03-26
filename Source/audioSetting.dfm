object AudioSettingsForm: TAudioSettingsForm
  Left = 423
  Top = 263
  Width = 857
  Height = 428
  Caption = 'AudioSettingsForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  DesignSize = (
    841
    389)
  PixelsPerInch = 96
  TextHeight = 13
  object VolumeLevel: TLabel
    Left = 8
    Top = 72
    Width = 63
    Height = 13
    Caption = 'VolumeLevel:'
  end
  object Label2: TLabel
    Left = 88
    Top = 72
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label1: TLabel
    Left = 11
    Top = 32
    Width = 163
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  object pbDrawArea: TPaintBox
    Left = 192
    Top = 61
    Width = 640
    Height = 320
    OnPaint = pbDrawAreaPaint
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 8
    Width = 166
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboBox1Change
  end
  object TrackBar1: TTrackBar
    Left = 6
    Top = 48
    Width = 168
    Height = 20
    Anchors = [akLeft, akTop, akRight]
    Max = 100
    TabOrder = 1
    ThumbLength = 9
    TickMarks = tmBoth
    TickStyle = tsNone
    OnChange = TrackBar1Change
  end
  object Button1: TButton
    Left = 8
    Top = 143
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 2
    OnClick = Button1Click
  end
  object btn1: TButton
    Left = 8
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    OnClick = btn1Click
  end
  object Button2: TButton
    Left = 96
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Play'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 96
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 5
    OnClick = Button3Click
  end
  object CheckBox1: TCheckBox
    Left = 176
    Top = 8
    Width = 105
    Height = 25
    Caption = 'Noise Removal'
    TabOrder = 6
  end
  object Edit1: TEdit
    Left = 192
    Top = 32
    Width = 81
    Height = 21
    TabOrder = 7
    Text = '1000'
  end
  object Button4: TButton
    Left = 8
    Top = 96
    Width = 161
    Height = 33
    Caption = 'Initialize audio device'
    TabOrder = 8
    OnClick = Button4Click
  end
  object OpenDialog1: TOpenDialog
    Left = 120
    Top = 320
  end
  object SaveDialog1: TSaveDialog
    Left = 120
    Top = 272
  end
end
