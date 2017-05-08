unit AutoSaveUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,FileCtrl ;

type
  TautoSaveForm = class(TForm)
    AutoSavechk: TCheckBox;
    Edt2: TEdit;
    edt1: TEdit;
    tmr1: TTimer;
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure edt1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  AutoSavePath:string;
  public
    { Public declarations }
  end;

var
  autoSaveForm: TautoSaveForm;

implementation

uses
  Unit1, RunPASScript, ExGlobal;

{$R *.dfm}

procedure TautoSaveForm.Button1Click(Sender: TObject);
begin
  if SelectDirectory('��ָ���ļ���','',AutoSavePath) then
      Edt2.Text:= AutoSavePath;

end;
procedure TautoSaveForm.tmr1Timer(Sender: TObject);
begin
  if AutoSavePath = '' then
     AutoSavePath := APPpath + 'Log' ;
  if not DirectoryExists(AutoSavePath) then //�ж��ļ����Ƿ���ڣ��������򴴽��ļ���
     ForceDirectories(AutoSavePath); //�����ļ���
   MainForm.mmo1.Lines.SaveToFile(AutoSavePath + '\'  + FormatDateTime('yyyymmdd', now) + '_autosave.txt');

end;

procedure TautoSaveForm.edt1KeyPress(Sender: TObject; var Key: Char);
begin
 if not (Key in ['0'..'9',#8]) then Key := #0;
end;

procedure TautoSaveForm.edt1Change(Sender: TObject);
var
  t:Integer;
begin
  t:=GetNum(edt1.Text);
  if t < 5 then
  begin
     edt1.Text :='5';
     Exit;
  end
  else
  begin
     tmr1.Interval := t * 60000;
  end;

end;

procedure TautoSaveForm.FormCreate(Sender: TObject);
begin
      Edt2.Text:= AutoSavePath;
end;

end.
