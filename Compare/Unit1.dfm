object Form1: TForm1
  Left = -281
  Top = 183
  Width = 1211
  Height = 706
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Compare'
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
    Left = 712
    Top = 8
    Width = 60
    Height = 13
    Caption = #25991#20214#21015#34920#65306
  end
  object lbl2: TLabel
    Left = 960
    Top = 8
    Width = 60
    Height = 13
    Caption = #21305#37197#21015#34920#65306
  end
  object lbl3: TLabel
    Left = 472
    Top = 552
    Width = 28
    Height = 13
    Caption = #22352#26631':'
  end
  object lbl7: TLabel
    Left = 528
    Top = 610
    Width = 12
    Height = 16
    Caption = '%'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 712
    Top = 320
    Width = 72
    Height = 13
    Caption = #25991#20214#22841#36335#24452#65306
  end
  object Label3: TLabel
    Left = 774
    Top = 8
    Width = 3
    Height = 13
  end
  object Label4: TLabel
    Left = 1024
    Top = 8
    Width = 3
    Height = 13
  end
  object lbl12: TLabel
    Left = 360
    Top = 0
    Width = 96
    Height = 13
    Caption = 'Image A('#26631#20934#22270#29255')'
  end
  object lbl13: TLabel
    Left = 360
    Top = 256
    Width = 95
    Height = 13
    Caption = 'Image B('#23545#27604#22270#29255')'
  end
  object lbl4: TLabel
    Left = 504
    Top = 553
    Width = 3
    Height = 13
  end
  object btn1: TButton
    Left = 24
    Top = 552
    Width = 75
    Height = 25
    Caption = #25171#24320
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 712
    Top = 456
    Width = 75
    Height = 25
    Caption = #24320#22987
    TabOrder = 1
    OnClick = btn2Click
  end
  object edt6: TEdit
    Left = 456
    Top = 608
    Width = 65
    Height = 21
    TabOrder = 2
    Text = '95'
  end
  object Button1: TButton
    Left = 712
    Top = 368
    Width = 75
    Height = 25
    Caption = #23548#20837#25991#20214
    TabOrder = 3
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 712
    Top = 336
    Width = 241
    Height = 21
    TabOrder = 4
    OnChange = Edit1Change
  end
  object mmo3: TMemo
    Left = 712
    Top = 512
    Width = 457
    Height = 145
    Lines.Strings = (
      'mmo3')
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object lst1: TListBox
    Left = 712
    Top = 32
    Width = 241
    Height = 281
    ItemHeight = 13
    TabOrder = 6
    OnClick = lst1Click
  end
  object lst2: TListBox
    Left = 960
    Top = 32
    Width = 217
    Height = 281
    ItemHeight = 13
    TabOrder = 7
    OnClick = lst2Click
  end
  object btn3: TButton
    Left = 960
    Top = 328
    Width = 75
    Height = 25
    Caption = #23548#20986#25991#20214
    TabOrder = 8
    OnClick = btn3Click
  end
  object ImageEnView1: TImageEnView
    Left = 360
    Top = 16
    Width = 320
    Height = 240
    ParentCtl3D = False
    AutoFit = True
    ImageEnVersion = '2.1.9'
    TabOrder = 9
  end
  object ImageEnView2: TImageEnView
    Left = 360
    Top = 272
    Width = 320
    Height = 240
    ParentCtl3D = False
    AutoFit = True
    ImageEnVersion = '2.1.9'
    TabOrder = 10
  end
  object btn5: TBitBtn
    Left = 360
    Top = 544
    Width = 75
    Height = 25
    Caption = #25130#21462
    TabOrder = 11
    OnClick = btn5Click
  end
  object ImageEnView3: TImageEnView
    Left = 24
    Top = 16
    Width = 320
    Height = 240
    ParentCtl3D = False
    AutoFit = True
    ImageEnVersion = '2.1.9'
    TabOrder = 12
    OnMouseDown = ImageEnView3MouseDown
    OnMouseMove = ImageEnView3MouseMove
    OnMouseUp = ImageEnView3MouseUp
  end
  object ImageEnView4: TImageEnView
    Left = 24
    Top = 272
    Width = 320
    Height = 240
    ParentCtl3D = False
    AutoFit = True
    ImageEnVersion = '2.1.9'
    TabOrder = 13
  end
  object rb1: TRadioButton
    Left = 368
    Top = 600
    Width = 81
    Height = 17
    Caption = #30456#20284#24230#23567#20110
    Checked = True
    TabOrder = 14
    TabStop = True
  end
  object rb2: TRadioButton
    Left = 368
    Top = 624
    Width = 81
    Height = 17
    Caption = #30456#20284#24230#22823#20110
    TabOrder = 15
  end
  object btn4: TButton
    Left = 1144
    Top = 8
    Width = 33
    Height = 17
    Caption = 'C'
    TabOrder = 16
    OnClick = btn4Click
  end
  object dlgOpen1: TOpenDialog
    Left = 24
    Top = 600
  end
end
