unit DeviceComunicationLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Spcomm;

type
  TCOMMLogForm = class(TForm)
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
    procedure CfgOKClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure CfgCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  COMMLogForm: TCOMMLogForm;

implementation

uses
  ExGlobal, PComm, DeviceLog;

{$R *.dfm}

procedure TCOMMLogForm.FormCreate(Sender: TObject);
begin
  cbPort.Items := ComStrList;
end;

procedure TCOMMLogForm.CfgOKClick(Sender: TObject);
var
  Baudrate: integer;
begin
  BaudRate := StrToInt(cbBaudRate.text);
  LogForm.Comm1.CommName:= cbPort.text;
  LogForm.Comm1.BaudRate:= BaudRate;
  LogForm.Comm1.ByteSize:=_8;
  LogForm.Comm1.Parity:=None;
  LogForm.Comm1.StopBits:=_1;
  LogForm.Comm1.StartComm;  
  LogForm.N9.Enabled := False;
  LogForm.N10.Enabled := True;
  ModalResult := mrOk;
end;
procedure TCOMMLogForm.btn1Click(Sender: TObject);
begin
  refreshComList;
  cbPort.Items := ComStrList;
end;

procedure TCOMMLogForm.CfgCancelClick(Sender: TObject);
begin
  Close;
end;

end.

