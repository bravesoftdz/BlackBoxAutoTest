unit DeviceLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus, SPComm;

type
  TLogForm = class(TForm)
    stat1: TStatusBar;
    MainMenu1: TMainMenu;
    N2: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    Memo2: TMemo;
    N11: TMenuItem;
    dlgSave1: TSaveDialog;
    Comm1: TComm;
    Comm2: TComm;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N1: TMenuItem;
    procedure N7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure Com2SwitchMenu;
    procedure Com3SwitchMenu;
    procedure N11Click(Sender: TObject);
    procedure Comm2ReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure Comm1ReceiveData(Sender: TObject; Buffer: Pointer;
      BufferLength: Word);
    procedure N12Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  LogForm: TLogForm;

implementation

uses
  PComm, ExGlobal, DeviceComConfig, DeviceComunicationLog, LogOption;

{$R *.dfm}

procedure TLogForm.N7Click(Sender: TObject);
begin
  LogForm.PageControl1.ActivePage :=TabSheet2;
  ComuDeviceComSetForm.ShowModal;
end;
procedure TLogForm.N9Click(Sender: TObject);
begin
  LogForm.PageControl1.ActivePage :=TabSheet1;
  COMMLogForm.ShowModal;
end;
procedure TLogForm.FormCreate(Sender: TObject);
begin
  Memo1.text:='';
  Memo2.text:='';
  Com2SwitchMenu();
  Com3SwitchMenu();
end;

procedure TLogForm.N8Click(Sender: TObject);
begin
  LogForm.Comm2.StopComm;
  LogForm.N7.Enabled := True;
  LogForm.N8.Enabled := False;
end;

procedure TLogForm.N4Click(Sender: TObject);
begin
  CLOSE;
end;



procedure TLogForm.N10Click(Sender: TObject);
begin
  LogForm.Comm1.StopComm;
  LogForm.N9.Enabled := True;
  LogForm.N10.Enabled := False;
end;

procedure TLogForm.Com2SwitchMenu;
begin
  N7.Enabled := not Com2Open;
  N8.Enabled := Com2Open;
end;

procedure TLogForm.Com3SwitchMenu;
begin
  N9.Enabled := not Com3Open;
  N10.Enabled := Com3Open;
end;
procedure TLogForm.N11Click(Sender: TObject);
begin
  optionform.ShowModal;
end;

procedure TLogForm.Comm2ReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
  var
    pstr:pchar;
begin
 pstr:=buffer;
 Memo2.Lines.Add(pstr);

end;
function StrToHexStr(const S: string): string;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
  begin
    if I = 1 then
      Result := IntToHex(Ord(S[1]), 2)
    else
      Result := Result + ' ' + IntToHex(Ord(S[I]), 2);
  end;
end;

function StrPosCount(subs:string;source:string):integer;
var
Str : string;
begin
Result := 0;
str := source;
while Pos(Subs,Str)<>0 do
begin
Delete(Str,Pos(Subs,Str),Length(Subs));
Inc(Result);
end;

end;

procedure TLogForm.Comm1ReceiveData(Sender: TObject; Buffer: Pointer;
  BufferLength: Word);
var
  str :string;
  strf:string;
  da,temp:string;
begin
  da := formatdatetime('yyyy-mm-dd hh:mm:ss zzz', now);
  memo1.Lines.Add(da);
  SetLength(Str,BufferLength);
  move(buffer^,pchar(@Str[1])^,bufferlength);
  temp:= StrToHexStr(str) + #13#10;
  if StrPosCount('55FF',temp) >= 2 then
    begin
      strf:= StringReplace(temp,'55 FF',#13#10+'55 FF', [rfReplaceAll]);
      Delete(strf, 1, 2);
    end
  else
    strf:= temp;
  memo1.Lines.Add(strf);
  //strsave(da+ #13#10,'c:\' + LogFile);
 // strsave(strf + #13#10,'c:\' + LogFile);
end;

procedure TLogForm.N12Click(Sender: TObject);
begin
  Memo2.Clear;
end;

procedure TLogForm.N14Click(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TLogForm.N15Click(Sender: TObject);
begin
  dlgSave1.DefaultExt := 'txt';
  dlgSave1.Filter := '文本文档(*.txt)|*.txt';
  if dlgSave1.Execute then
  begin
    if FileExists(dlgSave1.FileName) then
    begin
      if MessageBox(0, '文件已存在，是否覆盖', 'information', MB_OKCANCEL) = MB_OKCANCEL then
      begin
        memo1.Lines.SaveToFile(dlgSave1.FileName);
      end;
    end
    else
    begin
      memo1.Lines.SaveToFile(dlgSave1.FileName);
    end;
  end;
end;

procedure TLogForm.N13Click(Sender: TObject);
begin
  dlgSave1.DefaultExt := 'txt';
  dlgSave1.Filter := '文本文档(*.txt)|*.txt';
  if dlgSave1.Execute then
  begin
    if FileExists(dlgSave1.FileName) then
    begin
      if MessageBox(0, '文件已存在，是否覆盖', 'information', MB_OKCANCEL) = MB_OKCANCEL then
      begin
        memo2.Lines.SaveToFile(dlgSave1.FileName);
      end;
    end
    else
    begin
      memo2.Lines.SaveToFile(dlgSave1.FileName);
    end;
  end;
end;

end.
