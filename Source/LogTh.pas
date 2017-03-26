unit LogTh;

interface

uses
  Classes;

type
  LogThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
    procedure Myfun;
  end;

implementation

uses
  DeviceLog, ExGlobal;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure StrThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ StrThread }

procedure LogThread.Myfun;
begin
  case LogFlag of
    1: LogForm.Memo1.Lines.Clear;
    2: LogForm.Memo2.Lines.Clear;
    3: LogForm.Memo1.Lines.SaveToFile(LogPath);
    4: LogForm.Memo2.Lines.SaveToFile(LogPath);
    5: LogTxt := LogForm.Memo1.Lines.Text;
    6: LogTxt := LogForm.Memo2.Lines.Text;    
  end;
  LogFlag:=0;
  LogPath:='';
  logCPFlag:=False;  
end;

procedure LogThread.Execute;
begin
  FreeOnTerminate := True;
  Synchronize(Myfun);
end;

end.

