unit DTMFUnit;

interface
type
  TVolumeLevel = 0..127;

procedure MakeSound(Frequency1 {Hz}, Frequency2 {Hz}, Duration {mSec}: Integer);
procedure MakeSin(Frequency1 {Hz}, Duration {mSec}: Integer);
procedure DTMFOut(Tone: Integer; Duration: integer);
implementation

uses
  MMSystem, Classes, Dialogs, SysUtils, Windows;



procedure MakeSound(Frequency1 {Hz}, Frequency2 {Hz}, Duration {mSec}: Integer);
  {writes tone to memory and plays it}
var
  WaveFormatEx: TWaveFormatEx;
  MS: TMemoryStream;
  i, TempInt, DataCount, RiffCount: integer;
  SoundValue: byte;
  w, ww: double; // omega ( 2 * pi * frequency)

const
  Mono: Word = $0001;
  SampleRate: Integer = 44100; // 8000, 11025, 22050, or 44100
  RiffId: AnsiString = 'RIFF';
  WaveId: AnsiString = 'WAVE';
  FmtId: AnsiString = 'fmt ';
  DataId: AnsiString = 'data';
begin
  if (Frequency1 > (0.6 * SampleRate)) or (Frequency2 > (0.6 * SampleRate)) then
  begin
    ShowMessage(Format('Sample rate of %d is too Low to play a tone of %dHz %dHz',
      [SampleRate, Frequency1, Frequency2]));
    Exit;
  end;
  with WaveFormatEx do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := Mono;
    nSamplesPerSec := SampleRate;
    wBitsPerSample := $0008;
    nBlockAlign := (nChannels * wBitsPerSample) div 8;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;
  MS := TMemoryStream.Create;
  with MS do
  begin
    {Calculate length of sound data and of file data}
    DataCount := (Duration * SampleRate) div 1000; // sound data
    RiffCount := Length(WaveId) + Length(FmtId) + SizeOf(DWORD) +
      SizeOf(TWaveFormatEx) + Length(DataId) + SizeOf(DWORD) + DataCount; // file data
    {write out the wave header}
    Write(RiffId[1], 4); // 'RIFF'
    Write(RiffCount, SizeOf(DWORD)); // file data size
    Write(WaveId[1], Length(WaveId)); // 'WAVE'
    Write(FmtId[1], Length(FmtId)); // 'fmt '
    TempInt := SizeOf(TWaveFormatEx);
    Write(TempInt, SizeOf(DWORD)); // TWaveFormat data size
    Write(WaveFormatEx, SizeOf(TWaveFormatEx)); // WaveFormatEx record
    Write(DataId[1], Length(DataId)); // 'data'
    Write(DataCount, SizeOf(DWORD)); // sound data size
    {calculate and write out the tone signal}// now the data values
    w := 2 * Pi * Frequency1; // omega
    ww := 2 * Pi * Frequency2; // omega
    for i := 0 to DataCount - 1 do
    begin
      SoundValue := 127 + trunc(40 * (sin(i * w / SampleRate) + sin(i * ww /
        SampleRate))); // wt = w * i / SampleRate
      Write(SoundValue, SizeOf(Byte));
    end;
    {now play the sound}
    sndPlaySound(MS.Memory, SND_MEMORY or SND_SYNC);
    MS.Free;
  end;
end;


procedure MakeSin(Frequency1 {Hz}, Duration {mSec}: Integer);
  {writes tone to memory and plays it}
var
  WaveFormatEx: TWaveFormatEx;
  MS: TMemoryStream;
  i, TempInt, DataCount, RiffCount: integer;
  SoundValue: byte;
  w, ww: double; // omega ( 2 * pi * frequency)

const
  Mono: Word = $0001;
  SampleRate: Integer = 44100; // 8000, 11025, 22050, or 44100
  RiffId: AnsiString = 'RIFF';
  WaveId: AnsiString = 'WAVE';
  FmtId: AnsiString = 'fmt ';
  DataId: AnsiString = 'data';
begin
  if (Frequency1 > (0.6 * SampleRate)) then
  begin
    ShowMessage(Format('Sample rate of %d is too Low to play a tone of %dHz',
      [SampleRate, Frequency1]));
    Exit;
  end;
  with WaveFormatEx do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := Mono;
    nSamplesPerSec := SampleRate;
    wBitsPerSample := $0008;
    nBlockAlign := (nChannels * wBitsPerSample) div 8;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;
  MS := TMemoryStream.Create;
  with MS do
  begin
    {Calculate length of sound data and of file data}
    DataCount := (Duration * SampleRate) div 1000; // sound data
    RiffCount := Length(WaveId) + Length(FmtId) + SizeOf(DWORD) +
      SizeOf(TWaveFormatEx) + Length(DataId) + SizeOf(DWORD) + DataCount; // file data
    {write out the wave header}
    Write(RiffId[1], 4); // 'RIFF'
    Write(RiffCount, SizeOf(DWORD)); // file data size
    Write(WaveId[1], Length(WaveId)); // 'WAVE'
    Write(FmtId[1], Length(FmtId)); // 'fmt '
    TempInt := SizeOf(TWaveFormatEx);
    Write(TempInt, SizeOf(DWORD)); // TWaveFormat data size
    Write(WaveFormatEx, SizeOf(TWaveFormatEx)); // WaveFormatEx record
    Write(DataId[1], Length(DataId)); // 'data'
    Write(DataCount, SizeOf(DWORD)); // sound data size
    {calculate and write out the tone signal}// now the data values
    w := 2 * Pi * Frequency1; // omega
    for i := 0 to DataCount - 1 do
    begin
      SoundValue := 127 + trunc(50 * (sin(i * w / SampleRate))); // wt = w * i / SampleRate
      Write(SoundValue, SizeOf(Byte));
    end;
    {now play the sound}
    sndPlaySound(MS.Memory, SND_MEMORY or SND_SYNC);
    MS.Free;
  end;
end;

// How to call the function:
// MakeSound(1209,697, 1000, 30);
procedure DTMFOut(Tone: Integer; Duration: integer);
begin
  case Tone of
    0: MakeSound(1336, 941, Duration); //0  
    1: MakeSound(1209, 697, Duration);
    2: MakeSound(1336, 697, Duration);
    3: MakeSound(1477, 697, Duration);
    4: MakeSound(1209, 770, Duration);
    5: MakeSound(1336, 770, Duration);
    6: MakeSound(1477, 770, Duration);
    7: MakeSound(1209, 852, Duration);
    8: MakeSound(1336, 852, Duration);
    9: MakeSound(1477, 852, Duration);
    10: MakeSound(1633, 697, Duration);//A
    11: MakeSound(1633, 770, Duration);//B
    12: MakeSound(1633, 852, Duration);//C
    13: MakeSound(1633, 941, Duration);//D
    14: MakeSound(1209, 941, Duration);//*
    15: MakeSound(1477, 941, Duration);//#

  end;
end;  

end.

