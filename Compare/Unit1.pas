unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, FileCtrl, Math, jpeg, ieview, imageenview,
  Buttons;

type
  TForm1 = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    btn1: TButton;
    lbl3: TLabel;
    btn2: TButton;
    lbl7: TLabel;
    dlgOpen1: TOpenDialog;
    edt6: TEdit;
    Button1: TButton;
    Edit1: TEdit;
    Label2: TLabel;
    mmo3: TMemo;
    lst1: TListBox;
    lst2: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    btn3: TButton;
    ImageEnView1: TImageEnView;
    ImageEnView2: TImageEnView;
    lbl12: TLabel;
    lbl13: TLabel;
    btn5: TBitBtn;
    ImageEnView3: TImageEnView;
    ImageEnView4: TImageEnView;
    lbl4: TLabel;
    rb1: TRadioButton;
    rb2: TRadioButton;
    btn4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure lst2Click(Sender: TObject);
    procedure lst1Click(Sender: TObject);
     procedure btn3Click(Sender: TObject);
    procedure ImageEnView3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageEnView3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btn4Click(Sender: TObject);
    procedure ImageEnView3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btn5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

type
  TRGBColor = record
    Red, Green, Blue: Byte;
  end;
  THSVColor = record
    Hue, Saturation, Brightness: Double;
  end;
var
  filespath: string; //文件夹路径
  srcfile:string;
  ExpRGB: TRGBColor; //预期结果
  DevRGB: TRGBColor; //误差
  CriterionRGB_L: TRGBColor; //基准
  CriterionRGB_H: TRGBColor; //基准
  P1 //起点坐标
  , P2: TPoint; //终点坐标
  pain: Boolean;
  SrcRect: TRect;
function GetColor(bmp: TBitmap; x, y: integer): TRGBColor;
function RGBToHSV(rgb: TRGBColor): THSVColor;
function Jpg2Bmp(FileName: string): TBitMap;
implementation

uses
  checkThread;

{$R *.dfm}

function Jpg2Bmp(FileName: string): TBitMap;
var
  Jpg: TJpegImage;
begin

  Jpg := TJpegImage.Create;
  try
    Jpg.CompressionQuality := 100;
    Jpg.LoadFromFile(FileName);
    Result := TBitMap.Create;

    Result.Assign(Jpg); //将Jpg指定给TBitMap对象

  finally
    Jpg.Free;

  end;
end;

{
function Jpg2Bmp(FileName: string): TBitMap;
var
  Jpg: TJpegImage;
begin
  try
    Jpg := TJpegImage.Create;
    Jpg.LoadFromFile(FileName);
    Result := nil;
    if Assigned(Jpg) then //如果Jpg不为空
    begin
      Result := TBitMap.Create;
      Result.Assign(Jpg); //将Jpg指定给TBitMap对象
      Jpg.DIBNeeded; //转换
    end;
  finally
    Jpg.Free;
    Jpg := nil;
  end;
end;
}

procedure TForm1.FormCreate(Sender: TObject);
begin
  mmo3.Clear;
  ImageEnView1.Bitmap.Width := 320;
  ImageEnView1.Bitmap.Height := 240;
  ImageEnView2.Bitmap.Width := 320;
  ImageEnView2.Bitmap.Height := 240;
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  with ImageEnView3.IO do
  begin
    srcfile:=ExecuteOpenDialog('', '', false, 1, '');
    LoadFromFile(srcfile);
  end;
end;

function searchfile(path: string): TStringList;
var
  SearchRec: TSearchRec;
  found: integer;
begin
  Result := TStringList.Create;
  found := FindFirst(path + '\' + '*.*', faAnyFile, SearchRec);
  while found = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (SearchRec.Attr <> faDirectory) then
      Result.Add(SearchRec.Name);
    found := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

// RGB TO HSV

function RGBToHSV(rgb: TRGBColor): THSVColor;
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

function GetColor(bmp: TBitmap; x, y: integer): TRGBColor;
var
  r, g, b: integer;
begin
  r := GetRValue(bmp.Canvas.Pixels[x, y]);
  g := GetgValue(bmp.Canvas.Pixels[x, y]);
  b := GetbValue(bmp.Canvas.Pixels[x, y]);
  Result.Red := r;
  Result.Green := g;
  Result.Blue := b;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  files: TStringList;
  i: Integer;
begin
  files := TStringList.Create;
  if SelectDirectory('请指定文件夹', '', filespath) then
    Edit1.Text := filespath;
  try

    files := searchfile(filespath);

    for i := 0 to files.count - 1 do
    begin
      lst1.Items.Clear;
    end;
    for i := 0 to files.count - 1 do
    begin
      if sameText(Copy(files.Strings[i], (Length(files.Strings[i]) - 2), 3), 'bmp')
        or sameText(Copy(files.Strings[i], (Length(files.Strings[i]) - 2), 3), 'jpg') then
        lst1.Items.Add(files.Strings[i]);
    end;
    label3.Caption := IntToStr(lst1.Items.count); //显示文件数
  finally
    files.Free;
  end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  if Edit1.Text <> '' then
  begin
    Button1.Enabled := True;
  end
  else
  begin
    Button1.Enabled := False;
  end;
end;

procedure TForm1.btn2Click(Sender: TObject);

begin
  mmo3.Clear;

  checkPIC.Create(false);
end;

procedure TForm1.lst2Click(Sender: TObject);
var
  files: TStringList;
begin
  files := SplitString(lst2.Items[lst2.Itemindex], ',');
{  try
    img1.Picture.LoadFromFile(filespath + '\' + files[0]);
  finally
    files.Free;
  end;  }


  with ImageEnView4.IO do
    LoadFromFile(filespath + '\' + files[0]);


end;

procedure TForm1.lst1Click(Sender: TObject);
{
 if sameText(Copy(lst1.Items[lst1.Itemindex], (Length(lst1.Items[lst1.Itemindex]) - 2), 3), 'bmp') then
   img1.Picture.LoadFromFile(filespath + '\' + lst1.Items[lst1.Itemindex])
 else
 begin
   img1.Picture.Assign(Jpg2Bmp(filespath + '\' + lst1.Items[lst1.Itemindex]));
 end;
       }
begin
  with ImageEnView4.IO do
    LoadFromFile(filespath + '\' + lst1.Items[lst1.Itemindex]);
end;



procedure TForm1.btn3Click(Sender: TObject);
var
  expPath, filesname: string;
  i: Integer;
  files: TStringList;
begin

  if SelectDirectory('请指定文件夹', '', expPath) then
  begin
    for i := 0 to lst2.Items.Count - 1 do
    begin
      files := SplitString(lst2.Items[i], ',');
      filesname := files[0];
      CopyFile(pchar(filespath + '\' + filesname), PChar(expPath + '\' + filesname), False);

    end;
    files.Free;
  end;
end;

procedure TForm1.ImageEnView3MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  P1 := Point(x, y);
  P2 := P1;
  if button = mbleft then //鼠标左键按下
    pain := True;
end;

procedure TForm1.ImageEnView3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
  P2 := Point(x, y);
  pain := False;
  Lbl4.Caption := IntToStr(p1.x * 2) + ',' + IntToStr(p1.y * 2) + ',' +
    IntToStr(p2.x * 2) + ','
    + IntToStr(p2.y * 2);
  ImageEnView3.IEBitmap.Canvas.Pen.Style := psSolid;
  ImageEnView3.IEBitmap.Canvas.Brush.Style := bsclear;
  ImageEnView3.IEBitmap.Canvas.Pen.Color := clRed;
  ImageEnView3.IEBitmap.Canvas.Pen.Width := 2;
  ImageEnView3.IEBitmap.Canvas.Rectangle(SrcRect);
  ImageEnView3.Update;

end;

procedure TForm1.btn4Click(Sender: TObject);
var
  i:Integer;
begin
    for i := 0 to lst2.Items.Count - 1 do
    begin
      lst2.Items.Clear;
    end;
end;

procedure TForm1.ImageEnView3MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);

begin
  if pain = true then
  begin
    p2 := Point(x, y);
    SrcRect := rect(P1.X * 2, P1.Y * 2, P2.X * 2, P2.Y * 2);

  end;
end;

procedure TForm1.btn5Click(Sender: TObject);
begin
  with ImageEnView1.IO do
  begin
    LoadFromFile(srcfile);
  end;
  ImageEnView1.MouseInteract := [miSelect];
  ImageEnView1.Proc.Crop(P1.X * 2, P1.Y * 2, P2.X * 2, P2.Y * 2);  
end;

end.

