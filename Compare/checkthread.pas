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
function SplitString(const source, ch: string): tstringlist; //按Ch 分割字符串
implementation

uses
  Dialogs, SysUtils, Graphics, Unit1, ImageEnProc, hyiedefs;

var
  x, y: Integer;
  s0: string;
  psI: Integer;

function SplitString(const source, ch: string): tstringlist; //按Ch 分割字符串
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
  ww, hh: integer;
  v: double;
begin
  // adjust sizes (make ImageEnView1=ImageEnView2)
  with form1 do
  begin
    with ImageEnView2.IO do
    begin
      LoadFromFile(filespath + '\' + s0);
      ImageEnView4.IO.LoadFromFile(filespath + '\' + s0);
      ImageEnView2.Proc.Crop(P1.X * 2, P1.Y * 2, P2.X * 2, P2.Y * 2);
    end;
    ww := ImageEnView1.Bitmap.Width;
    hh := ImageEnView1.Bitmap.Height;
    if (ww <> ImageEnView2.Bitmap.Width) or (hh <> ImageEnView2.Bitmap.Height) then
      ImageEnView2.Proc.Resample(ww, hh, rfNone);
    //
    v := ImageEnView1.Proc.CompareWith(ImageEnView2.IEBitmap, nil);

    if rb1.Checked then
    begin
      if (v * 100) <= StrToFloat(edt6.Text) then
      begin
        lst2.Items.Add(s0 + ',' + inttostr(psI));
        label4.Caption := inttostr(lst2.Items.Count); //显示失败数
      end;
    end
    else
    begin
      if (v * 100) >= StrToFloat(edt6.Text) then
      begin
        lst2.Items.Add(s0 + ',' + inttostr(psI));
        label4.Caption := inttostr(lst2.Items.Count); //显示失败数
      end;

    end;
    form1.mmo3.Lines.Add(s0 + ' 相似度: ' + floattostr(v * 100) + ' %');
  end;
  {
  try

    rgb := GetColor(bmp, x, y);
    HSV := RGBToHSV(rgb);
    Form1.mmo3.Lines.Add(s0 + ' 坐标:' + inttostr(x) + ',' + inttostr(y) + ' RGB:=' + inttostr(rgb.Red) + ',' + inttostr(rgb.Green) + ',' + inttostr(rgb.Blue)
      + ' HSV:' + (FloatToStr(HSV.Hue) + ',' + FloatToStr(HSV.Saturation) + ',' + FloatToStr(HSV.Brightness))
      );
    if not ((rgb.Red > CriterionRGB_L.Red) and (rgb.Red < CriterionRGB_H.Red) and
      (rgb.Green > CriterionRGB_L.Green) and (rgb.Green < CriterionRGB_H.Green) and
      (rgb.Blue > CriterionRGB_L.Blue) and (rgb.Blue < CriterionRGB_H.Blue)) then
    begin
      Form1.lst2.Items.Add(s0 + ',' + inttostr(psI));
      Form1.label4.Caption := inttostr(Form1.lst2.Items.Count); //显示失败数
    end;
  finally
    bmp.Free;
  end;   }
end;

procedure checkPIC.Execute;
var
  i: integer;

  tempstr: TStringList;

begin

  { tempstr := SplitString(Form1.edt6.Text, ',');
   if (tempstr.Count > 0) and (tempstr.Count < 3) then
   begin
     x := StrToInt(tempstr.Strings[0]);
     y := StrToInt(tempstr.Strings[1]);
     tempstr.Free;
   end
   else
   begin
     ShowMessage('坐标错');
     Exit;
   end;
         }
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

