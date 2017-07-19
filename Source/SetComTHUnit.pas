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
  ExGlobal, PComm, Unit1, SysUtils, Forms,DobotExGlobal;

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
    // 按串口列表发送数据
    try
      ComNum := 1;
      OpenPort(COM1, B9600, P_NONE or BIT_8 or STOP_1);
      MainForm.mmo1.Lines.Add('COM' + IntToStr(COM1) + '串口检测');
    except
      ClosePort1(COM1);
      MainForm.mmo1.Lines.Add(ComStrList.ValueFromIndex[i] + '串口未找到');
      Continue;
    end;
    SendStrhex(Com1, '55FF01B600');

    while true do //等待数据接收
    begin
      sleep(1);
      Application.ProcessMessages;
      if sendOK then // 发送成功
      begin
        if (Rec_CMD = $B6) and (Rec_DATA[1] = 01) then
        begin
          Com1Open := True;
          MainForm.SwitchMenu();
          MainForm.mmo1.Lines.Add('找到控制器，串口设置成功！');
          StartDobot();
          exit; // 退出线程
        end
        else
        begin
          ClosePort1(COM1); //关闭串口继续
          break;
        end;
      end;
      if sendNG then // 发送无应答
      begin
        ClosePort1(COM1);
        break;
      end;
    end;
  end;
  MainForm.mmo1.Lines.Add('未找到控制器，请检查串口连接是否正常！');
  StartDobot();
end;

procedure SetCom.Execute;
begin
  FreeOnTerminate := True;
  Synchronize(Myfun);
end;


end.
