unit ComRead2;

interface

uses
  Classes;

type
  ReadCOM2 = class(TThread)
  private
   m_buf2 : array [0..1023] of Char;
    { Private declarations }
  protected
    procedure Execute; override;
    procedure ShowData2;        
  end;

implementation

uses
  SysUtils, ExGlobal, PComm, DeviceLog;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure Read2.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ Read2 }



procedure ReadCOM2.ShowData2;
var
  lend : LongInt;
  Str:string;
  DataLenRx:Integer;
begin
  (*
    When got any data,dump buffer to Edit window.

    NOTE:
    If any Null character in buffer,
    characters after null can't be dumped
    to Edit window.
  *)

  lend := Length(LogForm.Memo2.Text);

  Str:=  (string(m_buf2));

  LogForm.Memo2.SelStart := lend;
  LogForm.Memo2.SelLength := 0;
  LogForm.Memo2.SelText := Str;
end;

procedure ReadCOM2.Execute;
var
  len : LongInt;
begin
  (* before close port,set GhExit to true to terminate
     the read thread *)
  FreeOnTerminate:=True;     
  while not COM2GhExit do
  begin
    Sleep(3);  //10
    len := sio_read(Com2,@m_buf2,1023);
    if (len>0) then
    begin
      m_buf2[len] := Char(0);{null terminated string}
      Synchronize(ShowData2);
    end
  end;
end;

end.
