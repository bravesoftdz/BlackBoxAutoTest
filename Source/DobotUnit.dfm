object DobotForm: TDobotForm
  Left = 276
  Top = 138
  Width = 989
  Height = 677
  Caption = 'DobotForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = InitStringGrid
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 136
    Top = 32
    Width = 89
    Height = 18
  end
  object ConnectDobot: TButton
    Left = 40
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = ConnectDobotClick
  end
  object Dobot_Home: TButton
    Left = 40
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Home'
    TabOrder = 1
    OnClick = Dobot_HomeClick
  end
  object Memo1: TMemo
    Left = 40
    Top = 184
    Width = 417
    Height = 406
    TabOrder = 2
  end
  object Dobot_Record: TButton
    Left = 136
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Record'
    TabOrder = 3
    OnClick = Dobot_RecordClick
  end
  object Run: TButton
    Left = 232
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Run'
    TabOrder = 4
    OnClick = RunClick
  end
  object Edit1: TEdit
    Left = 40
    Top = 144
    Width = 49
    Height = 21
    TabOrder = 5
    Text = 'X'
  end
  object Edit2: TEdit
    Left = 163
    Top = 144
    Width = 49
    Height = 21
    TabOrder = 6
    Text = 'Y'
  end
  object Edit3: TEdit
    Left = 285
    Top = 144
    Width = 49
    Height = 21
    TabOrder = 7
    Text = 'Z'
  end
  object Edit4: TEdit
    Left = 408
    Top = 144
    Width = 49
    Height = 21
    TabOrder = 8
    Text = 'R'
  end
  object StringGrid1: TStringGrid
    Left = 536
    Top = 184
    Width = 385
    Height = 409
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    TabOrder = 9
  end
  object Button2: TButton
    Left = 536
    Top = 104
    Width = 72
    Height = 24
    Caption = 'X-'
    TabOrder = 10
    OnMouseDown = Button2MouseDown
    OnMouseUp = Button2MouseUp
  end
  object Button3: TButton
    Left = 632
    Top = 64
    Width = 72
    Height = 24
    Caption = 'Y+'
    TabOrder = 11
    OnMouseDown = Button3MouseDown
    OnMouseUp = Button3MouseUp
  end
  object Button4: TButton
    Left = 632
    Top = 104
    Width = 72
    Height = 24
    Caption = 'Y-'
    TabOrder = 12
    OnMouseDown = Button4MouseDown
    OnMouseUp = Button4MouseUp
  end
  object Button5: TButton
    Left = 728
    Top = 64
    Width = 72
    Height = 24
    Caption = 'Z+'
    TabOrder = 13
    OnMouseDown = Button5MouseDown
    OnMouseUp = Button5MouseUp
  end
  object Button6: TButton
    Left = 728
    Top = 104
    Width = 72
    Height = 24
    Caption = 'Z-'
    TabOrder = 14
    OnMouseDown = Button6MouseDown
    OnMouseMove = Button6MouseMove
  end
  object Button7: TButton
    Left = 832
    Top = 64
    Width = 72
    Height = 24
    Caption = 'R+'
    TabOrder = 15
    OnMouseDown = Button7MouseDown
    OnMouseUp = Button7MouseUp
  end
  object Button8: TButton
    Left = 832
    Top = 104
    Width = 72
    Height = 24
    Caption = 'R-'
    TabOrder = 16
    OnMouseDown = Button8MouseDown
    OnMouseUp = Button8MouseUp
  end
  object Button1: TButton
    Left = 536
    Top = 64
    Width = 72
    Height = 24
    Caption = 'X+'
    TabOrder = 17
    OnMouseDown = Button1MouseDown
    OnMouseUp = Button1MouseUp
  end
  object Button9: TButton
    Left = 40
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 18
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 320
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 19
    OnClick = Button10Click
  end
  object edt1: TEdit
    Left = 352
    Top = 64
    Width = 65
    Height = 21
    TabOrder = 20
    Text = '30'
  end
  object ScrollBar1: TScrollBar
    Left = 128
    Top = 67
    Width = 209
    Height = 16
    Min = 1
    PageSize = 0
    Position = 30
    TabOrder = 21
    OnChange = ScrollBar1Change
  end
  object PopupMenu1: TPopupMenu
    Left = 488
    Top = 160
    object delete1: TMenuItem
      Caption = 'delete'
      OnClick = delete1Click
    end
    object edit5: TMenuItem
      Caption = 'edit'
    end
  end
end
