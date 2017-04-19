unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ComCtrls, ExtCtrls, Grids, DBGrids,
  PaxCompilerExplorer, PaxCompilerDebugger, PaxRunner, PaxProgram,
  PaxCompiler, PaxBasicLanguage, PaxRegister, PaxInvoke,
  SynEditHighlighter, SynHighlighterPas, SynEdit, SynMemo, Buttons, DateUtils, FileCtrl,
  ToolWin, ImgList, SPComm, IdBaseComponent, IdThreadComponent, PerlRegEx,
  CoolTrayIcon, IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP,
  IdMessage, IdComponent, IdIOHandler, IdIOHandlerSocket, IdSSLOpenSSL ;

type
  TMainForm = class(TForm)
    meufile1: TMenuItem;
    MeuSet: TMenuItem;
    stat1: TStatusBar;
    MeuHelp: TMenuItem;
    MeuAbut: TMenuItem;
    MeuExit: TMenuItem;
    MainComSet: TMenuItem;
    MeuCameraSet: TMenuItem;
    MeuCase: TMenuItem;
    MeuLog: TMenuItem;
    MainComOpen: TMenuItem;
    MainComClose: TMenuItem;
    OpenDialog1: TOpenDialog;
    PaxCompiler1: TPaxCompiler;
    PaxProgram1: TPaxProgram;
    PaxCompilerDebugger1: TPaxCompilerDebugger;
    PaxCompilerExplorer1: TPaxCompilerExplorer;
    PaxInvoke1: TPaxInvoke;
    PaxPascalLanguage1: TPaxPascalLanguage;
    SynPasSyn1: TSynPasSyn;
    Edit1: TEdit;
    lbl2: TLabel;
    Edit2: TEdit;
    lbl3: TLabel;
    N1: TMenuItem;
    N2: TMenuItem;
    SaveDialog1: TSaveDialog;
    tmr1: TTimer;
    tmr2: TTimer;
    mniN3: TMenuItem;
    mniN4: TMenuItem;
    mniN5: TMenuItem;
    mniCard: TMenuItem;
    chk1: TCheckBox;
    mniN6: TMenuItem;
    grp1: TGroupBox;
    grp2: TGroupBox;
    grp3: TGroupBox;
    SynMemo1: TSynMemo;
    il1: TImageList;
    tlb1: TToolBar;
    mm1: TMainMenu;
    btn2: TToolButton;
    btn5: TToolButton;
    btn6: TToolButton;
    btn7: TToolButton;
    btn8: TToolButton;
    btn9: TToolButton;
    btnPause: TToolButton;
    btn11: TToolButton;
    btnStop: TToolButton;
    btnRun: TToolButton;
    btn13: TToolButton;
    btn14: TToolButton;
    btn15: TToolButton;
    btn16: TToolButton;
    btn17: TToolButton;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    mmo1: TMemo;
    mmo2: TMemo;
    pgc2: TPageControl;
    ts3: TTabSheet;
    ts4: TTabSheet;
    lst1: TListBox;
    mniandroid1: TMenuItem;
    mniAPK1: TMenuItem;
    dlgOpenAPK: TOpenDialog;
    tv1: TTreeView;
    ComboBox1: TComboBox;
    PerlRegEx1: TPerlRegEx;
    N3: TMenuItem;
    TrayIcon1: TCoolTrayIcon;
    mniN7: TMenuItem;
    edt1: TEdit;
    N4: TMenuItem;
    IdSSLIOHandlerSocket1: TIdSSLIOHandlerSocket;
    IdMessage1: TIdMessage;
    IdSMTP1: TIdSMTP;
    N5: TMenuItem;
    N6: TMenuItem;
    mniadb1: TMenuItem;
    procedure MeuAbutClick(Sender: TObject);
    procedure MeuCameraSetClick(Sender: TObject);
    procedure MeuLogClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MeuExitClick(Sender: TObject);
    procedure MainComOpenClick(Sender: TObject);
    procedure MainComCloseClick(Sender: TObject);
    procedure SwitchMenu;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MeuCaseClick(Sender: TObject);
    procedure PaxProgram1PrintEvent(Sender: TPaxRunner; const Text: string);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure tmr2Timer(Sender: TObject);
    procedure mniN4Click(Sender: TObject);
    procedure mniCardClick(Sender: TObject);
    procedure mniN6Click(Sender: TObject);
    procedure lst1Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn13Click(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure mniandroid1Click(Sender: TObject);
    procedure mniAPK1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure tv1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N3Click(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure mniN7Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure mniadb1Click(Sender: TObject);
  private
    { Private declarations }
    TestResult: Boolean; //���Խ��
  public
    { Public declarations }
    ExcuteValue: Int64;
    Value: Int64;    
  end;
type
  SetComThread = class(TThread)
  protected
    procedure execute; override;
  end;
var
  MainForm: TMainForm;
  PascalScripThread: TThread;
  DEVThread: TThread;
  COMMThread: TThread;
implementation

uses
  PComm, ReadComThread, ExGlobal, ComRead2, WriteCom, CameraSetUnit, About,
  Config, DeviceLog, QRcodeUnit, OCRUnit, CardSet,
  testcase, DTMFUnit, IMPORT_SysUtils, RunPASScript,// MultInst,
  audioSetting,Bass, SetComTHUnit, RoboticArmUnit, AutoSaveUnit, adbunit;

{$R *.dfm}

var
  MainThread: TThread;
  StartTime: string;

procedure TMainForm.MeuAbutClick(Sender: TObject);
begin
  AboutFrm.ShowModal;
end;

procedure TMainForm.MeuCameraSetClick(Sender: TObject);
begin
  CameraSetForm.show;
  if CameraSetForm.WindowState = wsMinimized then //��С����ʹ��ָ�
    CameraSetForm.WindowState := wsNormal
end;

procedure TMainForm.MeuLogClick(Sender: TObject);
begin
  LogForm.show;
  if LogForm.WindowState = wsMinimized then //��С����ʹ��ָ�
    LogForm.WindowState := wsNormal
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  pgc1.ActivePage := ts2;
  pgc2.ActivePage := ts4;
  refreshComList;
  mmo1.Text := '';
  mmo2.Text := '';
  ADBpath:=Apppath + 'lib\adb.exe';
  SwitchMenu();
   TrayIcon1.IconVisible:=True;
  TrayIcon1.Icon :=Application.Icon;
//  SetComThread.Create(False);
  SetCom.Create(False);
end;

procedure TMainForm.MeuExitClick(Sender: TObject);
begin
  close;
end;

procedure TMainForm.MainComOpenClick(Sender: TObject);
begin
  if CfgForm.ShowModal = mrCancel then
    Exit;
end;

procedure TMainForm.MainComCloseClick(Sender: TObject);
begin
  ClosePort1(Com1);
  SwitchMenu();
end;

procedure Tmainform.SwitchMenu;
begin
  MainComOpen.Enabled := not Com1Open;
  maincomclose.Enabled := Com1Open;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

  case Application.MessageBox('ȷ���˳�ϵͳ?', 'ѯ��', 35) of
    6:
      begin
        // ShowMessage('������,���ڹر�');
        CanClose := True;
      end;
    7:
      begin
        // ShowMessage('���˷�,����');
        CanClose := False;
      end;
    2:
      begin
        // ShowMessage('����ȡ��,���ڲ��ر�');
        CanClose := False;
      end;
  end;

end;

procedure TMainForm.MeuCaseClick(Sender: TObject);
begin
  frmTestCase1.show;
  if frmTestCase1.WindowState = wsMinimized then //��С����ʹ��ָ�
    frmTestCase1.WindowState := wsNormal
end;

{********************************************}

procedure TMainForm.PaxProgram1PrintEvent(Sender: TPaxRunner;
  const Text: string);
begin
  MainForm.mmo1.Lines.Add(Text);
end;

procedure TMainForm.N1Click(Sender: TObject);
var
  F: TextFile;
  S: string;
begin
  OpenDialog1.Filter := '�ı��ĵ�(*.txt)|*.txt';
  if OpenDialog1.Execute then
  begin
    SynMemo1.Lines.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.Filter := '�ı��ĵ�(*.txt)|*.txt';
  if SaveDialog1.Execute then
  begin
    if FileExists(SaveDialog1.FileName) then
    begin
      if MessageBox(0, '�ļ��Ѵ��ڣ��Ƿ񸲸�', 'information', MB_OKCANCEL) = MB_OKCANCEL then
      begin
        SynMemo1.Lines.SaveToFile(SaveDialog1.FileName);
      end;
    end
    else
    begin
      SynMemo1.Lines.SaveToFile(SaveDialog1.FileName);
    end;
  end;
end;

procedure TMainForm.tmr1Timer(Sender: TObject);
var
  S1, S2: string;
  T1, T2: TDateTime;
  D, H, M, S: Integer;
  // Value: Int64;
const
  SecsPerDay = 86400;
  SecsPerHour = 3600;
  SecsPerMin = 60;
begin
  DateSeparator := '-';
  S1 := StartTime;
  S2 := FormatDateTime('yyyy-mm-dd hh:mm:ss', now);
  T1 := StrToDateTime(S1);
  T2 := StrToDateTime(S2);

  Value := ExcuteValue + SecondsBetween(T1, T2);
  D := Value div SecsPerDay;
  H := Value mod SecsPerDay div SecsPerHour;
  M := Value mod SecsPerDay mod SecsPerHour div SecsPerMin;
  S := Value mod SecsPerDay mod SecsPerHour mod SecsPerMin;

  stat1.Panels[1].Text := '����ʱ�䣺' + Format('%.2d��%.2dСʱ%.2d��%.2d��', [D, H, M, S]);
end;

procedure TMainForm.tmr2Timer(Sender: TObject);
begin
  stat1.Panels[0].Text := '��ǰʱ�䣺' + FormatDateTime('yyyy-mm-dd hh:mm:ss', now);
end;

procedure TMainForm.mniN4Click(Sender: TObject);
begin
  WinExec(pchar(APPpath + '\' + 'Extra' + '\' + 'Compare.exe'), SW_NORMAL);
end;

{ ���ô����߳���ں��� }

procedure SetComThread.Execute;
var
  i: integer;
begin
  FreeOnTerminate := True;
  for i := 0 to ComStrList.Count - 1 do
  begin
    if Com1Open then
      ClosePort1(COM1);
    COM1 := GetNum(ComStrList.ValueFromIndex[i]);
    // �������б�������
    try
      ComNum := 1;
      OpenPort(COM1, B9600, P_NONE or BIT_8 or STOP_1);
     // MainForm.mmo1.Lines.Add('COM' + IntToStr(COM1) + '���ڼ��');
    except
      ClosePort1(COM1);
     // MainForm.mmo1.Lines.Add(ComStrList.ValueFromIndex[i] + '����δ�ҵ�');
      Continue;
    end;
    SendStrhex(Com1, '55FF01B600');

    while true do //�ȴ����ݽ���
    begin
      sleep(1);
      Application.ProcessMessages;
      if sendOK then // ���ͳɹ�
      begin
        if (Rec_CMD = $B6) and (Rec_DATA[1] = 01) then
        begin
          Com1Open := True;
          MainForm.SwitchMenu();
       //   MainForm.mmo1.Lines.Add('�ҵ����������������óɹ���');
          exit; // �˳��߳�
        end
        else
        begin
          ClosePort1(COM1); //�رմ��ڼ���
          break;
        end;
      end;
      if sendNG then // ������Ӧ��
      begin
        ClosePort1(COM1);
        break;
      end;
    end;
  end;
//  MainForm.mmo1.Lines.Add('δ�ҵ������������鴮�������Ƿ�������');
end;

procedure TMainForm.mniCardClick(Sender: TObject);
begin
  FormCardSet.ShowModal;
end;

function searchfile(path: string): TStringList;
var
  SearchRec: TSearchRec;
  found: integer;
begin
  Result := TStringList.Create;
  found := FindFirst(path + '\' + '*.*', faAnyFile, SearchRec);
  while found = 0 do
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (SearchRec.Attr <> faDirectory) then
      Result.Add(SearchRec.Name);
    found := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

procedure TMainForm.mniN6Click(Sender: TObject);
var
  files: TStringList;
  i: Integer;
begin
  files := TStringList.Create;
  if SelectDirectory('��ָ���ļ���', '', filespath) then
    // Edit1.Text := filespath;
    try

      files := searchfile(filespath);

      for i := 0 to files.count - 1 do
      begin
        lst1.Items.Clear;
      end;
      for i := 0 to files.count - 1 do
      begin
        if sameText(Copy(files.Strings[i], (Length(files.Strings[i]) - 2), 3), 'txt')
          or sameText(Copy(files.Strings[i], (Length(files.Strings[i]) - 2), 3), 'TXT') then
          lst1.Items.Add(files.Strings[i]);
      end;
      // label3.Caption := IntToStr(lst1.Items.count); //��ʾ�ļ���
    finally
      files.Free;
    end;
end;

procedure TMainForm.lst1Click(Sender: TObject);
var
  F: TextFile;
  S: string;
begin

  SynMemo1.Lines.LoadFromFile(filespath + '\' + lst1.Items[lst1.Itemindex]);

end;

procedure TMainForm.btn9Click(Sender: TObject);
begin
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.Filter := '�ı��ĵ�(*.txt)|*.txt';
  if SaveDialog1.Execute then
  begin
    if FileExists(SaveDialog1.FileName) then
    begin
      if MessageBox(0, '�ļ��Ѵ��ڣ��Ƿ񸲸�', 'information', MB_OKCANCEL) = MB_OKCANCEL then
      begin
        mmo1.Lines.SaveToFile(SaveDialog1.FileName);
      end;
    end
    else
    begin
      mmo1.Lines.SaveToFile(SaveDialog1.FileName);
    end;
  end;
end;

procedure TMainForm.btn6Click(Sender: TObject);
begin
  mmo1.Clear;
end;

procedure TMainForm.btn13Click(Sender: TObject);
begin
  CameraSetForm.show;
  if CameraSetForm.WindowState = wsMinimized then //��С����ʹ��ָ�
    CameraSetForm.WindowState := wsNormal
end;

procedure TMainForm.btnRunClick(Sender: TObject);
begin
  pgc1.ActivePage := ts2;
  pgc2.ActivePage := ts4;
  if (btnRun.Caption = '��ʼ') and (CheckThreadFreed(PascalScripThread) <> 1) then
  begin
    if MainForm.ComboBox1.ItemIndex = 0 then //ѭ���������������ж�
    begin
      MainForm.Edit1.Text := '0';
    end;
    btnRun.Enabled := False;
    Edit1.Enabled := False;
    Edit2.Enabled := False;
    // SynMemo1.Enabled := False;
    SynMemo1.ReadOnly := True;
    exitdelay := False;
    PascalScripThread := PascalScript.Create(True);
    PascalScripThread.Resume;
    StartTime := FormatDateTime('yyyy-mm-dd hh:mm:ss', now);
    ExcuteValue := 0; // ��ͣ��¼ʱ����0
    tmr1.Enabled := True;
    autoSaveForm.tmr1.Enabled:=True;  //�Զ������¼
  end;
end;

procedure TMainForm.btn5Click(Sender: TObject);
begin
  N1.Click;
end;

procedure TMainForm.btn8Click(Sender: TObject);
begin
  N2.Click;
end;

procedure TMainForm.btnPauseClick(Sender: TObject);
begin
  if (btnPause.Caption = '��ͣ') and (btnRun.Enabled = False) and (CheckThreadFreed(PascalScripThread) = 1) then
  begin
    btnPause.Caption := '�ָ�';
    btnStop.Enabled := False;
    PascalScripThread.Suspend;
    ExcuteValue := Value; //��¼�Ѳ��Ե�ʱ��
    tmr1.Enabled := False;
    autoSaveForm.tmr1.Enabled:=False;  //�Զ������¼
    Exit;
  end;
  if (btnPause.Caption = '�ָ�') and (btnRun.Enabled = False) and (CheckThreadFreed(PascalScripThread) = 1) then
  begin
    btnPause.Caption := '��ͣ';
    btnStop.Enabled := true;
    PascalScripThread.Resume;
    StartTime := FormatDateTime('yyyy-mm-dd hh:mm:ss', now); //�ָ���ʱ
    tmr1.Enabled := true;
  autoSaveForm.tmr1.Enabled:=true;  //�Զ������¼
    Exit;
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  if CheckThreadFreed(PascalScripThread) = 1 then
  begin
    //    PascalScripThread.terminate;
    try
      TerminateThread(PascalScripThread.Handle, 0); // ��ֹ�߳�
      PascalScripThread.Free; //�ͷ��߳�
    except
      ;
    end;
  end;
  MainForm.mmo1.Lines.add('CheckThreadFreed(PascalScripThread)=' + IntToStr(CheckThreadFreed(PascalScripThread)));
  Edit1.Enabled := True;
  Edit2.Enabled := true;
  btnRun.Enabled := True;
  ExitDelay := True;
  //SynMemo1.Enabled := True;
  SynMemo1.ReadOnly := False;
  tmr1.Enabled := False;
  autoSaveForm.tmr1.Enabled:=False;  //�Զ������¼
end;

procedure TMainForm.mniandroid1Click(Sender: TObject);
var
  CMDOut: string;
begin
 // CMDOut := GetDosOutput(Apppath + 'lib\adb.exe devices');
  CMDOut := GetDosOutput(ADBpath+' devices');
  MainForm.mmo1.Lines.add(CMDOut);
end;

procedure TMainForm.mniAPK1Click(Sender: TObject);
var
  CMDOut: string;
begin
  dlgOpenAPK.Filter := 'APK�ļ�(*.apk)|*.apk';
  if dlgOpenAPK.Execute then
  begin
    CMDOut := GetDosOutput(ADBpath+' install -r ' + dlgOpenAPK.FileName);
    MainForm.mmo1.Lines.add(CMDOut);
  end;
end;

procedure TMainForm.btn2Click(Sender: TObject);
var
  id: Integer;
begin
  id := MessageDlg('�Ƿ񱣴��ļ���', mtConfirmation, mbYesNoCancel, 0);

  case id of
    mrYes: N2.Click;
    mrCancel: Exit;
  end;
  SynMemo1.Clear;
end;

procedure TMainForm.tv1Click(Sender: TObject);
var
  ID: Integer;
begin
  ID := tv1.Selected.SelectedIndex;
  // MainForm.mmo1.Lines.add(IntToStr(ID));
  case ID of
    11:
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add('����: KeyPress(Keys: string; DownTime: Integer; Interval: Integer): Boolean;' + #13#10 +
          '���: ���ư������¼�����' + #13#10 +
          '������Keys:��ֵ1-16��DownTime:����ʱ��(ms)��Interval:���ʱ��(ms)' + #13#10 +
          'ע�ͣ����������",",ͬʱ���µļ����"|"' + #13#10 +
          '���磺Keypress (''1,2'',200,300);  ����"1,2",Keypress(''2|4'',200,300);  "2,4"ͬʱ����');
      end;
  else
    pgc1.ActivePage := ts1;
    mmo2.Clear;
    MainForm.mmo2.Lines.add(' function QR(cameraID: Integer;X1,Y1,X2,Y2:Integer; text: string): Boolean;'  + #13#10 +
'function SnapShot(cameraID: Integer; Path: string): Boolean '    + #13#10 +
'procedure Delay(ms: Integer);                 '    + #13#10 +
'function OCR(CameraID: Integer; X1,Y1,X2,Y2: Integer; Text: string): Boolean;   '    + #13#10 +
'function Rand(Min:Integer;Max:Integer):integer;                  '    + #13#10 +
'function StrRand(Min:Integer;Max:Integer):string;               '    + #13#10 +
'function KeyPress(Keys: string; DownTime: Integer; Interval: Integer): Boolean;   '    + #13#10 +
'function KeyDown(Keys: string): Boolean;          '    + #13#10 +
'function KeyUp(): Boolean;               '    + #13#10 +
'function IO(IO1,IO2,IO3,IO4:Integer): Boolean;    '    + #13#10 +
'function Ring(R1, R2: Integer): Boolean       '    + #13#10 +
'function GetAveHSV(CameraID:Integer;x1,y1,x2,y2:Integer;HSV:string): Boolean;   '    + #13#10 +
'function WaitUntilRing(R1, R2: Integer; MSecs: Longint): Boolean;   '    + #13#10 +
'function WaitUnlock(IO1, IO2,IO3,IO4: Integer; MSecs: Longint): Boolean;  '    + #13#10 +
'function Talking(Channel, Direction: Integer): Boolean;  '    + #13#10 +
'function Photosynth(C1,C2: Integer; Path: string): Boolean;  '    + #13#10 +
'function ImgSimilar(Camera:Integer;X1,Y1,X2,Y2:Integer; Hash: string;Percent:Real):Boolean;  '    + #13#10 +
'function LEDIndn(CameraID: Integer; x1, y1, x2, y2: Integer; HSV: string; MSecs: Integer): Int64; '    + #13#10 +
'function Serial(Com: Integer; sData: string): integer;  '    + #13#10 +
'function Card(cardNum: int64): Boolean;    '    + #13#10 +
'function Android_ScreenCAP(Path: string):Boolean;  '    + #13#10 +
'procedure Android_Tap(Coordinate: string);  '    + #13#10 +
'procedure Android_Swipe(Coordinate: string;time:Integer);  '    + #13#10 +
'function CommLogSave(Path: string): Boolean;    '    + #13#10 +
'function LogSave(Path: string): Boolean;   '    + #13#10 +
'procedure LogClear();   '    + #13#10 +
'procedure CommLogClear();  '    + #13#10 +
'function SendCmd(Com: Integer; SData: string;RData: string): Boolean;  '    + #13#10 +
'function CommLogFind(str: string): Boolean;   '    + #13#10 +
'function LogFind(str: string): Boolean;     '    + #13#10 +
'procedure LogExtract(str: string;Path:string);   '    + #13#10 +
'function Speaking():Boolean;    '    + #13#10 +
'procedure TestPause();   '      + #13#10 +
'procedure AudioRecord(MSecs:Integer);'    + #13#10 +
'procedure PlayAudio(path:string);' + #13#10 +
'procedure RFIDFMList();'  + #13#10 +
'procedure SetWavSavePath(Path:string);'  + #13#10 +
'function CallingChannel(WAVPayFile:string;AudHash:string;MSecs:Integer):Single;'  + #13#10 +
'function GetAudioLevel():LongWord;' + #13#10 +
'procedure SaveToIMG(SavePath:string);'  + #13#10 +
'procedure AudioSave(path: string; MSecs: Integer);'  + #13#10 +
'function AudioCompare(AudHash: string): Single;'    + #13#10 +
'procedure SendMail(Email: string; Subject : string; Body : string);'   + #13#10 +
'function FaceDetect(cameraID: Integer; X1, Y1, X2, Y2: Integer): Integer; ����������'
);
end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  SysDev.Free;
  CameraSetForm.FilterGraph1.ClearGraph;
  CameraSetForm.FilterGraph1.Active := false;
  CameraSetForm.FilterGraph2.ClearGraph;
  CameraSetForm.FilterGraph2.Active := false;
  CameraSetForm.FilterGraph3.ClearGraph;
  CameraSetForm.FilterGraph3.Active := false;
  CameraSetForm.FilterGraph4.ClearGraph;
  CameraSetForm.FilterGraph4.Active := false;

  ClosePort1(Com1);
  if CheckThreadFreed(PascalScripThread) = 1 then
  begin
    TerminateThread(PascalScripThread.Handle, 0); // ��ֹ�߳�
    PascalScripThread.Free; //�ͷ��߳�
  end;

  if CheckThreadFreed(COMMThread) = 1 then
  begin
    TerminateThread(COMMThread.Handle, 0); // ��ֹ�߳�
    COMMThread.Free; //�ͷ��߳�
  end;

  { if CheckThreadFreed(DEVThread) = 1 then
  begin
    TerminateThread(DEVThread.Handle,0);  // ��ֹ�߳�
    DEVThread.Free;               //�ͷ��߳�
  end;
               }
  ScripThreadExit := True;
  ExitDelay := True;
  EndProcess('adb.exe');
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
  WinExec(pchar(APPpath + '\' + 'Extra' + '\' + 'RegExTester.exe'), SW_NORMAL);
end;

procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
  TrayIcon1.ShowMainForm;    // ALWAYS use this method to restore!!!
end;

procedure TMainForm.mniN7Click(Sender: TObject);
begin
  TrayIcon1.MinimizeToTray := not TrayIcon1.MinimizeToTray;

end;

procedure TMainForm.N4Click(Sender: TObject);
begin
  AudioSettingsForm.Show;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
 BASS_Free;
  bit.Free;
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
  roboticarmform.show;
end;

procedure TMainForm.N6Click(Sender: TObject);
begin
  autosaveform.ShowModal;
end;

procedure TMainForm.mniadb1Click(Sender: TObject);
begin
  adbsetform.show;
end;

end.

