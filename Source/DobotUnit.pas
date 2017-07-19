unit DobotUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,DobotExGlobal,DOBOTDLL, DOBOTTYPE,ExtCtrls, ComCtrls,
  Grids,DBGrid1,math, Menus;


type TArrDouble=array of Double;

type
  TDobotForm = class(TForm)
    ConnectDobot: TButton;
    Dobot_Home: TButton;
    Memo1: TMemo;
    Dobot_Record: TButton;
    Run: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    StringGrid1: TStringGrid;
    PopupMenu1: TPopupMenu;
    delete1: TMenuItem;
    edit5: TMenuItem;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button1: TButton;
    Button9: TButton;
    Label1: TLabel;
    Button10: TButton;
    edt1: TEdit;
    ScrollBar1: TScrollBar;
    procedure ConnectDobotClick(Sender: TObject);
    procedure Dobot_RecordClick(Sender: TObject);
    procedure RunClick(Sender: TObject);
    procedure Dobot_HomeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure InitStringGrid(Sender: TObject);
    procedure delete1Click(Sender: TObject);
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button5MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button6MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button7MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button7MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button8MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button8MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    //procedure StringGridDrawCell(Sender: TObject;ACol,ARow:Integer;
          //Rect:TRect;State:TGridDrawState);
   //procedure Dobot_Timer_PoseTimer(Sender: TObject);
    private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DobotForm: TDobotForm;
  x_s,y_s,z_s,r_s: string;
  isconected:Boolean;
implementation

uses
  ExGlobal;

{$R *.dfm}



procedure TDobotForm.ConnectDobotClick(Sender: TObject);
begin
   StartDobot();
end;

procedure TDobotForm.Dobot_RecordClick(Sender: TObject);
var
dobotPose : POSE;
begin
    if not isconected then
      Exit;
   GetPose(dobotPose);
 DobotForm.Memo1.Lines.Add(FloatToStrF(dobotPose.x,ffNumber,5,2) + ',' + FloatToStrF(dobotPose.y,ffNumber,5,2)+ ',' +
                           FloatToStrF(dobotPose.z,ffNumber,5,2)+',' + FloatToStrF(dobotPose.r,ffNumber,5,2))  ;

 StringGrid1.RowCount:=StringGrid1.RowCount+1;
 StringGrid1.Row:= StringGrid1.RowCount-1; //行号跟进
 //Label1.Caption:='当前行：'+IntToStr(StringGrid1.RowCount); //指示滚动条和行号同步
 //Form1.StringGrid1.Cells[1,StringGrid1.Row] := floattostr(dobotPose.x);
 //Form1.StringGrid1.Cells[2,StringGrid1.Row] := FloatToStr(dobotPose.y);
 //Form1.StringGrid1.Cells[3,StringGrid1.Row] := FloatToStr(dobotPose.z);
 //Form1.StringGrid1.Cells[4,StringGrid1.Row] := FloatToStr(dobotPose.r);


 DobotForm.StringGrid1.Cells[1,StringGrid1.Row] := FloatToStrF(dobotPose.x,ffNumber,5,2);
 DobotForm.StringGrid1.Cells[2,StringGrid1.Row] := FloatToStrF(dobotPose.y,ffNumber,5,2);
 DobotForm.StringGrid1.Cells[3,StringGrid1.Row] := FloatToStrF(dobotPose.z,ffNumber,5,2);
 DobotForm.StringGrid1.Cells[4,StringGrid1.Row] := FloatToStrF(dobotPose.r,ffNumber,5,2);

end;

procedure TDobotForm.RunClick(Sender: TObject);
var
  I, J, K : Integer;
   x,y,z,r:double;
   val:Single;
   s:String;
   test:single;
  arr:array of Double;
  dobotPose : POSE;
  styleMode  :PTPMode;
  SplitStr : String;
begin
      if not isconected then
      Exit;
   //StringGrid1.Row :=1;
   for i:=1 to StringGrid1.RowCount-1 do
   begin
      x := StrToFloat(StringGrid1.Cells[1,i]);
      y := StrToFloat(StringGrid1.Cells[2,i]);
      z := StrToFloat(StringGrid1.Cells[3,i]);
      r := StrToFloat(StringGrid1.Cells[4,i]);
      DobotPTP(2,x,y,z,r);
      StringGrid1.Row:=i;
      Delayms(1000);
   end;
end;



procedure TDobotForm.Dobot_HomeClick(Sender: TObject);
begin
      if not isconected then
      Exit;
   RestDobot();
end;


procedure TDobotForm.Timer1Timer(Sender: TObject);
var
   dobotPose : POSE;
   i:Single;
begin
   //if not Timer1.Enabled then
    // Exit
  // else
  // begin
  // GetPose(dobotPose);
   //i:=1.234;
   //Form1.Memo1.Lines.Add(FloatToStr(dobotPose.x)+'   '
                       //  +FloatToStr(dobotPose.y)+'   '
                       //  +FloatToStr(dobotPose.z)+'   '
                       //  +FloatToStr(dobotPose.r));


   //StringGrid1.RowCount:=StringGrid1.RowCount+1;
   //StringGrid1.Row:= StringGrid1.RowCount-1; //行号跟进
   //Label1.Caption:='当前行：'+IntToStr(StringGrid1.RowCount); //指示滚动条和行号同步


   //Form1.StringGrid1.Cells[1,StringGrid1.Row] := FloatToStr(dobotPose.x);
   //Form1.StringGrid1.Cells[2,StringGrid1.Row] := FloatToStr(dobotPose.y);
   //Form1.StringGrid1.Cells[3,StringGrid1.Row] := FloatToStr(dobotPose.z);
   //Form1.StringGrid1.Cells[4,StringGrid1.Row] := FloatToStr(dobotPose.r);
   //end;

   //Timer1.Enabled := False;
end;

procedure TDobotForm.InitStringGrid(Sender: TObject);
begin
 DobotForm.StringGrid1.Cells[1,0]:='X';
 DobotForm.StringGrid1.Cells[2,0]:='Y';
 DobotForm.StringGrid1.Cells[3,0]:='Z';
 DobotForm.StringGrid1.Cells[4,0]:='R';
end;


procedure  DeleteStringGridRow(vRow: Integer;  StringGrid:   TStringGrid);
var
i:   Integer;
begin
 if   StringGrid.RowCount   >   vRow   then
  begin
    for   i   :=   vRow   to   StringGrid.RowCount   -   vRow   do
      begin
        StringGrid.Rows[i]   :=   StringGrid.Rows[i+1];
      end;
      StringGrid.RowCount   :=   StringGrid.RowCount   -   1;
  end;
end;

procedure TDobotForm.delete1Click(Sender: TObject);
var
vSelRow: Integer;
begin
//得到所选行
vSelRow := StringGrid1.Row;
//删除所选行
DeleteStringGridrow(vSelRow, StringGrid1);
end;

procedure TDobotForm.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DobotJOG(byte(JogAPPressed));
end;

procedure TDobotForm.Button1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogANPressed));
end;

procedure TDobotForm.Button2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogBPPressed));
end;

procedure TDobotForm.Button3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogBNPressed));
end;

procedure TDobotForm.Button4MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogCPPressed));
end;

procedure TDobotForm.Button5MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    DobotJOG(byte(JogCNPressed));
end;

procedure TDobotForm.Button6MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button7MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    DobotJOG(byte(JogDPPressed));
end;

procedure TDobotForm.Button7MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button8MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogDNPressed));
end;

procedure TDobotForm.Button8MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   DobotJOG(byte(JogIdle));
end;

procedure TDobotForm.Button9Click(Sender: TObject);
begin
    DisconnectDobot();
    isconected:=False;
    DobotForm.label1.caption := 'Connect error';
end;

procedure TDobotForm.Button10Click(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TDobotForm.ScrollBar1Change(Sender: TObject);
var
     pbdParam:PTPCommonParams ;
      cmdIndex:int64;
begin
    if not isconected then
      Exit;
    cmdIndex :=0;
     pbdParam.velocityRatio := ScrollBar1.Position; //   30
     pbdParam.accelerationRatio := 100; //  30
     SetPTPCommonParams(pbdParam, false, cmdIndex);
     edt1.Text := IntToStr(ScrollBar1.Position);
end;

end.
