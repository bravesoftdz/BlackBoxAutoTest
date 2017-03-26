unit android;

interface

function Android_ScreenCAP(Path: string): Boolean;
procedure Android_Tap(Coordinate: string);
procedure Android_Swipe(Coordinate: string;time:Integer);
implementation

uses
  TypInfo, Windows, Graphics, SysUtils, Forms, Dialogs, DSPack, ExGlobal, Unit1,
  CameraSetUnit, QRcodeUnit, OCRUnit, PaxRegister, IMPORT_Common, DTMFUnit, jpeg, math, PComm, Classes;

function Android_ScreenCAP(Path: string): Boolean;
var
  CMDOut: string;
  FileName: string;
begin

  Mainform.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Executing: Android.ScreenCAP  | ' + path);
  Result := False;
  if (Path[Length(Path)] = '\') then
    Path := Copy(Path, 1, (Length(Path) - 1));
  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\SnapShot');
      ForceDirectories('c:\SnapShot'); //创建文件夹
      Path := 'c:\SnapShot'; //使用默认
    end;
  end;
  FileName := FormatDateTime('yyyymmddhhmmsszzz', now) + '.png';
  path := Path + '\' + FileName;
  MainForm.mmo1.Lines.Add('SnapShot ' + path);
  GetDosOutput(Apppath + 'lib\adb.exe shell screencap -p /sdcard/' + FileName);
  CMDOut := GetDosOutput(Apppath + 'lib\adb.exe pull /sdcard/' + FileName + ' ' + path);
  MainForm.mmo1.Lines.add(CMDOut);
  GetDosOutput(Apppath + 'lib\adb.exe shell rm /sdcard/' + FileName);
  if FileExists(path) then
    Result := True
  else
    MainForm.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Error: AndroidScreenCAP截图保存失败');
end;

procedure Android_Tap(Coordinate: string);
var
  CMDOut: string;
  xy: TStrings;
  x: string;
  y: string;
begin

  Mainform.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Executing: Android_Tap  | ' + Coordinate);

  xy := SplitString(Coordinate, ','); //按','分割字符
  if xy.Count <> 2 then //单个按键动作
  begin
    MainForm.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Error: 坐标参数错误');
    exit;
  end;
  x := xy.Strings[0];
  y := xy.Strings[1];
  CMDOut := GetDosOutput(Apppath + 'lib\adb.exe shell input tap ' + x + ' ' + y);
  MainForm.mmo1.Lines.add(CMDOut);

  xy.Free;

end;


procedure Android_Swipe(Coordinate: string;time:Integer);
var
  CMDOut: string;
  xy: TStrings;
  x1: string;
  y1: string;
  x2: string;
  y2: string;
begin

  Mainform.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Executing: Android_Tap  | ' + Coordinate);

  xy := SplitString(Coordinate, ','); //按','分割字符
  if xy.Count <> 4  then //单个按键动作
  begin
    MainForm.mmo1.Lines.add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'Error: 坐标参数错误');
    exit;
  end;
  x1 := xy.Strings[0];
  y1 := xy.Strings[1];
  x2 := xy.Strings[2];
  y2 := xy.Strings[3];
  CMDOut := GetDosOutput(Apppath + 'lib\adb.exe shell input swipe ' + x1 + ' ' + y1 +' '+ x2 + ' ' + y2 + ' '+inttostr(time) );
  MainForm.mmo1.Lines.add(CMDOut);

  xy.Free;

end;

end.

