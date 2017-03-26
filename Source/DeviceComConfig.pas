unit DeviceComConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Spcomm;

type
  TComuDeviceComSetForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cbPort: TComboBox;
    cbBaudRate: TComboBox;
    cbParity: TComboBox;
    cbByteSize: TComboBox;
    cbStopBits: TComboBox;
    GroupBox2: TGroupBox;
    chHw: TCheckBox;
    chSw: TCheckBox;
    CfgOK: TButton;
    CfgCancel: TButton;
    GroupBox3: TGroupBox;
    chDtr: TCheckBox;
    chRts: TCheckBox;
    btn1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure CfgCancelClick(Sender: TObject);
    procedure CfgOKClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ComuDeviceComSetForm: TComuDeviceComSetForm;

implementation

uses
  PComm, ExGlobal, DeviceLog;

{$R *.dfm}

procedure TComuDeviceComSetForm.FormCreate(Sender: TObject);
begin
  cbPort.Items := ComStrList;
end;

procedure TComuDeviceComSetForm.CfgCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TComuDeviceComSetForm.CfgOKClick(Sender: TObject);
var
  Baudrate: integer;
begin
  BaudRate := strtoint(cbBaudRate.text);
  LogForm.Comm2.CommName:= cbPort.text;
  LogForm.Comm2.BaudRate:= BaudRate;
  LogForm.Comm2.StartComm;
  LogForm.N7.Enabled := False;
  LogForm.N8.Enabled := True;
  ModalResult := mrOk;
end;

procedure TComuDeviceComSetForm.btn1Click(Sender: TObject);
begin
  refreshComList;
  cbPort.Items := ComStrList;
end;

end.

