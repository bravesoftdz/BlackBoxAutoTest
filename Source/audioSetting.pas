unit audioSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Bass, ExtCtrls;
type
  WAVHDR = packed record
    riff: array[0..3] of AnsiChar;
    len: DWord;
    cWavFmt: array[0..7] of AnsiChar;
    dwHdrLen: DWord;
    wFormat: Word;
    wNumChannels: Word;
    dwSampleRate: DWord;
    dwBytesPerSec: DWord;
    wBlockAlign: Word;
    wBitsPerSample: Word;
    cData: array[0..3] of AnsiChar;
    dwDataLen: DWord;
  end;

type
  TAudioSettingsForm = class(TForm)
    ComboBox1: TComboBox;
    TrackBar1: TTrackBar;
    VolumeLevel: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    Button1: TButton;
    pbDrawArea: TPaintBox;
    OpenDialog1: TOpenDialog;
    btn1: TButton;
    Button2: TButton;
    Button3: TButton;
    SaveDialog1: TSaveDialog;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Button4: TButton;
    procedure TrackBar1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartRecording;
    procedure StopRecording;
    procedure UpdateInputInfo;
    procedure Button1Click(Sender: TObject);
    procedure pbDrawAreaPaint(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    WaveStream: TMemoryStream;
    procedure Draw;
  public
    { Public declarations }
  end;
procedure MicRecord();
procedure MICSTOP();
procedure WAVSave(FileName: string);
procedure openaduio(path: string);
procedure SaveAudioBMP(Path: string);
procedure PlayWAV(Mp3Path: string);
function getaudioLv(path: string):LongWord;
var
  AudioSettingsForm: TAudioSettingsForm;
  WaveHdr: WAVHDR; // WAV header
  rchan: HRECORD; // recording channel
  chan: HSTREAM; // playback channel
var
  hs: HSTREAM; {�����}
  pyhs: HSTREAM;
  Data: array of Cardinal;
  bit: TBitmap;
implementation

uses Unit1;

{$R *.dfm}

(* This is called while recording audio *)

function RecordingCallback(Handle: HRECORD; buffer: Pointer; length: DWORD; user: Pointer): boolean; stdcall;
begin
    // Copy new buffer contents to the memory buffer
  AudioSettingsForm.WaveStream.Write(buffer^, length);
    // Allow recording to continue
  Result := True;
end;

procedure TAudioSettingsForm.UpdateInputInfo;
var
  i: DWord;
  level: Single;
begin
  I := BASS_RecordGetInput(ComboBox1.ItemIndex, level);
  TrackBar1.Position := Round(level * 100); // set the level slider
  Label2.Caption := IntToStr(TrackBar1.Position);

  case (i and BASS_INPUT_TYPE_MASK) of
    BASS_INPUT_TYPE_DIGITAL: Label1.Caption := 'digital';
    BASS_INPUT_TYPE_LINE: Label1.Caption := 'line-in';
    BASS_INPUT_TYPE_MIC: Label1.Caption := 'microphone';
    BASS_INPUT_TYPE_SYNTH: Label1.Caption := 'midi synth';
    BASS_INPUT_TYPE_CD: Label1.Caption := 'analog cd';
    BASS_INPUT_TYPE_PHONE: Label1.Caption := 'telephone';
    BASS_INPUT_TYPE_SPEAKER: Label1.Caption := 'pc speaker';
    BASS_INPUT_TYPE_WAVE: Label1.Caption := 'wave/pcm';
    BASS_INPUT_TYPE_AUX: Label1.Caption := 'aux';
    BASS_INPUT_TYPE_ANALOG: Label1.Caption := 'analog';
  else
    Label1.Caption := 'undefined';
  end;
end;

(* Start recording to memory *)

procedure TAudioSettingsForm.StartRecording;
begin
  if ComboBox1.ItemIndex < 0 then Exit;
  if WaveStream.Size > 0 then
  begin // free old recording
    BASS_StreamFree(chan);
    WaveStream.Clear;
  end;
 // generate header for WAV file
  with WaveHdr do
  begin
    riff := 'RIFF';
    len := 36;
    cWavFmt := 'WAVEfmt ';
    dwHdrLen := 16;
    wFormat := 1;
    wNumChannels := 2;
    dwSampleRate := 44100;
    wBlockAlign := 4;
    dwBytesPerSec := 176400;
    wBitsPerSample := 16;
    cData := 'data';
    dwDataLen := 0;
  end;
  WaveStream.Write(WaveHdr, SizeOf(WAVHDR));
 // start recording @ 44100hz 16-bit stereo
  rchan := BASS_RecordStart(44100, 2, 0, @RecordingCallback, nil);
  if rchan = 0 then
  begin
    MessageDlg('Couldn''t start recording!', mtError, [mbOk], 0);
    WaveStream.Clear;
  end
  else
  begin
  //	bRecord.Caption := 'Stop';
 //	bPlay.Enabled := False;
 //	bSave.Enabled := False;
  end;
end;

(* Stop recording *)

procedure TAudioSettingsForm.StopRecording;
var
  i: integer;
begin
  BASS_ChannelStop(rchan);
 //	bRecord.Caption := 'Record';
 // complete the WAV header
  WaveStream.Position := 4;
  i := WaveStream.Size - 8;
  WaveStream.Write(i, 4);
  i := i - $24;
  WaveStream.Position := 40;
  WaveStream.Write(i, 4);
  WaveStream.Position := 0;
 // create a stream from the recorded data
  chan := BASS_StreamCreateFile(True, WaveStream.Memory, 0, WaveStream.Size, 0);
  if chan <> 0 then
  begin
  // enable "Play" & "Save" buttons
       // bPlay.Enabled := True;
       // bSave.Enabled := True;
  end
  else
    MessageDlg('Error creating stream from recorded data!', mtError, [mbOk], 0);
end;

procedure TAudioSettingsForm.TrackBar1Change(Sender: TObject);
begin
  BASS_RecordSetInput(ComboBox1.ItemIndex, 0, TrackBar1.Position / 100);
  Label2.Caption := IntToStr(TrackBar1.Position);
end;

procedure TAudioSettingsForm.ComboBox1Change(Sender: TObject);
var
  i: Integer;
  r: Boolean;
begin
 // enable the selected input
  r := True;
  i := 0;
    // first disable all inputs, then...
  while r do
  begin
    r := BASS_RecordSetInput(i, BASS_INPUT_OFF, -1);
    Inc(i);
  end;
    // ...enable the selected.
  BASS_RecordSetInput(ComboBox1.ItemIndex, BASS_INPUT_ON, -1);
  UpdateInputInfo; // update info
end;

procedure TAudioSettingsForm.FormCreate(Sender: TObject);
var
  i: Integer;
  dName: PAnsiChar;
  level: Single;   
begin
  bit := TBitmap.Create;
  Button4.Enabled :=False;
 // pbDrawArea.Align := alTop;
 // check the correct BASS was loaded
  if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
  begin
    MessageBox(0, 'An incorrect version of BASS.DLL was loaded', nil, MB_ICONERROR);
   // Application.Terminate;
    Button4.Enabled :=True;
    Exit;
  end;
  if (not BASS_RecordInit(-1)) or (not BASS_Init(-1, 44100, 0, Handle, nil)) then
  begin
    BASS_RecordFree;
    BASS_Free();
   // MessageDlg('Cannot start default recording device!', mtError, [mbOk], 0);
    Button4.Enabled :=True;
    Exit;
   //	Application.Terminate;
  end;
  WaveStream := TMemoryStream.Create;
  i := 0;
  dName := BASS_RecordGetInputName(i);
  while dName <> nil do
  begin
    ComboBox1.Items.Add(StrPas(dName));
  // is this one currently "on"?
    if (BASS_RecordGetInput(i, level) and BASS_INPUT_OFF) = 0 then
      ComboBox1.ItemIndex := i;
    Inc(i);
    dName := BASS_RecordGetInputName(i);
  end;
  ComboBox1Change(Self); // display info   
end;

procedure MICRecord();
begin
  AudioSettingsForm.StartRecording;
end;

procedure MICSTOP();
begin
  AudioSettingsForm.StopRecording
end;

procedure WAVSave(FileName: string);
begin
  AudioSettingsForm.WaveStream.SaveToFile(FileName);
end;

procedure TAudioSettingsForm.Button1Click(Sender: TObject);
var
  Mp3Path: AnsiString;
  i: Cardinal;
  time: Double;
  hs2: HSTREAM;
begin
  BASS_StreamFree(hs);

  OpenDialog1.Filter := 'Wav �ļ�(*.wav)|*wav|Mp3 �ļ�(*.mp3)|*.mp3';
  if OpenDialog1.Execute then
    Mp3Path := AnsiString(OpenDialog1.FileName);

  hs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  if hs < BASS_ERROR_ENDED then
    Text := '��ʧ��'
  else begin
    Text := string(Mp3Path);
    bit.Free;
    bit := TBitmap.Create;
    pbDrawArea.Repaint;

    {���漸�в������}
    {���½����ļ��� hs2, ���Ĳ�����: BASS_STREAM_DECODE, ����������ǰ��ȡ��������}
    hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);

    {�� BASS_ChannelGetLevel ��ȡ��ֵʱ, ���� 20ms Ϊһ����λ��; �Ȼ�ȡ��ʱ��}
    time := BASS_ChannelBytes2Seconds(hs2, BASS_ChannelGetLength(hs, BASS_POS_BYTE));

    {time * 1000 div 20 + 1 �ǿ��Ի�ȡ���ܵķ�ֵ����, Ҳ��������Ҫ�Ĵ�С}
    SetLength(Data, Trunc(time * 50 + 1));

    {������ֵ�����������}
    for i := 0 to Length(Data) - 1 do Data[i] := BASS_ChannelGetLevel(hs2);

    {hs2 ��ʱ�����ʹ��, �ͷ���}
    BASS_StreamFree(hs2);

    {���û��ƹ���}
    Draw;
  end;
end;

procedure openaduio(path: string);
var
  Mp3Path: AnsiString;
  i: Cardinal;
  time: Double;
  hs2: HSTREAM;
begin
  BASS_StreamFree(hs);

  Mp3Path := AnsiString(path);

  hs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  if hs < BASS_ERROR_ENDED then
    //Text := '��ʧ��'
  else begin
   // Text := string(Mp3Path);
    bit.Free;
    bit := TBitmap.Create;
   // AudioSettingsForm.pbDrawArea.Repaint;

    {���漸�в������}
    {���½����ļ��� hs2, ���Ĳ�����: BASS_STREAM_DECODE, ����������ǰ��ȡ��������}
    hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);

    {�� BASS_ChannelGetLevel ��ȡ��ֵʱ, ���� 20ms Ϊһ����λ��; �Ȼ�ȡ��ʱ��}
    time := BASS_ChannelBytes2Seconds(hs2, BASS_ChannelGetLength(hs, BASS_POS_BYTE));

    {time * 1000 div 20 + 1 �ǿ��Ի�ȡ���ܵķ�ֵ����, Ҳ��������Ҫ�Ĵ�С}
    SetLength(Data, Trunc(time * 50 + 1));

    {������ֵ�����������}
    for i := 0 to Length(Data) - 1 do Data[i] := BASS_ChannelGetLevel(hs2);

    {hs2 ��ʱ�����ʹ��, �ͷ���}
    BASS_StreamFree(hs2);

    {���û��ƹ���}
    AudioSettingsForm.Draw;
  end;
end;


function getaudioLv(path: string):LongWord;
var
  Mp3Path: AnsiString;
  i,j: Cardinal;
  time: Double;
  hs2: HSTREAM;
  LData: array of Cardinal;
  tmp:Int64;
begin
  tmp:=0;
  BASS_StreamFree(hs);

  Mp3Path := AnsiString(path);

  hs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  if hs < BASS_ERROR_ENDED then
    //Text := '��ʧ��'
  else begin
   // Text := string(Mp3Path);

    {���漸�в������}
    {���½����ļ��� hs2, ���Ĳ�����: BASS_STREAM_DECODE, ����������ǰ��ȡ��������}
    hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);

    {�� BASS_ChannelGetLevel ��ȡ��ֵʱ, ���� 20ms Ϊһ����λ��; �Ȼ�ȡ��ʱ��}
    time := BASS_ChannelBytes2Seconds(hs2, BASS_ChannelGetLength(hs, BASS_POS_BYTE));

    {time * 1000 div 20 + 1 �ǿ��Ի�ȡ���ܵķ�ֵ����, Ҳ��������Ҫ�Ĵ�С}
    j:=  Trunc(time * 50 + 1);

    {������ֵ�����������}
    for i := 1 to j do
      tmp := tmp + BASS_ChannelGetLevel(hs2);
     // LData[i] := BASS_ChannelGetLevel(hs2);

    {hs2 ��ʱ�����ʹ��, �ͷ���}
    BASS_StreamFree(hs2);
     Result:= tmp div j;

   MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + inttostr( Result));
  end;
end;

{ˢ��}

procedure TAudioSettingsForm.pbDrawAreaPaint(Sender: TObject);
begin
  pbDrawArea.Canvas.StretchDraw(Bounds(0, 0, pbDrawArea.Width, pbDrawArea.Height), bit);
end;

{���Ʋ���ͼ}

procedure TAudioSettingsForm.Draw;
var
  i, ch: Integer;
  L, R: SmallInt;
  lv:Integer;
begin
  bit.Width := Length(Data);
  bit.Height := 320; //pbDrawArea.Height;
  ch := bit.Height div 2;
  lv:=StrToInt(Edit1.Text);
  bit.Canvas.Brush.Color := clBlack;
  bit.Canvas.FillRect(Bounds(0, 0, bit.Width, bit.Height));
  bit.Canvas.Pen.Color := clLime;

  for i := 0 to Length(Data) - 1 do
  begin
    L := LoWord(Data[i]);
    R := HiWord(Data[i]);
    if CheckBox1.Checked then
    begin
      if L < lv then
        L := 0
      else
        L := L - lv;
      if R < lv then
        R := 0
      else
        R := R - lv;
    end;
    bit.Canvas.MoveTo(i, ch - Trunc(L / 32768 * ch));
    bit.Canvas.LineTo(i, ch + Trunc(R / 32768 * ch));
  end;
  pbDrawArea.Repaint;
end;

procedure TAudioSettingsForm.btn1Click(Sender: TObject);
var
  aBitmap: TBitmap;
begin
  aBitmap := TBitmap.Create;
  try
    aBitmap.Width := 640;
    aBitmap.Height := 320;
    aBitmap.Canvas.StretchDraw(rect(0, 0, 640, 320), bit);
    SaveDialog1.DefaultExt := 'bmp';
    SaveDialog1.Filter := '�ı��ĵ�(*.bmp)|*.bmp';
    if SaveDialog1.Execute then
    begin
      if FileExists(SaveDialog1.FileName) then
      begin
        if MessageBox(0, '�ļ��Ѵ��ڣ��Ƿ񸲸�', 'information', MB_OKCANCEL) = MB_OKCANCEL then
        begin
          aBitmap.SaveToFile(SaveDialog1.FileName);
        end;
      end
      else
      begin
        aBitmap.SaveToFile(SaveDialog1.FileName);
      end;
    end;
  finally
    aBitmap.Free;
  end;
end;

procedure SaveAudioBMP(Path: string);
var
  aBitmap: TBitmap;
begin
  aBitmap := TBitmap.Create;
  try
    aBitmap.Width := 640;
    aBitmap.Height := 320;
    aBitmap.Canvas.StretchDraw(rect(0, 0, 640, 320), bit);
    abitmap.SaveToFile(Path);
  finally
    aBitmap.Free;
  end;
end;

procedure TAudioSettingsForm.Button2Click(Sender: TObject);
var
  Mp3Path: AnsiString;
begin
  {���ļ�}
  OpenDialog1.Filter := 'Mp3 �ļ�(*.mp3)|*.mp3|Wav �ļ�(*.wav)|*wav';
  if OpenDialog1.Execute then
    Mp3Path := AnsiString(OpenDialog1.FileName);

  {��������ļ���, ��Ҫ�ͷ���}
  BASS_StreamFree(pyhs);

  {����������}
  pyhs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);

  {�Ƿ�򿪳ɹ�, ��ʾһ��}
  if pyhs < BASS_ERROR_ENDED then
    Text := '��ʧ��' else Text := string(Mp3Path);
  {����}
  BASS_ChannelPlay(pyhs, False); {���� 1 �������; ���� 2 ���� True ÿ�ζ����ͷ����}
end;

procedure PlayWAV(Mp3Path: string);
begin
  {��������ļ���, ��Ҫ�ͷ���}
  BASS_StreamFree(pyhs);
  {����������}
  pyhs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  {����}
  BASS_ChannelPlay(pyhs, False); {���� 1 �������; ���� 2 ���� True ÿ�ζ����ͷ����}
end;

procedure TAudioSettingsForm.Button3Click(Sender: TObject);
begin
  BASS_ChannelStop(pyhs);
end;

procedure TAudioSettingsForm.Button4Click(Sender: TObject);
var
  i: Integer;
  dName: PAnsiChar;
  level: Single;
begin
  bit := TBitmap.Create;
 // pbDrawArea.Align := alTop;
 // check the correct BASS was loaded
  if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
  begin
    MessageBox(0, 'An incorrect version of BASS.DLL was loaded', nil, MB_ICONERROR);
    Exit;
   // Application.Terminate;
  end;
  if (not BASS_RecordInit(-1)) or (not BASS_Init(-1, 44100, 0, Handle, nil)) then
  begin
    BASS_RecordFree;
    BASS_Free();
    MessageDlg('Cannot start default recording device!', mtError, [mbOk], 0);
    Exit;
  //	Application.Terminate;
  end;
  WaveStream := TMemoryStream.Create;
  i := 0;
  dName := BASS_RecordGetInputName(i);
  while dName <> nil do
  begin
    ComboBox1.Items.Add(StrPas(dName));
  // is this one currently "on"?
    if (BASS_RecordGetInput(i, level) and BASS_INPUT_OFF) = 0 then
      ComboBox1.ItemIndex := i;
    Inc(i);
    dName := BASS_RecordGetInputName(i);
  end;
  ComboBox1Change(Self); // display info
  Button4.Enabled:=False;
end;

end.

