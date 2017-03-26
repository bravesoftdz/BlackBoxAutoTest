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
    procedure btnCfgCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCfgOKClick(Sender: TObject);
    procedure cbbPortChange(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCardSet: TFormCardSet;

implementation

uses ExGlobal,PComm, Unit1;

{$R *.dfm}

procedure TFormCardSet.btnCfgCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormCardSet.FormCreate(Sender: TObject);
begin
  cbbPort.Items:=ComStrList;
end;

procedure TFormCardSet.btnCfgOKClick(Sender: TObject);
var
  ret: Integer;
begin
   ComCard:= GetNum(cbbPort.text);
  ret := sio_open(ComCard);
  if ret <> SIO_OK then
  begin
    Mainform.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz', now) + ' ' + 'sio_open' + IntToStr(ret));
    Exit;
  end;
  if sio_ioctl(ComCard, B9600, P_NONE or BIT_8 or STOP_1) <> sio_ok then
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
  num:Int64;
  begin
  if OpenDialog1.Execute then            // Display Open dialog box
  begin
          ListBox1.Items.Clear;
  AssignFile(F, OpenDialog1.FileName); //���ļ����ļ����ͱ���
  Reset(F);//��һ�����ڵ��ļ�,��Rewrite�����ļ�����
  while not eof(F) do begin
  Readln(F, S);
  if S = '' then  //ȥ������
  continue;
  num := getnum(S);//�������֣�ȥ���������ַ�
  if num < 4294967296 then
 // Memo1.Lines.Add(S);
          ListBox1.Items.Add(inttostr(num));
  end;
  CloseFile(F);
  lbl2.Caption := IntToStr(ListBox1.Items.count); //��ʾ�ļ���
  end;
 end;

  {
    for i := 0 to files.count - 1 do
    begin
      lst1.Items.Clear;
    end;
    for i := 0 to files.count - 1 do
    begin
      if sameText(Copy(files.Strings[i], (Length(files.Strings[i]) - 2), 3), 'bmp')
        or sameText(Copy(files.Strings[i], (Length(files.Strings[i]) - 2), 3), 'jpg') then
        lst1.Items.Add(files.Strings[i]);
    end;
    label3.Caption := IntToStr(lst1.Items.count); //��ʾ�ļ���
  finally
    files.Free;
  end;
end;   }

end.
