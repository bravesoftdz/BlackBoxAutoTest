unit checkthread;

interface

uses
  Classes;

type
  checkPIC = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure ShowData2;
  end;
function SplitString(const source, ch: string): tstringlist; //°´Ch ·Ö¸î×Ö·û´®
implementation

uses
  Dialogs, SysUtils, Graphics, Unit1, jpeg;

var
  x, y: Integer;
  s0: string;
  psI: Integer;

function SplitString(const source, ch: string): tstringlist; //°´Ch ·Ö¸î×Ö·û´®
var
  temp: string;
  i: integer;
begin
  result := tstringlist.Create;
  temp := source;
  i := pos(ch, source);
  while i <> 0 do
  begin
    result.Add(copy(temp, 0, i - 1));
    delete(temp, 1, i);
    i := pos(ch, temp);
  end;
  result.Add(temp);
end;

procedure checkPIC.ShowData2;
var
  rgb: TRGBColor;
  HSV: THSVColor;
  bmp: TBitmap;
  jpeg: TJPEGImage;
begin
  jpeg := TJPEGImage.Create;
  bmp := tbitmap.Create;
  try


    if sameText(Copy(s0, (Length(s0) - 2), 3), 'bmp') then
      bmp.LoadFromFile(filespath + '\' + s0)
    else
    begin

     //bmp.Assign(Jpg2Bmp(filespath + '\' + s0));
      try
        jpeg.LoadFromFile(filespath + '\' + s0);
        bmp.Assign(jpeg);
      finally
        jpeg.free
      end;
    end;


    Form1.img1.Picture.Assign(bmp);
    rgb := GetColor(bmp, x, y);
    HSV := RGBToHSV(rgb);
    Form1.mmo3.Lines.Add(s0 + ' ×ø±ê:' + inttostr(x) + ',' + inttostr(y) + ' RGB:=' + inttostr(rgb.Red) + ',' + inttostr(rgb.Green) + ',' + inttostr(rgb.Blue)
      + ' HSV:' + (FloatToStr(HSV.Hue) + ',' + FloatToStr(HSV.Saturation) + ',' + FloatToStr(HSV.Brightness))
      );

    if Form1.chk1.Checked then
    begin
      if  ((rgb.Red >= CriterionRGB_L.Red) and (rgb.Red <= CriterionRGB_H.Red) and
        (rgb.Green >= CriterionRGB_L.Green) and (rgb.Green <= CriterionRGB_H.Green) and
        (rgb.Blue >= CriterionRGB_L.Blue) and (rgb.Blue <= CriterionRGB_H.Blue)) then
      begin
        Form1.lst2.Items.Add(s0 + ',' + inttostr(psI));
        Form1.label4.Caption := inttostr(Form1.lst2.Items.Count); //ÏÔÊ¾Ê§°ÜÊý
      end;
    end
    else
    begin
      if not ((rgb.Red >= CriterionRGB_L.Red) and (rgb.Red <= CriterionRGB_H.Red) and
        (rgb.Green >= CriterionRGB_L.Green) and (rgb.Green <= CriterionRGB_H.Green) and
        (rgb.Blue >= CriterionRGB_L.Blue) and (rgb.Blue <= CriterionRGB_H.Blue)) then
      begin
        Form1.lst2.Items.Add(s0 + ',' + inttostr(psI));
        Form1.label4.Caption := inttostr(Form1.lst2.Items.Count); //ÏÔÊ¾Ê§°ÜÊý
      end;
    end;


  finally
    bmp.Free;
  end;
end;

procedure checkPIC.Execute;
var
  i: integer;

  tempstr: TStringList;

begin

  tempstr := SplitString(Form1.edt6.Text, ',');
  if (tempstr.Count > 0) and (tempstr.Count < 3) then
  begin
    x := StrToInt(tempstr.Strings[0]);
    y := StrToInt(tempstr.Strings[1]);
    tempstr.Free;
  end
  else
  begin
    ShowMessage('×ø±ê´í');
    Exit;
  end;

  for i := 0 to Form1.lst1.Count - 1 do
  begin
    if Form1.lst1.items[i] <> '' then
    begin
      s0 := Form1.lst1.items[i];
      Form1.mmo3.Lines.Add(IntToStr(i + 1) + ':');
      psI := i + 1;
      Synchronize(ShowData2);
    end;
  end;

end;

end.

