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
  sendtimes: integer; // �����ط�����
begin
  FreeOnTerminate:=True;
  beginTick := GetTickCount; // ������ֵ
  sendtimes := 0; // �����ط�����
  while true do
  begin
    endTick := GetTickCount;
    if Rec_OK then
    begin
      Rec_OK := false;
      if (Rec_CMD = Send_CMD) then // ��������Ƿ��뷢��һ��
      begin
        strhexCache := ''; // ��շ�������
        sendtimes := 0; // ����ط�����
        SendOK := true;
        break;
      end;
    end
    else if (endTick - beginTick) > overtime then // ���ݷ��ͳ�ʱ
    begin
      beginTick := GetTickCount; // ���»�ȡ������ֵ
      WriteStrhex(Comresend,strhexCache);
      sendtimes := sendtimes + 1;
    end;

    if sendtimes >= 2 then // �ط�2��
    begin
      sendtimes := 0;
      strhexCache := ''; // ��շ�������
      SendNG := True; // ����ʧ��
     // Form1.stat1.Panels[0].Text := 'ͨѶ��Ӧ��';
      break;
    end;
    sleep(1);
  end;
end;

end.
