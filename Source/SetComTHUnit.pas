unit SetComTHUnit;

interface

uses
  Classes;

type
  SetCom = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure Myfun;
  end;

implementation

uses
  ExGlobal, PComm, Unit1, SysUtils, Forms;

{ SetCom }
procedure SetCom.Myfun;
 var
   i:Integer;
begin
 for i := 0 to ComStrList.Count - 1 do
  begin
    if Com1Open then
      ClosePort1(COM1);
    COM1 := GetNum(ComStrList.ValueFromIndex[i]);
    // �������б�������
    try
      ComNum := 1;
      OpenPort(COM1, B9600, P_NONE or BIT_8 or STOP_1);
      MainForm.mmo1.Lines.Add('COM' + IntToStr(COM1) + '���ڼ��');
    except
      ClosePort1(COM1);
      MainForm.mmo1.Lines.Add(ComStrList.ValueFromIndex[i] + '����δ�ҵ�');
      Continue;
    end;
    SendStrhex(Com1, '55FF01B600');

    while true do //�ȴ����ݽ���
    begin
      sleep(1);
      Application.ProcessMessages;
      if sendOK then // ���ͳɹ�
      begin
        if (Rec_CMD = $B6) and (Rec_DATA[1] = 01) then
        begin
          Com1Open := True;
          MainForm.SwitchMenu();
          MainForm.mmo1.Lines.Add('�ҵ����������������óɹ���');
          exit; // �˳��߳�
        end
        else
        begin
          ClosePort1(COM1); //�رմ��ڼ���
          break;
        end;
      end;
      if sendNG then // ������Ӧ��
      begin
        ClosePort1(COM1);
        break;
      end;
    end;
  end;
  MainForm.mmo1.Lines.Add('δ�ҵ������������鴮�������Ƿ�������');
end;

procedure SetCom.Execute;
begin
  FreeOnTerminate := True;
  Synchronize(Myfun);
end;


end.
