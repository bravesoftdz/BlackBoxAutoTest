unit RunPASScript;

interface

uses
  Classes;

type
  PascalScript = class(TThread)
  private
    { Private declarations }
    TS: Boolean; //测试结果


    testtimes: Int64; //测试次数
  protected
    procedure Execute; override;
    procedure Formcanvas2;
  end;
var
  finshtimes: Int64; //完成次数
    Pass: Int64;
    Fail: int64;
    listID: int64;

implementation

uses
  TypInfo, Windows, Graphics, SysUtils, Forms, Dialogs, DSPack, ExGlobal, Unit1,
  CameraSetUnit, QRcodeUnit, OCRUnit, PaxRegister, IMPORT_Common, DTMFUnit,
  jpeg, math, PComm, android, DeviceComunicationLog, CoolTrayIcon,
  DeviceLog, LogTh, PerlRegEx, audioSetting, Bass, AudioOutUnit, CardSet,IdSSLOpenSSL,IdIOHandlerSocket,
  IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdMessage, IdComponent, IdIOHandler, AutoSaveUnit, facedetectUnit, U_Main;
{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure Script.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ Script }

var
  Key: array[0..16] of string = (//0-16 按键键值
    'FFFF', 'FEFF', 'FDFF', 'FBFF', 'F7FF', 'EFFF', 'DFFF',
    'BFFF', '7FFF', 'FFFE', 'FFFD', 'FFFB', 'FFF7', 'FFEF', 'FFDF', 'FFBF',
    'FF7F'
    );

  DwrRect: TRect; //画截取图片坐标
  WavSavePath: string = ''; //  CallingChannel 音频保存的设置路径
const
  Calling = 1; //主呼通道
  Responding = 2; //应答通道
  Duplexing = 3; //双工

procedure PascalScript.Formcanvas2;
begin
  VMRRect(CameraSetForm.VideoWindow1, DwrRect);
  MainForm.Edit2.text := IntToStr(finshtimes);
  MainForm.edt1.Text := IntToStr(Fail);
  MainForm.TrayIcon1.ShowBalloonHint('测试中...',
    '完成：' + inttostr(finshtimes) + #13 +
    '通过：' + inttostr(Pass) + #13 +
    '失败：' + inttostr(Fail) + #13,
    bitInfo, 60);
end;

//接收1个字符，转换成功输出字符对应的数，转换失败输出-1

function hex(c: char): integer;
var
  x: integer;
begin
  //if c='' then
    //x:=0
  //else
  if (ord(c) >= ord('0')) and (ord(c) <= ord('9')) then
    x := ord(c) - ord('0')
  else if (ord(c) >= ord('a')) and (ord(c) <= ord('f')) then
    x := ord(c) - ord('a') + 10
  else if (ord(c) >= ord('A')) and (ord(c) <= ord('F')) then
    x := ord(c) - ord('A') + 10
  else
    x := -1;
  result := x;
end;

function strtobcd(s: string): integer;

var
  tmpint1, tmpint2: integer;
begin
  if length(s) = 1 then
  begin
    result := hex(s[1]);
  end
  else
  begin
    if length(s) = 2 then
    begin
      tmpint1 := hex(s[1]);
      tmpint2 := hex(s[2]);
      if (tmpint1 = -1) or (tmpint2 = -1) then
      begin
        result := -1;
      end
      else
      begin
        result := tmpint1 * 16 + tmpint2;
      end;
    end
    else
    begin
      result := -1;
    end;
  end;
end;

procedure GenerateCRC8(value: byte; var CrcValue: byte);
var
  CRC: word;
begin
  crc := crcvalue xor value;
  crc := crc xor (crc shl 1) xor (crc shl 2) xor (crc shl 3) xor (crc shl 4)
    xor (crc shl 5) xor (crc shl 6) xor (crc shl 7);
  crc := (crc and $FE) xor ((crc shr 8) and $01);
  crcValue := Crc;
end;

function GetCrc8(AStr: string): Byte;
var
  i: integer;
  len: Integer;
  count: integer;
  strtempsend: string;
begin
  strtempsend := '';
  i := 1;
  len := length(AStr);
  while i < len do
  begin
    try
      strtempsend := strtempsend + chr(strtobcd(copy(AStr, i, 2)));
       i:=i+2;
    except
    end;
  end;
  AStr := strtempsend;

  count := length(AStr);
  result := 0;
  for i := 1 to count do
    GenerateCRC8(ord(Astr[i]), result);
  result := result xor $FF;
end;

procedure DeleteBMPFile(sFileName: string);
begin
  while FileExists(sFileName) do
  begin
    SetFileAttributes(PChar(sFileName), FILE_ATTRIBUTE_ARCHIVE);
    DeleteFile(sFileName)
  end;
end;

function KeyPress(Keys: string; DownTime: Integer; Interval: Integer): Boolean;
  //按键控制
var
  MultipleKeys: TStrings;
  pars: TStrings;
  i: Integer;
  j: Integer;
  keyint: Integer; //多键值计算临时变量
  cmdstr: string; //发送的数据
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'KeyPress ' + Keys
    + ' DownDelay:' + inttostr(DownTime) + ' Interval:' + inttostr(Interval));
  pars := SplitString(Keys, ','); //按','分割字符
  if pars.Count > 0 then //判断Keys是否为空,不为空则执行按键解析
  begin
    for i := 0 to pars.Count - 1 do
    begin
      if Pos('|', pars[i]) > 0 then //多个按键同时按下
      begin
        MultipleKeys := SplitString(pars[i], '|'); //按'|'分割字符
        keyint := $FFFFF;
        for j := 0 to MultipleKeys.Count - 1 do
        begin
          keyint := keyint and strtoint('$' + Key[GetNum(MultipleKeys[j])]);
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
        sleep(1);
        if sendOK then // 发送成功
        begin
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + 'info: ' + cmdstr + '发送成功');
          Result := True;
          Break; //
        end;
        if sendNG then // 发送无应答
        begin
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + 'error: ' + cmdstr + '发送失败');
          break;
        end;
      end;
      Delayms(DownTime); //按键按下时间
      cmdstr := '55FF02B1FFFF'; //按键释放
      SendStrhex(Com1, cmdstr);
      while true do //等待数据接收
      begin
        sleep(1);
        if sendOK then // 发送成功
        begin
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + 'info: ' + cmdstr + '发送成功');
          Result := True;
          Break; //
        end;
        if sendNG then // 发送无应答
        begin
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + 'error: ' + cmdstr + '发送失败');
          break;
        end;
      end;
      Delayms(Interval); //按按间隔时间
    end;
  end;
  pars.Free;
  MultipleKeys.Free;
end;

function KeyDown(Keys: string): Boolean; //按键按下
var
  pars: TStrings;
  keyint, i: Integer; //多键值计算临时变量
  cmdstr: string; //发送的数据
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'KeyDown ' + Keys);
  pars := SplitString(Keys, ','); //按','分割字符
  if pars.Count < 2 then //单个按键动作
  begin
    cmdstr := '55FF02B1' + Key[GetNum(Keys)];
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
    sleep(1);
    if sendOK then // 发送成功
    begin
      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
        'info: ' + cmdstr + '发送成功');
      Result := True;
      Break; //
    end;
    if sendNG then // 发送无应答
    begin
      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
        'error: ' + cmdstr + '发送失败');
      break;
    end;
  end;
end;

function KeyUp(): Boolean; //按键释放
var
  cmdstr: string; //发送的数据
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'KeyUp() ');
  cmdstr := '55FF02B1FFFF';
  SendStrhex(Com1, cmdstr);
  while true do //等待数据接收
  begin
    sleep(1);
    if sendOK then // 发送成功
    begin
      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
        'info: KeyUp 发送成功');
      Result := True;
      Break; //
    end;
    if sendNG then // 发送无应答
    begin
      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
        'error: KeyUp 发送失败');
      break;
    end;
  end;
end;

function IO(IO1, IO2, IO3, IO4: Integer): Boolean;
var
  cmdstr: string; //发送的数据
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'IO ' + inttostr(IO1) + inttostr(IO2) + inttostr(IO3) +
    inttostr(IO4));
  cmdstr := '55FF04B500000000';
  SendStrhex(Com1, cmdstr);
  while true do //等待数据接收
  begin
    sleep(1);
    if sendOK then // 发送成功
    begin
      if (Rec_DATA[1] = IO1) and (Rec_DATA[2] = IO2) and
        (Rec_DATA[3] = IO3) and (Rec_DATA[4] = IO4) then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + 'info: ' + 'IO' + '返回:' + inttostr(Rec_Data[1]) + ',' +
          inttostr(Rec_Data[2]) +
          ',' + inttostr(Rec_Data[3]) + ',' + inttostr(Rec_Data[4]) +
          ' 检测OK');
        Result := True;
      end
      else
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + 'error: ' + 'IO' + '返回:' + inttostr(Rec_Data[1]) + ',' +
          inttostr(Rec_Data[2])
          + ',' + inttostr(Rec_Data[3]) + ',' +
          inttostr(Rec_Data[4]) + ' 检测NG');
      end;
      Break; //
    end;
    if sendNG then // 发送无应答
    begin
      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
        'error: IO' + '通讯无应答');
      break;
    end;
  end;
end;

function Ring(R1, R2: Integer): Boolean; //铃声检测
var
  cmdstr: string; //发送的数据
begin
  Result := False;
  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
    now) + #13#10 + 'Ring');
  cmdstr := '55FF02B20000';
  SendStrhex(Com1, cmdstr);
  while true do //等待数据接收
  begin
    sleep(1);
    if sendOK then // 发送成功
    begin
      if (Rec_DATA[1] = R1) and (Rec_DATA[2] = R2) then
      begin
        MainForm.mmo1.Lines.Add('Ring' + '返回:' + inttostr(Rec_Data[1]) + ',' +
          inttostr(Rec_Data[2]) + ' 检测OK');
        Result := True;
      end
      else
      begin
        MainForm.mmo1.Lines.Add('Ring' + '返回:' + inttostr(Rec_Data[1]) + ',' +
          inttostr(Rec_Data[2]) + ' 检测NG');
      end;
      Break; //
    end;
    if sendNG then // 发送无应答
    begin
      MainForm.mmo1.Lines.Add('Ring' + '通讯无应答');
      break;
    end;
  end;
end;

function CHChange(CH, TR: Integer): Boolean; //检测通道
var
  cmdstr: string; //发送的数据
  CMD_CH: string;
  CMD_TR: string;
begin
  Result := False;
  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
    now) + #13#10 + 'Channel');
  if CH = 1 then
    CMD_CH := '01'
  else
    CMD_CH := '02';
  if TR = 1 then
    CMD_TR := '0F'
  else
    CMD_TR := 'F0';
  cmdstr := '55FF02B3' + CMD_CH + CMD_TR;
  SendStrhex(Com1, cmdstr);
  while true do //等待数据接收
  begin
    sleep(1);
    if sendOK then // 发送成功
    begin
      MainForm.mmo1.Lines.Add('Channel 切换OK');
      Result := True;
      Break; //
    end;
    if sendNG then // 发送无应答
    begin
      MainForm.mmo1.Lines.Add('Channel' + '通讯无应答');
      break;
    end;
  end;
end;

function Talking(Channel, Direction: Integer): Boolean; //通话检测
var
  cmdstr: string; //发送的数据
  audiofrecy: Integer;
  CH: Integer;
  TestTimes: Integer; //测试失败重测次数
  Res1: Boolean; //双工通道检测结果1
  Res2: Boolean; //双工通道检测结果1
begin
  Result := False;
  Res1 := False;
  Res2 := False;
  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
    now) + #13#10 + 'Talking');

  case Direction of
    Calling: //主呼通道 = 1
      begin
        TestTimes := 5;
        repeat
          CHChange(Channel, 1); //  OS-> IS
          MakeSin(1948, 1000);
          cmdstr := '55FF02B40000';
          SendStrhex(Com1, cmdstr);
          while true do //等待数据接收
          begin
            sleep(1);
            if sendOK then // 发送成功
            begin
              audiofrecy := ((Rec_Data[1] shl 8) + Rec_Data[2]) * 4;
              MainForm.mmo1.Lines.Add('检测到通话频率:' + inttostr(audiofrecy));
              if (audiofrecy >= 1600) and (audiofrecy <= 2400) then
              begin
                MainForm.mmo1.Lines.Add('Talking Calling通道检测OK');
                Res1 := True;
              end
              else
              begin
                MainForm.mmo1.Lines.Add('Talking Calling通道检测NG');
              end;
              Break;
            end;
            if sendNG then // 发送无应答
            begin
              MainForm.mmo1.Lines.Add('Talking' + '通讯无应答');
              break;
            end;
          end;
          TestTimes := TestTimes - 1;
          if Res1 = False then //测试失败等待一定随机时间后重测
            Delayms(Rand(1000, 3000));
        until (TestTimes <= 0) or Res1;
        TestTimes := 3; //测试相反的通道，应为不能通话
        repeat
          CHChange(Channel, 2); //  IS-> OS
          MakeSin(1948, 1000);
          cmdstr := '55FF02B40000';
          SendStrhex(Com1, cmdstr);
          while true do //等待数据接收
          begin
            sleep(1);
            if sendOK then // 发送成功
            begin
              audiofrecy := ((Rec_Data[1] shl 8) + Rec_Data[2]) * 4;
              MainForm.mmo1.Lines.Add('检测到通话频率:' + inttostr(audiofrecy));
              if (audiofrecy >= 1600) and (audiofrecy <= 2400) then
              begin
                MainForm.mmo1.Lines.Add('Calling Responding通道检测OK');
              end
              else
              begin
                MainForm.mmo1.Lines.Add('Calling Responding通道检测NG');
                Res2 := True;
              end;
              Break;
            end;
            if sendNG then // 发送无应答
            begin
              MainForm.mmo1.Lines.Add('Talking' + '通讯无应答');
              break;
            end;
          end;
          TestTimes := TestTimes - 1;
          if Res2 = False then //测试失败等待一定随机时间后重测
            Delayms(Rand(1000, 3000));
        until (TestTimes <= 0) or Res2;
        Result := Res1 and Res2;
      end;
    Responding: //应答通道 =2
      begin
        TestTimes := 5;
        repeat
          CHChange(Channel, 2); //  IS-> OS
          MakeSin(1948, 1000);
          cmdstr := '55FF02B40000';
          SendStrhex(Com1, cmdstr);
          while true do //等待数据接收
          begin
            sleep(1);
            if sendOK then // 发送成功
            begin
              audiofrecy := ((Rec_Data[1] shl 8) + Rec_Data[2]) * 4;
              MainForm.mmo1.Lines.Add('检测到通话频率:' + inttostr(audiofrecy));
              if (audiofrecy >= 1600) and (audiofrecy <= 2400) then
              begin
                MainForm.mmo1.Lines.Add('Talking Responding通道检测OK');
                Res2 := True;
              end
              else
              begin
                MainForm.mmo1.Lines.Add('Talking Responding通道检测NG');
              end;
              Break;
            end;
            if sendNG then // 发送无应答
            begin
              MainForm.mmo1.Lines.Add('Talking' + '通讯无应答');
              break;
            end;
          end;
          TestTimes := TestTimes - 1;
          if Res2 = False then //测试失败等待一定随机时间后重测
            Delayms(Rand(1000, 3000));
        until (TestTimes <= 0) or Res2;
        TestTimes := 3;
        repeat
          CHChange(Channel, 1); //  OS-> IS
          MakeSin(1948, 1000);
          cmdstr := '55FF02B40000';
          SendStrhex(Com1, cmdstr);
          while true do //等待数据接收
          begin
            sleep(1);
            if sendOK then // 发送成功
            begin
              audiofrecy := ((Rec_Data[1] shl 8) + Rec_Data[2]) * 4;
              MainForm.mmo1.Lines.Add('检测到通话频率:' + inttostr(audiofrecy));
              if (audiofrecy >= 1600) and (audiofrecy <= 2400) then
              begin
                MainForm.mmo1.Lines.Add('Responding Calling通道检测OK');
              end
              else
              begin
                MainForm.mmo1.Lines.Add('Responding Calling通道检测NG');
                Res1 := True;
              end;
              Break;
            end;
            if sendNG then // 发送无应答
            begin
              MainForm.mmo1.Lines.Add('Talking' + '通讯无应答');
              break;
            end;
          end;
          TestTimes := TestTimes - 1;
          if Res1 = False then //测试失败等待一定随机时间后重测
            Delayms(Rand(1000, 3000));
        until (TestTimes <= 0) or Res1;
        Result := Res1 and Res2;
      end;
    Duplexing: //双工 =3
      begin
        repeat
          TestTimes := 5;
          CHChange(Channel, 1); //  OS-> IS
          MakeSin(1948, 1000);
          cmdstr := '55FF02B40000';
          SendStrhex(Com1, cmdstr);
          while true do //等待数据接收
          begin
            sleep(1);
            if sendOK then // 发送成功
            begin
              audiofrecy := ((Rec_Data[1] shl 8) + Rec_Data[2]) * 4;
              MainForm.mmo1.Lines.Add('检测到通话频率:' + inttostr(audiofrecy));
              if (audiofrecy >= 1600) and (audiofrecy <= 2400) then
              begin
                MainForm.mmo1.Lines.Add('Talking Duplexing Calling通道检测OK');
                Res1 := True;
              end
              else
              begin
                MainForm.mmo1.Lines.Add('Talking  Duplexing Calling通道检测NG');
              end;
              Break;
            end;
            if sendNG then // 发送无应答
            begin
              MainForm.mmo1.Lines.Add('Talking' + '通讯无应答');
              break;
            end;
          end;
          TestTimes := TestTimes - 1;
          if Res1 = False then //测试失败等待一定随机时间后重测
            Delayms(Rand(1000, 3000));
        until (TestTimes <= 0) or Res1;
        TestTimes := 5;
        repeat
          CHChange(Channel, 2); //  IS-> OS
          MakeSin(1948, 1000);
          cmdstr := '55FF02B40000';
          SendStrhex(Com1, cmdstr);
          while true do //等待数据接收
          begin
            sleep(1);
            if sendOK then // 发送成功
            begin
              audiofrecy := ((Rec_Data[1] shl 8) + Rec_Data[2]) * 4;
              MainForm.mmo1.Lines.Add('检测到通话频率:' + inttostr(audiofrecy));
              if (audiofrecy >= 1600) and (audiofrecy <= 2400) then
              begin
                MainForm.mmo1.Lines.Add('Talking Duplexing Responding通道检测OK');
                Res2 := True;
              end
              else
              begin
                MainForm.mmo1.Lines.Add('Talking Duplexing Responding通道检测NG');
              end;
              Break;
            end;
            if sendNG then // 发送无应答
            begin
              MainForm.mmo1.Lines.Add('Talking' + '通讯无应答');
              break;
            end;
          end;
          TestTimes := TestTimes - 1;
          if Res2 = False then //测试失败等待一定随机时间后重测
            Delayms(Rand(1000, 3000));
        until (TestTimes <= 0) or Result;
        Result := Res1 and Res2;
      end;
  end;
end;

function WaitUntilRing(R1, R2: Integer; MSecs: Longint): Boolean;
var
  FirstTickCount, Nw: Longint;
  RingResult, Exit: Boolean;
begin
  Exit := False;
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'WaitUntilRing ' + inttostr(R1) + inttostr(R2) +
    inttostr(MSecs));
  FirstTickCount := GetTickCount();
  repeat
    RingResult := Ring(R1, R2);
    Nw := GetTickCount();
    if RingResult then
    begin
      MainForm.mmo1.Lines.Add('WaitRingTime: ' + IntToStr(Nw - FirstTickCount) +
        'ms');
      Exit := True;
      Result := True;
    end;

    Application.ProcessMessages;
    Sleep(1);

  until (Nw - FirstTickCount >= MSecs) or (Nw < FirstTickCount) or Exit;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'WaitUntilRing end');
end;

function WaitUnlock(IO1, IO2, IO3, IO4: Integer; MSecs: Longint): Boolean;
var
  FirstTickCount, Nw: Longint;
  RingResult, Exit: Boolean;
begin
  Exit := False;
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'WaitInPut ' + inttostr(IO1) + inttostr(IO2) + inttostr(IO3) +
    inttostr(IO4) + inttostr(MSecs));
  FirstTickCount := GetTickCount();
  repeat
    RingResult := IO(IO1, IO2, IO3, IO4);
    Nw := GetTickCount();
    if RingResult then
    begin
      MainForm.mmo1.Lines.Add('WaitInPut: ' + IntToStr(Nw - FirstTickCount) +
        'ms');
      Exit := True;
      Result := True;
    end;

    Application.ProcessMessages;
    Sleep(1);

  until (Nw - FirstTickCount >= MSecs) or (Nw < FirstTickCount) or Exit;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'WaitInPut end');
end;

function QR(cameraID: Integer; X1, Y1, X2, Y2: Integer; text: string): Boolean;
  //QRcode解码
var
  socbmp: TBitmap;
  ImgPath: string;
  QRPicPath: string;
  QRresult: string;
  SrcRect: TRect; //截取图片的坐标
  bmp: TBitmap;
  del: Integer;
  i: Integer;
begin

  Result := False;
  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
    now) + #13#10 + 'QR');
  for i := 1 to 3 do
  begin
    try
      ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) +
        '_' + inttostr(cameraID) + '.bmp'; //解码的图片
      SocBMP := CMSnapShotMem(cameraID); //图像抓拍，内存中

      QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_QR.bmp';
      SrcRect := Rect(X1, Y1, X2, Y2); //截取坐标
      DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2); //截取的区域坐标
      bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
      CameraSetForm.image1.Picture.Bitmap.Assign(bmp); //显示截取的图片
      bmp.SaveToFile(QRPicPath); //保存截取的图片
      QRresult := DecodeFile(QRPicPath);

      if sameText(QRresult, text) then
      begin
        // MainForm.mmo1.Lines.Add('返回:' + QRresult + ' 检测OK');
         //  DeleteBMPFile(ImgPath);
          // DeleteBMPFile(QRPicPath);
        Result := True;
      end;

      DeleteBMPFile(QRPicPath); //检测成功，删除文件
    finally
      bmp.Free; //释放内存
      SocBMP.free;
    end;
    MainForm.mmo1.Lines.Add('第 ' + IntToStr(i) + ' 次检测结果: ' + QRresult);
    if Result = True then
      Break;
    del := RandomRange(300, 3000 + 1);
    Delayms(del);
    MainForm.mmo1.Lines.Add('延时: ' + IntToStr(del) + ' ms 重新检测');
  end;
end;

function SnapShot(CameraID: Integer; Path: string): Boolean;
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: SnapShot | ' + 'Camera: ' + inttostr(cameraID) + ' | ' + path +
    ' |');
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
  path := Path + '\' + FormatDateTime('yyyymmddhhmmsszzz', now) + '.jpg';
  MainForm.mmo1.Lines.Add('SnapShot ' + path);
  CameraSetUnit.CMSnapShot(cameraID, path); //抓图
  if FileExists(path) then
    Result := True;
end;

procedure Delay(ms: Integer); //延时
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: Delay ' + IntToStr(ms) + 'ms');
  Delayms(ms);
end;

function OCR(CameraID: Integer; X1, Y1, X2, Y2: Integer; Text: string): Boolean;
  //文字识别
var
  bmp: TBitmap;
  ImgPath: string; //QR图片文件路径
  OCRtext: string; //文字识别结果
  QRPicPath: string;
  SocBMP: TBitmap; //源图片
  SrcRect: TRect; //截取图片的坐标
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: OCR ');
  bmp := TBitmap.Create;
  try
    ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) +
      '_' + inttostr(CameraID) + '.bmp'; //文字识别图片路径
    SocBMP := CMSnapShotMem(1); //图像抓拍，内存中

    QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_OCR.bmp';
    SrcRect := Rect(X1, Y1, X2, Y2); //截取坐标
    DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2);
    //  Synchronize(Formcanvas); //视频区显示截取的区域
    bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
    ruihua(bmp); //图片锐化
    BMPbinary(bmp); //图片二值化
    bmp.SaveToFile(QRPicPath); //保存截取的图片
    CameraSetForm.image1.Picture.LoadFromFile(QRPicPath); //显示截取的图片
    OCRtext := OCRdetection(QRPicPath); //OCR
    if sameText(OCRtext, Text) then
    begin
      MainForm.mmo1.Lines.Add('返回:' + OCRtext + ' 检测OK');
      Result := True;
      // DeleteBMPFile(ImgPath); //检测成功，删除文件
    end
    else
    begin
      MainForm.mmo1.Lines.Add('返回:' + OCRtext + ' 检测NG' + #13#10 + ImgPath);
      SocBMP.SaveToFile(ImgPath); //保存抓拍的图片
    end;
    DeleteBMPFile(QRPicPath); //检测成功，删除文件
  finally
    bmp.Free; //释放内存
    SocBMP.Free;
  end;
end;

function GetAveHSV(CameraID: Integer; x1, y1, x2, y2: Integer; HSV: string):
  Boolean; //颜色检测，获取范围(x1,y1,x2,y2)HSV颜色的均值
var
  socbmp: TBitmap;
  SrcRect: TRect; //截取图片的坐标
  ColorRGB: TRGBColor; //颜色RGB
  ColorHSV: THSBColor; //颜色HSV
  ExpColor: TStringList; //预期颜色值
  DevColor: TStringList; //预期颜色值误差
  ExpTempColor: TStringList; //预期颜色值临时
  ColorAL: Integer; //预期最小值，最大值
  ColorBL: Integer;
  ColorCL: Integer;
  ColorAH: Integer;
  ColorBH: Integer;
  ColorCH: Integer;
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: GetAveHSV ');
  try
    SocBMP := CMSnapShotMem(CameraID); //图像抓拍，内存中
    SrcRect := Rect(X1, Y1, X2, y2); //颜色区域
    DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2);
    ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
    ColorHSV := RGBToHSV(colorRGB);
  finally
    SocBMP.Free;
  end;
  if Pos('-', HSV) > 0 then // 字符串是否包含-，有则有偏色参数
  begin
    try
      ExpTempColor := SplitString(HSV, '-'); //按'-'分割字符
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
        (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH)
        and
        (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH)
        then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + '返回：' + floattostr(ColorHSV.Hue)
          + '.' + floattostr(ColorHSV.Saturation) + '.' +
          floattostr(ColorHSV.Brightness) + '测试OK');
        Result := True;
      end
      else
        MainForm.mmo1.Lines.Add('[error] ' +
          FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
          floattostr(ColorHSV.Hue)
          + '.' + floattostr(ColorHSV.Saturation) + '.' +
          floattostr(ColorHSV.Brightness));
    finally
      ExpTempColor.Free;
      ExpColor.Free;
      DevColor.Free;
    end;
  end
  else //颜色不包含偏值参数
  begin
    try
      ExpColor := SplitString(HSV, '.');
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
      if (ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAH) and
        (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH) and
        (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH)
        then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + '返回：' + floattostr(ColorHSV.Hue) + '.' +
          floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness) +
          '测试OK');
        Result := True;
      end
      else
        MainForm.mmo1.Lines.Add('[error] ' +
          FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
          floattostr(ColorHSV.Hue) + '.' + floattostr(ColorHSV.Saturation) + '.' +
          floattostr(ColorHSV.Brightness));
    finally
      ExpColor.Free;
    end;
  end;
end;

function GetAveRGB(CameraID: Integer; x1, y1, x2, y2: Integer; RGB: string):
  Boolean; //颜色检测，获取范围(x1,y1,x2,y2)HSV颜色的均值
var
  socbmp: TBitmap;
  SrcRect: TRect; //截取图片的坐标
  ColorRGB: TRGBColor; //颜色RGB
  ExpColor: TStringList; //预期颜色值
  DevColor: TStringList; //预期颜色值误差
  ExpTempColor: TStringList; //预期颜色值临时
  ColorAL: Integer; //预期最小值，最大值
  ColorBL: Integer;
  ColorCL: Integer;
  ColorAH: Integer;
  ColorBH: Integer;
  ColorCH: Integer;
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: GetAveRGB ');
  try
    SocBMP := CMSnapShotMem(CameraID); //图像抓拍，内存中
    SrcRect := Rect(X1, Y1, X2, y2); //颜色区域
    DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2);
    ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
  finally
    SocBMP.Free;
  end;
  if Pos('-', RGB) > 0 then // 字符串是否包含-，有则有偏色参数
  begin
    try
      ExpTempColor := SplitString(RGB, '-'); //按'-'分割字符
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
        (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH)
        then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + '返回：' + floattostr(ColorRGB.Red)
          + '.' + floattostr(ColorRGB.Green) + '.' +
          floattostr(ColorRGB.Blue) + '测试OK');
        Result := True;
      end
      else
        MainForm.mmo1.Lines.Add('[error] ' +
          FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
          floattostr(ColorRGB.Red)
          + '.' + floattostr(ColorRGB.Green) + '.' +
          floattostr(ColorRGB.Blue));
    finally
      ExpTempColor.Free;
      ExpColor.Free;
      DevColor.Free;
    end;
  end
  else //颜色不包含偏值参数
  begin
    try
      ExpColor := SplitString(RGB, '.');
      ColorAL := StrToInt(ExpColor[0]) - Round(StrToInt(ExpColor[0]) * 0.1);
      if ColorAL < 0 then
         ColorAL := 0;
      ColorBL:= StrToInt(ExpColor[1]) - Round(StrToInt(ExpColor[1]) * 0.1);
      if ColorBL < 0 then
        ColorBL := 0;
      ColorCL:= StrToInt(ExpColor[2]) - Round(StrToInt(ExpColor[2]) * 0.1);
      if ColorCL < 0 then
        ColorCL := 0;

      ColorAH := StrToInt(ExpColor[0]) + Round(StrToInt(ExpColor[0]) * 0.1);
      if ColorAH > 255 then
        ColorAH := 255;
      ColorBH := StrToInt(ExpColor[1]) + Round(StrToInt(ExpColor[1]) * 0.1);
      if ColorBH > 255 then
        ColorBH := 255;
      ColorCH := StrToInt(ExpColor[2]) + Round(StrToInt(ExpColor[2]) * 0.1);
      if ColorCH > 255 then
        ColorCH := 255;

      if (ColorRGB.Red >= ColorAL) and (ColorRGB.Red <= ColorAH) and
        (ColorRGB.Green >= ColorBL) and (ColorRGB.Green <= ColorBH) and
        (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH)
        then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + '返回：' + floattostr(ColorRGB.Red) + '.' +
          floattostr(ColorRGB.Green) + '.' + floattostr(ColorRGB.Blue) +
          '测试OK');
        Result := True;
      end
      else
        MainForm.mmo1.Lines.Add('[error] ' +
          FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
          floattostr(ColorRGB.Red) + '.' + floattostr(ColorRGB.Green) + '.' +
          floattostr(ColorRGB.Blue));
    finally
      ExpColor.Free;
    end;
  end;
end;

function GetRGB(CameraID: Integer; x, y: Integer; RGB: string):
  Boolean; //颜色检测，获取范围(x1,y1,x2,y2)HSV颜色的均值
var
  socbmp: TBitmap;
  SrcRect: TRect; //截取图片的坐标
  ColorRGB: TRGBColor; //颜色RGB
  ExpColor: TStringList; //预期颜色值
  DevColor: TStringList; //预期颜色值误差
  ExpTempColor: TStringList; //预期颜色值临时
  ColorAL: Integer; //预期最小值，最大值
  ColorBL: Integer;
  ColorCL: Integer;
  ColorAH: Integer;
  ColorBH: Integer;
  ColorCH: Integer;
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: GetAveRGB ');
  try
    SocBMP := CMSnapShotMem(CameraID); //图像抓拍，内存中
    ColorRGB := GetColorFunc(SocBMP, X,Y);
  finally
    SocBMP.Free;
  end;
  if Pos('-', RGB) > 0 then // 字符串是否包含-，有则有偏色参数
  begin
    try
      ExpTempColor := SplitString(RGB, '-'); //按'-'分割字符
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
        (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH)
        then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + '返回：' + floattostr(ColorRGB.Red)
          + '.' + floattostr(ColorRGB.Green) + '.' +
          floattostr(ColorRGB.Blue) + '测试OK');
        Result := True;
      end
      else
        MainForm.mmo1.Lines.Add('[error] ' +
          FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
          floattostr(ColorRGB.Red)
          + '.' + floattostr(ColorRGB.Green) + '.' +
          floattostr(ColorRGB.Blue));
    finally
      ExpTempColor.Free;
      ExpColor.Free;
      DevColor.Free;
    end;
  end
  else //颜色不包含偏值参数
  begin
    try
      ExpColor := SplitString(RGB, '.');
      ColorAL := StrToInt(ExpColor[0]) - Round(StrToInt(ExpColor[0]) * 0.1);
      if ColorAL < 0 then
         ColorAL := 0;
      ColorBL:= StrToInt(ExpColor[1]) - Round(StrToInt(ExpColor[1]) * 0.1);
      if ColorBL < 0 then
        ColorBL := 0;
      ColorCL:= StrToInt(ExpColor[2]) - Round(StrToInt(ExpColor[2]) * 0.1);
      if ColorCL < 0 then
        ColorCL := 0;

      ColorAH := StrToInt(ExpColor[0]) + Round(StrToInt(ExpColor[0]) * 0.1);
      if ColorAH > 255 then
        ColorAH := 255;
      ColorBH := StrToInt(ExpColor[1]) + Round(StrToInt(ExpColor[1]) * 0.1);
      if ColorBH > 255 then
        ColorBH := 255;
      ColorCH := StrToInt(ExpColor[2]) + Round(StrToInt(ExpColor[2]) * 0.1);
      if ColorCH > 255 then
        ColorCH := 255;

      if (ColorRGB.Red >= ColorAL) and (ColorRGB.Red <= ColorAH) and
        (ColorRGB.Green >= ColorBL) and (ColorRGB.Green <= ColorBH) and
        (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH)
        then
      begin
        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now)
          + '返回：' + floattostr(ColorRGB.Red) + '.' +
          floattostr(ColorRGB.Green) + '.' + floattostr(ColorRGB.Blue) +
          '测试OK');
        Result := True;
      end
      else
        MainForm.mmo1.Lines.Add('[error] ' +
          FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
          floattostr(ColorRGB.Red) + '.' + floattostr(ColorRGB.Green) + '.' +
          floattostr(ColorRGB.Blue));
    finally
      ExpColor.Free;
    end;
  end;
end;

function LEDIndn(CameraID: Integer; x1, y1, x2, y2: Integer; HSV: string; MSecs:
  Integer): Int64; //LED闪烁检查
var
  socbmp: TBitmap;
  SrcRect: TRect; //截取图片的坐标
  ColorRGB: TRGBColor; //颜色RGB
  ColorHSV: THSBColor; //颜色HSV
  ExpColor: TStringList; //预期颜色值
  DevColor: TStringList; //预期颜色值误差
  ExpTempColor: TStringList; //预期颜色值临时
  ColorAL: Integer; //预期最小值，最大值
  ColorBL: Integer;
  ColorCL: Integer;
  ColorAH: Integer;
  ColorBH: Integer;
  ColorCH: Integer;
  Res1: Boolean;
  Res2: Boolean;
  Res3: Boolean;
  FirstTickCount, Nw: Longint;
begin
  Result := 0;
  Res1 := False;
  Res2 := False;
  Res3 := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'LEDIndn ');
  if Pos('-', HSV) > 0 then // 字符串是否包含-，有则有偏色参数
  begin
    try
      ExpTempColor := SplitString(HSV, '-'); //按'-'分割字符
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

      FirstTickCount := GetTickCount();
      repeat
        Nw := GetTickCount();
        try
          SocBMP := CMSnapShotMem(CameraID); //图像抓拍，内存中
          SrcRect := Rect(X1, Y1, X2, y2); //颜色区域
          ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
          ColorHSV := RGBToHSV(colorRGB);
        finally
          SocBMP.Free;
        end;

        if not ((ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAH) and
          (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH)
          and
          (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH))
          then
        begin
          Res1 := True;
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + '返回：' + floattostr(ColorHSV.Hue)
            + '.' + floattostr(ColorHSV.Saturation) + '.' +
            floattostr(ColorHSV.Brightness) + 'Waiting LED ON');
        end;

      until (Nw - FirstTickCount >= MSecs) or (Nw < FirstTickCount) or Res1;

      FirstTickCount := GetTickCount();

      repeat
        Nw := GetTickCount();

        try
          SocBMP := CMSnapShotMem(CameraID); //图像抓拍，内存中
          SrcRect := Rect(X1, Y1, X2, y2); //颜色区域
          ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
          ColorHSV := RGBToHSV(colorRGB);
        finally
          SocBMP.Free;
        end;

        if (ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAH) and
          (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH)
          and
          (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH)
          then
        begin
          Res2 := True;
          FirstTickCount := GetTickCount();
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + '返回：' + floattostr(ColorHSV.Hue)
            + '.' + floattostr(ColorHSV.Saturation) + '.' +
            floattostr(ColorHSV.Brightness) + 'LED ON');
        end;

      until (Nw - FirstTickCount >= MSecs) or (Nw < FirstTickCount) or Res2;

      repeat
        Nw := GetTickCount();

        try
          SocBMP := CMSnapShotMem(CameraID); //图像抓拍，内存中
          SrcRect := Rect(X1, Y1, X2, y2); //颜色区域
          DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2);
          ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
          ColorHSV := RGBToHSV(colorRGB);
        finally
          SocBMP.Free;
        end;

        if not ((ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAH) and
          (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH)
          and
          (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH))
          then
        begin

          Res3 := True;
          MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
            now) + '返回：' + floattostr(ColorHSV.Hue)
            + '.' + floattostr(ColorHSV.Saturation) + '.' +
            floattostr(ColorHSV.Brightness) + 'LED OFF');
        end;

      until (Nw - FirstTickCount >= MSecs) or (Nw < FirstTickCount) or Res3;

      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
        'LED ON TIME: ' + FloatToStr(Nw - FirstTickCount));
      if Res1 and Res2 and Res3 and ((Nw - FirstTickCount) <= MSecs) then
      begin

        Result := (Nw - FirstTickCount);
      end;

    finally
      ExpTempColor.Free;
      ExpColor.Free;
      DevColor.Free;
    end;
  end;
end;

function Serial_Open(Com: Integer): Boolean;
var
  ret: Integer;
begin
   sio_close(Com);
  ret := sio_open(Com);
  if ret <> SIO_OK then
  begin
    Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) +
      ' Error:' + 'sio_open' + IntToStr(ret));
    Exit;
  end;
  if sio_ioctl(Com, B19200, P_NONE or BIT_8 or STOP_1) <> sio_ok then
  begin
    sio_close(Com);
    Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) +
      ' Error:' + 'sio_ioctl' + IntToStr(ret));
    Exit;
  end;
  ret := sio_SetReadTimeouts(Com, 0, 20);
  Result := True;
end;

function Serial_Close(Com: Integer): Boolean;
var
  ret: Integer;
begin
  ret := sio_close(Com);
  if ret <> SIO_OK then
  begin
    Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) +
      ' Error:' + 'sio_close' + IntToStr(ret));
    Exit;
  end;
  Result := True;
end;

function Serial(Com: Integer; sData: string): Boolean;
var
  s2: string;
  buf1: array[0..511] of char;
  i: integer;
  ret: Integer;
begin
  Result := False;
  s2 := '';
  for i := 1 to length(sData) do
  begin
    if ((copy(sData, i, 1) >= '0') and (copy(sData, i, 1) <= '9')) or
      ((copy(sData, i, 1) >= 'a') and (copy(sData, i, 1) <= 'f'))
      or ((copy(sData, i, 1) >= 'A') and (copy(sData, i, 1) <= 'F')) then
    begin
      s2 := s2 + copy(sData, i, 1);
    end;
  end;
  // s2 := s2 + GetCheck(s2); //添加校验
  for i := 0 to (length(s2) div 2 - 1) do
    buf1[i] := char(strtoint('$' + copy(s2, i * 2 + 1, 2)));
  ret := sio_write(Com, @buf1, (length(s2) div 2));
  Result := True;
  Mainform.mmo1.Lines.Append(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' '
    + 'Serial:' + inttostr(Com) + ' Sent:' + s2)
end;

function SendCmd(Com: Integer; SData: string; RData: string): Boolean;
var
  str, Rtemp: string;
  len: Longint;
  beginTick, endTick: longint;
  buf: array[0..511] of Char;
  testtimes: Integer;
  crc8: integer;
begin
  Result := False;
  SData := TrimAll(SData); //去除字符串的空格
  SData := AnsiUpperCase(SData); //大写
  RData := TrimAll(RData); //去除字符串的空格
  RData := AnsiUpperCase(RData); //大写
  Serial_Open(Com);
  testtimes := 3;
  crc8 := GetCrc8(sData);
  repeat
    if Serial(Com, sData + inttohex(crc8, 2)) then
    begin
      if RData <> '' then
      begin
        beginTick := GetTickCount; // 计数初值
        while True do
        begin
          endTick := GetTickCount;
          Sleep(10);
          len := sio_read(Com, @buf, 512);
          if len > 0 then
          begin
            SetLength(str, len);
            Move(PChar(@buf)^, PChar(@str[1])^, len);
            Rtemp := StringToHex(str);
            Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz',
              now) + ' ' + Rtemp);
          end;

          if Pos(RData, Rtemp) > 0 then
          begin
            Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz',
              now) + '数据匹配');
            Result := True;
            Break
          end
          else if (endTick - beginTick) > 1000 then // 数据发送超时
          begin
            Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz',
              now) + ' 接收超时(1000ms)');
            Result := False;
            Break;
          end;
        end;
      end
      else
        Result := True;
    end
    else
      result := False;
    TestTimes := TestTimes - 1;
  until (TestTimes <= 0) or result = True;
  Serial_Close(Com);
end;

function Card(cardNum: int64): Boolean; //
var
  cardtimes: Integer; //
  cmdstr: string; //发送的数据
begin
  Result := False;

  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing:' + 'Card :' + IntToStr(cardNum));
  if cardNum < 4294967296 then
  begin
    cardtimes := 30; //strtoint(form2.Edit1.Text);
    cmdstr := '55ff05b7' + formatfloat('00', cardtimes) + inttohex(cardNum, 8);

  end
  else
  begin
    MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
      'error:' + 'Card :' + IntToStr(cardNum));
    exit;
  end;

  //SendStrhex(ComCard, cmdstr);
  WriteStrhex(ComCard, cmdstr);
  Delayms(500);
  { while true do //等待数据接收
   begin
     sleep(1);
     if sendOK then // 发送成功
     begin
      if  (Rec_Data[1] shl 32) + (Rec_Data[2] shl 16)+(Rec_Data[3] shl 8)+(Rec_Data[4])
        = cardNum then
      begin

        MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'info: ' + cmdstr + '发送成功');
        Result := True;
        Break; //
        end;
     end;
     if sendNG then // 发送无应答
     begin
       MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'error: ' + cmdstr + '发送失败');
       break;
     end;
   end;    }
end;

procedure RFIDFMList(); // 卡列表注册
var
  ID: Int64;
begin
  if CardSet.FormCardSet.ListBox1.Count > 0 then
  begin
    MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
      'Executing:' + 'RFIDFMList()');

    ID := StrToInt64(CardSet.FormCardSet.ListBox1.Items[listID]);
    Card(ID);
    listID := listID + 1;
    if listID > (CardSet.FormCardSet.ListBox1.Items.Count - 1) then
      listID := 0;
  end
  else
    MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
      'ERROR:' + '卡列表为空!');
end;

function HeCheng(SourceA, SourceB: TBitmap): TBitmap;
var
  des: TRect;
  From1: TRect;
  From2: TRect;
begin
  SourceA.PixelFormat := pf24Bit;
  SourceB.PixelFormat := pf24Bit;

  try
    begin
      Result := TBitmap.Create; //产生Tbitmap对象bmp
      Result.PixelFormat := pf24bit; //设置Bmp为24色位图
      Result.Width := SourceA.Width;
      Result.Height := SourceA.Height + SourceB.Height;

      From1 := Rect(0, 0, SourceA.Width, SourceA.Height);
      From2 := Rect(0, 0, SourceB.Width, SourceB.Height);
      des := Rect(0, 0, SourceA.Width, SourceA.Height);

      result.Canvas.Lock;
      SourceA.Canvas.Lock;
      SourceB.Canvas.Lock;
      Result.Canvas.CopyRect(des, SourceA.Canvas, From1);
      des := Rect(0, SourceA.Height, Result.Width, Result.Height);
      Result.Canvas.CopyRect(des, SourceB.Canvas, From2);
      result.Canvas.unLock;
      SourceA.Canvas.unLock;
      SourceB.Canvas.unLock;
    end;
  except
    ShowMessage('图片太大导致存储空间不足！');
  end;
end;

function Photosynth(C1, C2: Integer; Path: string): Boolean;
var
  ABitmap: Tbitmap;
  BBitmap: Tbitmap;
  HBitmap: Tbitmap;
  JpgBmitmp: TJpegImage;
begin
  Result := False;
  Abitmap := TBitmap.Create;
  Bbitmap := TBitmap.Create;
  Hbitmap := TBitmap.Create;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: Photosynth | ' + 'Camera: ' + inttostr(C1) + inttostr(C2) + ' | '
    + path +
    ' |');
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
  path := Path + '\' + FormatDateTime('yyyymmddhhmmsszzz', now) + '.jpg';
  MainForm.mmo1.Lines.Add('Photosynth ' + path);
  try
    Abitmap := CMSnapShotMem(C1);
    Bbitmap := CMSnapShotMem(C2);
    if Assigned(Abitmap) and Assigned(Bbitmap) then //如果Bmp不为nil
    begin
      HBitmap := HeCheng(Abitmap, Bbitmap);
      HBitmap.SaveToFile(Path);
      JpgBmitmp := TJpegImage.Create;
      JpgBmitmp.Assign(HBitmap); //将bmp指定给TJpegImage对象
      JpgBmitmp.CompressionQuality := 70; //压缩比例
      JpgBmitmp.JPEGNeeded; //转换
      JpgBmitmp.Compress; //压缩
    end;
    JpgBmitmp.SaveToFile(Path);
  finally
    ABitmap.Free;
    BBitmap.Free;
    HBitmap.Free;
    JpgBmitmp.free;
  end;
  if FileExists(path) then
    Result := True;
end;

function ImgSimilar(Camera: Integer; X1, Y1, X2, Y2: Integer; Hash: string;
  Value: Real): Boolean;
var
  bmp: TBitmap;
  bmp2: TBitmap;
  SocBMP: TBitmap;
  Imghash: string; //获得图片的hash
  HashBit: string;
  SrcRect: TRect;
  HashRsut: Integer;
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Executing: ImgSimilar | ' + 'Camera: ' + inttostr(Camera));
  Result := False;
  try
    SocBMP := CMSnapShotMem(Camera);
    SrcRect := Rect(X1, Y1, X2, y2); //区域
    DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2);
    bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
    bmp2 := Imageresize(bmp, 8, 8); //8*8
    imghash := GetImageHash(bmp2); //获得图片的hash
    MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'imghash: ' + imghash);
    CameraSetForm.image1.Picture.Assign(bmp); //显示截取的图片
  finally
    Bmp.Free;
    bmp2.Free;
    SocBMP.Free;
  end;
  HashBit := HexToBitStr(Hash); //转成2进制数
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Hash: ' + HashBit);
  HashRsut := hamming(HashBit, Imghash); //计算相似度
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'HashResult: ' + inttostr(HashRsut));
  if (1 - (HashRsut / 64)) >= Value then
    Result := True;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Similar: ' + floattostr(1 - (HashRsut / 64)));
end;

function CommLogSave(Path: string): Boolean;
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: CommLogSave | ' + 'Path: ' + Path);
  Result := False;
  if (Path[Length(Path)] = '\') then
    Path := Copy(Path, 1, (Length(Path) - 1));
  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\Logs');
      ForceDirectories('c:\Logs'); //创建文件夹
      Path := 'c:\Logs'; //使用默认
    end;
  end;
  path := Path + '\' + FormatDateTime('yyyymmddhhmmsszzz', now) + '_COMM.txt';
  MainForm.mmo1.Lines.Add('CommLogSave ' + path);
  // LogForm.Memo1.Lines.SaveToFile(Path);
   //  LogForm.Memo1.Lines.Clear;
  // if FileExists(path) then
  //   Result := True;
  LogPath := Path;
  LogFlag := 3;
  LogThread.Create(False);
end;

function LogSave(Path: string): Boolean;
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: LogSave | ' + 'Path: ' + Path);
  Result := False;
  if (Path[Length(Path)] = '\') then
    Path := Copy(Path, 1, (Length(Path) - 1));
  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\Logs');
      ForceDirectories('c:\Logs'); //创建文件夹
      Path := 'c:\Logs'; //使用默认
    end;
  end;
  path := Path + '\' + FormatDateTime('yyyymmddhhmmsszzz', now) + '_DEV.txt';
  MainForm.mmo1.Lines.Add('LogSave ' + path);
  // LogForm.Memo2.Lines.SaveToFile(Path);
   // LogForm.Memo2.Lines.Clear;
  // if FileExists(path) then
   //  Result := True;
  LogPath := Path;
  LogFlag := 4;
  LogThread.Create(False);
end;

procedure CommLogClear();
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: CommLogClear ');
  LogFlag := 1;
  LogThread.Create(False);
end;

procedure LogClear();
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: LogClear ');
  LogFlag := 2;
  LogThread.Create(False);
end;

function CommLogFind(str: string): Boolean;
var
  txt: string;
  reg: TPerlRegEx;
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: CommLogFind ');
  logCPFlag := True;
  LogFlag := 5;
  LogThread.Create(False);
  while logCPFlag do
    Application.ProcessMessages;
  logCPFlag := True;
  txt := LogTxt;
  LogTxt := '';
  //查找是否存在
  reg := TPerlRegEx.Create(nil);
  reg.Subject := txt;
  reg.RegEx := str;
  if reg.Match then
    Result := True;
  FreeAndNil(reg);
end;

function LogFind(str: string): Boolean;
var
  txt: string;
  reg: TPerlRegEx;
begin
  Result := False;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: LogFind');
  logCPFlag := True;
  LogFlag := 6;
  LogThread.Create(False);
  while logCPFlag do
    Application.ProcessMessages;
  logCPFlag := True;
  txt := LogTxt;
  LogTxt := '';
  //查找是否存在
  reg := TPerlRegEx.Create(nil);
  reg.Subject := txt;
  reg.RegEx := str;
  if reg.Match then
    Result := True;
  FreeAndNil(reg);
end;

procedure LogExtract(str: string; FilePath: string);
var
  txt: string;
  reg: TPerlRegEx;
  Path: string;
  FileName: string;
  stxt: string;
  temp: string;
  F: TextFile;
begin
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) +
    'Executing: LogFind');

  Path := ExtractFileDir(FilePath);
  FileName := ExtractFileName(FilePath);
  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\LogExtract');
      ForceDirectories('c:\LogExtract'); //创建文件夹
      Path := 'c:\LogExtract'; //使用默认
    end;
  end;
  path := Path + '\' + FileName;
  MainForm.mmo1.Lines.Add('LogSave ' + path);

  logCPFlag := True;
  LogFlag := 6;
  LogThread.Create(False);
  while logCPFlag do
    Application.ProcessMessages;
  logCPFlag := True;
  txt := LogTxt;
  LogTxt := '';
  //查找是否存在
  reg := TPerlRegEx.Create(nil);
  reg.Subject := txt;
  reg.RegEx := str;
  stxt := '';
  while reg.MatchAgain do
  begin
    temp := reg.MatchedExpression;
    MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Match: ' + temp);
    stxt := stxt + temp + #13#10;
  end;
  FreeAndNil(reg);
  try
    AssignFile(F, path);
    if FileExists(path) = false then
      ReWrite(F)
    else
      Append(F);
    Writeln(F, stxt);
  finally
    CloseFile(F);
  end;

end;

procedure PlayAudio(path: string);
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'PlayAudio:' + path);
  try
    PlayWAV(path);
  finally
  end;
end;

function Speaking(): Boolean;
var
  CMDOut: string;
  j: Integer;
  DTMFnum: string;
begin
  Result := False;
  Tone := Rand(0, 9);
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'DTMF TONE:' + IntToStr(Tone));
  AudioOut.Create(False);
  try
    MicRecord();
  finally
  end;
  Delayms(300);
  try
    MICSTOP();
  finally
  end;
  WAVSave(Apppath + 'dtmf2num\DTMF.wav');
  //Delayms(3000);
  CMDOut := GetDosOutput(Apppath + 'dtmf2num\dtmf2num.exe -o ' + Apppath + 'dtmf2num\DTMF.wav');
  j := pos('DTMF numbers:  ', CMDOut);
  if j <> 0 then
    DTMFnum := Copy(CMDOut, j + 15, 1);
  MainForm.mmo1.Lines.add('DTMF: ' + DTMFnum);
  if DTMFnum <> 'n' then
  begin
    if IntToStr(Tone) = DTMFnum then
      Result := True;
  end;
  DTMFnum := '';
  Tone := -1;
end;

function CONTspeaking(MSecs: integer): Boolean;
var
  FirstTickCount, Nw: Longint;
  TestTimes: Integer; //测试失败重测次数
begin
  Result := False;
  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + #13#10 + 'CONTspeaking');
  TestTimes := 5;
  FirstTickCount := GetTickCount();
  repeat
    if Speaking() then
    begin
      TestTimes := 5;
      Result := True;
    end
    else
    begin
      TestTimes := TestTimes - 1;
     // Delayms(Rand(100, 1000));  //测试失败等待一定随机时间后重测
    end;
    if TestTimes <= 0 then
      Result := False;
    Nw := GetTickCount();
  until (Nw - FirstTickCount >= MSecs) or (TestTimes <= 0);

end;

procedure TestPause();
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'pause: ');
  MainForm.btnPause.Caption := '恢复';
  MainForm.btnStop.Enabled := False;
  PascalScripThread.Suspend;
  MainForm.ExcuteValue := MainForm.Value; //记录已测试的时间
  MainForm.tmr1.Enabled := False;
end;

procedure SetWavSavePath(Path: string);
begin
  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\Record');
      ForceDirectories('c:\Record'); //创建文件夹
      Path := 'c:\Record'; //使用默认
    end;
  end;
  WavSavePath := Path + '\';
end;

function CallingChannel(WAVPayFile: string; AudHash: string; MSecs: Integer): Single;
var
  bmp, bmp2: TBitmap;
  Imghash: string; //获得图片的hash
  HashBit: string;
  HashRsut: Integer;
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'CallingChannel: ' + IntToStr(MSecs) + 'ms');
  Result := 0.0;
  if WavSavePath = '' then
  begin
    MainForm.mmo1.Lines.Add('Error: 在使用CallingChannel前,请用SetWavSavePath(Path:string);设置音频保存路径!');
    Exit;
  end;

  try
    PlayAudio(WAVPayFile);
    MicRecord();
  finally
  end;
  Delayms(MSecs);
  try
    MICSTOP();
  finally
  end;

  WavSavePath := WavSavePath + FormatDateTime('yyyymmddhhmmsszzz', now) + '_' + inttostr(finshtimes) + '.wav';
  WAVSave(WavSavePath);
  openaduio(WavSavePath);
  SaveAudioBMP(WavSavePath + '.bmp');
  try
    bmp := TBitmap.Create;
    bmp.LoadFromFile(WavSavePath + '.bmp');
    bmp2 := Imageresize(bmp, 16, 16); //8*8
    imghash := GetImageHash(bmp2); //获得图片的hash
    CameraSetForm.image1.Picture.Assign(bmp); //显示截取的图片
  finally
    Bmp.Free;
    bmp2.Free;
  end;
  HashBit := HexToBitStr(AudHash); //转成2进制数
  HashRsut := hamming(HashBit, Imghash); //计算相似度
  Result := (1 - (HashRsut / 256));
  //MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Audhash_S: ' + HashBit);
  //MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Audhash_B: ' + imghash);
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Audhash_H: ' + BitStrToHextStr(imghash));
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Similar: ' + floattostr(1 - (HashRsut / 256)));
end;

procedure AudioSave(path: string; MSecs: Integer);
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'AudioRecord: ' + IntToStr(MSecs) + 'ms');
  try
    MicRecord();
  finally
  end;
  Delayms(MSecs);
  try
    MICSTOP();
  finally
  end;

  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\Record');
      ForceDirectories('c:\Record'); //创建文件夹
      Path := 'c:\Record'; //使用默认
    end;
  end;

  path := Path + '\' + FormatDateTime('yyyymmddhhmmsszzz', now) + '.wav';
  WAVSave(Path);
  openaduio(path);
  SaveAudioBMP(Path + '.bmp');
end;

function AudioRecord(MSecs: Integer): Boolean;
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'AudioRecord: ' + IntToStr(MSecs) + 'ms');
  try
    MicRecord();
  finally
  end;
  Delayms(MSecs);
  try
    MICSTOP();
  finally
  end;

  if WavSavePath = '' then
  begin
    MainForm.mmo1.Lines.Add('Error: WavSavePath = ''音频路径为空!');
    Exit;
  end;

  WavSavePath := WavSavePath + FormatDateTime('yyyymmddhhmmsszzz', now) + '_' + inttostr(finshtimes) + '.wav';
  WAVSave(WavSavePath);
end;

function GetAudioLevel(): LongWord;
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'GetAudioLevel()');
  Result := 0;
  if WavSavePath = '' then
  begin
    MainForm.mmo1.Lines.Add('Error: WavSavePath = ''音频路径为空!');
    Exit;
  end;
  Result := getaudioLv(WavSavePath);
end;

procedure SaveToIMG(SavePath: string);
var
  f: string;
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'SaveToIMG()');
  if WavSavePath = '' then
  begin
    MainForm.mmo1.Lines.Add('Error: WavSavePath = ''音频路径为空!');
    Exit;
  end;
  openaduio(WavSavePath);
  f := ExtractFileName(WavSavePath);
  SaveAudioBMP(SavePath + f + '.bmp');
end;

procedure SendMail(Email: string; Subject : string; Body : string);
var
  filename: string;
begin     //发送邮件主函数
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'SendMail()');
  try
    MainForm.IdSSLIOHandlerSocket1.SSLOptions.Method:=sslvSSLv3;
    MainForm.IdSMTP1.IOHandler:= MainForm.IdSSLIOHandlerSocket1;  //区别在这儿哟
    MainForm.IdSMTP1.AuthenticationType:=atLogin; //设置登陆类型
    MainForm.IdSMTP1.Username:='cndex_autotest'; //设置登陆帐号
    MainForm.IdSMTP1.Password:='CNDEX9622289'; //设置登陆密码
    MainForm.IdSMTP1.Host:='smtp.163.com'; //设置SMTP地址
    MainForm.IdSMTP1.Port:=465;     //设置端口 ,默认是25，gmail是465
    if not MainForm.idsmtp1.Connected then
    begin
      MainForm.IdSMTP1.Connect(2000); //开始连接服务器
    end;
  except
    MainForm.mmo1.Lines.add('连接失败!');
    Exit; //连接失败 的话 退出该执行过程
  end;
  MainForm.IdMessage1.Body.Clear;  //先清空上次发送的内容
  MainForm.IdMessage1.Subject:= subject; //设置邮件发送的标题
  MainForm.IdMessage1.Body.add(Body);  //设置邮件发送的主体
 // filename := 'C:\1.txt';   //需要添加的附件文件
 // TIdAttachment.Create(IdMessage1.MessageParts, filename);  //添加附件
  MainForm.IdMessage1.From.Address:= 'cndex_autotest@163.com'; //设置邮件的发件人  也就是说该邮件来自什么地方
  MainForm.IdMessage1.From.Name := 'Autotest';
  MainForm.IdMessage1.Recipients.EMailAddresses:= Email;  //收件人的地址
 // IdMessage1.CCList.EMailAddresses:='7894@126.com';//抄送
 // IdMessage1.BccList.EmailAddresses:='aaaabbb@gmail.com'; //密送
  MainForm.IdMessage1.Priority:=mpHighest; //邮件重要性
  try
    MainForm.idSMTP1.Authenticate;
    MainForm.idSMTP1.Send(  MainForm.IdMessage1);
    MainForm.mmo1.Lines.add('发送成功!');
  except
    MainForm.mmo1.Lines.add('邮件发送失败!');
  end;
  MainForm.IdSMTP1.Disconnect;
end;

function AudioCompare(AudHash: string): Single;
var
  bmp, bmp2: TBitmap;
  Imghash: string; //获得图片的hash
  HashBit: string;
  HashRsut: Integer;
begin
  MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'AudioCompare: ');
  Result := 0.0;
  if WavSavePath = '' then
  begin
    MainForm.mmo1.Lines.Add('Error: WavSavePath音频保存路径为空!');
    Exit;
  end;

  openaduio(WavSavePath);
  SaveAudioBMP(WavSavePath + '.bmp');
  try
    bmp := TBitmap.Create;
    bmp.LoadFromFile(WavSavePath + '.bmp');
    bmp2 := Imageresize(bmp, 16, 16); //8*8
    imghash := GetImageHash(bmp2); //获得图片的hash
    CameraSetForm.image1.Picture.Assign(bmp); //显示截取的图片
  finally
    Bmp.Free;
    bmp2.Free;
  end;
  HashBit := HexToBitStr(AudHash); //转成2进制数
  HashRsut := hamming(HashBit, Imghash); //计算相似度
  Result := (1 - (HashRsut / 256));
  //MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Audhash_S: ' + HashBit);
  //MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Audhash_B: ' + imghash);
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Audhash_H: ' + BitStrToHextStr(imghash));
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + 'Similar: ' + floattostr(1 - (HashRsut / 256)));
end;

function FaceDetect(cameraID: Integer; X1, Y1, X2, Y2: Integer): Integer;
  //QRcode解码
var
  socbmp: TBitmap;
  ImgPath: string;
  QRPicPath: string;
  QRresult: Integer;
  SrcRect: TRect; //截取图片的坐标
  bmp: TBitmap;
  del: Integer;
  i: Integer;
begin

  Result := 0;
  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ',
    now) + #13#10 + 'FaceDetect');
  for i := 1 to 3 do
  begin
    try
      ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) +
        '_' + inttostr(cameraID) + '.bmp'; //解码的图片
      SocBMP := CMSnapShotMem(cameraID); //图像抓拍，内存中

      QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_FaceDetect.bmp';
      SrcRect := Rect(X1, Y1, X2, Y2); //截取坐标
      DwrRect := Rect(X1 div 2, Y1 div 2, X2 div 2, Y2 div 2); //截取的区域坐标
      bmp := Capture(SocBMP, SrcRect); //截取图片 ，内存中
      CameraSetForm.image1.Picture.Bitmap.Assign(bmp); //显示截取的图片
      bmp.SaveToFile(QRPicPath); //保存截取的图片
      //QRresult := DecodeFile(QRPicPath);
      QRresult := facedetect_frontal(PChar(QRPicPath), 1.2, 3, 24, 0);

      if QRresult > 0  then
      begin
        // MainForm.mmo1.Lines.Add('返回:' + QRresult + ' 检测OK');
         //  DeleteBMPFile(ImgPath);
          // DeleteBMPFile(QRPicPath);
        Result := QRresult;
      end;

      DeleteBMPFile(QRPicPath); //检测成功，删除文件
    finally
      bmp.Free; //释放内存
      SocBMP.free;
    end;
    MainForm.mmo1.Lines.Add('第 ' + IntToStr(i) + ' 次检测结果: ' +IntToStr( QRresult));
    if Result > 0 then
      Break;
    del := RandomRange(300, 3000 + 1);
    Delayms(del);
    MainForm.mmo1.Lines.Add('延时: ' + IntToStr(del) + ' ms 重新检测');
  end;
end;

procedure TestRecord(path:string);
begin
  if not DirectoryExists(Path) then //判断文件夹是否存在，不存在则创建文件夹
  begin
    ForceDirectories(Path); //创建文件夹
    if not DirectoryExists(Path) then //创建文件夹错误，使用默认文件夹
    begin
      MainForm.mmo1.Lines.Add('Error: ' + Path + ' 不能创建,使用C:\Video');
      ForceDirectories('c:\Video'); //创建文件夹
      Path := 'c:\Video'; //使用默认
    end;
  end;

  path := Path + '\' + FormatDateTime('yyyymmddhhmmsszzz', now) + '.avi';

  LogFlag := 7;
  LogThread.Create(False);
  CapFName := path;
end;

procedure StopRecord();
begin
  LogFlag := 8;
  LogThread.Create(False);
  CapFName := '';
end;

procedure PascalScript.Execute;
var
  i: Integer;
  count: Integer;
begin

  testtimes := StrToInt64(MainForm.Edit1.text);
  count := 0;
  if MainForm.chk1.Checked then
  begin
    count := MainForm.lst1.Count - 1
  end;
  {
   MainForm.PaxCompiler1.RegisterHeader(0, 'function QR(cameraID: Integer; text: string): Boolean;', @QR);
   MainForm.PaxCompiler1.RegisterHeader(0, 'function SnapShot(cameraID: Integer; Path: string): Boolean;', @SnapShot);
   MainForm.PaxCompiler1.RegisterHeader(0, 'procedure Delay(ms: Integer);', @Delay);
   MainForm.PaxCompiler1.RegisterHeader(0, 'function OCR(CameraID: Integer; ALeft: Integer; ATop: Integer; ARight: Integer; ABottom: Integer; Text: string): Boolean;', @OCR);
  }

  FreeOnTerminate := True;
  for i := 0 to count do
  begin
    MainForm.mmo1.Clear;
    if MainForm.chk1.Checked then
    begin
      MainForm.SynMemo1.Lines.LoadFromFile(filespath + '\' +
        MainForm.lst1.Items[i]);
      MainForm.mmo1.Lines.Add(filespath + '\' + MainForm.lst1.Items[i]);
        //当前测试脚本
    end;
    MainForm.PaxCompiler1.Reset;
    MainForm.PaxCompiler1.RegisterLanguage(MainForm.PaxPascalLanguage1);
    MainForm.PaxCompiler1.RegisterVariable(0, 'TS', _typeBOOLEAN, @TS);
      //主程序调用脚本变量
    MainForm.PaxCompiler1.RegisterVariable(0, 'Pass', _typeINT64, @Pass);
    MainForm.PaxCompiler1.RegisterVariable(0, 'Fail', _typeINT64, @Fail);
    MainForm.PaxCompiler1.RegisterVariable(0, 'finshtimes', _typeINT64, @finshtimes);
    MainForm.PaxCompiler1.RegisterConstant(0, 'Call', _typeINTEGER, 1);
    MainForm.PaxCompiler1.RegisterConstant(0, 'Respond', _typeINTEGER, 2);
    MainForm.PaxCompiler1.RegisterConstant(0, 'duplex', _typeINTEGER, 3);

    MainForm.PaxCompiler1.AddModule('1',
      MainForm.PaxPascalLanguage1.LanguageName);
    MainForm.PaxCompiler1.AddCode('1', MainForm.SynMemo1.Lines.Text);
    if MainForm.PaxCompiler1.Compile(MainForm.PaxProgram1) then
    begin
      Pass := 0;
      Fail := 0;
      finshtimes := 0;
      DwrRect := Rect(0, 0, 0, 0);

      repeat
        TS := False;
        finshtimes := finshtimes + 1;
        MainForm.mmo1.Lines.Add('第 ' + inttostr(finshtimes) + ' 测试');
        // Synchronize(REC);
        MainForm.PaxProgram1.Run;
        Synchronize(Formcanvas2); //视频区显示截取的区域
        // Synchronize(StopREC);
       // finshtimes := finshtimes + 1;

        if MainForm.ComboBox1.ItemIndex <> 0 then //循环测试跳过次数判断
        begin
          if finshtimes >= testtimes then
            Break;
        end;
        Sleep(1);
      until Terminated;
      if MainForm.chk1.Checked then
      begin
        ForceDirectories(filespath + '\log');
        MainForm.mmo1.Lines.SaveToFile(filespath + '\log\' +
          MainForm.lst1.Items[i] + '_log.txt');
      end;
      finshtimes := 0;

    end
    else
    begin
      MainForm.mmo1.Lines.Add('Error: ' + MainForm.PaxCompiler1.ErrorMessage[0]);
    end;
    if Terminated then
      Break;
  end;
  MainForm.tmr1.Enabled := False;
  autoSaveForm.tmr1.Enabled:=False;  //自动保存记录
end;



initialization
  RegisterHeader(0,
    'function QR(cameraID: Integer;X1,Y1,X2,Y2:Integer; text: string): Boolean;',
    @QR);
  RegisterHeader(0,
    'function SnapShot(cameraID: Integer; Path: string): Boolean;', @SnapShot);
  RegisterHeader(0, 'procedure Delay(ms: Integer);', @Delay);
  RegisterHeader(0,
    'function OCR(CameraID: Integer; X1,Y1,X2,Y2: Integer; Text: string): Boolean;',
    @OCR);
  RegisterHeader(0, 'function Rand(Min:Integer;Max:Integer):integer;', @Rand);
    //返回一个随机数整数
  RegisterHeader(0, 'function StrRand(Min:Integer;Max:Integer):string;',
    @strRand); //返回一个随机数字符串
  RegisterHeader(0,
    'function KeyPress(Keys: string; DownTime: Integer; Interval: Integer): Boolean;',
    @KeyPress); //按键控制
  RegisterHeader(0, 'function KeyDown(Keys: string): Boolean;', @KeyDown);
    //按键控制
  RegisterHeader(0, 'function KeyUp(): Boolean;', @KeyUp); //按键控制
  RegisterHeader(0, 'function IO(IO1,IO2,IO3,IO4:Integer): Boolean', @IO);
    //输入检测
  RegisterHeader(0, 'function Ring(R1, R2: Integer): Boolean', @Ring); //
  RegisterHeader(0,
    'function GetAveHSV(CameraID:Integer;x1,y1,x2,y2:Integer;HSV:string): Boolean;',
    @GetAveHSV); //颜色检测，获取范围(x1,y1,x2,y2)HSV颜色的均值
  RegisterHeader(0,
    'function WaitUntilRing(R1, R2: Integer; MSecs: Longint): Boolean;',
    @WaitUntilRing);
  RegisterHeader(0,
    'function WaitUnlock(IO1, IO2,IO3,IO4: Integer; MSecs: Longint): Boolean;',
    @WaitUnlock); //等待开锁
  RegisterHeader(0, 'function Talking(Channel, Direction: Integer): Boolean;',
    @Talking); //通话检测
  RegisterHeader(0,
    'function Photosynth(C1,C2: Integer; Path: string): Boolean;', @Photosynth);
    //图片合成
  RegisterHeader(0,
    'function ImgSimilar(Camera:Integer;X1,Y1,X2,Y2:Integer; Hash: string;Percent:Real):Boolean;',
    @ImgSimilar); //图像相似度
  RegisterHeader(0,
    'function LEDIndn(CameraID: Integer; x1, y1, x2, y2: Integer; HSV: string; MSecs: Integer): Int64;',
    @LEDIndn);
  RegisterHeader(0, 'function Serial(Com: Integer; sData: string): integer;',
    @Serial);
  RegisterHeader(0, 'function Card(cardNum: int64): Boolean;', @Card);
  RegisterHeader(0, ' procedure RFIDFMList();', @RFIDFMList);
  RegisterHeader(0, 'function Android_ScreenCAP(Path: string):Boolean;',
    @Android_ScreenCAP);
  RegisterHeader(0, 'procedure Android_Tap(Coordinate: string);', @Android_Tap);
  RegisterHeader(0, 'procedure Android_Swipe(Coordinate: string;time:Integer);',
    @Android_Swipe);
  RegisterHeader(0, 'function CommLogSave(Path: string): Boolean;',
    @CommLogSave);
  RegisterHeader(0, 'function LogSave(Path: string): Boolean;', @LogSave);
  RegisterHeader(0, 'procedure LogClear();', @LogClear);
  RegisterHeader(0, 'procedure CommLogClear();', @CommLogClear);
  RegisterHeader(0,
    'function SendCmd(Com: Integer; SData: string;RData: string): Boolean;',
    @SendCmd);
  RegisterHeader(0, 'function CommLogFind(str: string): Boolean;',
    @CommLogFind);
  RegisterHeader(0, 'function LogFind(str: string): Boolean;', @LogFind);
  RegisterHeader(0, 'procedure LogExtract(str: string;Path:string);',
    @LogExtract);
  RegisterHeader(0, 'function Speaking():Boolean;', @Speaking);
  RegisterHeader(0, 'procedure TestPause();', @TestPause);
  RegisterHeader(0, 'function CONTspeaking(MSecs: integer): Boolean;', @CONTspeaking);
  RegisterHeader(0, 'procedure AudioRecord(MSecs:Integer);', @AudioRecord);
  RegisterHeader(0, 'procedure PlayAudio(path:string); ', @PlayAudio);
  RegisterHeader(0, 'procedure SetWavSavePath(Path:string);', @SetWavSavePath);
  RegisterHeader(0, 'function CallingChannel(WAVPayFile:string;AudHash:string;MSecs:Integer):Single;', @CallingChannel);
  RegisterHeader(0, 'function GetAudioLevel():LongWord;', @GetAudioLevel);
  RegisterHeader(0, 'procedure SaveToIMG(SavePath:string);', @SaveToIMG);
  RegisterHeader(0, 'procedure AudioSave(path: string; MSecs: Integer);', @AudioSave);
  RegisterHeader(0, 'function AudioCompare(AudHash: string): Single;', @AudioCompare);
  RegisterHeader(0, 'procedure SendMail(Email: string; Subject : string; Body : string);', @SendMail);
  RegisterHeader(0, 'function FaceDetect(cameraID: Integer; X1, Y1, X2, Y2: Integer): Integer;', @FaceDetect);
  RegisterHeader(0, 'function GetAveRGB(CameraID: Integer; x1, y1, x2, y2: Integer; RGB: string):Boolean;', @GetAveRGB);
  RegisterHeader(0, 'function GetRGB(CameraID: Integer; x, y: Integer; RGB: string):Boolean;', @GetRGB);
  RegisterHeader(0, 'procedure TestRecord(path:string)', @TestRecord);
  RegisterHeader(0, 'procedure StopRecord();', @StopRecord);
end.

