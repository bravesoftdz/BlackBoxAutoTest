unit adbunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAdbSetForm = class(TForm)
    dlgOpen1: TOpenDialog;
    edt1: TEdit;
    lbl1: TLabel;
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AdbSetForm: TAdbSetForm;
  ADBpath:string;  
implementation

{$R *.dfm}

procedure TAdbSetForm.btn1Click(Sender: TObject);
var
  F: TextFile;
  S: string;
begin
  dlgOpen1.Filter := 'exe(*.exe)|*.exe';
  if dlgOpen1.Execute then
  begin
    ADBpath := dlgOpen1.FileName;
    edt1.Text :=ADBpath;
  end;
end;

procedure TAdbSetForm.FormCreate(Sender: TObject);
begin
   edt1.Text :=ADBpath;
end;

end.
