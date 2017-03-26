unit ComRead3;

interface

uses
  Classes;

type
  ReadCOM3 = class(TThread)
  private
    m_buf: array [0..1023] of Byte;
    { Private declarations }
    { Private declarations }
  protected
    procedure Execute; override;
  end;


implementation

uses
  Windows, SysUtils, PComm, ExGlobal, DeviceLog, Dialogs, LogOption;



function StrToHexStr(const S: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
  begin
    if I = 1 then
      Result := IntToHex(Ord(S[1]), 2)
    else
      Result := Result + IntToHex(Ord(S[I]), 2);
  end;
end;

procedure ReadCOM3.Execute;
var
  len: LongInt;
  temp, str: string;
  t: string;
begin
  FreeOnTerminate := True;
  while not COM3GhExit do
  begin
    Sleep(10); //10
    t := FormatDateTime('yyyy-mm-dd hh:mm:ss zzz', now);
    len := sio_read(Com3, @m_buf, 1023);
    if (len > 0) then
    begin
      SetLength(str, len);
      Move(PChar(@m_buf)^, PChar(@str[1])^, len);
      temp := strtohexstr(str);
      //  m_buf[len] := Char(0);{null terminated string}
       // Synchronize(ShowData);
      LogForm.Memo1.Lines.Add(t+': '+temp);
     // LogForm.Memo1.Lines.Add(temp);

    end;
  end;
end;

end.

