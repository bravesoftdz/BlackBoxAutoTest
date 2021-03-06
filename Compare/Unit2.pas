unit checkThread;

interface

uses
  Classes;

type
  checkPIC = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  Dialogs;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure checkPIC.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ checkPIC }

procedure checkPIC.Execute;
begin
  { Place thread code here }
  ShowMessage('ok');
end;

end.
 