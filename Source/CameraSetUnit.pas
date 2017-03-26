unit CameraSetUnit;

interface

uses
  Windows, jpeg, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus, ComCtrls, DSPack, DSUtil, DirectShow9,
  ExtCtrls, Math, Buttons;

type
  TCameraSetForm = class(TForm)
    stat1: TStatusBar;
    SnapShotBtn: TButton;
    Image1: TImage;
    VideoWindow2: TVideoWindow;
    FilterGraph2: TFilterGraph;
    Filter2: TFilter;
    SampleGrabber2: TSampleGrabber;
    MainMenu1: TMainMenu;
    Camera1: TMenuItem;
    image2: TImage;
    btn1: TButton;
    btn5: TButton;
    Button1: TButton;
    Button2: TButton;
    edt2: TEdit;
    btn6: TButton;
    lbl1: TLabel;
    edtcolor: TEdit;
    btngetcolor: TButton;
    EdtHSV: TEdit;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    shp1: TShape;
    singlerb: TRadioButton;
    arearb: TRadioButton;
    Button3: TButton;
    VideoWindow1: TVideoWindow;
    FilterGraph1: TFilterGraph;
    Filter1: TFilter;
    SampleGrabber1: TSampleGrabber;
    Camera2: TMenuItem;
    Camera3: TMenuItem;
    Camera4: TMenuItem;
    VideoWindow3: TVideoWindow;
    SampleGrabber3: TSampleGrabber;
    VideoWindow4: TVideoWindow;
    FilterGraph3: TFilterGraph;
    Filter3: TFilter;
    FilterGraph4: TFilterGraph;
    Filter4: TFilter;
    SampleGrabber4: TSampleGrabber;
    edtOCRresult: TEdit;
    lbl5: TLabel;
    btnQR: TButton;
    edtQRresult: TEdit;
    lbl6: TLabel;
    VideoSoc: TComboBox;
    lbl7: TLabel;
    Memo1: TMemo;
    lbl8: TLabel;
    btn2: TButton;
    dlgOpen1: TOpenDialog;
    mniN1: TMenuItem;
    mniN2: TMenuItem;
    mniN3: TMenuItem;
    mniN4: TMenuItem;
    PaintBox1: TPaintBox;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormCreate(Sender: TObject);
    //    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SnapShotBtnClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure VideoWindow1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow2MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow2MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow3MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow4MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VideoWindow4MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure btn6Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btngetcolorClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnQRClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure mniN1Click(Sender: TObject);
    procedure mniN2Click(Sender: TObject);
    procedure mniN3Click(Sender: TObject);
    procedure mniN4Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnSelectDevice1(sender: TObject);
    procedure OnSelectDevice2(sender: TObject);
    procedure OnSelectDevice3(sender: TObject);
    procedure OnSelectDevice4(sender: TObject);
  end;
type
  TRGBColor = record
    Red, Green, Blue: Byte;
  end;
  THSBColor = record
    Hue, Saturation, Brightness: Double;
  end;
function CMSnapShot(CameraNum: Integer; Path: string): Boolean;
function CMSnapShotMem(CameraNum: Integer): TBitmap;
function CaptureRect(PicName: string; Rt: TRect): TBitmap;
function Capture(srcBMP: TBitmap; Rt: TRect): TBitmap;
procedure VMRRect(VideoWindow: TVideoWindow; Rt: TRect);
procedure ruihua(bmp: TBitmap); //图片锐化
procedure BMPbinary(Bmp: TBitmap); //图片二值化
function GetAveRGBFunc(bmp: TBitmap; Rt: TRect): TRGBColor;
function RGBToHSV(rgb: TRGBColor): THSBColor;
function Imageresize(bmp: TBitmap;Imwidth:Integer;Imheight: Integer): TBitmap;
function BitStrToHextStr(const BitStr: string): string;
function HexToBitStr(HexStr: string): string;
function GetImageHash(bmp:TBitmap):string;
function hamming(s1, s2: string): integer;
procedure Recording(CameraID: Integer; Path: string);
procedure StopRecording(CameraID: Integer);
var
  CameraSetForm: TCameraSetForm;
  SysDev: TSysDevEnum;
  CameraDevice1:Integer;
  CameraDevice2:Integer;
  CameraDevice3:Integer;
  CameraDevice4:Integer;  
implementation

uses
  ExGlobal, Unit1, OCRUnit, QRcodeUnit;
{$R *.dfm}
var
  P1 //起点坐标
  , P2: TPoint; //终点坐标
  pain: Boolean;

procedure TCameraSetForm.CreateParams(var params: TCreateParams);
//窗体不随主窗体最小化
begin
  inherited CreateParams(Params);
  with Params do
    WndParent := GetDesktopWindow();
end;

function RGBToHSV(rgb: TRGBColor): THSBColor;
var
  minRGB, maxRGB, delta: Double;
  h, s, b: Double;
begin
  h := 0.0;
  minRGB := Min(Min(rgb.Red, rgb.Green), rgb.Blue);
  maxRGB := Max(Max(rgb.Red, rgb.Green), rgb.Blue);
  delta := (maxRGB - minRGB);
  b := maxRGB;
  if (maxRGB <> 0.0) then
    s := 255.0 * delta / maxRGB
  else
    s := 0.0;
  if (s <> 0.0) then
  begin
    if rgb.Red = maxRGB then
      h := (rgb.Green - rgb.Blue) / delta
    else if rgb.Green = maxRGB then
      h := 2.0 + (rgb.Blue - rgb.Red) / delta
    else if rgb.Blue = maxRGB then
      h := 4.0 + (rgb.Red - rgb.Green) / delta
  end;
  // else h := -1.0;
  h := h * 60;
  if h < 0.0 then
    h := h + 360.0;
  with result do
  begin
    Hue := round(h);
    Saturation := round(s * 100 / 255);
    Brightness := round(b * 100 / 255); // round
  end;
end;

procedure TCameraSetForm.FormCreate(Sender: TObject);
var
  i: integer;
  Device1: TMenuItem;
  Device2: TMenuItem;
  Device3: TMenuItem;
  Device4: TMenuItem;
begin
  SysDev := TSysDevEnum.Create(CLSID_VideoInputDeviceCategory);
  if SysDev.CountFilters > 0 then
    for i := 0 to SysDev.CountFilters - 1 do
    begin
      Device1 := TMenuItem.Create(Camera1);
      Device2 := TMenuItem.Create(Camera2);
      Device3 := TMenuItem.Create(Camera3);
      Device4 := TMenuItem.Create(Camera4);
      Device1.Caption := SysDev.Filters[i].FriendlyName;
      Device1.Tag := i;
      Device1.AutoCheck:=True;      
      Device1.OnClick := OnSelectDevice1;
      Device2.Caption := SysDev.Filters[i].FriendlyName;
      Device2.Tag := i;
      Device2.AutoCheck:=True;
      Device2.OnClick := OnSelectDevice2;
      Device3.Caption := SysDev.Filters[i].FriendlyName;
      Device3.Tag := i;
      Device3.AutoCheck:=True;
      Device3.OnClick := OnSelectDevice3;
      Device4.Caption := SysDev.Filters[i].FriendlyName;
      Device4.Tag := i;
      Device4.AutoCheck:=True;      
      Device4.OnClick := OnSelectDevice4;
      Camera1.Add(Device1);
      Camera2.Add(Device2);
      Camera3.Add(Device3);
      Camera4.Add(Device4);
    end;
end;

procedure TCameraSetForm.OnSelectDevice1(sender: TObject);
begin
  FilterGraph1.ClearGraph;
  FilterGraph1.Active := false;
  Filter1.BaseFilter.Moniker := SysDev.GetMoniker(TMenuItem(Sender).tag);
  CameraDevice1:= TMenuItem(Sender).tag;
  FilterGraph1.Active := true;
  with FilterGraph1 as ICaptureGraphBuilder2 do
  //  CheckDSError(RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter1 as IBaseFilter, SampleGrabber1 as IBaseFilter, VideoWindow1 as IbaseFilter));

                 RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter1 as IBaseFilter, nil, VideoWindow1 as IBaseFilter);

  FilterGraph1.Play;
end;

procedure TCameraSetForm.OnSelectDevice2(sender: TObject);
begin
  FilterGraph2.ClearGraph;
  FilterGraph2.Active := false;
  Filter2.BaseFilter.Moniker := SysDev.GetMoniker(TMenuItem(Sender).tag);
  CameraDevice2:= TMenuItem(Sender).tag;
  FilterGraph2.Active := true;
  with FilterGraph2 as ICaptureGraphBuilder2 do
    CheckDSError(RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter2 as IBaseFilter, SampleGrabber2 as IBaseFilter, VideoWindow2 as IbaseFilter));
  FilterGraph2.Play;
end;

procedure TCameraSetForm.OnSelectDevice3(sender: TObject);
begin
  FilterGraph3.ClearGraph;
  FilterGraph3.Active := false;
  Filter3.BaseFilter.Moniker := SysDev.GetMoniker(TMenuItem(Sender).tag);
  CameraDevice3:= TMenuItem(Sender).tag;
  FilterGraph3.Active := true;
  with FilterGraph3 as ICaptureGraphBuilder2 do
    CheckDSError(RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter3 as IBaseFilter, SampleGrabber3 as IBaseFilter, VideoWindow3 as IbaseFilter));
  FilterGraph3.Play;
end;

procedure TCameraSetForm.OnSelectDevice4(sender: TObject);
begin
  FilterGraph4.ClearGraph;
  FilterGraph4.Active := false;
  Filter4.BaseFilter.Moniker := SysDev.GetMoniker(TMenuItem(Sender).tag);
  CameraDevice4:= TMenuItem(Sender).tag;
  FilterGraph4.Active := true;
  with FilterGraph4 as ICaptureGraphBuilder2 do
    CheckDSError(RenderStream(@PIN_CATEGORY_PREVIEW, nil, Filter4 as IBaseFilter, SampleGrabber4 as IBaseFilter, VideoWindow4 as IbaseFilter));
  FilterGraph4.Play;
end;
{
procedure TCameraSetForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  SysDev.Free;
  FilterGraph.ClearGraph;
  FilterGraph.Active := false;
end;
 }

procedure TCameraSetForm.SnapShotBtnClick(Sender: TObject);
begin
  CMSnapShot(1, APPpath + 's.bmp');
  Image1.Picture.LoadFromFile(APPpath + 's.bmp');
end;

function CMSnapShot(CameraNum: Integer; Path: string): Boolean;
var
  ABitmap: Tbitmap;
  JpgBmitmp: TJpegImage;
begin
  Result := False;
  Abitmap := Tbitmap.Create;
  try
    case CameraNum of
      1:
        begin
          CameraSetForm.sampleGrabber1.GetBitmap(Abitmap);
        end;
      2:
        begin
          CameraSetForm.sampleGrabber2.GetBitmap(Abitmap);
        end;
      3:
        begin
          CameraSetForm.sampleGrabber3.GetBitmap(Abitmap);
        end;
      4:
        begin
          CameraSetForm.sampleGrabber4.GetBitmap(Abitmap);
        end;
    end;
    if Assigned(Abitmap) then //如果Bmp不为nil
    begin
      JpgBmitmp := TJpegImage.Create;
      JpgBmitmp.Assign(Abitmap); //将bmp指定给TJpegImage对象
      JpgBmitmp.CompressionQuality := 70; //压缩比例,MAX 100
      JpgBmitmp.JPEGNeeded; //转换
      JpgBmitmp.Compress; //压缩
    end;
    JpgBmitmp.SaveToFile(Path);
  finally
    ABitmap.Free;
    JpgBmitmp.free;
  end;
  Result := True;
end;

function CMSnapShotMem(CameraNum: Integer): TBitmap;
begin
  Result := TBitmap.Create;
  case CameraNum of
    1:
      begin
        CameraSetForm.sampleGrabber1.GetBitmap(Result);
      end;
    2:
      begin
        CameraSetForm.sampleGrabber2.GetBitmap(Result);
      end;
    3:
      begin
        CameraSetForm.sampleGrabber3.GetBitmap(Result);
      end;
    4:
      begin
        CameraSetForm.sampleGrabber4.GetBitmap(Result);
      end;
  end;
end;

procedure Recording(CameraID: Integer; Path: string);
var
  multiplexer: IBaseFilter;
  Writer: IFileSinkFilter;
begin
  case CameraID of
    1:
      begin

 
      end;
    2:
      begin

      end;
    3:
      begin

      end;
    4:
      begin

      end;
  end;

end;



procedure StopRecording(CameraID: Integer);

begin
  case CameraID of
    1:

  end;
end;

procedure ruihua(bmp: TBitmap);
var
  p: pbyteArray;
  xmax, ymax, x, y: integer;
  r, g, b: integer;
begin
  bmp.PixelFormat := pf24bit; //设置为24位真彩位图
  xmax := bmp.Width - 1;
  ymax := bmp.Height - 1;
  for y := 0 to ymax do
  begin
    p := bmp.scanline[y];
    for x := 0 to xmax do
      //如果RGB大于125，乘以8/7，否则除以8/7
    begin
      if p[3 * x + 2] > 125 then
        r := p[3 * x + 2] * 8 div 7
      else
        r := p[3 * x + 2] * 7 div 8;
      if p[3 * x + 1] > 125 then
        g := p[3 * x + 1] * 8 div 7
      else
        g := p[3 * x + 1] * 7 div 8;
      if p[3 * x] > 125 then
        b := p[3 * x] * 8 div 7
      else
        b := p[3 * x] * 7 div 8;
      if r > 255 then
        r := 255;
      if g > 255 then
        g := 255;
      if b > 255 then
        b := 255;
      //R G B 三分量的赋值
      p[3 * x + 2] := byte(r);
      p[3 * x + 1] := byte(g);
      p[3 * x] := byte(b);
    end;
  end;
end;

procedure TCameraSetForm.btn1Click(Sender: TObject); //锐化
var
  bmp: TBitmap;
  destBMP: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.Assign(Image1.Picture.Bitmap);
    ruihua(bmp);
    Image1.Picture.Bitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

procedure BMPbinary(Bmp: TBitmap); //二值化
var
  p: PByteArray;
  Gray, x, y: Integer;
begin
  //设置为24位真彩色
  Bmp.PixelFormat := pf24Bit;
  randomize;
  for y := 0 to Bmp.Height - 1 do
  begin
    p := Bmp.scanline[y];
    for x := 0 to Bmp.Width - 1 do
    begin
      //一个象素点三个字节
      Gray := Round(p[x * 3 + 2] * 0.3 + p[x * 3 + 1] * 0.59 + p[x * 3] * 0.11);
      if gray > 70 then //全局阀值128
      begin
        p[x * 3] := 255;
        p[x * 3 + 1] := 255;
        p[x * 3 + 2] := 255;
      end
      else
      begin
        p[x * 3] := 0;
        p[x * 3 + 1] := 0;
        p[x * 3 + 2] := 0;
      end;
    end;
  end;
end;

procedure TCameraSetForm.Button1Click(Sender: TObject);

begin
  if dlgOpen1.Execute then
  begin
    Image1.Picture.LoadFromFile(dlgOpen1.FileName);
  end;
end;



procedure TCameraSetForm.Button2Click(Sender: TObject); //灰度
var
  p: pbyteArray;
  x, y: integer;
  Bmp: TBitmap;
  Gray: integer;
begin
  Bmp := Tbitmap.Create;
  Bmp.Assign(Image1.Picture.Bitmap);
  //设置为24位真彩位图
  Bmp.PixelFormat := pf24bit;
  for y := 0 to Bmp.Height - 1 do
  begin
    p := Bmp.scanline[y];
    for x := 0 to Bmp.Width - 1 do
    begin
      //取平均值
      Gray := (p[3 * x + 2] + p[3 * x + 1] + p[3 * x]) div 3;
      //R G B 三分量的赋值
      p[3 * x + 2] := byte(Gray);
      p[3 * x + 1] := byte(Gray);
      p[3 * x] := byte(Gray);
    end;
  end;
  Image1.Picture.Bitmap := Bmp;
  //释放位图资源
  Bmp.Free;
end;

procedure VMRRect(VideoWindow: TVideoWindow; Rt: TRect);
var
  VMRBitmap: TVMRBitmap;
begin
  if VideoWindow = nil then
    Exit;
  VMRBitmap := TVMRBitmap.Create(VideoWindow);
  with VMRBitmap, Canvas do
  begin
    LoadEmptyBitmap(VideoWindow.Width, VideoWindow.Height, pf24bit, clSilver);
    Source := VMRBitmap.Canvas.ClipRect;
    Options := VMRBitmap.Options + [vmrbSrcColorKey];
    ColorKey := clSilver;
    Brush.Style := bsClear;
    //Brush.Color := clSilver;
    Pen.Color := clRed;
    //Pen.width := 2;
    Rectangle(Rt);
    DrawTo(0, 0, 1, 1, 1);
  end;
  VMRBitmap.Free;
end;

{
procedure CaptureRect(SampleGrabber: TSampleGrabber; Rt: TRect; PicName: string
  =
  'c:\photo.Bmp');
var
  srcBMP, rtBmp: TBitmap;
  srcRT: TRect;
begin
  srcBMP := TBitmap.Create;
  rtBmp := TBitmap.Create;
  try
    SampleGrabber.GetBitmap(srcBMP);
    with rtBmp, Canvas do
    begin
      Width := (Rt.Right - Rt.Left) * 2; //2倍放大
      Height := (Rt.Bottom - Rt.Top) * 2;
      //要截取的区域：
      srcRT := Rect((Rt.Left * 2),
        (Rt.Top * 2),
        (Rt.Right * 2),
        (Rt.Bottom * 2));

      CopyRect(ClipRect, srcBMP.Canvas, srcRT);
    end;
    rtBmp.SaveToFile(PicName);
  finally
    rtBmp.Free;
    srcBMP.Free;
  end;
end;
}

function CaptureRect(PicName: string; Rt: TRect): TBitmap;
var
  srcBMP: TBitmap;
  srcRT: TRect;
begin
  srcBMP := TBitmap.Create;
  Result := TBitmap.Create;
  try
    result.Canvas.Lock;
    srcBMP.Canvas.Lock;
    srcBMP.LoadFromFile(PicName);
    with Result, Canvas do
    begin
      Width := (Rt.Right - Rt.Left); //2倍放大？
      Height := (Rt.Bottom - Rt.Top);
      //要截取的区域：
      srcRT := Rect((Rt.Left),
        (Rt.Top),
        (Rt.Right),
        (Rt.Bottom));
      CopyRect(ClipRect, srcBMP.Canvas, srcRT);
    end;
    result.Canvas.unLock;
    srcBMP.Canvas.unLock;
  finally
    srcBMP.Free;
  end;
end;

function Capture(srcBMP: TBitmap; Rt: TRect): TBitmap;
var
  srcRT: TRect;
begin
  Result := TBitmap.Create;
  result.Canvas.Lock;
  srcBMP.Canvas.Lock;
  with Result, Canvas do
  begin
    Width := (Rt.Right - Rt.Left); //2倍放大？
    Height := (Rt.Bottom - Rt.Top);
    //要截取的区域：
    srcRT := Rect((Rt.Left),
      (Rt.Top),
      (Rt.Right),
      (Rt.Bottom));
    CopyRect(ClipRect, srcBMP.Canvas, srcRT);
  end;
  result.Canvas.unLock;
  srcBMP.Canvas.unLock;
end;

procedure TCameraSetForm.VideoWindow1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P1 := Point(x, y);
  P2 := P1;
  VideoSoc.ItemIndex := 0; //视频源1
  if button = mbleft then //鼠标左键按下
    pain := True;
end;

procedure TCameraSetForm.VideoWindow1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P2 := Point(x, y);
  pain := False;
  edt2.text := IntToStr(p1.x * 2) + ',' + IntToStr(p1.y * 2) + ',' +
    IntToStr(p2.x * 2) + ','
    + IntToStr(p2.y * 2);
end;

procedure TCameraSetForm.VideoWindow1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SrcRect: TRect;
begin
  if pain = true then
  begin
    p2 := Point(x, y);
    SrcRect := rect(P1.X, P1.Y, P2.X, P2.Y);
    VMRRect(VideoWindow1, SrcRect);
  end;
end;

procedure TCameraSetForm.VideoWindow2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P1 := Point(x, y);
  P2 := P1;
  VideoSoc.ItemIndex := 1; //视频源2
  if button = mbleft then //鼠标左键按下
    pain := True;
end;

procedure TCameraSetForm.VideoWindow2MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P2 := Point(x, y);
  pain := False;
  edt2.text := IntToStr(p1.x * 2) + ',' + IntToStr(p1.y * 2) + ',' +
    IntToStr(p2.x * 2) + ',' + IntToStr(p2.y * 2);
end;

procedure TCameraSetForm.VideoWindow2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SrcRect: TRect;
begin
  if pain = true then
  begin
    p2 := Point(x, y);
    SrcRect := rect(P1.X, P1.Y, P2.X, P2.Y);
    VMRRect(VideoWindow2, SrcRect);
  end;
end;

procedure TCameraSetForm.VideoWindow3MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P1 := Point(x, y);
  P2 := P1;
  VideoSoc.ItemIndex := 2; //视频源3
  if button = mbleft then //鼠标左键按下
    pain := True;
end;

procedure TCameraSetForm.VideoWindow3MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P2 := Point(x, y);
  pain := False;
  edt2.text := IntToStr(p1.x * 2) + ',' + IntToStr(p1.y * 2) + ',' +
    IntToStr(p2.x * 2) + ',' + IntToStr(p2.y * 2);
end;

procedure TCameraSetForm.VideoWindow3MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SrcRect: TRect;
begin
  if pain = true then
  begin
    p2 := Point(x, y);
    SrcRect := rect(P1.X, P1.Y, P2.X, P2.Y);
    VMRRect(VideoWindow3, SrcRect);
  end;
end;

procedure TCameraSetForm.VideoWindow4MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P1 := Point(x, y);
  P2 := P1;
  VideoSoc.ItemIndex := 3; //视频源4
  if button = mbleft then //鼠标左键按下
    pain := True;
end;

procedure TCameraSetForm.VideoWindow4MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P2 := Point(x, y);
  pain := False;
  edt2.text := IntToStr(p1.x * 2) + ',' + IntToStr(p1.y * 2) + ',' +
    IntToStr(p2.x * 2) + ','
    + IntToStr(p2.y * 2);
end;

procedure TCameraSetForm.VideoWindow4MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SrcRect: TRect;
begin
  if pain = true then
  begin
    p2 := Point(x, y);
    SrcRect := rect(P1.X, P1.Y, P2.X, P2.Y);
    VMRRect(VideoWindow4, SrcRect);
  end;
end;

function GetColorFunc(bmp: TBitmap; x, y: integer): TRGBColor;
begin
  Result.Red := GetRValue(bmp.Canvas.Pixels[x, y]);
  Result.Green := GetgValue(bmp.Canvas.Pixels[x, y]);
  Result.Blue := GetbValue(bmp.Canvas.Pixels[x, y]);
end;

function GetAveRGBFunc(bmp: TBitmap; Rt: TRect): TRGBColor;
var
  p: pbyteArray;
  x, y: integer;
  RSum, GSum, BSum: integer;
  Sum: Integer; //像素总数
begin
  //设置为24位真彩位图
  Bmp.PixelFormat := pf24bit;
  Sum := 0;
  RSum := 0;
  GSum := 0;
  BSum := 0;
  if ((Rt.Top = 0) and (Rt.Bottom = 0) and (Rt.Left = 0) and (Rt.Right = 0)) then
  begin //未选择区域返回
    Result.Red := 255;
    Result.Green := 255;
    Result.Blue := 255;
    Exit;
  end;
  for y := Rt.top to Rt.Bottom - 1 do
  begin
    p := Bmp.scanline[y];
    for x := Rt.Left to Rt.Right - 1 do
    begin
      RSum := RSum + p[3 * x + 2];
      GSum := GSum + p[3 * x + 1];
      BSum := BSum + p[3 * x];
      inc(Sum);
    end;
  end;
  Result.Red := Round(RSum / Sum);
  Result.Green := Round(GSum / Sum);
  Result.Blue := Round(Bsum / Sum);
end;

function Imageresize(bmp: TBitmap;Imwidth:Integer;Imheight: Integer): TBitmap;
begin
  bmp.PixelFormat := pf24bit; //设置位图为24位图
  try
    begin
      Result := TBitmap.Create; //产生Tbitmap对象bmp
      Result.PixelFormat := pf24bit; //设置Bmp为24色位图
      //缩小图像
      Result.Width := Imwidth;
      Result.Height := Imheight;
      //保持最大限度不失真
      SetStretchBltMode(Result.Canvas.Handle, HALFTONE);
      StretchBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height,
        bmp.Canvas.Handle, 0, 0,
        bmp.Width, bmp.Height, SRCCOPY);
    end;
  except
    ShowMessage('图片太大导致存储空间不足！');
  end;
end;

//计算汉明距离

function hamming(s1, s2: string): integer;
var
  haming_number: Integer;
  i: Integer;
  minlength, maxlength: Integer;
begin
  haming_number := 0;
  minlength := min(Length(s1), Length(s2));
  maxlength := max(Length(s1), Length(s2));
  for i := 0 to minlength do
  begin
    if s1[i] <> s2[i] then
      haming_number := haming_number + 1
  end;
  haming_number := haming_number + (maxlength - minlength);
  Result := haming_number;
end;

function GetImageHash(bmp:TBitmap):string;
var
  p: PByteArray;
  Gray, x, y: Integer;
  GraySum: integer;
  arayavg: Integer;
  ImageHash: string;
begin
    //设置为24位真彩色
  Bmp.PixelFormat := pf24Bit;
  GraySum := 0;
  for y := 0 to Bmp.Height - 1 do
  begin
    p := Bmp.scanline[y];
    for x := 0 to Bmp.Width - 1 do
    begin
      //一个象素点三个字节
      Gray := Round(p[x * 3 + 2] * 0.3 + p[x * 3 + 1] * 0.59 + p[x * 3] * 0.11);
      GraySum := GraySum + Gray;
    end;
  end;
  arayavg := GraySum div 400;
  ImageHash := '';
  for y := 0 to Bmp.Height - 1 do
  begin
    p := Bmp.scanline[y];
    for x := 0 to Bmp.Width - 1 do
    begin
      Gray := Round(p[x * 3 + 2] * 0.3 + p[x * 3 + 1] * 0.59 + p[x * 3] * 0.11);
      if gray > arayavg then //全局阀值
      begin
        p[x * 3] := 255;
        p[x * 3 + 1] := 255;
        p[x * 3 + 2] := 255;
        ImageHash := ImageHash + '1';
      end
      else
      begin
        p[x * 3] := 0;
        p[x * 3 + 1] := 0;
        p[x * 3 + 2] := 0;
        ImageHash := ImageHash + '0';
      end;
    end;
  end;
  Result := ImageHash;
end;

function BitStrToHextStr(const BitStr: string): string;
var
  vD: Byte;
  I: Integer;
  vHextStr: string;
  vP: PChar;
  vLen: Integer;
begin
  vLen := Length(BitStr);
  if vLen mod 4 > 0 then
  begin
    SetLength(vHextStr, vLen div 4 + 1);
    vLen := vlen div 4 + 1;
  end
  else
  begin
    SetLength(vHextStr, vLen div 4);
    vLen := vlen div 4;
  end;

  //初始化
  vD := 0;
  vP := PChar(BitStr) + length(BitStr) - 1;
  I := 0; //开始计数

  while vP^ <> #0 do
  begin
    if vp^ = '1' then
    begin
      case i of
        0: vD := vd + 1;
        1: vD := vd + 2;
        2: vD := vd + 4;
        3: vD := vd + 8;
      end;
    end;

    Dec(vP);
    Inc(I);
    if I = 4 then
    begin
      case vD of
        0..9: vHextStr[vLen] := Chr(vD + $30);
        10..15: vHextStr[vLen] := Chr(vD - 10 + $41);
      end;
      Dec(vLen);
      I := 0;
      vD := 0;
    end;
  end;

  if I > 0 then
  begin
    case vD of
      0..9: vHextStr[vLen] := Chr(vD + $30);
      10..15: vHextStr[vLen] := Chr(vD + $41);
    end;
  end;

  Result := vHextStr;
end;

function HexToBitStr(HexStr: string): string;
const
  cBitStrings: array[0..15] of string =
    (
    '0000', '0001', '0010', '0011',
    '0100', '0101', '0110', '0111',
    '1000', '1001', '1010', '1011',
    '1100', '1101', '1110', '1111'
    );
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(HexStr) do
    Result := Result + cBitStrings[StrToIntDef('$' + HexStr[I], 0)];
//  while Pos('0', Result) = 1 do
 //   Delete(Result, 1, 1);
end; {   HexToBit   }

procedure TCameraSetForm.btn6Click(Sender: TObject);
var
  SocBMP: TBitmap;
  Bmp: TBitmap;
  st: TStringList;
  SrcRect: TRect;
begin
  if edt2.Text <> '' then
  begin
    st := SplitString(edt2.Text, ','); //按','分割字符
    try
      SrcRect := Rect(strtoint(st[0]), strtoint(st[1]), strtoint(st[2]), strtoint(st[3]));
      SocBMP := CMSnapShotMem(VideoSoc.ItemIndex + 1);
      bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
      ruihua(bmp); //图片锐化
      BMPbinary(bmp); //图片二值化
      bmp.SaveToFile(APPpath + 'OCR.bmp'); //保存截取的图片
      CameraSetForm.image1.Picture.LoadFromFile(APPpath + 'OCR.bmp'); //显示截取的图片
      edtOCRresult.Text := OCRdetection(APPpath + 'OCR.bmp'); //OCR
      DeleteFile(APPpath + 'OCR.bmp');
    finally
      Bmp.Free;
      SocBMP.Free;
      st.Free;
    end;

  end;
end;

procedure TCameraSetForm.btn5Click(Sender: TObject); //截取
var
  SrcRect: TRect;
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  SrcRect := rect(P1.X * 2, P1.Y * 2, P2.X * 2, P2.Y * 2); //放大2倍
  try
    CMSnapShot(1, APPpath + '1.BMP');
    bmp := CaptureRect(APPpath + '1.bmp', SrcRect);
    image1.Picture.Bitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

procedure TCameraSetForm.btngetcolorClick(Sender: TObject);
var
  bmp: TBitmap;
  ColorRGB: TRGBColor;
  ColorHSV: THSBColor;
begin
  colorRGB.red:=0;
  colorRGB.Green:=0;
  colorRGB.Blue:=0;
  ColorHSV.Hue:=0;
  ColorHSV.Saturation:=0;
  ColorHSV.Brightness:=0;
  try
    bmp := CMSnapShotMem(VideoSoc.ItemIndex + 1);
    if singlerb.Checked then
      colorRGB := GetColorFunc(bmp, p1.x * 2, P1.Y * 2)
    else
      colorRGB := GetAveRGBFunc(bmp, Rect(p1.x * 2, P1.Y * 2, P2.X * 2, P2.Y * 2));
    shp1.Brush.Color := rgb(colorRGB.Red, colorRGB.Green, colorRGB.Blue);
    edtcolor.Text := IntToStr(colorRGB.red) + '.' + IntToStr(colorRGB.Green) + '.' + IntToStr(colorRGB.Blue);
    ColorHSV := RGBToHSV(colorRGB);
    EdtHSV.Text := FloatToStr(ColorHSV.Hue) + '.' + FloatToStr(ColorHSV.Saturation) + '.' + FloatToStr(ColorHSV.Brightness);
  finally
    bmp.Free;
  end;
end;

procedure TCameraSetForm.Button3Click(Sender: TObject); //二值化
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  Bmp.Assign(Image1.Picture.Bitmap);
  BMPbinary(Bmp);
  image2.Picture.Bitmap.Assign(bmp);
  Bmp.Free;
end;

procedure TCameraSetForm.btnQRClick(Sender: TObject);
var
  SocBMP: TBitmap;
  Bmp: TBitmap;
  st: TStringList;
  SrcRect: TRect;
begin
  if edt2.Text <> '' then //按区域
  begin
    st := SplitString(edt2.Text, ','); //按','分割字符
    SocBMP := CMSnapShotMem(VideoSoc.ItemIndex + 1); //图像抓拍，内存中
    SrcRect := Rect(strtoint(st[0]), strtoint(st[1]), strtoint(st[2]), strtoint(st[3])); //截取坐标
    bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
    CameraSetForm.image1.Picture.Bitmap.Assign(bmp); //显示截取的图片
    bmp.SaveToFile(APPpath + 'QR.bmp'); //保存截取的图片
    edtQRresult.text := DecodeFile(APPpath + 'QR.bmp');
    DeleteFile(APPpath + 'QR.bmp');
  end
  else //整个图片
  begin
    CMSnapShot((VideoSoc.ItemIndex + 1), APPpath + 'QR.bmp'); //抓拍图像
    edtQRresult.Text := DecodeFile(APPpath + 'QR.bmp');
    DeleteFile(APPpath + 'QR.bmp');
  end;
end;

procedure TCameraSetForm.btn2Click(Sender: TObject);
var
  bmp:TBitmap;
  bmp2:TBitmap;

  SocBMP: TBitmap;
  st: TStringList;
  SrcRect: TRect;
begin

  if edt2.Text <> '' then
  begin
    st := SplitString(edt2.Text, ','); //按','分割字符
    try
      SrcRect := Rect(strtoint(st[0]), strtoint(st[1]), strtoint(st[2]), strtoint(st[3]));
      SocBMP := CMSnapShotMem(VideoSoc.ItemIndex + 1);
      bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中

      bmp2:=Imageresize(bmp,8,8);
      Memo1.Text:= BitStrToHextStr(GetImageHash(bmp2));
      CameraSetForm.image1.Picture.Assign(bmp); //显示截取的图片

    finally
      Bmp.Free;
      SocBMP.Free;
      st.Free;
    end;

  end;

end;

procedure TCameraSetForm.mniN1Click(Sender: TObject);
begin
   FilterGraph1.Active := True;
  ShowFilterPropertyPage(Self.Handle, Filter1 as IBaseFilter);
//  FilterGraph.Active := False;
end;

procedure TCameraSetForm.mniN2Click(Sender: TObject);
begin
   FilterGraph2.Active := True;
  ShowFilterPropertyPage(Self.Handle, Filter2 as IBaseFilter);
//  FilterGraph.Active := False;
end;

procedure TCameraSetForm.mniN3Click(Sender: TObject);
begin
   FilterGraph3.Active := True;
  ShowFilterPropertyPage(Self.Handle, Filter3 as IBaseFilter);
//  FilterGraph.Active := False;
end;

procedure TCameraSetForm.mniN4Click(Sender: TObject);
begin
   FilterGraph4.Active := True;
  ShowFilterPropertyPage(Self.Handle, Filter4 as IBaseFilter);
//  FilterGraph.Active := False;
end;

end.

