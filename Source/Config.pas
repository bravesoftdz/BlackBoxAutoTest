(*********************************************************************
    Config.pas
     -- Config dialog for com port commnucation parameters


    History:   Date       Author         Comment
               3/9/98     Casper         Wrote it.

**********************************************************************)
unit Config;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,StdCtrls, Buttons;

type
  TCfgForm = class(TForm)
    cbPort: TComboBox;
    Label1: TLabel;
    CfgOK: TButton;
    CfgCancel: TButton;
    chk1: TCheckBox;
    btn1: TBitBtn;
    procedure CfgOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CfgCancelClick(Sender: TObject);
    procedure cbPortChange(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CfgForm: TCfgForm;

implementation

uses ExGlobal, PComm, ReadComThread, Unit1;
{$R *.DFM}

procedure TCfgForm.FormCreate(Sender: TObject);
begin
  cbPort.Items:=ComStrList;
end;

procedure TCfgForm.CfgOKClick(Sender: TObject);
begin
   COM1:= GetNum(cbPort.text);
   if Com1Open then
     ClosePort1(COM1);
   ComNum:=1;
   OpenPort(COM1,B9600,P_NONE or BIT_8 or STOP_1);
   MainForm.SwitchMenu();
   Close;
end;   

procedure TCfgForm.CfgCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCfgForm.cbPortChange(Sender: TObject);
begin
  ClosePort1(COM1);
end;

procedure TCfgForm.btn1Click(Sender: TObject);
begin
  refreshComList;
  cbPort.Items := ComStrList;
end;

end.
