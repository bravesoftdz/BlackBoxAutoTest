unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, FileCtrl, Math, jpeg;

type
  TForm1 = class(TForm)
    img1: TImage;
    lbl1: TLabel;
    lbl2: TLabel;
    btn1: TButton;
    edt1: TEdit;
    lbl3: TLabel;
    btn2: TButton;
    edt2: TEdit;
    lbl4: TLabel;
    lbl5: TLabel;
    edt3: TEdit;
    lbl6: TLabel;
    edt4: TEdit;
    lbl7: TLabel;
    edt5: TEdit;
    lbl8: TLabel;
    dlgOpen1: TOpenDialog;
    edt6: TEdit;
    lbl9: TLabel;
    Label1: TLabel;
    Button1: TButton;
    Edit1: TEdit;
    Label2: TLabel;
    mmo3: TMemo;
    edt7: TEdit;
    lbl10: TLabel;
    lbl11: TLabel;
    edt8: TEdit;
    rb1: TRadioButton;
    rb2: TRadioButton;
    lst1: TListBox;
    lst2: TListBox;
    Label3: TLabel;
    Label4: TLabel;
    btn3: TButton;
    chk1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure img1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure lst2Click(Sender: TObject);
    procedure lst1Click(Sender: TObject);
    procedure img1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btn3Click(Sender: TObject);
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
  ExpRGB: TRGBColor; //预期结果
  DevRGB: TRGBColor; //误差
  CriterionRGB_L: TRGBColor; //基准
  CriterionRGB_H: TRGBColor; //基准
function GetColor(bmp: TBitmap; x, y: integer): TRGBColor;
function RGBToHSV(rgb: TRGBColor): THSVColor;
function Jpg2Bmp(FileName: string): TBitMap;
implementation

uses
  checkThread;

var
  P1, P2: TPoint;

{$R *.dfm}

function Jpg2Bmp(FileName: string): TBitMap;
var
  Jpg: TJpegImage;
begin
  Jpg := TJpegImage.Create;
  Jpg.LoadFromFile(FileName);
  Result := nil;
  if Assigned(Jpg) then //如果Jpg不为空
  begin
    Result := TBitMap.Create;
    Result.Assign(Jpg); //将Jpg指定给TBitMap对象
    Jpg.DIBNeeded; //转换
  end;
  Jpg.Free;
  Jpg := nil;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  mmo3.Clear;
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  with dlgOpen1 do
  begin
    Filter := '图片|*.BMP';
    DefaultExt := 'BMP';
    FileName := '';
    //  Options:='ofHideReadOnly,ofFileMustExist,ofPathMustExist';
    if Execute then
      // ofextensiondifferent in Options then
     //   MessageDlg('这不是图片'，mterror,'mbok',0)
    //  esle
      img1.picture.loadfromfile(FileName);
  end;
end;

procedure TForm1.img1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  P1 := Point(x, y);
  edt1.Text := IntToStr(P1.x) + ',' + IntToStr(P1.y);
  edt6.Text := IntToStr(P1.x) + ',' + IntToStr(P1.y);
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
var
  strlist: TStringList;
  i: integer;
begin
  mmo3.Clear;
  try
    for i := 0 to lst2.items.count - 1 do
      lst2.Items.Clear;
    strlist := SplitString(Form1.edt4.Text, ',');
    ExpRGB.Red := StrToInt(strlist.Strings[0]);
    ExpRGB.Green := StrToInt(strlist.Strings[1]);
    ExpRGB.Blue := StrToInt(strlist.Strings[2]);
    strlist := SplitString(Form1.edt5.Text, ',');
    DevRGB.Red := StrToInt(strlist.Strings[0]);
    DevRGB.Green := StrToInt(strlist.Strings[1]);
    DevRGB.Blue := StrToInt(strlist.Strings[2]);

    if (ExpRGB.Red - devRGB.Red) < 0 then
      CriterionRGB_L.Red := 0
    else
      CriterionRGB_L.Red := (ExpRGB.Red - devRGB.Red);

    if (ExpRGB.Green - devRGB.Green) < 0 then
      CriterionRGB_L.Green := 0
    else
      CriterionRGB_L.Green := (ExpRGB.Green - devRGB.Green);
    if (ExpRGB.Blue - devRGB.Blue) < 0 then
      CriterionRGB_L.Blue := 0
    else
      CriterionRGB_L.Blue := (ExpRGB.Blue - devRGB.Blue);

    if (ExpRGB.Red + devRGB.Red) > 255 then
      CriterionRGB_H.Red := 255
    else
      CriterionRGB_H.Red := (ExpRGB.Red + devRGB.Red);

    if (ExpRGB.Green + devRGB.Green) > 255 then
      CriterionRGB_h.Green := 255
    else
      CriterionRGB_H.Green := (ExpRGB.Green + devRGB.Green);
    if (ExpRGB.Blue + devRGB.Blue) > 255 then
      CriterionRGB_H.Blue := 255
    else
      CriterionRGB_H.Blue := (ExpRGB.Blue + devRGB.Blue);

  finally
    strlist.Free;
  end;
  checkPIC.Create(false);
end;

procedure TForm1.lst2Click(Sender: TObject);
var
  files: TStringList;
begin
  files := SplitString(lst2.Items[lst2.Itemindex], ',');
  try
    img1.Picture.LoadFromFile(filespath + '\' + files[0]);
  finally
    files.Free;
  end;
end;

procedure TForm1.lst1Click(Sender: TObject);
begin
  if sameText(Copy(lst1.Items[lst1.Itemindex], (Length(lst1.Items[lst1.Itemindex]) - 2), 3), 'bmp') then
    img1.Picture.LoadFromFile(filespath + '\' + lst1.Items[lst1.Itemindex])
  else
  begin
    img1.Picture.Assign(Jpg2Bmp(filespath + '\' + lst1.Items[lst1.Itemindex]));
  end;

end;

procedure TForm1.img1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  rgb: TRGBColor;
  HSV: THSVColor;
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  bmp := img1.Picture.Bitmap;
  rgb := GetColor(bmp, P1.X, P1.Y);
  HSV := RGBToHSV(rgb);
  edt2.Text := IntToStr(rgb.red) + ',' + IntToStr(rgb.Green) + ',' + IntToStr(rgb.Blue);
  edt4.Text := edt2.Text;
  edt3.Text := (FloatToStr(HSV.Hue) + '|' + FloatToStr
    (HSV.Saturation) + '|' + FloatToStr(HSV.Brightness));
  edt7.Text := edt3.Text;
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

end.

