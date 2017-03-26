object Form1: TForm1
  Left = 225
  Top = 90
  Width = 1186
  Height = 708
  Caption = #39068#33394#27604#36739
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object img1: TImage
    Left = 16
    Top = 32
    Width = 640
    Height = 480
    OnMouseDown = img1MouseDown
    OnMouseUp = img1MouseUp
  end
  object lbl1: TLabel
    Left = 672
    Top = 8
    Width = 60
    Height = 13
    Caption = #25991#20214#21015#34920#65306
  end
  object lbl2: TLabel
    Left = 936
    Top = 8
    Width = 60
    Height = 13
    Caption = #22833#36133#21015#34920#65306
  end
  object lbl3: TLabel
    Left = 40
    Top = 568
    Width = 24
    Height = 13
    Caption = #22352#26631
  end
  object lbl4: TLabel
    Left = 16
    Top = 600
    Width = 24
    Height = 13
    Caption = #39068#33394
  end
  object lbl5: TLabel
    Left = 48
    Top = 600
    Width = 20
    Height = 13
    Caption = 'RGB'
  end
  object lbl6: TLabel
    Left = 48
    Top = 640
    Width = 19
    Height = 13
    Caption = 'HSV'
  end
  object lbl7: TLabel
    Left = 384
    Top = 520
    Width = 36
    Height = 13
    Caption = #39044#26399#20540
  end
  object lbl8: TLabel
    Left = 592
    Top = 576
    Width = 24
    Height = 13
    Caption = #35823#24046
  end
  object lbl9: TLabel
    Left = 384
    Top = 544
    Width = 24
    Height = 13
    Caption = #22352#26631
  end
  object Label1: TLabel
    Left = 384
    Top = 576
    Width = 24
    Height = 13
    Caption = #39068#33394
  end
  object Label2: TLabel
    Left = 672
    Top = 320
    Width = 72
    Height = 13
    Caption = #25991#20214#22841#36335#24452#65306
  end
  object lbl10: TLabel
    Left = 384
    Top = 608
    Width = 20
    Height = 13
    Caption = 'RGB'
  end
  object lbl11: TLabel
    Left = 384
    Top = 640
    Width = 19
    Height = 13
    Caption = 'HSV'
  end
  object Label3: TLabel
    Left = 739
    Top = 8
    Width = 3
    Height = 13
  end
  object Label4: TLabel
    Left = 998
    Top = 8
    Width = 75
    Height = 17
  end
  object btn1: TButton
    Left = 16
    Top = 528
    Width = 75
    Height = 25
    Caption = #25171#24320
    TabOrder = 0
    OnClick = btn1Click
  end
  object edt1: TEdit
    Left = 72
    Top = 568
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object btn2: TButton
    Left = 672
    Top = 464
    Width = 75
    Height = 25
    Caption = #24320#22987
    TabOrder = 2
    OnClick = btn2Click
  end
  object edt2: TEdit
    Left = 72
    Top = 600
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object edt3: TEdit
    Left = 72
    Top = 632
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object edt4: TEdit
    Left = 416
    Top = 600
    Width = 121
    Height = 21
    TabOrder = 5
    Text = '0,0,0'
  end
  object edt5: TEdit
    Left = 544
    Top = 600
    Width = 121
    Height = 21
    TabOrder = 6
    Text = '20,20,20'
  end
  object edt6: TEdit
    Left = 416
    Top = 544
    Width = 121
    Height = 21
    TabOrder = 7
    Text = '0,0'
  end
  object Button1: TButton
    Left = 672
    Top = 384
    Width = 75
    Height = 25
    Caption = #23548#20837#27604#36739#25991#20214
    TabOrder = 8
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 672
    Top = 344
    Width = 241
    Height = 21
    TabOrder = 9
    OnChange = Edit1Change
  end
  object mmo3: TMemo
    Left = 672
    Top = 512
    Width = 489
    Height = 145
    Lines.Strings = (
      'mmo3')
    ScrollBars = ssVertical
    TabOrder = 10
  end
  object edt7: TEdit
    Left = 416
    Top = 632
    Width = 121
    Height = 21
    TabOrder = 11
  end
  object edt8: TEdit
    Left = 544
    Top = 632
    Width = 121
    Height = 21
    TabOrder = 12
  end
  object rb1: TRadioButton
    Left = 440
    Top = 576
    Width = 41
    Height = 17
    Caption = 'RGB'
    Checked = True
    TabOrder = 13
    TabStop = True
  end
  object rb2: TRadioButton
    Left = 488
    Top = 576
    Width = 41
    Height = 17
    Caption = 'HSV'
    TabOrder = 14
  end
  object lst1: TListBox
    Left = 672
    Top = 32
    Width = 241
    Height = 281
    ItemHeight = 13
    TabOrder = 15
    OnClick = lst1Click
  end
  object lst2: TListBox
    Left = 936
    Top = 32
    Width = 217
    Height = 281
    ItemHeight = 13
    TabOrder = 16
    OnClick = lst2Click
  end
  object btn3: TButton
    Left = 936
    Top = 341
    Width = 89
    Height = 25
    Caption = #23548#20986#22833#36133#25991#20214
    TabOrder = 17
    OnClick = btn3Click
  end
  object dlgOpen1: TOpenDialog
    Left = 168
    Top = 96
  end
end
