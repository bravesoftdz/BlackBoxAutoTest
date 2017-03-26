unit RunScriptUnit;

interface

uses
  Classes;

type
  RunScript = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure Formcanvas;
  end;

implementation

uses
  TypInfo, Windows, Graphics, SysUtils, Forms, Dialogs, DSPack, ExGlobal, Unit1, CameraSetUnit,
  QRcodeUnit, OCRUnit;
type
  TMyStrSel = (KeyPress, KeyDown, KeyUp, Delay, SnapShot, Ring, IO, QR, OCR, GetAveHSV, GetAveRGB);
type
  TScript = packed record //定义个结构
    act: string; //命令
    pars: TStrings; //参数
  end;

var
  Key: array[0..16] of string = (//0-16 按键键值
    'FFFF', 'FEFF', 'FDFF', 'FBFF', 'F7FF', 'EFFF', 'DFFF',
    'BFFF', '7FFF', 'FFFE', 'FFFD', 'FFFB', 'FFF7', 'FFEF', 'FFDF', 'FFBF',
    'FF7F'
    );
  DwrRect: TRect; //画截取图片坐标

procedure DeleteBMPFile(sFileName: string);
begin
  while FileExists(sFileName) do
  begin
    SetFileAttributes(PChar(sFileName), FILE_ATTRIBUTE_ARCHIVE);
    DeleteFile(sFileName)
  end;
end;

function InterpretCMD(tmps: string): TScript;
var
  i: Integer;
  s1: string;
  st: TStringList;
begin
  S1 := tmps;
  //初始化返回值
  if S1 <> '' then
  begin
    {   for i := 1 to 16 do
       begin
         Result.pars[i] := '';
       end;}
    Result.act := '';
    Result.pars := TStringList.Create;
  end;
  st := SplitString(S1, ','); //按','分割字符
  if st.Count > 0 then
  begin
    if st.Strings[0] <> '' then
    begin
      Result.act := st.Strings[0]; //返回命令
      for i := 1 to (st.count - 1) do
      begin
        Result.pars.Add(st.Strings[i]);
      end;
    end;
  end;
  st.Free;
end;

procedure RunScript.Formcanvas;
begin
  VMRRect(CameraSetForm.VideoWindow1, DwrRect);
end;

procedure RunScript.Execute;
var
  strSel: TMyStrSel;
  s0, str: string;
  path: string; //抓拍路径
  cmdstr: string; //发送的数据
  KeydownTime: Integer; //按键按下时间
  KeyIntervalTime: Integer; //按键间隔时间
  MultipleKeys: TStringList; //同时按下的多个按键
  ExpColor: TStringList; //预期颜色值
  DevColor: TStringList; //预期颜色值误差
  ExpTempColor: TStringList; //预期颜色值临时
  ColorAL: Integer; //预期最小值，最大值
  ColorBL: Integer;
  ColorCL: Integer;
  ColorAH: Integer;
  ColorBH: Integer;
  ColorCH: Integer;
  ImgPath: string; //QR图片文件路径
  QRPicPath: string; //截取的QR图片路径
  QRresult: string; //QR解码结果
  OCRtext: string; //文字识别结果
  SocBMP: TBitmap; //源图片
  bmp: TBitmap; //QR,
  SrcRect: TRect; //截取图片的坐标
  funcStr: TScript; //脚本函数解析
  i, j, k: integer;
  keyint: Integer; //多键值计算临时变量
  testtimes: Integer; //测试次数
  finshtimes: Integer; //完成次数
  ColorRGB: TRGBColor; //颜色RGB
  ColorHSV: THSBColor; //颜色HSV
begin
  // S0:='OCR,1,CCD VIDEO,123,456,789,098';
  FreeOnTerminate := True;
  testtimes := StrToInt(MainForm.Edit1.text);
  MainForm.mmo2.Enabled := False;
  while not ScripThreadExit do
  begin
    Sleep(1);
    for k := 0 to MainForm.mmo2.Lines.Count - 1 do
    begin
      if MainForm.mmo2.Lines.Strings[k] <> '' then
      begin
        s0 := MainForm.mmo2.Lines.Strings[k];
        funcStr := InterpretCMD(s0);
        with funcStr do
        begin
          if ScripThreadExit then
            Break;
          str := act;
          strSel := TMyStrSel(GetEnumValue(TypeInfo(TMystrsel), str));
          case strSel of
            KeyPress: //按键控制
              begin
                MainForm.mmo1.Lines.Add('[info] ' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + 'Executing:' + s0);
                MultipleKeys := TStringList.Create;
                keyIntervalTime := StrToInt(pars[pars.Count - 1]); //间隔时间
                pars.Delete(pars.Count - 1); // 去除时间
                keydownTime := StrToInt(pars[pars.Count - 1]); //按下时间
                pars.Delete(pars.Count - 1); //去除时间
                for i := 0 to pars.Count - 1 do
                begin
                  if Pos('|', pars[i]) > 0 then //多个按键同时按下
                  begin
                    MultipleKeys := SplitString(pars[i], '|'); //按'|'分割字符
                    keyint := $FFFFF;
                    for j := 0 to MultipleKeys.Count - 1 do
                    begin
                      keyint := keyint and strtoint('$' +
                        Key[GetNum(MultipleKeys[j])]);
                    end;
                    cmdstr := '55FF02B1' + IntToHex(keyint, 4);
                  end
                  else //单个按键
                  begin
                    cmdstr := '55FF02B1' + Key[GetNum(pars[i])]; //按键按下
                  end;
                  SendStrhex(Com1, cmdstr);
                  while true do //等待数据接收
                  begin
                    sleep(10);
                    if sendOK then // 发送成功
                    begin
                      MainForm.mmo1.Lines.Add(cmdstr + '发送成功');
                      Break; //
                    end;
                    if sendNG then // 发送无应答
                    begin
                      MainForm.mmo1.Lines.Add('[error] ' + cmdstr + '发送失败');
                      break;
                    end;
                  end;
                  Delayms(keydownTime);
                  cmdstr := '55FF02B1FFFF'; //按键释放
                  SendStrhex(Com1, cmdstr);
                  while true do //等待数据接收
                  begin
                    sleep(10);
                    if sendOK then // 发送成功
                    begin
                      MainForm.mmo1.Lines.Add(cmdstr + '发送成功');
                      Break; //
                    end;
                    if sendNG then // 发送无应答
                    begin
                      MainForm.mmo1.Lines.Add('[error] ' + cmdstr + '发送失败');
                      break;
                    end;
                  end;
                  Delayms(keyIntervalTime);
                end;
                MultipleKeys.Free;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            KeyDown: //按键按下
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                if pars.Count < 2 then //单个按键动作
                begin
                  cmdstr := '55FF02B1' + Key[GetNum(pars[0])];
                end
                else //多个按键同时动作
                begin
                  keyint := $FFFFF;
                  for i := 0 to pars.Count - 1 do
                  begin
                    keyint := keyint and strtoint('$' + Key[GetNum(pars[i])]);
                  end;
                  cmdstr := '55FF02B1' + IntToHex(keyint, 4);
                end;
                SendStrhex(Com1, cmdstr);
                while true do //等待数据接收
                begin
                  sleep(10);
                  if sendOK then // 发送成功
                  begin
                    MainForm.mmo1.Lines.Add(cmdstr + '发送成功');
                    Break; //
                  end;
                  if sendNG then // 发送无应答
                  begin
                    MainForm.mmo1.Lines.Add(cmdstr + '发送失败');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            KeyUp: //按键释放
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                cmdstr := '55FF02B1FFFF';
                SendStrhex(Com1, cmdstr);
                while true do //等待数据接收
                begin
                  sleep(10);
                  if sendOK then // 发送成功
                  begin
                    MainForm.mmo1.Lines.Add(s0 + '发送成功');
                    Break; //
                  end;
                  if sendNG then // 发送无应答
                  begin
                    MainForm.mmo1.Lines.Add(s0 + '发送失败');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            Delay: //延时
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                Delayms(GetNum(pars[0]));
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            SnapShot: //抓拍
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                if (pars[1][Length(pars[1])] = '\') then
                  pars[1] := Copy(pars[1], 1, (Length(pars[1]) - 1));
                if not DirectoryExists(pars[1]) then
                  //判断文件夹是否存在，不存在则创建文件夹
                begin
                  ForceDirectories(pars[1]); //创建文件夹
                  if not DirectoryExists(pars[1]) then
                    //创建文件夹错误，使用默认文件夹
                  begin
                    MainForm.mmo1.Lines.Add('Err: ' + pars[1] + ' 不能创建');
                    ForceDirectories('c:\SnapShot'); //创建文件夹
                    pars[1] := 'c:\SnapShot'; //使用默认
                  end;
                end;
                path := pars[1] + '\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) + '.bmp';
                MainForm.mmo1.Lines.Add('SnapShot ' + path);
                CameraSetUnit.CMSnapShot(GetNum(pars[0]), path); //抓图
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            Ring:
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                cmdstr := '55FF02B20000';
                SendStrhex(Com1, cmdstr);
                while true do //等待数据接收
                begin
                  sleep(1);
                  if sendOK then // 发送成功
                  begin
                    if (Rec_DATA[1] = StrToInt(pars[0])) and (Rec_DATA[2] = StrToInt(pars[1])) then
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '返回:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2]) + ' 检测OK');
                    end
                    else
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '返回:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2]) + ' 检测NG');
                    end;
                    Break; //
                  end;
                  if sendNG then // 发送无应答
                  begin
                    MainForm.mmo1.Lines.Add(s0 + '通讯无应答');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            IO:
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                cmdstr := '55FF04B500000000';
                SendStrhex(Com1, cmdstr);
                while true do //等待数据接收
                begin
                  sleep(10);
                  if sendOK then // 发送成功
                  begin
                    if (Rec_DATA[1] = StrToInt(pars[0])) and (Rec_DATA[2] = StrToInt(pars[1])) and
                      (Rec_DATA[3] = StrToInt(pars[2])) and (Rec_DATA[4] = StrToInt(pars[3])) then
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '返回:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2]) +
                        ',' + inttostr(Rec_Data[3]) + ',' + inttostr(Rec_Data[4]) + ' 检测OK');
                    end
                    else
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '返回:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2])
                        + ',' + inttostr(Rec_Data[3]) + ',' +
                        inttostr(Rec_Data[4]) + ' 检测NG');
                    end;
                    Break; //
                  end;
                  if sendNG then // 发送无应答
                  begin
                    MainForm.mmo1.Lines.Add(s0 + '通讯无应答');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            QR: //QRcode解码
              begin
                try
                  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                  ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) + '_' + pars[0] + '.bmp'; //解码的图片
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //图像抓拍，内存中
                  if pars.Count > 2 then
                  begin
                    QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_QR.bmp';
                    SrcRect := Rect(strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4]), strtoint(pars[5])); //截取坐标
                    DwrRect := Rect(strtoint(pars[2]) div 2, strtoint(pars[3]) div 2, strtoint(pars[4]) div 2, strtoint(pars[5]) div 2); //截取的区域坐标
                    Synchronize(Formcanvas); //视频区显示截取的区域
                    bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
                    CameraSetForm.image1.Picture.Bitmap.Assign(bmp); //显示截取的图片
                    bmp.SaveToFile(QRPicPath); //保存截取的图片
                    QRresult := DecodeFile(QRPicPath);
                  end
                  else
                  begin
                    CMSnapShot(strtoint(pars[0]), ImgPath); //抓拍图像
                    QRresult := DecodeFile(ImgPath);
                  end;
                  if sameText(QRresult, pars[1]) then
                  begin
                    MainForm.mmo1.Lines.Add('返回:' + QRresult + ' 检测OK');
                    DeleteBMPFile(ImgPath); //检测成功，删除文件
                    DeleteBMPFile(QRPicPath);
                  end
                  else
                  begin
                    MainForm.mmo1.Lines.Add('返回:' + QRresult + ' 检测NG');
                  end;
                finally
                  bmp.Free; //释放内存
                  SocBMP.free;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            OCR: //文字识别
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                bmp := TBitmap.Create;
                try
                  ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) + '_' + pars[0] + '.bmp'; //文字识别图片路径
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //图像抓拍，内存中
                  if pars.Count > 2 then
                  begin
                    QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_OCR.bmp';
                    SrcRect := Rect(strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4]), strtoint(pars[5])); //截取坐标
                    DwrRect := Rect(strtoint(pars[2]) div 2, strtoint(pars[3]) div 2, strtoint(pars[4]) div 2, strtoint(pars[5]) div 2);
                    Synchronize(Formcanvas); //视频区显示截取的区域
                    bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
                    ruihua(bmp); //图片锐化
                    BMPbinary(bmp); //图片二值化
                    bmp.SaveToFile(QRPicPath); //保存截取的图片
                    CameraSetForm.image1.Picture.LoadFromFile(QRPicPath); //显示截取的图片
                    OCRtext := OCRdetection(QRPicPath); //OCR
                  end;
                  if sameText(OCRtext, pars[1]) then
                  begin
                    MainForm.mmo1.Lines.Add('返回:' + OCRtext + ' 检测OK');
                   // DeleteBMPFile(ImgPath); //检测成功，删除文件
                    DeleteBMPFile(QRPicPath); //检测成功，删除文件
                  end
                  else
                  begin
                    MainForm.mmo1.Lines.Add('返回:' + OCRtext + ' 检测NG' + #13#10 + ImgPath);
                    SocBMP.SaveToFile(ImgPath); //保存抓拍的图片
                  end;
                finally
                  bmp.Free; //释放内存
                  SocBMP.Free;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            GetAveRGB: //颜色检测，获取范围(x1,y1,x2,y2)RGB颜色的均值
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                try
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //图像抓拍，内存中
                  SrcRect := Rect(strtoint(pars[1]), strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4])); //颜色区域
                  ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
                finally
                  SocBMP.Free;
                end;
                if Pos('-', pars[5]) > 0 then // 字符串是否包含-，有则有偏色参数
                begin
                  try
                    ExpTempColor := SplitString(pars[5], '-'); //按'-'分割字符
                    ExpColor := SplitString(ExpTempColor[0], '.');
                    DevColor := SplitString(ExpTempColor[1], '.');
                    if (StrToInt(ExpColor[0]) - StrToInt(DevColor[0])) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) - StrToInt(DevColor[1])) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) - StrToInt(DevColor[2])) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - StrToInt(DevColor[2]);

                    if (StrToInt(ExpColor[0]) + StrToInt(DevColor[0])) > 255 then
                      ColorAH := 255
                    else
                      ColorAH := StrToInt(ExpColor[0]) + StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) + StrToInt(DevColor[1])) > 255 then
                      ColorBH := 255
                    else
                      ColorBH := StrToInt(ExpColor[1]) + StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) + StrToInt(DevColor[2])) > 255 then
                      ColorCH := 255
                    else
                      ColorCH := StrToInt(ExpColor[2]) + StrToInt(DevColor[2]);
                    if (ColorRGB.Red >= ColorAL) and (ColorRGB.Red <= ColorAH) and
                      (ColorRGB.Green >= ColorBL) and (ColorRGB.Green <= ColorBH) and
                      (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '返回：' + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue) + '测试OK')
                    else
                      MainForm.mmo1.Lines.Add(FormatDateTime('[error]' + 'yyyy/mm/dd hh:mm:ss.zzz ', now) + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue));
                  finally
                    ExpTempColor.Free;
                    ExpColor.Free;
                    DevColor.Free;
                  end;
                end
                else //颜色不包含偏值参数
                begin
                  try
                    ExpColor := SplitString(pars[5], '.');
                    if (StrToInt(ExpColor[0]) - 10) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - 10;
                    if (StrToInt(ExpColor[1]) - 10) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - 10;
                    if (StrToInt(ExpColor[2]) - 10) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - 10;

                    if (StrToInt(ExpColor[0]) + 10) > 255 then
                      ColorAH := 255
                    else
                      ColorAH := StrToInt(ExpColor[0]) + 10;
                    if (StrToInt(ExpColor[1]) + 10) > 255 then
                      ColorBH := 255
                    else
                      ColorBH := StrToInt(ExpColor[1]) + 10;
                    if (StrToInt(ExpColor[2]) + 10) > 255 then
                      ColorCH := 255
                    else
                      ColorCH := StrToInt(ExpColor[2]) + 10;
                    if (ColorRGB.Red >= ColorAL) and (ColorRGB.Red <= ColorAH) and
                      (ColorRGB.Green >= ColorBL) and (ColorRGB.Green <= ColorBH) and
                      (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '返回：' + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue) + '测试OK')
                    else
                      MainForm.mmo1.Lines.Add(FormatDateTime('[error]' + 'yyyy/mm/dd hh:mm:ss.zzz ', now) + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue));
                  finally
                    ExpColor.Free;
                  end;
                end;
              end;
            GetAveHSV: //颜色检测，获取范围(x1,y1,x2,y2)HSV颜色的均值
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                try
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //图像抓拍，内存中
                  SrcRect := Rect(strtoint(pars[1]), strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4])); //颜色区域
                  ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
                  ColorHSV := RGBToHSV(colorRGB);
                finally
                  SocBMP.Free;
                end;
                if Pos('-', pars[5]) > 0 then // 字符串是否包含-，有则有偏色参数
                begin
                  try
                    ExpTempColor := SplitString(pars[5], '-'); //按'-'分割字符
                    ExpColor := SplitString(ExpTempColor[0], '.');
                    DevColor := SplitString(ExpTempColor[1], '.');
                    if (StrToInt(ExpColor[0]) - StrToInt(DevColor[0])) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) - StrToInt(DevColor[1])) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) - StrToInt(DevColor[2])) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - StrToInt(DevColor[2]);

                    if (StrToInt(ExpColor[0]) + StrToInt(DevColor[0])) > 360 then
                      ColorAH := 360
                    else
                      ColorAH := StrToInt(ExpColor[0]) + StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) + StrToInt(DevColor[1])) > 100 then
                      ColorBH := 100
                    else
                      ColorBH := StrToInt(ExpColor[1]) + StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) + StrToInt(DevColor[2])) > 100 then
                      ColorCH := 100
                    else
                      ColorCH := StrToInt(ExpColor[2]) + StrToInt(DevColor[2]);
                    if (ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAH) and
                      (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH) and
                      (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '返回：' + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness) + '测试OK')
                    else
                      MainForm.mmo1.Lines.Add('[error] ' +FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness));
                  finally
                    ExpTempColor.Free;
                    ExpColor.Free;
                    DevColor.Free;
                  end;
                end
                else //颜色不包含偏值参数
                begin
                  try
                    ExpColor := SplitString(pars[5], '.');
                    if (StrToInt(ExpColor[0]) - 10) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - 10;
                    if (StrToInt(ExpColor[1]) - 10) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - 10;
                    if (StrToInt(ExpColor[2]) - 10) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - 10;

                    if (StrToInt(ExpColor[0]) + 10) > 360 then
                      ColorAH := 360
                    else
                      ColorAH := StrToInt(ExpColor[0]) + 10;
                    if (StrToInt(ExpColor[1]) + 10) > 100 then
                      ColorBH := 100
                    else
                      ColorBH := StrToInt(ExpColor[1]) + 10;
                    if (StrToInt(ExpColor[2]) + 10) > 100 then
                      ColorCH := 100
                    else
                      ColorCH := StrToInt(ExpColor[2]) + 10;
                    if (ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAL) and
                      (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH) and
                      (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '返回：' + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness) + '测试OK')
                    else
                      MainForm.mmo1.Lines.Add('[error] ' +FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness));
                  finally
                    ExpColor.Free;
                  end;
                end;
              end;
          end;
        end;
        funcStr.pars.free;
      end;
    end;
    finshtimes := finshtimes + 1;
    MainForm.Edit2.text := IntToStr(finshtimes);
    if finshtimes >= testtimes then
      ScripThreadExit := True;
  end;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '测试结束' + #13#10);
  MainForm.btnRun.Enabled := True;
end;

end.

