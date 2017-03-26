unit RunScriptUnit;

interface

uses
  Classes;

type
  RunScript = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure Formcanvas;
  end;

implementation

uses
  TypInfo, Windows, Graphics, SysUtils, Forms, Dialogs, DSPack, ExGlobal, Unit1, CameraSetUnit,
  QRcodeUnit, OCRUnit;
type
  TMyStrSel = (KeyPress, KeyDown, KeyUp, Delay, SnapShot, Ring, IO, QR, OCR, GetAveHSV, GetAveRGB);
type
  TScript = packed record //������ṹ
    act: string; //����
    pars: TStrings; //����
  end;

var
  Key: array[0..16] of string = (//0-16 ������ֵ
    'FFFF', 'FEFF', 'FDFF', 'FBFF', 'F7FF', 'EFFF', 'DFFF',
    'BFFF', '7FFF', 'FFFE', 'FFFD', 'FFFB', 'FFF7', 'FFEF', 'FFDF', 'FFBF',
    'FF7F'
    );
  DwrRect: TRect; //����ȡͼƬ����

procedure DeleteBMPFile(sFileName: string);
begin
  while FileExists(sFileName) do
  begin
    SetFileAttributes(PChar(sFileName), FILE_ATTRIBUTE_ARCHIVE);
    DeleteFile(sFileName)
  end;
end;

function InterpretCMD(tmps: string): TScript;
var
  i: Integer;
  s1: string;
  st: TStringList;
begin
  S1 := tmps;
  //��ʼ������ֵ
  if S1 <> '' then
  begin
    {   for i := 1 to 16 do
       begin
         Result.pars[i] := '';
       end;}
    Result.act := '';
    Result.pars := TStringList.Create;
  end;
  st := SplitString(S1, ','); //��','�ָ��ַ�
  if st.Count > 0 then
  begin
    if st.Strings[0] <> '' then
    begin
      Result.act := st.Strings[0]; //��������
      for i := 1 to (st.count - 1) do
      begin
        Result.pars.Add(st.Strings[i]);
      end;
    end;
  end;
  st.Free;
end;

procedure RunScript.Formcanvas;
begin
  VMRRect(CameraSetForm.VideoWindow1, DwrRect);
end;

procedure RunScript.Execute;
var
  strSel: TMyStrSel;
  s0, str: string;
  path: string; //ץ��·��
  cmdstr: string; //���͵�����
  KeydownTime: Integer; //��������ʱ��
  KeyIntervalTime: Integer; //�������ʱ��
  MultipleKeys: TStringList; //ͬʱ���µĶ������
  ExpColor: TStringList; //Ԥ����ɫֵ
  DevColor: TStringList; //Ԥ����ɫֵ���
  ExpTempColor: TStringList; //Ԥ����ɫֵ��ʱ
  ColorAL: Integer; //Ԥ����Сֵ�����ֵ
  ColorBL: Integer;
  ColorCL: Integer;
  ColorAH: Integer;
  ColorBH: Integer;
  ColorCH: Integer;
  ImgPath: string; //QRͼƬ�ļ�·��
  QRPicPath: string; //��ȡ��QRͼƬ·��
  QRresult: string; //QR������
  OCRtext: string; //����ʶ����
  SocBMP: TBitmap; //ԴͼƬ
  bmp: TBitmap; //QR,
  SrcRect: TRect; //��ȡͼƬ������
  funcStr: TScript; //�ű���������
  i, j, k: integer;
  keyint: Integer; //���ֵ������ʱ����
  testtimes: Integer; //���Դ���
  finshtimes: Integer; //��ɴ���
  ColorRGB: TRGBColor; //��ɫRGB
  ColorHSV: THSBColor; //��ɫHSV
begin
  // S0:='OCR,1,CCD VIDEO,123,456,789,098';
  FreeOnTerminate := True;
  testtimes := StrToInt(MainForm.Edit1.text);
  MainForm.mmo2.Enabled := False;
  while not ScripThreadExit do
  begin
    Sleep(1);
    for k := 0 to MainForm.mmo2.Lines.Count - 1 do
    begin
      if MainForm.mmo2.Lines.Strings[k] <> '' then
      begin
        s0 := MainForm.mmo2.Lines.Strings[k];
        funcStr := InterpretCMD(s0);
        with funcStr do
        begin
          if ScripThreadExit then
            Break;
          str := act;
          strSel := TMyStrSel(GetEnumValue(TypeInfo(TMystrsel), str));
          case strSel of
            KeyPress: //��������
              begin
                MainForm.mmo1.Lines.Add('[info] ' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + 'Executing:' + s0);
                MultipleKeys := TStringList.Create;
                keyIntervalTime := StrToInt(pars[pars.Count - 1]); //���ʱ��
                pars.Delete(pars.Count - 1); // ȥ��ʱ��
                keydownTime := StrToInt(pars[pars.Count - 1]); //����ʱ��
                pars.Delete(pars.Count - 1); //ȥ��ʱ��
                for i := 0 to pars.Count - 1 do
                begin
                  if Pos('|', pars[i]) > 0 then //�������ͬʱ����
                  begin
                    MultipleKeys := SplitString(pars[i], '|'); //��'|'�ָ��ַ�
                    keyint := $FFFFF;
                    for j := 0 to MultipleKeys.Count - 1 do
                    begin
                      keyint := keyint and strtoint('$' +
                        Key[GetNum(MultipleKeys[j])]);
                    end;
                    cmdstr := '55FF02B1' + IntToHex(keyint, 4);
                  end
                  else //��������
                  begin
                    cmdstr := '55FF02B1' + Key[GetNum(pars[i])]; //��������
                  end;
                  SendStrhex(Com1, cmdstr);
                  while true do //�ȴ����ݽ���
                  begin
                    sleep(10);
                    if sendOK then // ���ͳɹ�
                    begin
                      MainForm.mmo1.Lines.Add(cmdstr + '���ͳɹ�');
                      Break; //
                    end;
                    if sendNG then // ������Ӧ��
                    begin
                      MainForm.mmo1.Lines.Add('[error] ' + cmdstr + '����ʧ��');
                      break;
                    end;
                  end;
                  Delayms(keydownTime);
                  cmdstr := '55FF02B1FFFF'; //�����ͷ�
                  SendStrhex(Com1, cmdstr);
                  while true do //�ȴ����ݽ���
                  begin
                    sleep(10);
                    if sendOK then // ���ͳɹ�
                    begin
                      MainForm.mmo1.Lines.Add(cmdstr + '���ͳɹ�');
                      Break; //
                    end;
                    if sendNG then // ������Ӧ��
                    begin
                      MainForm.mmo1.Lines.Add('[error] ' + cmdstr + '����ʧ��');
                      break;
                    end;
                  end;
                  Delayms(keyIntervalTime);
                end;
                MultipleKeys.Free;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            KeyDown: //��������
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                if pars.Count < 2 then //������������
                begin
                  cmdstr := '55FF02B1' + Key[GetNum(pars[0])];
                end
                else //�������ͬʱ����
                begin
                  keyint := $FFFFF;
                  for i := 0 to pars.Count - 1 do
                  begin
                    keyint := keyint and strtoint('$' + Key[GetNum(pars[i])]);
                  end;
                  cmdstr := '55FF02B1' + IntToHex(keyint, 4);
                end;
                SendStrhex(Com1, cmdstr);
                while true do //�ȴ����ݽ���
                begin
                  sleep(10);
                  if sendOK then // ���ͳɹ�
                  begin
                    MainForm.mmo1.Lines.Add(cmdstr + '���ͳɹ�');
                    Break; //
                  end;
                  if sendNG then // ������Ӧ��
                  begin
                    MainForm.mmo1.Lines.Add(cmdstr + '����ʧ��');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            KeyUp: //�����ͷ�
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                cmdstr := '55FF02B1FFFF';
                SendStrhex(Com1, cmdstr);
                while true do //�ȴ����ݽ���
                begin
                  sleep(10);
                  if sendOK then // ���ͳɹ�
                  begin
                    MainForm.mmo1.Lines.Add(s0 + '���ͳɹ�');
                    Break; //
                  end;
                  if sendNG then // ������Ӧ��
                  begin
                    MainForm.mmo1.Lines.Add(s0 + '����ʧ��');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            Delay: //��ʱ
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                Delayms(GetNum(pars[0]));
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            SnapShot: //ץ��
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                if (pars[1][Length(pars[1])] = '\') then
                  pars[1] := Copy(pars[1], 1, (Length(pars[1]) - 1));
                if not DirectoryExists(pars[1]) then
                  //�ж��ļ����Ƿ���ڣ��������򴴽��ļ���
                begin
                  ForceDirectories(pars[1]); //�����ļ���
                  if not DirectoryExists(pars[1]) then
                    //�����ļ��д���ʹ��Ĭ���ļ���
                  begin
                    MainForm.mmo1.Lines.Add('Err: ' + pars[1] + ' ���ܴ���');
                    ForceDirectories('c:\SnapShot'); //�����ļ���
                    pars[1] := 'c:\SnapShot'; //ʹ��Ĭ��
                  end;
                end;
                path := pars[1] + '\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) + '.bmp';
                MainForm.mmo1.Lines.Add('SnapShot ' + path);
                CameraSetUnit.CMSnapShot(GetNum(pars[0]), path); //ץͼ
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            Ring:
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                cmdstr := '55FF02B20000';
                SendStrhex(Com1, cmdstr);
                while true do //�ȴ����ݽ���
                begin
                  sleep(1);
                  if sendOK then // ���ͳɹ�
                  begin
                    if (Rec_DATA[1] = StrToInt(pars[0])) and (Rec_DATA[2] = StrToInt(pars[1])) then
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '����:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2]) + ' ���OK');
                    end
                    else
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '����:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2]) + ' ���NG');
                    end;
                    Break; //
                  end;
                  if sendNG then // ������Ӧ��
                  begin
                    MainForm.mmo1.Lines.Add(s0 + 'ͨѶ��Ӧ��');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            IO:
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                cmdstr := '55FF04B500000000';
                SendStrhex(Com1, cmdstr);
                while true do //�ȴ����ݽ���
                begin
                  sleep(10);
                  if sendOK then // ���ͳɹ�
                  begin
                    if (Rec_DATA[1] = StrToInt(pars[0])) and (Rec_DATA[2] = StrToInt(pars[1])) and
                      (Rec_DATA[3] = StrToInt(pars[2])) and (Rec_DATA[4] = StrToInt(pars[3])) then
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '����:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2]) +
                        ',' + inttostr(Rec_Data[3]) + ',' + inttostr(Rec_Data[4]) + ' ���OK');
                    end
                    else
                    begin
                      MainForm.mmo1.Lines.Add(s0 + '����:' + inttostr(Rec_Data[1]) + ',' + inttostr(Rec_Data[2])
                        + ',' + inttostr(Rec_Data[3]) + ',' +
                        inttostr(Rec_Data[4]) + ' ���NG');
                    end;
                    Break; //
                  end;
                  if sendNG then // ������Ӧ��
                  begin
                    MainForm.mmo1.Lines.Add(s0 + 'ͨѶ��Ӧ��');
                    break;
                  end;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            QR: //QRcode����
              begin
                try
                  MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                  ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) + '_' + pars[0] + '.bmp'; //�����ͼƬ
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //ͼ��ץ�ģ��ڴ���
                  if pars.Count > 2 then
                  begin
                    QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_QR.bmp';
                    SrcRect := Rect(strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4]), strtoint(pars[5])); //��ȡ����
                    DwrRect := Rect(strtoint(pars[2]) div 2, strtoint(pars[3]) div 2, strtoint(pars[4]) div 2, strtoint(pars[5]) div 2); //��ȡ����������
                    Synchronize(Formcanvas); //��Ƶ����ʾ��ȡ������
                    bmp := Capture(SocBMP, SrcRect); //��ȡͼƬ ���ڴ���
                    CameraSetForm.image1.Picture.Bitmap.Assign(bmp); //��ʾ��ȡ��ͼƬ
                    bmp.SaveToFile(QRPicPath); //�����ȡ��ͼƬ
                    QRresult := DecodeFile(QRPicPath);
                  end
                  else
                  begin
                    CMSnapShot(strtoint(pars[0]), ImgPath); //ץ��ͼ��
                    QRresult := DecodeFile(ImgPath);
                  end;
                  if sameText(QRresult, pars[1]) then
                  begin
                    MainForm.mmo1.Lines.Add('����:' + QRresult + ' ���OK');
                    DeleteBMPFile(ImgPath); //���ɹ���ɾ���ļ�
                    DeleteBMPFile(QRPicPath);
                  end
                  else
                  begin
                    MainForm.mmo1.Lines.Add('����:' + QRresult + ' ���NG');
                  end;
                finally
                  bmp.Free; //�ͷ��ڴ�
                  SocBMP.free;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            OCR: //����ʶ��
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                bmp := TBitmap.Create;
                try
                  ImgPath := APPpath + 'IMG\' + FormatDateTime('yyyymmdd_hhmmss_zzz', now) + '_' + pars[0] + '.bmp'; //����ʶ��ͼƬ·��
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //ͼ��ץ�ģ��ڴ���
                  if pars.Count > 2 then
                  begin
                    QRPicPath := Copy(ImgPath, 1, Length(ImgPath) - 4) + '_OCR.bmp';
                    SrcRect := Rect(strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4]), strtoint(pars[5])); //��ȡ����
                    DwrRect := Rect(strtoint(pars[2]) div 2, strtoint(pars[3]) div 2, strtoint(pars[4]) div 2, strtoint(pars[5]) div 2);
                    Synchronize(Formcanvas); //��Ƶ����ʾ��ȡ������
                    bmp := Capture(SocBMP, SrcRect); //��ȡͼƬ ���ڴ���
                    ruihua(bmp); //ͼƬ��
                    BMPbinary(bmp); //ͼƬ��ֵ��
                    bmp.SaveToFile(QRPicPath); //�����ȡ��ͼƬ
                    CameraSetForm.image1.Picture.LoadFromFile(QRPicPath); //��ʾ��ȡ��ͼƬ
                    OCRtext := OCRdetection(QRPicPath); //OCR
                  end;
                  if sameText(OCRtext, pars[1]) then
                  begin
                    MainForm.mmo1.Lines.Add('����:' + OCRtext + ' ���OK');
                   // DeleteBMPFile(ImgPath); //���ɹ���ɾ���ļ�
                    DeleteBMPFile(QRPicPath); //���ɹ���ɾ���ļ�
                  end
                  else
                  begin
                    MainForm.mmo1.Lines.Add('����:' + OCRtext + ' ���NG' + #13#10 + ImgPath);
                    SocBMP.SaveToFile(ImgPath); //����ץ�ĵ�ͼƬ
                  end;
                finally
                  bmp.Free; //�ͷ��ڴ�
                  SocBMP.Free;
                end;
                MainForm.mmo1.Lines.Add('End:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10);
              end;
            GetAveRGB: //��ɫ��⣬��ȡ��Χ(x1,y1,x2,y2)RGB��ɫ�ľ�ֵ
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                try
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //ͼ��ץ�ģ��ڴ���
                  SrcRect := Rect(strtoint(pars[1]), strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4])); //��ɫ����
                  ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
                finally
                  SocBMP.Free;
                end;
                if Pos('-', pars[5]) > 0 then // �ַ����Ƿ����-��������ƫɫ����
                begin
                  try
                    ExpTempColor := SplitString(pars[5], '-'); //��'-'�ָ��ַ�
                    ExpColor := SplitString(ExpTempColor[0], '.');
                    DevColor := SplitString(ExpTempColor[1], '.');
                    if (StrToInt(ExpColor[0]) - StrToInt(DevColor[0])) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) - StrToInt(DevColor[1])) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) - StrToInt(DevColor[2])) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - StrToInt(DevColor[2]);

                    if (StrToInt(ExpColor[0]) + StrToInt(DevColor[0])) > 255 then
                      ColorAH := 255
                    else
                      ColorAH := StrToInt(ExpColor[0]) + StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) + StrToInt(DevColor[1])) > 255 then
                      ColorBH := 255
                    else
                      ColorBH := StrToInt(ExpColor[1]) + StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) + StrToInt(DevColor[2])) > 255 then
                      ColorCH := 255
                    else
                      ColorCH := StrToInt(ExpColor[2]) + StrToInt(DevColor[2]);
                    if (ColorRGB.Red >= ColorAL) and (ColorRGB.Red <= ColorAH) and
                      (ColorRGB.Green >= ColorBL) and (ColorRGB.Green <= ColorBH) and
                      (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '���أ�' + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue) + '����OK')
                    else
                      MainForm.mmo1.Lines.Add(FormatDateTime('[error]' + 'yyyy/mm/dd hh:mm:ss.zzz ', now) + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue));
                  finally
                    ExpTempColor.Free;
                    ExpColor.Free;
                    DevColor.Free;
                  end;
                end
                else //��ɫ������ƫֵ����
                begin
                  try
                    ExpColor := SplitString(pars[5], '.');
                    if (StrToInt(ExpColor[0]) - 10) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - 10;
                    if (StrToInt(ExpColor[1]) - 10) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - 10;
                    if (StrToInt(ExpColor[2]) - 10) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - 10;

                    if (StrToInt(ExpColor[0]) + 10) > 255 then
                      ColorAH := 255
                    else
                      ColorAH := StrToInt(ExpColor[0]) + 10;
                    if (StrToInt(ExpColor[1]) + 10) > 255 then
                      ColorBH := 255
                    else
                      ColorBH := StrToInt(ExpColor[1]) + 10;
                    if (StrToInt(ExpColor[2]) + 10) > 255 then
                      ColorCH := 255
                    else
                      ColorCH := StrToInt(ExpColor[2]) + 10;
                    if (ColorRGB.Red >= ColorAL) and (ColorRGB.Red <= ColorAH) and
                      (ColorRGB.Green >= ColorBL) and (ColorRGB.Green <= ColorBH) and
                      (ColorRGB.Blue >= ColorCL) and (ColorRGB.Blue <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '���أ�' + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue) + '����OK')
                    else
                      MainForm.mmo1.Lines.Add(FormatDateTime('[error]' + 'yyyy/mm/dd hh:mm:ss.zzz ', now) + inttostr(ColorRGB.Red)
                        + '.' + inttostr(ColorRGB.Green) + '.' + inttostr(ColorRGB.Blue));
                  finally
                    ExpColor.Free;
                  end;
                end;
              end;
            GetAveHSV: //��ɫ��⣬��ȡ��Χ(x1,y1,x2,y2)HSV��ɫ�ľ�ֵ
              begin
                MainForm.mmo1.Lines.Add('Start:' + FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + #13#10 + s0);
                try
                  SocBMP := CMSnapShotMem(strtoint(pars[0])); //ͼ��ץ�ģ��ڴ���
                  SrcRect := Rect(strtoint(pars[1]), strtoint(pars[2]), strtoint(pars[3]), strtoint(pars[4])); //��ɫ����
                  ColorRGB := GetAveRGBFunc(SocBMP, SrcRect);
                  ColorHSV := RGBToHSV(colorRGB);
                finally
                  SocBMP.Free;
                end;
                if Pos('-', pars[5]) > 0 then // �ַ����Ƿ����-��������ƫɫ����
                begin
                  try
                    ExpTempColor := SplitString(pars[5], '-'); //��'-'�ָ��ַ�
                    ExpColor := SplitString(ExpTempColor[0], '.');
                    DevColor := SplitString(ExpTempColor[1], '.');
                    if (StrToInt(ExpColor[0]) - StrToInt(DevColor[0])) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) - StrToInt(DevColor[1])) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) - StrToInt(DevColor[2])) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - StrToInt(DevColor[2]);

                    if (StrToInt(ExpColor[0]) + StrToInt(DevColor[0])) > 360 then
                      ColorAH := 360
                    else
                      ColorAH := StrToInt(ExpColor[0]) + StrToInt(DevColor[0]);
                    if (StrToInt(ExpColor[1]) + StrToInt(DevColor[1])) > 100 then
                      ColorBH := 100
                    else
                      ColorBH := StrToInt(ExpColor[1]) + StrToInt(DevColor[1]);
                    if (StrToInt(ExpColor[2]) + StrToInt(DevColor[2])) > 100 then
                      ColorCH := 100
                    else
                      ColorCH := StrToInt(ExpColor[2]) + StrToInt(DevColor[2]);
                    if (ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAH) and
                      (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH) and
                      (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '���أ�' + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness) + '����OK')
                    else
                      MainForm.mmo1.Lines.Add('[error] ' +FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness));
                  finally
                    ExpTempColor.Free;
                    ExpColor.Free;
                    DevColor.Free;
                  end;
                end
                else //��ɫ������ƫֵ����
                begin
                  try
                    ExpColor := SplitString(pars[5], '.');
                    if (StrToInt(ExpColor[0]) - 10) < 0 then
                      ColorAL := 0
                    else
                      ColorAL := StrToInt(ExpColor[0]) - 10;
                    if (StrToInt(ExpColor[1]) - 10) < 0 then
                      ColorBL := 0
                    else
                      ColorBL := StrToInt(ExpColor[1]) - 10;
                    if (StrToInt(ExpColor[2]) - 10) < 0 then
                      ColorCL := 0
                    else
                      ColorCL := StrToInt(ExpColor[2]) - 10;

                    if (StrToInt(ExpColor[0]) + 10) > 360 then
                      ColorAH := 360
                    else
                      ColorAH := StrToInt(ExpColor[0]) + 10;
                    if (StrToInt(ExpColor[1]) + 10) > 100 then
                      ColorBH := 100
                    else
                      ColorBH := StrToInt(ExpColor[1]) + 10;
                    if (StrToInt(ExpColor[2]) + 10) > 100 then
                      ColorCH := 100
                    else
                      ColorCH := StrToInt(ExpColor[2]) + 10;
                    if (ColorHSV.Hue >= ColorAL) and (ColorHSV.Hue <= ColorAL) and
                      (ColorHSV.Saturation >= ColorBL) and (ColorHSV.Saturation <= ColorBH) and
                      (ColorHSV.Brightness >= ColorCL) and (ColorHSV.Brightness <= ColorCH) then
                      MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '���أ�' + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness) + '����OK')
                    else
                      MainForm.mmo1.Lines.Add('[error] ' +FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + floattostr(ColorHSV.Hue)
                        + '.' + floattostr(ColorHSV.Saturation) + '.' + floattostr(ColorHSV.Brightness));
                  finally
                    ExpColor.Free;
                  end;
                end;
              end;
          end;
        end;
        funcStr.pars.free;
      end;
    end;
    finshtimes := finshtimes + 1;
    MainForm.Edit2.text := IntToStr(finshtimes);
    if finshtimes >= testtimes then
      ScripThreadExit := True;
  end;
  MainForm.mmo1.Lines.Add(FormatDateTime('yyyy/mm/dd hh:mm:ss.zzz ', now) + '���Խ���' + #13#10);
  MainForm.btnRun.Enabled := True;
end;

end.

