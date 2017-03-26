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
  if SelectDirectory('请指定文件夹','',AutoSavePath) then
      Edt2.Text:= AutoSavePath;

end;
procedure TautoSaveForm.tmr1Timer(Sender: TObject);
begin
   MainForm.mmo1.Lines.Add(
    '完成：' + inttostr(finshtimes) + #13 +
    '通过：' + inttostr(Pass) + #13 +
    '失败：' + inttostr(Fail) + #13
    );
    if AutoSavePath = '' then
        AutoSavePath := APPpath + 'Log' ;
  if not DirectoryExists(AutoSavePath) then //判断文件夹是否存在，不存在则创建文件夹
     ForceDirectories(AutoSavePath); //创建文件夹
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
