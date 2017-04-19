//==============================================================================
// Unit Name: MultInst
// Author   : ysai
// Date     : 2003-05-20
// Purpose  : ���Ӧ�ó����ʵ������
// History  :
//==============================================================================

//==============================================================================
// ��������
// ����������ȡ��ԭ����������Ϣ��������,Ȼ��㲥һ����Ϣ.
// ���������ʵ������,�յ��㲥��Ϣ��ط���Ϣ�����ͳ���,���������Լ��ľ��
// ���ͳ�����յ�����Ϣ,�����յ���Ϣ�ĳ���,Ȼ��ر��Լ�
//==============================================================================
unit MultInst;

interface

uses
  Windows ,Messages, SysUtils, Classes, Forms;

implementation

const
  STR_UNIQUE    = '{1BE6D96E-827F-4BF8-B33E-8740412CDE69}';
  MI_ACTIVEAPP  = 1;  //����Ӧ�ó���
  MI_GETHANDLE  = 2;  //ȡ�þ��

var
  iMessageID    : Integer;
  OldWProc      : TFNWndProc;
  MutHandle     : THandle;
  BSMRecipients : DWORD;

function NewWndProc(Handle: HWND; Msg: Integer; wParam, lParam: Longint):
  Longint; stdcall;
begin
  Result := 0;
  if Msg = iMessageID then
  begin
    case wParam of
      MI_ACTIVEAPP: //����Ӧ�ó���
        if lParam<>0 then
        begin
          //�յ���Ϣ�ļ���ǰһ��ʵ��
          //ΪʲôҪ����һ�������м���?
          //��Ϊ��ͬһ��������SetForegroundWindow�����ܰѴ����ᵽ��ǰ
          if IsIconic(lParam) then
            OpenIcon(lParam)
          else
            SetForegroundWindow(lParam);
          //��ֹ��ʵ��
          Application.Terminate;
        end;
      MI_GETHANDLE: //ȡ�ó�����
        begin
          PostMessage(HWND(lParam), iMessageID, MI_ACTIVEAPP,
            Application.Handle);
        end;
    end;
  end
  else
    Result := CallWindowProc(OldWProc, Handle, Msg, wParam, lParam);
end;

procedure InitInstance;
begin
  //ȡ��Ӧ�ó������Ϣ����
  OldWProc    := TFNWndProc(SetWindowLong(Application.Handle, GWL_WNDPROC,
    Longint(@NewWndProc)));

  //�򿪻������
  MutHandle := OpenMutex(MUTEX_ALL_ACCESS, False, STR_UNIQUE);
  if MutHandle = 0 then
  begin
    //�����������
    MutHandle := CreateMutex(nil, False, STR_UNIQUE);
  end
  else begin
    Application.ShowMainForm  :=  False;
    //�Ѿ��г���ʵ��,�㲥��Ϣȡ��ʵ�����
    BSMRecipients := BSM_APPLICATIONS;
    BroadCastSystemMessage(BSF_IGNORECURRENTTASK or BSF_POSTMESSAGE,
        @BSMRecipients, iMessageID, MI_GETHANDLE,Application.Handle);
  end;
end;

initialization
  //ע����Ϣ
  iMessageID  := RegisterWindowMessage(STR_UNIQUE);
  InitInstance;

finalization
  //��ԭ��Ϣ��������
  if OldWProc <> Nil then
    SetWindowLong(Application.Handle, GWL_WNDPROC, LongInt(OldWProc));

  //�رջ������
  if MutHandle <> 0 then CloseHandle(MutHandle);

end.

 

//ʹ�÷����ܼ�,ֻҪ�Ѵ˵�Ԫ���빤�̾Ϳ�����.