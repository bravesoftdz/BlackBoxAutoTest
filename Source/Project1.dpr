program Project1;

uses
  Forms,
  SysUtils,
  Unit1 in 'Unit1.pas' {MainForm},
  PComm in 'Pcomm.pas',
  ExGlobal in 'ExGlobal.pas',
  ReadComThread in 'ReadComThread.pas',
  WriteCom in 'WriteCom.pas',
  CameraSetUnit in 'CameraSetUnit.pas' {CameraSetForm},
  About in 'About.pas' {AboutFrm},
  Config in 'Config.pas' {CfgForm},
  DeviceLog in 'DeviceLog.pas' {LogForm},
  DeviceComConfig in 'DeviceComConfig.pas' {ComuDeviceComSetForm},
  DeviceComunicationLog in 'DeviceComunicationLog.pas' {COMMLogForm},
  QRcodeUnit in 'QRcodeUnit.pas',
  OCRUnit in 'OCRUnit.pas',
  testcase in 'testcase.pas' {frmTestCase1},
  DTMFUnit in 'DTMFUnit.pas',
  AddCaseUnit in 'AddCaseUnit.pas' {AddCaseFrm},
  RunPASScript in 'RunPASScript.pas',
  LogOption in 'LogOption.pas' {OptionForm},
  IMPORT_SysUtils in 'IMPORT_SysUtils.pas',
  CardSet in 'CardSet.pas' {FormCardSet},
  android in 'android.pas',
  LogTh in 'LogTh.pas',
  audioSetting in 'audioSetting.pas' {AudioSettingsForm},
  AudioOutUnit in 'AudioOutUnit.pas',
  SetComTHUnit in 'SetComTHUnit.pas',
  AutoSaveUnit in 'AutoSaveUnit.pas' {autoSaveForm},
  facedetectUnit in 'facedetectUnit.pas',
  adbunit in 'adbunit.pas' {AdbSetForm},
  TestingVideoUnit in 'TestingVideoUnit.pas' {Form2},
  U_Main in 'U_Main.pas' {Video_frm_Main},
  U_Option in 'U_Option.pas' {frm_Option},
  DobotUnit in 'DobotUnit.pas' {DobotForm};

{$R *.res}

begin
  Application.Initialize;
  APPpath:=ExtractFilePath(ParamStr(0));//�õ�Ӧ�ó������ڵ�·��
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TCameraSetForm, CameraSetForm);
  Application.CreateForm(TAboutFrm, AboutFrm);
  Application.CreateForm(TCfgForm, CfgForm);
  Application.CreateForm(TLogForm, LogForm);
  Application.CreateForm(TComuDeviceComSetForm, ComuDeviceComSetForm);
  Application.CreateForm(TCOMMLogForm, COMMLogForm);
  Application.CreateForm(TfrmTestCase1, frmTestCase1);
  Application.CreateForm(TAddCaseFrm, AddCaseFrm);
  Application.CreateForm(TOptionForm, OptionForm);
  Application.CreateForm(TFormCardSet, FormCardSet);
  Application.CreateForm(TAudioSettingsForm, AudioSettingsForm);
  Application.CreateForm(TautoSaveForm, autoSaveForm);
  Application.CreateForm(TAdbSetForm, AdbSetForm);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TVideo_frm_Main, Video_frm_Main);
  Application.CreateForm(Tfrm_Option, frm_Option);
  Application.CreateForm(TDobotForm, DobotForm);
  Application.Run;
end.
