object CameraSetForm: TCameraSetForm
  Left = 306
  Top = 43
  Width = 1024
  Height = 768
  Caption = #25668#20687#22836#35774#32622
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
  object Image1: TImage
    Left = 649
    Top = 0
    Width = 320
    Height = 240
    Stretch = True
  end
  object image2: TImage
    Left = 649
    Top = 241
    Width = 320
    Height = 240
    Stretch = True
  end
  object lbl1: TLabel
    Left = 16
    Top = 514
    Width = 36
    Height = 13
    Caption = #22352#26631#65306
  end
  object lbl2: TLabel
    Left = 16
    Top = 536
    Width = 36
    Height = 13
    Caption = #39068#33394#65306
  end
  object lbl3: TLabel
    Left = 16
    Top = 590
    Width = 32
    Height = 13
    Caption = 'RGB'#65306
  end
  object lbl4: TLabel
    Left = 96
    Top = 590
    Width = 31
    Height = 13
    Caption = 'HSV'#65306
  end
  object shp1: TShape
    Left = 64
    Top = 536
    Width = 41
    Height = 17
    Pen.Style = psClear
  end
  object lbl5: TLabel
    Left = 184
    Top = 590
    Width = 34
    Height = 13
    Caption = 'OCR'#65306
  end
  object lbl6: TLabel
    Left = 304
    Top = 590
    Width = 53
    Height = 13
    Caption = 'QR code'#65306
  end
  object lbl7: TLabel
    Left = 16
    Top = 491
    Width = 48
    Height = 13
    Caption = #35270#39057#28304#65306
  end
  object lbl8: TLabel
    Left = 464
    Top = 584
    Width = 52
    Height = 13
    Caption = #22270#20687#25351#32441':'
  end
  object PaintBox1: TPaintBox
    Left = 320
    Top = 488
    Width = 465
    Height = 89
  end
  object stat1: TStatusBar
    Left = 0
    Top = 698
    Width = 1016
    Height = 19
    Panels = <>
  end
  object SnapShotBtn: TButton
    Left = 832
    Top = 600
    Width = 75
    Height = 25
    Caption = 'SnapShot'
    TabOrder = 1
    Visible = False
    OnClick = SnapShotBtnClick
  end
  object VideoWindow2: TVideoWindow
    Left = 321
    Top = 0
    Width = 320
    Height = 240
    Mode = vmVMR
    FilterGraph = FilterGraph2
    VMROptions.Mode = vmrWindowed
    VMROptions.Streams = 1
    VMROptions.Preferences = []
    Color = clBlack
    OnMouseDown = VideoWindow2MouseDown
    OnMouseMove = VideoWindow2MouseMove
    OnMouseUp = VideoWindow2MouseUp
  end
  object btn1: TButton
    Left = 920
    Top = 536
    Width = 75
    Height = 25
    Caption = #38160#21270
    TabOrder = 3
    Visible = False
    OnClick = btn1Click
  end
  object btn5: TButton
    Left = 832
    Top = 504
    Width = 75
    Height = 25
    Caption = #25130#21462
    TabOrder = 4
    Visible = False
    OnClick = btn5Click
  end
  object Button1: TButton
    Left = 832
    Top = 536
    Width = 75
    Height = 25
    Caption = 'open'
    TabOrder = 5
    Visible = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 920
    Top = 504
    Width = 75
    Height = 25
    Caption = #28784#24230
    TabOrder = 6
    Visible = False
    OnClick = Button2Click
  end
  object edt2: TEdit
    Left = 64
    Top = 513
    Width = 113
    Height = 21
    TabOrder = 7
  end
  object btn6: TButton
    Left = 184
    Top = 640
    Width = 75
    Height = 25
    Caption = #25991#23383#35782#21035
    TabOrder = 8
    OnClick = btn6Click
  end
  object edtcolor: TEdit
    Left = 16
    Top = 606
    Width = 73
    Height = 21
    TabOrder = 9
  end
  object btngetcolor: TButton
    Left = 16
    Top = 640
    Width = 75
    Height = 25
    Caption = #39068#33394#35782#21035
    TabOrder = 10
    OnClick = btngetcolorClick
  end
  object EdtHSV: TEdit
    Left = 96
    Top = 606
    Width = 73
    Height = 21
    TabOrder = 11
  end
  object singlerb: TRadioButton
    Left = 16
    Top = 554
    Width = 65
    Height = 17
    Caption = #21333#28857#35782#21035
    TabOrder = 12
  end
  object arearb: TRadioButton
    Left = 16
    Top = 572
    Width = 65
    Height = 17
    Caption = #21306#22495#35782#21035
    Checked = True
    TabOrder = 13
    TabStop = True
  end
  object Button3: TButton
    Left = 832
    Top = 568
    Width = 75
    Height = 25
    Caption = #20108#20540#21270
    TabOrder = 14
    Visible = False
    OnClick = Button3Click
  end
  object VideoWindow1: TVideoWindow
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Mode = vmVMR
    FilterGraph = FilterGraph1
    VMROptions.Mode = vmrWindowed
    Color = clBlack
    OnMouseDown = VideoWindow1MouseDown
    OnMouseMove = VideoWindow1MouseMove
    OnMouseUp = VideoWindow1MouseUp
  end
  object VideoWindow3: TVideoWindow
    Left = 0
    Top = 241
    Width = 320
    Height = 240
    Mode = vmVMR
    FilterGraph = FilterGraph3
    VMROptions.Mode = vmrWindowed
    VMROptions.Streams = 1
    VMROptions.Preferences = []
    Color = clBlack
    OnMouseDown = VideoWindow3MouseDown
    OnMouseMove = VideoWindow3MouseMove
    OnMouseUp = VideoWindow3MouseUp
  end
  object VideoWindow4: TVideoWindow
    Left = 321
    Top = 241
    Width = 320
    Height = 240
    Mode = vmVMR
    FilterGraph = FilterGraph4
    VMROptions.Mode = vmrWindowed
    VMROptions.Streams = 1
    VMROptions.Preferences = []
    Color = clBlack
    OnMouseDown = VideoWindow4MouseDown
    OnMouseMove = VideoWindow4MouseMove
    OnMouseUp = VideoWindow4MouseUp
  end
  object edtOCRresult: TEdit
    Left = 184
    Top = 606
    Width = 97
    Height = 21
    TabOrder = 18
  end
  object btnQR: TButton
    Left = 304
    Top = 640
    Width = 75
    Height = 25
    Caption = 'QR code'#35299#30721
    TabOrder = 19
    OnClick = btnQRClick
  end
  object edtQRresult: TEdit
    Left = 304
    Top = 606
    Width = 121
    Height = 21
    TabOrder = 20
  end
  object VideoSoc: TComboBox
    Left = 64
    Top = 486
    Width = 113
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 21
    Text = #31532'1'#36335
    Items.Strings = (
      #31532'1'#36335
      #31532'2'#36335
      #31532'3'#36335
      #31532'4'#36335)
  end
  object Memo1: TMemo
    Left = 464
    Top = 600
    Width = 153
    Height = 25
    MaxLength = 64
    TabOrder = 22
  end
  object btn2: TButton
    Left = 464
    Top = 640
    Width = 75
    Height = 25
    Caption = #22270#20687#35782#21035
    TabOrder = 23
    OnClick = btn2Click
  end
  object FilterGraph2: TFilterGraph
    Mode = gmCapture
    GraphEdit = True
    LinearVolume = True
    Left = 376
    Top = 16
  end
  object Filter2: TFilter
    BaseFilter.data = {00000000}
    FilterGraph = FilterGraph2
    Left = 440
    Top = 16
  end
  object SampleGrabber2: TSampleGrabber
    FilterGraph = FilterGraph2
    MediaType.data = {
      7669647300001000800000AA00389B717DEB36E44F52CE119F530020AF0BA770
      FFFFFFFF0000000001000000809F580556C3CE11BF0100AA0055595A00000000
      0000000000000000}
    Left = 512
    Top = 16
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    AutoLineReduction = maManual
    Left = 752
    Top = 16
    object Camera1: TMenuItem
      Caption = #31532'1'#36335
      object mniN1: TMenuItem
        Caption = #35270#39057#23646#24615
        OnClick = mniN1Click
      end
    end
    object Camera2: TMenuItem
      Caption = #31532'2'#36335
      object mniN2: TMenuItem
        Caption = #35270#39057#23646#24615
        OnClick = mniN2Click
      end
    end
    object Camera3: TMenuItem
      Caption = #31532'3'#36335
      object mniN3: TMenuItem
        Caption = #35270#39057#23646#24615
        OnClick = mniN3Click
      end
    end
    object Camera4: TMenuItem
      Caption = #31532'4'#36335
      object mniN4: TMenuItem
        Caption = #35270#39057#23646#24615
        OnClick = mniN4Click
      end
    end
  end
  object FilterGraph1: TFilterGraph
    Mode = gmCapture
    GraphEdit = True
    LinearVolume = True
    Left = 48
    Top = 40
  end
  object Filter1: TFilter
    BaseFilter.data = {00000000}
    FilterGraph = FilterGraph1
    Left = 104
    Top = 40
  end
  object SampleGrabber1: TSampleGrabber
    FilterGraph = FilterGraph1
    MediaType.data = {
      7669647300001000800000AA00389B717DEB36E44F52CE119F530020AF0BA770
      FFFFFFFF0000000001000000809F580556C3CE11BF0100AA0055595A00000000
      0000000000000000}
    Left = 168
    Top = 40
  end
  object SampleGrabber3: TSampleGrabber
    FilterGraph = FilterGraph3
    MediaType.data = {
      7669647300001000800000AA00389B717DEB36E44F52CE119F530020AF0BA770
      FFFFFFFF0000000001000000809F580556C3CE11BF0100AA0055595A00000000
      0000000000000000}
    Left = 184
    Top = 256
  end
  object FilterGraph3: TFilterGraph
    Mode = gmCapture
    GraphEdit = True
    LinearVolume = True
    Left = 96
    Top = 256
  end
  object Filter3: TFilter
    BaseFilter.data = {00000000}
    FilterGraph = FilterGraph3
    Left = 32
    Top = 256
  end
  object FilterGraph4: TFilterGraph
    Mode = gmCapture
    GraphEdit = True
    LinearVolume = True
    Left = 336
    Top = 280
  end
  object Filter4: TFilter
    BaseFilter.data = {00000000}
    FilterGraph = FilterGraph4
    Left = 400
    Top = 280
  end
  object SampleGrabber4: TSampleGrabber
    FilterGraph = FilterGraph4
    MediaType.data = {
      7669647300001000800000AA00389B717DEB36E44F52CE119F530020AF0BA770
      FFFFFFFF0000000001000000809F580556C3CE11BF0100AA0055595A00000000
      0000000000000000}
    Left = 472
    Top = 280
  end
  object dlgOpen1: TOpenDialog
    Left = 960
    Top = 568
  end
end
