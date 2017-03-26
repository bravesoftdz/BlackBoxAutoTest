unit ReadComThread;

interface

uses
  Classes;

type
  TReadThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  Unit1,SysUtils, ExGlobal, PComm,Dialogs;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TReadThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TReadThread }

procedure TReadThread.Execute;
const
  G_HEAD1 = -1;{帧头1}
  G_HEAD2 = -2;{帧头2}
  G_LEN = -3;  {数据长度}
  G_TYPE = -4; {命令字}
  G_DATA = -5; {数据}
  G_CHECK = -6;{校验}
var
  ch : longint;
  g_RecState:Integer; //数据接收状态
  g_reclen:Integer;//数据长度
  g_recheck:Integer;//校验
  len:Integer;
  viewstr:string;
  CheckSum:byte;//计算校验
begin
  (* before close port,set GhExit to true to terminate
     the read thread *)
  FreeOnTerminate:=True;     
  g_RecState:= G_HEAD1;
  while not COM1GhExit do
  begin
    Sleep(1);  //10
    ch := sio_getch(Com1);{读取一个字节}
    if ch >=0 then
    begin
     case g_RecState of
            G_HEAD1:
              begin
               if ch = $AA then
                  begin
                      g_RecState:= G_HEAD2;
                      CheckSum := ch;
                      viewstr:= IntToHex(ch,2);
                  end
               else
                  begin
                      g_RecState:= G_HEAD1;
                      viewstr := '';
                  end;
              end;
            G_HEAD2:
               if ch =$FF then
                   begin
                       g_RecState:= G_LEN;
                       CheckSum := CheckSum xor ch;
                       viewstr:=viewstr + IntToHex(ch,2);
                   end
               else
                  if ch = $AA then
                    begin
                      g_RecState:= G_HEAD2;
                      CheckSum := ch;
                      viewstr:= IntToHex(ch,2);
                    end
                    else
                     begin
                      g_RecState:= G_HEAD1;
                      viewstr:='';
                     end;
             G_LEN:
                 begin
                   viewstr:=viewstr + IntToHex(ch,2);
                   g_reclen:= ch;
                   CheckSum := CheckSum xor ch;
                   g_RecState:= G_TYPE;
                 end;
             G_TYPE:
                 begin
                  viewstr:=viewstr + IntToHex(ch,2);
                   Rec_CMD:=ch;
                   CheckSum:= CheckSum xor ch;
                   g_RecState:= G_DATA;
                   len :=0;
                 end;
             G_DATA:
                 begin
                  viewstr:=viewstr + IntToHex(ch,2);
                   inc(len);
                   Rec_DATA[len]:=ch;
                   CheckSum:= CheckSum xor ch;
                   if len >= g_reclen then
                      g_RecState:= G_CHECK;
                 end;
             G_CHECK:
                 begin
                   g_recheck:=ch;
                   viewstr:=viewstr + IntToHex(ch,2);
                   if CheckSum = g_recheck then //校验
                     Rec_OK:=true;
                   g_RecState:=G_HEAD1;
                     {$IFDEF DEBUG}
                   Mainform.mmo1.Lines.Append(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz',now)+' ' +'Received:' + viewstr );
                     {$endif}
                   viewstr:='';
                 end;

     end;

     end;

  end;
 end;

end.




