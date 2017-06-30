unit android;

interface

function Android_ScreenCAP(Device:string;Path: string): Boolean;
procedure Android_Tap(Device:string;Coordinate: string);
procedure Android_Swipe(Device:string;Coordinate: string;time:Integer);
implementation

uses
  TypInfo, Windows, Graphics, SysUtils, Forms, Dialogs, DSPack, ExGlobal, Unit1,
  CameraSetUnit, QRcodeUnit, OCRUnit, PaxRegister, IMPORT_Common, DTMFUnit, jpeg, math, PComm, Classes, 
  adbunit;

function Android_ScreenCAP(Device:string;Path: string): Boolean;
var
  CMDOut: string;
  FileName: string;
begin

  Mainform.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Executing: Android.ScreenCAP  | '+Device + path);
  Result := False;
  if (Path[Length(Path)] = '\') then
    Path := Copy(Path, 1, (Length(Path) - 1));
  if not DirectoryExists(Path) then //�ж��ļ����Ƿ���ڣ��������򴴽��ļ���
  begin
    ForceDirectories(Path); //�����ļ���
    if not DirectoryExists(Path) then //�����ļ��д���ʹ��Ĭ���ļ���
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' ���ܴ���,ʹ��C:\SnapShot');
      ForceDirectories('c:\SnapShot'); //�����ļ���
      Path := 'c:\SnapShot'; //ʹ��Ĭ��
    end;
  end;
  FileName := FormatDateTime('yyyymmddhhmmsszzz', now) + '.png';
  path := Path + '\' + FileName;
  MainForm.mmo1.Lines.Add('SnapShot ' + path);
  GetDosOutput(ADBpath + ' -s '+Device + ' shell screencap /sdcard/' + FileName);
  CMDOut := GetDosOutput(ADBpath+' -s '+ Device + ' pull /sdcard/' + FileName + ' ' + path);
  MainForm.mmo1.Lines.add(CMDOut);
  GetDosOutput(ADBpath + ' -s '+Device +' shell rm /sdcard/' + FileName);
  if FileExists(path) then
    Result := True
  else
    MainForm.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Error: AndroidScreenCAP��ͼ����ʧ��');
end;

procedure Android_Tap(Device:string;Coordinate: string);
var
  CMDOut: string;
  xy: TStrings;
  x: string;
  y: string;
begin

  Mainform.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Executing: Android_Tap  | '+Device + Coordinate);

  xy := SplitString(Coordinate, ','); //��','�ָ��ַ�
  if xy.Count <> 2 then //������������
  begin
    MainForm.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Error: �����������');
    exit;
  end;
  x := xy.Strings[0];
  y := xy.Strings[1];
  CMDOut := GetDosOutput(ADBpath + ' -s '+Device + ' shell input tap ' + x + ' ' + y);
  MainForm.mmo1.Lines.add(CMDOut);

  xy.Free;

end;


procedure Android_Swipe(Device:string;Coordinate: string;time:Integer);
var
  CMDOut: string;
  xy: TStrings;
  x1: string;
  y1: string;
  x2: string;
  y2: string;
begin

  Mainform.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Executing: Android_Tap  | '+Device + Coordinate);

  xy := SplitString(Coordinate, ','); //��','�ָ��ַ�
  if xy.Count <> 4  then //������������
  begin
    MainForm.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Error: �����������');
    exit;
  end;
  x1 := xy.Strings[0];
  y1 := xy.Strings[1];
  x2 := xy.Strings[2];
  y2 := xy.Strings[3];
  CMDOut := GetDosOutput(ADBpath + ' -s '+Device + ' shell input swipe ' + x1 + ' ' + y1 +' '+ x2 + ' ' + y2 + ' '+inttostr(time) );
  MainForm.mmo1.Lines.add(CMDOut);

  xy.Free;

end;

end.

