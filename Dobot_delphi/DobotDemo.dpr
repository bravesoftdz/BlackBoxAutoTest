program DobotDemo;

uses
  Forms,
  DobotUnit in 'DobotUnit.pas' {DobotForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDobotForm, DobotForm);
  Application.Run;
end.
