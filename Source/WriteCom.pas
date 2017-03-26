unit WriteCom;

interface

uses
  Classes;

type
  WriteComThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  ExGlobal,Windows,SysUtils, Unit1;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure WriteComThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ WriteComThread }



procedure WriteComThread.Execute;
var
  beginTick, endTick: longint;
  sendtimes: integer; // 命令重发次数
begin
  FreeOnTerminate:=True;
  beginTick := GetTickCount; // 计数初值
  sendtimes := 0; // 重置重发次数
  while true do
  begin
    endTick := GetTickCount;
    if Rec_OK then
    begin
      Rec_OK := false;
      if (Rec_CMD = Send_CMD) then // 检测命令是否与发送一致
      begin
        strhexCache := ''; // 清空发送数据
        sendtimes := 0; // 清空重发次数
        SendOK := true;
        break;
      end;
    end
    else if (endTick - beginTick) > overtime then // 数据发送超时
    begin
      beginTick := GetTickCount; // 重新获取计数初值
      WriteStrhex(Comresend,strhexCache);
      sendtimes := sendtimes + 1;
    end;

    if sendtimes >= 2 then // 重发2次
    begin
      sendtimes := 0;
      strhexCache := ''; // 清空发送数据
      SendNG := True; // 发送失败
     // Form1.stat1.Panels[0].Text := '通讯无应答';
      break;
    end;
    sleep(1);
  end;
end;

end.
