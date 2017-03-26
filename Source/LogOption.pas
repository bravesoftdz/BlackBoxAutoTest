unit LogOption;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TOptionForm = class(TForm)
    chk1: TCheckBox;
    edt1: TEdit;
    btn1: TButton;
    btn2: TButton;
    dlgSave1: TSaveDialog;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
  logpath:string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionForm: TOptionForm;

implementation

uses
  ComRead3, ExGlobal;

{$R *.dfm}


procedure TOptionForm.FormCreate(Sender: TObject);
begin
    logpath:=  APPpath +'log_'+ FormatDateTime('yyyymmddhhmmss',now) + '_DEV.txt';
    edt1.Text := logpath;
    logpath:=  APPpath +'log_'+ FormatDateTime('yyyymmddhhmmss',now) + '_DEV.txt';
    edit1.Text := logpath;    
end;

procedure TOptionForm.btn1Click(Sender: TObject);
begin
  dlgSave1.DefaultExt := 'txt';
  dlgSave1.Filter := 'ÎÄ±¾ÎÄµµ(*.txt)|*.txt';
  dlgSave1.FileName:=logpath;
  if dlgSave1.Execute then
  begin
    edt1.Text:= dlgSave1.FileName;
    logpath:= dlgSave1.FileName;
  end;
end;

end.
