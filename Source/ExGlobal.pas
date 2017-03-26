unit ExGlobal;

interface

uses SysUtils, Dialogs, StrUtils, Registry, Classes, Windows, Forms,Math,Tlhelp32;

function TrimAll(const S: string): string; //ȥ���ַ��������пո�
function SendStrhex(Com: Integer; sData: string): integer;
  //�������ݷ��Ͳ����Ӧ���ط�
function WriteStrhex(Com: Integer; sData: string): integer; //�������ݷ���
procedure EnumComDevicesFromRegistry(List: TStrings); //��ȡ���Դ����б�
procedure MxShowError(title: string; errcode: LongInt);
function OpenPort(port: integer; Baud: integer; mode: LongInt): Boolean;
  //�򿪴���
function GetNum(Str: string): int64; // ���ַ�������ȡ����
function ClosePort1(COM: integer): Integer; //�رմ���
procedure refreshComList(); //ˢ�´����б�
function SplitString(const source, ch: string): tstringlist; //��Ch �ָ��ַ���
procedure Delayms(MSecs: Longint); //��ʱms
function Rand(Min:Integer;Max:Integer):integer;  //����һ�������
function StrRand(Min:Integer;Max:Integer):string;  //����һ�������
function CheckThreadFreed(aThread: TThread): Byte; //�ж��߳��Ƿ��ͷ�
function GetDosOutput(Command: string): string;
function EndProcess(ExeFileName:string):integer;
function StringToHex(s: string): string;
var
  { Global variable for example }
  Com1Open: boolean; { opened ? }
  Com2Open: Boolean;
  Com3Open: Boolean;
  COM1GhExit: boolean; { stop thread ? }
  COM2GhExit: boolean;
  COM3GhExit: boolean;
  ScripThreadExit: Boolean; {stop scrip thread}
  Com1: Integer;
  Com2: Integer;
  Com3: Integer;
  ComCard:integer;//ģ�⿨���ں�
  Comresend:integer;
  overtime:Integer;
  ComNum: Integer;
  ComStrList: TStrings; {�����б�}
  {���ݽ���ȫ�ֱ���}
  Rec_OK: Boolean;
  Rec_CMD: Byte; {������}
  Send_CMD: Byte; {���͵�������}
  Rec_DATA: array[0..12] of Byte; {���ݽ���}
  SendOK: Boolean; //����������ɲ��յ�Ӧ��
  SendNG: Boolean; //��������δ�յ�Ӧ��  
  strhexCache: string; //�������ݻ��棬�����ط�
  APPpath: string; //Ӧ�ó���·��
  filespath: string; //�ļ���·��  
  ExitDelay:Boolean;//�˳���ʱ
  LogFlag:Integer;
  logCPFlag:Boolean;
  LogTxt:string;
  LogPath:string;

  //{$define DEBUG}
implementation

uses PComm, Unit1, WriteCom, ReadComThread;

function EndProcess(ExeFileName:string):integer;
const
  PROCESS_TERMINATE = $0001;
var   
  ContinueLoop: BOOLean;  
  FSnapshotHandle: THandle;  
  FProcessEntry32:TProcessEntry32;  
begin  
  Result := 0;  
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);  
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);  
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);   
  
while Integer(ContinueLoop) <> 0 do   
begin   
  if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =  
  UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =  
  UpperCase(ExeFileName))) then  
  Result := Integer(  
  TerminateProcess(OpenProcess(PROCESS_TERMINATE,  
  BOOL(0),FProcessEntry32.th32ProcessID),0));  
  ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);  
end;   
  CloseHandle(FSnapshotHandle);   
end;

function GetDosOutput(Command: string): string;
var
  hReadPipe: THandle;
  hWritePipe: THandle;
  SI: TStartUpInfo;
  PI: TProcessInformation;
  SA: TSecurityAttributes;
  BytesRead: DWORD;
  Dest: array[0..32767] of ansichar;
  CmdLine: array[0..512] of char;
  Avail, ExitCode, wrResult: DWORD;
  osVer: TOSVERSIONINFO;
  tmpstr: string;
  Line: string;
begin
  osVer.dwOSVersionInfoSize := Sizeof(TOSVERSIONINFO);
  GetVersionEX(osVer);
  if osVer.dwPlatformId = VER_PLATFORM_WIN32_NT then
  begin
    SA.nLength := SizeOf(SA);
    SA.lpSecurityDescriptor := nil;
    SA.bInheritHandle := True;
    CreatePipe(hReadPipe, hWritePipe, @SA, 0);
  end
  else
    CreatePipe(hReadPipe, hWritePipe, nil, 1024);
  try
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(TStartUpInfo);
    SI.wShowWindow := SW_HIDE;
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.dwFlags := SI.dwFlags or STARTF_USESTDHANDLES;
    SI.hStdOutput := hWritePipe;
    SI.hStdError := hWritePipe;
    StrPCopy(CmdLine, Command);
    if CreateProcess(nil, CmdLine, nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, SI, PI) then
    begin
      ExitCode := 0;
      while ExitCode = 0 do
      begin
        wrResult := WaitForSingleObject(PI.hProcess, 1000);
        if PeekNamedPipe(hReadPipe, @Dest[0], 32768, @Avail, nil, nil) then
        begin
          if Avail > 0 then
          begin
            try
              FillChar(Dest, SizeOf(Dest), 0);
              ReadFile(hReadPipe, Dest[0], Avail, BytesRead, nil);
              TmpStr := Copy(Dest, 0, BytesRead - 1);
              Line := Line + TmpStr;
            except
            end;
          end;
        end;
        if wrResult <> WAIT_TIMEOUT then
          ExitCode := 1;
      end;
      GetExitCodeProcess(PI.hProcess, ExitCode);
      CloseHandle(PI.hProcess);
      CloseHandle(PI.hThread);
    end;
  finally
    if line = '' then
      line := 'NULL'; //����û�������Ӧ!
    result := Line;
    CloseHandle(hReadPipe);
    CloseHandle(hWritePipe);
  end;
end;

procedure ClearRecData();
var
  i:Integer;
begin
  for i:=0 to 12 do
    Rec_DATA[i]:=0;
end;

function StringToHex(s: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to length(s) do
    Result := Result + IntToHex(ord(s[i]), 2);
end;

function TrimAll(const S: string): string; //ȥ���ַ��������пո�
begin
  Result := S;
  while pos(' ', Result) > 0 do
    Delete(Result, pos(' ', Result), 1);
end;

function GetCheck(AStr: string): string;
var
  newstr1, he, oldstr: string;
  tj: boolean;
  count, i: integer;
begin
  i := 1;
  he := '';
  tj := true;
  // ȡ��Ҫ����У��ͼ�����ַ�����oldstr
  if (length(AStr) mod 2) <> 0 then
  begin
    result := '00';
    // showmessage('�������Դ������д����������������������룡');
    exit;
  end;
  count := Length(AStr);
  oldstr := copy(AStr, 1, Count);
  while tj = true do
  begin
    newstr1 := copy(oldstr, i, 2);
    oldstr := copy(oldstr, i + 2, length(oldstr) - 2);
    // ��ʼ����У��Ͳ���he����
    if he = '' then
    begin
      he := inttohex(strtointdef('$' + newstr1, 16) xor strtointdef('$' + '00',
        16), 2);
      he := rightstr(he, 2);
    end
    else
    begin
      he := inttohex(strtointdef('$' + newstr1, 16) xor strtointdef('$' + he,
        16), 2);
      he := rightstr(he, 2);
    end;
    if length(oldstr) = 0 then
      tj := false;
  end;
  result := he;
end;

function WriteStrhex(Com: Integer; sData: string): integer;
var
  s2: string;
  buf1: array[0..511] of char;
  i: integer;
begin
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
  strhexCache := s2; //���ͻ���
  s2 := s2 + GetCheck(s2); //���У��
  for i := 0 to (length(s2) div 2 - 1) do
    buf1[i] := char(strtoint('$' + copy(s2, i * 2 + 1, 2)));
  result := sio_write(Com, @buf1, (length(s2) div 2));
  {$IFDEF DEBUG}
  Mainform.mmo1.Lines.Append(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz',now)+' ' +'Sent:' + s2 )
  {$endif}
end;

function SendStrhex(Com: Integer; sData: string): integer;
var
  cmd:string;
begin
  SendOK:=False; //���ͳɹ���־
  sendNG:=False;//����ʧ�ܱ�־
  cmd:= '$' + Copy(sData,7,2); //��ȡ����������
  Send_CMD:= StrToInt(cmd);
  ClearRecData(); //��ս��ջ���
  Result := WriteStrhex(Com, sData);
  Comresend:=Com;
  overtime := 500;
   WriteComThread.Create(false); //Ӧ���ط�
end;

//��ȡ���Դ����б�

procedure EnumComDevicesFromRegistry(List: TStrings);
var
  Names: TStringList;
  i: Integer;
begin
  with TRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM') then
      begin
        Names := TStringList.Create;
        try
          GetValueNames(Names);
          for i := 0 to Names.Count - 1 do
            if GetDataType(Names[i]) = rdString then
              List.Add(ReadString(Names[i]));
        finally
          Names.Free;
        end
      end;
    finally
      Free;
    end;
end;

procedure ShowSysErr(title: string);
var
  syserr: LongInt;
  lpMsgBuf: array[0..79] of Char;
  lang: LongInt;
begin
  syserr := GetLastError();

  {MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT) }
  lang := (SUBLANG_DEFAULT shl 10) + LANG_NEUTRAL;

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    nil,
    syserr,
    lang,
    @lpMsgBuf,
    80,
    nil
    );
  Application.MessageBox(lpMsgBuf, PChar(title), MB_OK or MB_ICONSTOP);
end;

procedure MxShowError(title: string; errcode: LongInt);
var
  buf: string;
begin
  if errcode <> SIO_WIN32FAIL then
  begin
    case errcode of
      SIO_BADPORT:
        buf := 'Port number is invalid or port is not opened in advance';
      SIO_OUTCONTROL:
        buf := 'This board does not support this function';
      SIO_NODATA:
        buf := 'No data to read';
      SIO_OPENFAIL:
        buf := 'No such port or port is occupied by other program';
      SIO_RTS_BY_HW:
        buf := 'RTS can''t be set because H/W flowctrl';
      SIO_BADPARM:
        buf := 'Bad parameter';
      SIO_BOARDNOTSUPPORT:
        buf := 'This board does not support this function';
      SIO_ABORT_WRITE:
        buf := 'Write has blocked, and user abort write';
      SIO_WRITETIMEOUT:
        buf := 'Write timeout has happened';
    else
      buf := 'Unknown Error:' + IntToStr(errcode);
    end;
    Application.MessageBox(PChar(buf), PChar(title), MB_OK or MB_ICONSTOP);
  end
  else
    ShowSysErr(title);
end;

//������ͨ�Ų����ĺ���ʵ��

function PortSet(port: integer; Baud: integer; mode: Integer): Boolean;
var
  Ret: LongInt;
begin
  // mode:=P_NONE or BIT_8 or STOP_1;
  // HW:=0;//û��Ӳ����������
  // Sw:=0;//û�������������
  Result := False;
  Ret := sio_ioctl(port, Baud, mode); //setting
  if Ret <> sio_ok then
  begin
    MxShowError('sio_open', ret);
    Exit;
  end;
  Result := True;
end;

function OpenPort(port: integer; Baud: integer; mode: Integer): Boolean;
var
  ret: Integer;
begin
  OpenPort := false;
  ret := sio_open(port);
  if ret <> SIO_OK then
  begin
    Mainform.mmo1.Lines.Append(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz',now)+' ' +'sio_open'+ IntToStr(ret) );
   // MxShowError('sio_open', ret);
    Exit;
  end;
  if PortSet(port, Baud, mode) = false then
  begin
    sio_close(port);
    Exit;
  end;
  ret := SIO_DTR(port, 0); //����DTR��RTS�ĵ�ѹ
  ret := sio_RTS(port, 0);
  OpenPort := true;
  case ComNum of
    1:
      begin
        COM1GhExit := false;
        Com1Open := True;
        TReadThread.Create(false);
      end;
    2:
      begin
        COM2GhExit := false;
        Com2Open := True;
   //     DEVThread:=ReadCOM2.Create(false);
      end;
    3:
      begin
        COM3GhExit := false;
        Com3Open := True;
    //    COMMThread:=ReadCOM3.Create(false);
      end;
  end;
end;

function GetNum(Str: string): int64; // ���ַ�������ȡ����
var
  i, n: integer;
  sStr: string;
begin
  sStr := '';
  n := length(Str);
  for i := n downto 1 do
    if Str[i] in ['0'..'9'] then
      sStr := Str[i] + sStr;
  if sStr ='' then
    sStr := '0';    
  result := StrToint64(sStr);
end;

function ClosePort1(COM: integer): Integer; //�رմ���
begin
  COM1GhExit := true;
  Result := sio_close(Com);
  COM1Open := False;
end;

procedure refreshComList(); //ˢ�´����б�
begin
  ComStrList := Tstringlist.Create;
  EnumComDevicesFromRegistry(ComStrList);
end;

function SplitString(const source, ch: string): tstringlist; //��Ch �ָ��ַ���
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

function Rand(Min:Integer;Max:Integer):integer;  //����һ�������
begin
  Randomize;      //��ʼ�������������
  Result:=RandomRange(min,max+1); //����һ��0<=X<Range�������
end;

function StrRand(Min:Integer;Max:Integer):string;  //����һ�������
begin
  Randomize;      //��ʼ�������������
  Result:=IntToStr(RandomRange(min,max+1)); //����һ��0<=X<Range�������
end;

procedure Delayms(MSecs: Longint);
var
  FirstTickCount, Now: Longint;
begin
  FirstTickCount := GetTickCount();
  repeat
    Application.ProcessMessages;
    Sleep(1);
    Now := GetTickCount();
  until (Now - FirstTickCount >= MSecs) or (Now < FirstTickCount ) or ExitDelay;
end;

//�����������Դ�����̳��
//�ж��߳��Ƿ��ͷ�
//����ֵ��0-���ͷţ�1-�������У�2-����ֹ��δ�ͷţ�
//3-δ�����򲻴���
function CheckThreadFreed(aThread: TThread): Byte;
var
 i: DWord;
 IsQuit: Boolean;
begin
 if Assigned(aThread) then
 begin
   IsQuit := GetExitCodeThread(aThread.Handle, i);
   if IsQuit then           //If the function succeeds, the return value is nonzero.
                                 //If the function fails, the return value is zero.
   begin
     if i = STILL_ACTIVE then    //If the specified thread has not terminated,
                                 //the termination status returned is STILL_ACTIVE.
       Result := 1
     else
       Result := 2;              //aThread?Free,??Tthread.Destroy??????
   end
   else
     Result := 0;                //???GetLastError??????
 end
 else
   Result := 3;
end;

end.

