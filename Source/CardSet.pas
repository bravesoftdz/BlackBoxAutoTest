unit CardSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormCardSet = class(TForm)
    lbl1: TLabel;
    cbbPort: TComboBox;
    chk1: TCheckBox;
    btnCfgOK: TButton;
    btnCfgCancel: TButton;
    btn1: TButton;
    ListBox1: TListBox;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    Lbl2: TLabel;
    Button2: TButton;
    Button3: TButton;
    edt1: TEdit;
    lbl3: TLabel;
    Button4: TButton;
    dlgSave1: TSaveDialog;
    edt2: TEdit;
    Label2: TLabel;
    procedure btnCfgCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCfgOKClick(Sender: TObject);
    procedure cbbPortChange(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure edt2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCardSet: TFormCardSet;

implementation

uses ExGlobal, PComm, Unit1;

{$R *.dfm}

procedure TFormCardSet.btnCfgCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCardSet.FormCreate(Sender: TObject);
begin
  cbbPort.Items := ComStrList;
end;

procedure TFormCardSet.btnCfgOKClick(Sender: TObject);
var
  ret: Integer;
begin
  ComCard := GetNum(cbbPort.text);
  ret := sio_open(ComCard);
  if ret <> SIO_OK then
  begin
    Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'sio_open' + IntToStr(ret));
    Exit;
  end;
  if sio_ioctl(ComCard, B19200, P_NONE or BIT_8 or STOP_1) <> sio_ok then
  begin
    sio_close(ComCard);
    Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'sio_ioctl' + IntToStr(ret));
    Exit;
  end;
  Close;
end;

procedure TFormCardSet.cbbPortChange(Sender: TObject);
begin
  sio_close(ComCard);
end;

procedure TFormCardSet.btn1Click(Sender: TObject);
begin
  refreshComList;
  cbbPort.Items := ComStrList;
end;

procedure TFormCardSet.Button1Click(Sender: TObject);

var
  F: TextFile;
  S: string;
  num: Int64;
begin
  if OpenDialog1.Execute then // Display Open dialog box
  begin
    ListBox1.Items.Clear;
    AssignFile(F, OpenDialog1.FileName); //绑定文件到文件类型变量
    Reset(F); //打开一个存在的文件,另Rewrite创建文件并打开
    while not eof(F) do begin
      Readln(F, S);
      if S = '' then //去除空行
        continue;
      num := getnum(S); //保留数字，去除非数字字符
      if (num < 4294967296) and (num > 0) then
        ListBox1.Items.Add(inttostr(num));
    end;
    CloseFile(F);
    lbl2.Caption := IntToStr(ListBox1.Items.count); //显示文件数
  end;
end;

procedure TFormCardSet.Button2Click(Sender: TObject);
begin
  ListBox1.Items.Clear;
end;

procedure TFormCardSet.Button3Click(Sender: TObject);
var
  H, L, num: string;
  i: Integer;
begin
  Randomize;
  for i := 0 to strtoint(edt1.text)-1 do
  begin
    H := IntToStr(Random(42950));
    l := IntToStr(Random(67296));
    num := h + l;
    ListBox1.Items.Add(num);
  end;
  lbl2.Caption := IntToStr(ListBox1.Items.count); //显示文件数
end;

procedure TFormCardSet.Button4Click(Sender: TObject);
begin
  dlgSave1.DefaultExt := 'txt';
  dlgSave1.Filter := '文本文档(*.txt)|*.txt';
  if dlgSave1.Execute then
  begin
    if FileExists(dlgSave1.FileName) then
    begin
      if MessageBox(0, '文件已存在，是否覆盖', 'information', MB_OKCANCEL) = MB_OKCANCEL then
      begin
        listbox1.Items.savetofile(dlgSave1.FileName);
      end;
    end
    else
    begin
      listbox1.Items.savetofile(dlgSave1.FileName);
    end;
  end;
end;

procedure TFormCardSet.edt1KeyPress(Sender: TObject; var Key: Char);
begin
 if not (Key in ['0'..'9',#8]) then Key := #0;
end;

procedure TFormCardSet.edt2KeyPress(Sender: TObject; var Key: Char);
begin
 if not (Key in ['0'..'9',#8]) then Key := #0;
end;

end.

