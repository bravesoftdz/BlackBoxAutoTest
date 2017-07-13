object DobotForm: TDobotForm
  Left = 232
  Top = 11
  Width = 1038
  Height = 699
  Caption = 'DobotForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = InitStringGrid
  PixelsPerInch = 96
  TextHeight = 13
  object ConnectDobot: TButton
    Left = 184
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = ConnectDobotClick
  end
  object Dobot_Home: TButton
    Left = 184
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Home'
    TabOrder = 1
    OnClick = Dobot_HomeClick
  end
  object Memo1: TMemo
    Left = 56
    Top = 256
    Width = 441
    Height = 406
    Lines.Strings = (
      'Memo1')
    TabOrder = 2
  end
  object Dobot_Record: TButton
    Left = 344
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Record'
    TabOrder = 3
    OnClick = Dobot_RecordClick
  end
  object Run: TButton
    Left = 480
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Run'
    TabOrder = 4
    OnClick = RunClick
  end
  object Edit1: TEdit
    Left = 72
    Top = 216
    Width = 25
    Height = 21
    TabOrder = 5
    Text = 'X'
  end
  object Edit2: TEdit
    Left = 192
    Top = 216
    Width = 49
    Height = 21
    TabOrder = 6
    Text = 'Y'
  end
  object Edit3: TEdit
    Left = 336
    Top = 216
    Width = 49
    Height = 21
    TabOrder = 7
    Text = 'Z'
  end
  object Edit4: TEdit
    Left = 440
    Top = 216
    Width = 49
    Height = 21
    TabOrder = 8
    Text = 'R'
  end
  object StringGrid1: TStringGrid
    Left = 624
    Top = 160
    Width = 329
    Height = 479
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 9
  end
  object Button2: TButton
    Left = 640
    Top = 72
    Width = 75
    Height = 25
    Caption = 'X-'
    TabOrder = 10
    OnMouseDown = Button2MouseDown
    OnMouseUp = Button2MouseUp
  end
  object Button3: TButton
    Left = 736
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Y+'
    TabOrder = 11
    OnMouseDown = Button3MouseDown
    OnMouseUp = Button3MouseUp
  end
  object Button4: TButton
    Left = 736
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Y-'
    TabOrder = 12
    OnMouseDown = Button4MouseDown
    OnMouseUp = Button4MouseUp
  end
  object Button5: TButton
    Left = 832
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Z+'
    TabOrder = 13
    OnMouseDown = Button5MouseDown
    OnMouseUp = Button5MouseUp
  end
  object Button6: TButton
    Left = 832
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Z-'
    TabOrder = 14
    OnMouseDown = Button6MouseDown
    OnMouseMove = Button6MouseMove
  end
  object Button7: TButton
    Left = 936
    Top = 32
    Width = 75
    Height = 25
    Caption = 'R+'
    TabOrder = 15
    OnMouseDown = Button7MouseDown
    OnMouseUp = Button7MouseUp
  end
  object Button8: TButton
    Left = 936
    Top = 72
    Width = 75
    Height = 25
    Caption = 'R-'
    TabOrder = 16
    OnMouseDown = Button8MouseDown
    OnMouseUp = Button8MouseUp
  end
  object Button1: TButton
    Left = 640
    Top = 32
    Width = 75
    Height = 25
    Caption = 'X+'
    TabOrder = 17
    OnMouseDown = Button1MouseDown
    OnMouseUp = Button1MouseUp
  end
  object Button9: TButton
    Left = 360
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 18
    OnClick = Button9Click
  end
  object PopupMenu1: TPopupMenu
    Left = 312
    Top = 136
    object delete1: TMenuItem
      Caption = 'delete'
      OnClick = delete1Click
    end
    object edit5: TMenuItem
      Caption = 'edit'
    end
  end
end
