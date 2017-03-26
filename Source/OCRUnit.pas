unit OCRUnit;

interface
function OCRdetection(pic_name: string): string;

implementation

uses
  Windows, SysUtils, ExGlobal, Unit1;



function OCRdetection(pic_name: string): string;
var
  OCRresulttxt: string;
  OCRout: string;
  F: TextFile;
begin
  OCRresulttxt := Apppath + 'tesseract\OCRresult'; //OCR输出文件名
  OCRout := GetDosOutput(Apppath + 'tesseract\tesseract.exe' + ' ' + pic_name + ' ' + OCRresulttxt);
  MainForm.mmo1.Lines.add(OCRout);
  if FileExists(Apppath + 'tesseract\OCRresult.txt') then
  begin
    AssignFile(F, Apppath + 'tesseract\OCRresult.txt');
    Reset(F);
    Readln(F, result);
    CloseFile(F);
    DeleteFile(Apppath + 'tesseract\OCRresult.txt');
  end
  else
    Result := '';
end;

end.

