unit DobotExGlobal;

interface

uses SysUtils, Dialogs, Registry, Classes, Windows, StrUtils,Forms,DOBOTDLL,
     DOBOTTYPE;

procedure StartDobot();
procedure InitDobot();
function DobotPTP(style:Byte;x: double;y: double;z: double; r: double):LongInt;
procedure RestDobot();
function DobotJOG(cmd: Byte):LongInt;

var
  m_bConnectStatus:boolean;

implementation

uses
  Unit1, DobotUnit;

procedure InitDobot();
var
   DobotjogJointParams:JOGJOINTPARAMS;
   i:integer;
   cmdIndex:int64;
   jdParam:JOGCommonParams ;
   pbsParam:PTPJointParams;
   cpbsParam:PTPCoordinateParams ;
   pbdParam:PTPCommonParams ;

begin
     SetCmdTimeout(3000);
     SetQueuedCmdClear();
     SetQueuedCmdStartExec();
     cmdIndex:=0;
     for i:=0 to 3 do
     begin
     pbsParam.velocity[i] := 200;
     pbsParam.acceleration[i] := 200;
     end;
     SetPTPJointParams(pbsParam, false, cmdIndex);

     cpbsParam.xyzVelocity := 100;
     cpbsParam.xyzAcceleration := 100;
     cpbsParam.rVelocity := 100;
     cpbsParam.rAcceleration := 100;
     SetPTPCoordinateParams(cpbsParam, false, cmdIndex);

     pbdParam.velocityRatio := 30; //   30
     pbdParam.accelerationRatio := 30; //  30
     SetPTPCommonParams(pbdParam, false, cmdIndex);
end;

procedure StartDobot();
var
   baud:DWORD;
   result:Integer;
begin
    baud := 115200;
    result := ConnectDobot('',baud);
    if result=Integer(DobotCommunicate_NoError)then
    begin
      DobotForm.label1.caption := 'Connect success';
      isconected :=True;
      InitDobot();
	    exit;
    end;
      DobotForm.label1.caption := 'Connect error';
end;

function DobotPTP(style:Byte;x: double;y: double;z: double; r: double):LongInt;
var
pdbCmd:PTPCmd ;
cmdIndex :int64;
ret :integer;
begin
  cmdIndex:=0;
  pdbCmd.ptpMode := style;
  pdbCmd.x := x;
  pdbCmd.y := y;
  pdbCmd.z := z;
  pdbCmd.r := r;

  while true do
  begin
     ret := SetPTPCmd(pdbCmd,true,cmdIndex);
     if ret = 0 then
     begin
        break;
     end;
  end; 
end;


function DobotJOG(cmd: Byte):LongInt;
var
currentCmd :JOGCMD ;
cmdIndex :int64;
begin
currentcmd.isJoint := 0;
currentcmd.cmd := cmd;
SetJOGCmd(currentCmd,false,cmdIndex);
end;

procedure RestDobot();
var
queuedCmdIndex : int64;
dobothomeCmd : HOMECMD;
ret : integer;
begin
  queuedCmdIndex:=0;
  while true do
  begin
    ret := SetHOMECmd(dobothomeCmd,true,queuedCmdIndex);
    if ret = Integer(DobotCommunicate_NoError) then
    begin
      break;
    end;
  end;
end;
end.

