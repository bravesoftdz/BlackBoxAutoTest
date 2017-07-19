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
    N7: TMenuItem;
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
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
    TestResult: Boolean; //测试结果
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
  audioSetting,Bass, SetComTHUnit, RoboticArmUnit, AutoSaveUnit, adbunit, 
  U_Main, DobotUnit,DobotExGlobal,DOBOTDLL;

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
  if CameraSetForm.WindowState = wsMinimized then //最小化则使其恢复
    CameraSetForm.WindowState := wsNormal
end;

procedure TMainForm.MeuLogClick(Sender: TObject);
begin
  LogForm.show;
  if LogForm.WindowState = wsMinimized then //最小化则使其恢复
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

  case Application.MessageBox('确认退出系统?', '询问', 35) of
    6:
      begin
        // ShowMessage('按了是,窗口关闭');
        CanClose := True;
      end;
    7:
      begin
        // ShowMessage('按了否,返回');
        CanClose := False;
      end;
    2:
      begin
        // ShowMessage('按了取消,窗口不关闭');
        CanClose := False;
      end;
  end;

end;

procedure TMainForm.MeuCaseClick(Sender: TObject);
begin
  frmTestCase1.show;
  if frmTestCase1.WindowState = wsMinimized then //最小化则使其恢复
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
  OpenDialog1.Filter := '文本文档(*.txt)|*.txt';
  if OpenDialog1.Execute then
  begin
    SynMemo1.Lines.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
  SaveDialog1.DefaultExt := 'txt';
  SaveDialog1.Filter := '文本文档(*.txt)|*.txt';
  if SaveDialog1.Execute then
  begin
    if FileExists(SaveDialog1.FileName) then
    begin
      if MessageBox(0, '文件已存在，是否覆盖', 'information', MB_OKCANCEL) = MB_OKCANCEL then
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

  stat1.Panels[1].Text := '运行时间：' + Format('%.2d天%.2d小时%.2d分%.2d秒', [D, H, M, S]);
end;

procedure TMainForm.tmr2Timer(Sender: TObject);
begin
  stat1.Panels[0].Text := '当前时间：' + FormatDateTime('yyyy-mm-dd hh:mm:ss', now);
end;

procedure TMainForm.mniN4Click(Sender: TObject);
begin
  WinExec(pchar(APPpath + '\' + 'Extra' + '\' + 'Compare.exe'), SW_NORMAL);
end;

{ 设置串口线程入口函数 }

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
    // 按串口列表发送数据
    try
      ComNum := 1;
      OpenPort(COM1, B9600, P_NONE or BIT_8 or STOP_1);
     // MainForm.mmo1.Lines.Add('COM' + IntToStr(COM1) + '串口检测');
    except
      ClosePort1(COM1);
     // MainForm.mmo1.Lines.Add(ComStrList.ValueFromIndex[i] + '串口未找到');
      Continue;
    end;
    SendStrhex(Com1, '55FF01B600');

    while true do //等待数据接收
    begin
      sleep(1);
      Application.ProcessMessages;
      if sendOK then // 发送成功
      begin
        if (Rec_CMD = $B6) and (Rec_DATA[1] = 01) then
        begin
          Com1Open := True;
          MainForm.SwitchMenu();
       //   MainForm.mmo1.Lines.Add('找到控制器，串口设置成功！');
          exit; // 退出线程
        end
        else
        begin
          ClosePort1(COM1); //关闭串口继续
          break;
        end;
      end;
      if sendNG then // 发送无应答
      begin
        ClosePort1(COM1);
        break;
      end;
    end;
  end;
//  MainForm.mmo1.Lines.Add('未找到控制器，请检查串口连接是否正常！');
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
  if SelectDirectory('请指定文件夹', '', filespath) then
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
      // label3.Caption := IntToStr(lst1.Items.count); //显示文件数
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
  SaveDialog1.Filter := '文本文档(*.txt)|*.txt';
  if SaveDialog1.Execute then
  begin
    if FileExists(SaveDialog1.FileName) then
    begin
      if MessageBox(0, '文件已存在，是否覆盖', 'information', MB_OKCANCEL) = MB_OKCANCEL then
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
  if CameraSetForm.WindowState = wsMinimized then //最小化则使其恢复
    CameraSetForm.WindowState := wsNormal
end;

procedure TMainForm.btnRunClick(Sender: TObject);
begin
  pgc1.ActivePage := ts2;
  pgc2.ActivePage := ts4;
  if (btnRun.Caption = '开始') and (CheckThreadFreed(PascalScripThread) <> 1) then
  begin
    if MainForm.ComboBox1.ItemIndex = 0 then //循环测试跳过次数判断
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
    ExcuteValue := 0; // 暂停记录时间清0
    tmr1.Enabled := True;
    autoSaveForm.tmr1.Enabled:=True;  //自动保存记录
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
  if (btnPause.Caption = '暂停') and (btnRun.Enabled = False) and (CheckThreadFreed(PascalScripThread) = 1) then
  begin
    btnPause.Caption := '恢复';
    btnStop.Enabled := False;
    PascalScripThread.Suspend;
    ExcuteValue := Value; //记录已测试的时间
    tmr1.Enabled := False;
    autoSaveForm.tmr1.Enabled:=False;  //自动保存记录
    Exit;
  end;
  if (btnPause.Caption = '恢复') and (btnRun.Enabled = False) and (CheckThreadFreed(PascalScripThread) = 1) then
  begin
    btnPause.Caption := '暂停';
    btnStop.Enabled := true;
    PascalScripThread.Resume;
    StartTime := FormatDateTime('yyyy-mm-dd hh:mm:ss', now); //恢复计时
    tmr1.Enabled := true;
  autoSaveForm.tmr1.Enabled:=true;  //自动保存记录
    Exit;
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  if CheckThreadFreed(PascalScripThread) = 1 then
  begin
    //    PascalScripThread.terminate;
    try
      TerminateThread(PascalScripThread.Handle, 0); // 终止线程
      PascalScripThread.Free; //释放线程
    except
      ;
    end;
  end;
  MainForm.mmo1.Lines.add('CheckThreadFreed(PascalScripThread)=' + IntToStr(CheckThreadFreed(PascalScripThread)));
  Edit1.Enabled := True;
  Edit2.Enabled := true;
  btnRun.Enabled := True;
  ExitDelay := True;
  SynMemo1.ReadOnly := False;
  tmr1.Enabled := False;
  autoSaveForm.tmr1.Enabled:=False;  //自动保存记录
  listID:=0;
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
  dlgOpenAPK.Filter := 'APK文件(*.apk)|*.apk';
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
  id := MessageDlg('是否保存文件？', mtConfirmation, mbYesNoCancel, 0);

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
        MainForm.mmo2.Lines.add('函数: KeyPress(Keys: string; DownTime: Integer; Interval: Integer): Boolean;' + #13#10 +
          '简介: 控制按键按下及弹起' + #13#10 +
          '参数：Keys:键值1-16，DownTime:动作时间(ms)，Interval:间隔时间(ms)' + #13#10 +
          '注释：按键间隔符",",同时按下的间隔符"|"' + #13#10 +
          '例如：Keypress (''1,2'',200,300);  输入"1,2",Keypress(''2|4'',200,300);  "2,4"同时按下');
      end;
    1:
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
        'function KeyPress(Keys: string; DownTime: Integer; Interval: Integer): Boolean; 按键  '    + #13#10 +
        'function KeyDown(Keys: string): Boolean;  按键按下        '    + #13#10 +
        'function KeyUp(): Boolean;  按键释放  '   );
      end;
    2:
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(

         'function SnapShot(cameraID: Integer; Path: string): Boolean 抓拍图片 '    + #13#10 +
         'function Photosynth(C1,C2: Integer; Path: string): Boolean; 抓拍图片，2个摄像头同时抓拍 '    + #13#10 +
         'function QR(cameraID: Integer;X1,Y1,X2,Y2:Integer; text: string): Boolean; QR code 解码'  + #13#10 +
         'function OCR(CameraID: Integer; X1,Y1,X2,Y2: Integer; Text: string): Boolean; 英文OCR  '    + #13#10 +
         'function GetAveHSV(CameraID:Integer;x1,y1,x2,y2:Integer;HSV:string): Boolean; 获取区域颜色HSV  '    + #13#10 +
         'function GetAveRGB(CameraID: Integer; x1, y1, x2, y2: Integer; RGB: string):Boolean; 获取区域颜色RGB'  + #13#10 +
         'function GetRGB(CameraID: Integer; x, y: Integer; RGB: string):Boolean;获取单点颜色RGB'     + #13#10 +
         'function ImgSimilar(Camera:Integer;X1,Y1,X2,Y2:Integer; Hash: string;Percent:Real):Boolean; 图片相似度 '    + #13#10 +
         'function LEDIndn(CameraID: Integer; x1, y1, x2, y2: Integer; HSV: string; MSecs: Integer): Int64; LED亮的时间长度'    + #13#10 +
         'function FaceDetect(cameraID: Integer; X1, Y1, X2, Y2: Integer): Integer; 返回人脸数'
          );
      end;
      3:  // 声音
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add
        (
        'function Ring(R1, R2: Integer): Boolean  声音检测试    '    + #13#10 +
        'function WaitUntilRing(R1, R2: Integer; MSecs: Longint): Boolean;  等待振铃 '    + #13#10 +
        'function Talking(Channel, Direction: Integer): Boolean; 通话检测 '    + #13#10 +


        'function Speaking():Boolean;  通话测试(DTMF)，成功返回真   '    + #13#10 +
        'function CONTspeaking(MSecs: integer): Boolean; 连续进行通话(DTMF)，成功返回真'      + #13#10 +
        
        'procedure PlayAudio(path:string); 播放音频 ' + #13#10 +
        'procedure SetWavSavePath(Path:string); 设置音频保存路径'  + #13#10 +
        'procedure AudioRecord(MSecs:Integer); 录制音频，需提前设置路径（SetWavSavePath）'    + #13#10 +
        'function CallingChannel(WAVPayFile:string;AudHash:string;MSecs:Integer):Single; 通话检测'  + #13#10 +
        'function GetAudioLevel():LongWord; 获取音量，需提前录音（AudioRecord）' + #13#10 +
        'procedure SaveToIMG(SavePath:string); 保存成图片，需提前设置路径（SetWavSavePath）'  + #13#10 +
        'function AudioCompare(AudHash: string): Single; 音频对比，返回与AudHash的相似度，需提前设置音频路径（SetWavSavePath）及录音（AudioRecord）'   + #13#10 +
        'procedure AudioSave(path: string; MSecs: Integer); 保存音频'  + #13#10 +
        'function AudioRecognition(FFTData: string): Single;  音频对比，返回与FFTData的相似度，需提前设置音频路径（SetWavSavePath）及录音（AudioRecord）'
          );
      end;
      4:  // 开锁、开灯检测
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add
        (
          'function IO(IO1,IO2,IO3,IO4:Integer): Boolean; 开锁、开灯等开关信号输出检测 '+ #13#10 +
          'function WaitUnlock(IO1, IO2,IO3,IO4: Integer; MSecs: Longint): Boolean; 等待开锁、开灯 '
        );
      end;
      5:  // 串口
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
          'function SendCmd(Com: Integer; SData: string;RData: string): Boolean; 串口发送数据,检查返回'
           );
      end;
      6:  // RFID卡
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
        'function Card(cardNum: int64): Boolean; 单张卡'    + #13#10 +
        'procedure RFIDFMList(); 卡列表注册'
           );
      end;
      7:   //android操作
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
         'function Android_ScreenCAP(Device:string;Path: string): Boolean; 抓拍 '    + #13#10 +
         'procedure Android_Tap(Device:string;Coordinate: string); 点击 '    + #13#10 +
         'procedure Android_Swipe(Device:string;Coordinate: string;time:Integer); 滑动 '   );
      end;
      8:   //LOG操作
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
          'function CommLogSave(Path: string): Boolean;  串口LOG保存  '    + #13#10 +
          'procedure CommLogClear(); 串口LOG清空 '    + #13#10 +
          'function CommLogFind(str: string): Boolean; 串口LOG查找  '    + #13#10 +          
          'function LogSave(Path: string): Boolean; LOG保存  '    + #13#10 +
          'procedure LogClear(); LOG清空  '    + #13#10 +
          'function LogFind(str: string): Boolean;   LOG查找  '    + #13#10 +
          'procedure LogExtract(str: string;Path:string);  LOG正则匹配 ' 
           );
      end;
       9:   //其它操作
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
       'function Rand(Min:Integer;Max:Integer):integer;  随机数，整型'+#13#10 +
       'function StrRand(Min:Integer;Max:Integer):string; 随机数，字符串'+ #13#10 +
       'procedure Delay(ms: Integer);    延时         '    + #13#10 +
       'procedure TestPause(); 测试暂停 '+ #13#10 +
       'procedure SendMail(Email: string; Subject : string; Body : string); 发邮件'   + #13#10 +

       'procedure TestRecord(path:string) 测试录像，path:保存路径'       + #13#10 +
       'procedure StopRecord();  停止录像 '
        );
      end;
       10:   //其它操作
      begin
        pgc1.ActivePage := ts1;
        mmo2.Clear;
        MainForm.mmo2.Lines.add(
       'procedure Robot(trajectory: string); 机械手控制'+#13#10

        );
      end;

  else
    pgc1.ActivePage := ts1;
    mmo2.Clear;
    MainForm.mmo2.Lines.add('')


end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DisconnectDobot();
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
    TerminateThread(PascalScripThread.Handle, 0); // 终止线程
    PascalScripThread.Free; //释放线程
  end;

  if CheckThreadFreed(COMMThread) = 1 then
  begin
    TerminateThread(COMMThread.Handle, 0); // 终止线程
    COMMThread.Free; //释放线程
  end;

  { if CheckThreadFreed(DEVThread) = 1 then
  begin
    TerminateThread(DEVThread.Handle,0);  // 终止线程
    DEVThread.Free;               //释放线程
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
  dobotform.show;
    if dobotform.WindowState = wsMinimized then //最小化则使其恢复
    dobotform.WindowState := wsNormal
end;

procedure TMainForm.N6Click(Sender: TObject);
begin
  autosaveform.ShowModal;
end;

procedure TMainForm.mniadb1Click(Sender: TObject);
begin
  adbsetform.ShowModal;
end;

procedure TMainForm.N7Click(Sender: TObject);
begin
  Video_frm_Main.show;
end;

end.

