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
    Button5: TButton;
    Memo1: TMemo;
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
    procedure Button5Click(Sender: TObject);
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
  hs: HSTREAM; {流句柄}
  pyhs: HSTREAM;
  Data: array of Cardinal;
  bit: TBitmap;
  type
  TArray = array of Integer;
function GetAudioFFTDate(Mp3Path:string):TArray;
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

  OpenDialog1.Filter := 'Wav 文件(*.wav)|*wav|Mp3 文件(*.mp3)|*.mp3';
  if OpenDialog1.Execute then
    Mp3Path := AnsiString(OpenDialog1.FileName);

  hs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  if hs < BASS_ERROR_ENDED then
    Text := '打开失败'
  else begin
    Text := string(Mp3Path);
    bit.Free;
    bit := TBitmap.Create;
    pbDrawArea.Repaint;

    {下面几行不好理解}
    {重新建立文件流 hs2, 最后的参数是: BASS_STREAM_DECODE, 这样可以提前读取波形数据}
    hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);

    {用 BASS_ChannelGetLevel 获取峰值时, 是以 20ms 为一个单位的; 先获取总时间}
    time := BASS_ChannelBytes2Seconds(hs2, BASS_ChannelGetLength(hs, BASS_POS_BYTE));

    {time * 1000 div 20 + 1 是可以获取的总的峰值数据, 也是数组需要的大小}
    SetLength(Data, Trunc(time * 50 + 1));

    {遍历峰值数据填充数组}
    for i := 0 to Length(Data) - 1 do Data[i] := BASS_ChannelGetLevel(hs2);

    {hs2 此时已完成使命, 释放它}
    BASS_StreamFree(hs2);

    {调用绘制过程}
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
    //Text := '打开失败'
  else begin
   // Text := string(Mp3Path);
    bit.Free;
    bit := TBitmap.Create;
   // AudioSettingsForm.pbDrawArea.Repaint;

    {下面几行不好理解}
    {重新建立文件流 hs2, 最后的参数是: BASS_STREAM_DECODE, 这样可以提前读取波形数据}
    hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);

    {用 BASS_ChannelGetLevel 获取峰值时, 是以 20ms 为一个单位的; 先获取总时间}
    time := BASS_ChannelBytes2Seconds(hs2, BASS_ChannelGetLength(hs, BASS_POS_BYTE));

    {time * 1000 div 20 + 1 是可以获取的总的峰值数据, 也是数组需要的大小}
    SetLength(Data, Trunc(time * 50 + 1));

    {遍历峰值数据填充数组}
    for i := 0 to Length(Data) - 1 do Data[i] := BASS_ChannelGetLevel(hs2);

    {hs2 此时已完成使命, 释放它}
    BASS_StreamFree(hs2);

    {调用绘制过程}
    AudioSettingsForm.Draw;
  end;
end;


function getaudioLv(path: string):LongWord;
var
  Mp3Path: AnsiString;
  i,j: Cardinal;
  time: Double;
  hs2: HSTREAM;
  tmp:Int64;
  Level: Cardinal;
begin
  tmp:=0;
  Level:=0;
  BASS_StreamFree(hs);

  Mp3Path := AnsiString(path);

  hs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  if hs < BASS_ERROR_ENDED then
    //Text := '打开失败'
  else begin
   // Text := string(Mp3Path);

    {下面几行不好理解}
    {重新建立文件流 hs2, 最后的参数是: BASS_STREAM_DECODE, 这样可以提前读取波形数据}
    hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);

    {用 BASS_ChannelGetLevel 获取峰值时, 是以 20ms 为一个单位的; 先获取总时间}
    time := BASS_ChannelBytes2Seconds(hs2, BASS_ChannelGetLength(hs, BASS_POS_BYTE));

    {time * 1000 div 20 + 1 是可以获取的总的峰值数据, 也是数组需要的大小}
    j:=  Trunc(time * 50 + 1);

    {遍历峰值数据填充数组}
    for i := 0 to j-1 do
    begin
      Level := BASS_ChannelGetLevel(hs2); {其低16位为左声道峰值; 高16位为右声道峰值}
      tmp := tmp + hiWord(Level);
    end;
    {hs2 此时已完成使命, 释放它}
    BASS_StreamFree(hs2);
    Result:= tmp div j;

   MainForm.mmo1.Lines.add(FormatDateTime('yyyy-mm-dd hh:mm:ss zzz  ', now) + inttostr( Result));
  end;
end;

{刷新}

procedure TAudioSettingsForm.pbDrawAreaPaint(Sender: TObject);
begin
  pbDrawArea.Canvas.StretchDraw(Bounds(0, 0, pbDrawArea.Width, pbDrawArea.Height), bit);
end;

{绘制波形图}

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
    SaveDialog1.Filter := '文本文档(*.bmp)|*.bmp';
    if SaveDialog1.Execute then
    begin
      if FileExists(SaveDialog1.FileName) then
      begin
        if MessageBox(0, '文件已存在，是否覆盖', 'information', MB_OKCANCEL) = MB_OKCANCEL then
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
  {打开文件}
  OpenDialog1.Filter := 'Mp3 文件(*.mp3)|*.mp3|Wav 文件(*.wav)|*wav';
  if OpenDialog1.Execute then
    Mp3Path := AnsiString(OpenDialog1.FileName);

  {如果已有文件打开, 先要释放它}
  BASS_StreamFree(pyhs);

  {建立播放流}
  pyhs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);

  {是否打开成功, 显示一下}
  if pyhs < BASS_ERROR_ENDED then
    Text := '打开失败' else Text := string(Mp3Path);
  {播放}
  BASS_ChannelPlay(pyhs, False); {参数 1 是流句柄; 参数 2 若是 True 每次都会从头播放}
end;

procedure PlayWAV(Mp3Path: string);
begin
  {如果已有文件打开, 先要释放它}
  BASS_StreamFree(pyhs);
  {建立播放流}
  pyhs := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, 0);
  {播放}
  BASS_ChannelPlay(pyhs, False); {参数 1 是流句柄; 参数 2 若是 True 每次都会从头播放}
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

procedure TAudioSettingsForm.Button5Click(Sender: TObject);
var
  Mp3Path: AnsiString;
  hs2: HSTREAM;
  i,di: Integer;
  FFTData: array[0..127] of Single;
  FFTPeacks  : array [0..127] of Integer;
  FFTstrData:string;
begin
  BASS_StreamFree(hs2);

  OpenDialog1.Filter := 'Wav 文件(*.wav)|*wav|Mp3 文件(*.mp3)|*.mp3';
  if OpenDialog1.Execute then
    Mp3Path := AnsiString(OpenDialog1.FileName);
  hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);


  if hs2 < BASS_ERROR_ENDED then
    Text := '打开失败'
  else
  begin
      {重新建立文件流 hs2, 最后的参数是: BASS_STREAM_DECODE, 这样可以提前读取波形数据}
   // hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);
    BASS_ChannelGetData(hs2, @FFTData, BASS_DATA_FFT256);

  bit.Width := pbDrawArea.Width;
  bit.Height := pbDrawArea.Height;
  bit.Canvas.Brush.Color := clBlack;
  bit.Canvas.FillRect(Rect(0, 0, bit.Width, bit.Height));

  bit.Canvas.Pen.Color := clLime;
  FFTstrData:='';
  for i := 0 to Length(FFTData) - 1 do
  begin
    di := Round(Abs(FFTData[i]) * 5000);
    FFTstrData:= FFTstrData + IntToStr(di)+ ',';
    FFTPeacks[i] := di;
     bit.Canvas.Pen.Color := bit.Canvas.Pen.Color;
    bit.Canvas.lineto(i,  bit.Height - FFTPeacks[i]);
   // bit.Canvas.LineTo(i,  FFTPeacks[i]);//56
    bit.Canvas.Pen.Color := bit.Canvas.Pen.Color;
    bit.Canvas.Brush.Color := bit.Canvas.Pen.Color;
  end;
  FFTstrData := Copy(FFTstrData, 1, (Length(FFTstrData) - 1));
  Memo1.Lines.Add(FFTstrData);
  BitBlt(pbDrawArea.Canvas.Handle, 0, 0, pbDrawArea.Width, pbDrawArea.Height, bit.Canvas.Handle, 0, 0, SRCCOPY);
  end;
end;

function GetAudioFFTDate(Mp3Path:string):TArray;
var
  hs2: HSTREAM;
  i,di: Integer;
  FFTData: array[0..127] of Single;
begin
  setlength(Result,128);
  BASS_StreamFree(hs2);
  hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);


  if hs2 < BASS_ERROR_ENDED then
   // Text := '打开失败'
  else
  begin
      {重新建立文件流 hs2, 最后的参数是: BASS_STREAM_DECODE, 这样可以提前读取波形数据}
   // hs2 := BASS_StreamCreateFile(False, PAnsiChar(Mp3Path), 0, 0, BASS_STREAM_DECODE);
    BASS_ChannelGetData(hs2, @FFTData, BASS_DATA_FFT256);
  for i := 0 to Length(FFTData) - 1 do
  begin
    di := Round(Abs(FFTData[i]) * 5000);
    Result[i] := di;

  end;

  end;
end;

end.

