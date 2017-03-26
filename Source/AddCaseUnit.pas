unit AddCaseUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Buttons, ExtCtrls, PaxCompiler, PaxRunner,
  PaxProgram, PaxCompilerDebugger, PaxCompilerExplorer,PaxRegister,
  SynEdit, SynMemo, SynEditHighlighter, SynHighlighterPas, ImgList,
  ActnList, Menus, ToolWin;

type
  TAddCaseFrm = class(TForm)
    lbl2: TLabel;
    PaxCompilerExplorer1: TPaxCompilerExplorer;
    PaxCompilerDebugger1: TPaxCompilerDebugger;
    PaxPascalLanguage1: TPaxPascalLanguage;
    PaxProgram1: TPaxProgram;
    PaxCompiler1: TPaxCompiler;
    SynPasSyn1: TSynPasSyn;
    tbDebug: TToolBar;
    tbtnRun: TToolButton;
    tbtnStep: TToolButton;
    tbtnGotoCursor: TToolButton;
    ToolButton1: TToolButton;
    tbtnToggleBreakpoint: TToolButton;
    tbtnClearAllBreakpoints: TToolButton;
    MainMenu1: TMainMenu;
    mDebug: TMenuItem;
    miDebugRun: TMenuItem;
    miDebugStep: TMenuItem;
    miDebugGotoCursor: TMenuItem;
    N1: TMenuItem;
    miToggleBreakpoint: TMenuItem;
    miClearBreakpoints: TMenuItem;
    imglActions: TImageList;
    imglGutterGlyphs: TImageList;
    pnl1: TPanel;
    SynMemo1: TSynMemo;
    btnBuild: TToolButton;
    btnStepInto: TToolButton;
    pnl2: TPanel;
    Memo2: TMemo;
    pnl3: TPanel;
    lbl18: TLabel;
    procedure PaxProgram1PauseUpdated(Sender: TPaxRunner;
      const ModuleName: string; SourceLineNumber: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);    
    procedure PaxProgram1PrintEvent(Sender: TPaxRunner;
      const Text: String);
    procedure btnBuildClick(Sender: TObject);
    procedure tbtnRunClick(Sender: TObject);
    procedure tbtnGotoCursorClick(Sender: TObject);
    procedure tbtnStepClick(Sender: TObject);
    procedure btnStepIntoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    ResumeRequest: Boolean;
    CloseRequest: Boolean;
    procedure UpdateDebugInfo;    
  public
    { Public declarations }
  end;

var
  AddCaseFrm: TAddCaseFrm;

implementation

{$R *.dfm}

procedure TAddCaseFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  CloseRequest := true;
end;

procedure TAddCaseFrm.PaxProgram1PauseUpdated(Sender: TPaxRunner;
  const ModuleName: string; SourceLineNumber: Integer);
begin
  UpdateDebugInfo;
  ResumeRequest := false;
  repeat
    Application.ProcessMessages;
    if ResumeRequest then
      Break;
    if CloseRequest then
      Abort;
  until false;
end;

procedure TAddCaseFrm.UpdateDebugInfo;

  procedure AddFields(StackFrameNumber, Id: Integer);
  var
    I, K: Integer;
    OwnerName, S: String;
  begin
    K := PaxCompilerExplorer1.GetFieldCount(Id);
    if K = 0 then
      Exit;

    OwnerName := PaxCompilerExplorer1.Names[Id];
    if PaxCompilerDebugger1.GetValueAsString(Id) = 'nil' then
      Exit;

    for I:=0 to K - 1 do
    begin
      S := OwnerName + '.' + PaxCompilerExplorer1.GetFieldName(Id, I);
      S := '      ' + S + '=' + PaxCompilerDebugger1.GetFieldValueAsString(
        StackFrameNumber, Id, I);
      Memo2.Lines.Add(S);
    end;
  end;

  procedure AddPublishedProps(StackFrameNumber, Id: Integer);
  var
    I, K: Integer;
    OwnerName, S: String;
  begin
    K := PaxCompilerExplorer1.GetPublishedPropCount(Id);
    if K = 0 then
      Exit;

    OwnerName := PaxCompilerExplorer1.Names[Id];
    if PaxCompilerDebugger1.GetValueAsString(Id) = 'nil' then
      Exit;

    for I:=0 to K - 1 do
    begin
      S := OwnerName + '.' + PaxCompilerExplorer1.GetPublishedPropName(Id, I);
      S := '      ' + S + '=' + PaxCompilerDebugger1.GetPublishedPropValueAsString(
        StackFrameNumber, Id, I);
      Memo2.Lines.Add(S);
    end;
  end;

  procedure AddArrayElements(StackFrameNumber, Id: Integer);
  var
    I, K1, K2: Integer;
    OwnerName, S: String;
  begin
    if not PaxCompilerExplorer1.HasArrayType(Id) then
      Exit;

    K1 := PaxCompilerExplorer1.GetArrayLowBound(Id);
    K2 := PaxCompilerExplorer1.GetArrayHighBound(Id);

    OwnerName := PaxCompilerExplorer1.Names[Id];

    for I:=K1 to K2 do
    begin
      S := OwnerName + '[' + IntToStr(I) + ']';
      S := '      ' + S + '=' + PaxCompilerDebugger1.GetArrayItemValueAsString(
        StackFrameNumber, Id, I);
      Memo2.Lines.Add(S);
    end;
  end;

  procedure AddDynArrayElements(StackFrameNumber, Id: Integer);
  var
    I, L: Integer;
    OwnerName, S: String;
  begin
    if not PaxCompilerExplorer1.HasDynArrayType(Id) then
      Exit;

    L := PaxCompilerDebugger1.GetDynArrayLength(StackFrameNumber, Id);

    OwnerName := PaxCompilerExplorer1.Names[Id];

    for I:=0 to L - 1 do
    begin
      S := OwnerName + '[' + IntToStr(I) + ']';
      S := '      ' + S + '=' + PaxCompilerDebugger1.GetDynArrayItemValueAsString(
        StackFrameNumber, Id, I);
      Memo2.Lines.Add(S);
    end;
  end;

var
  SourceLineNumber: Integer;
  ModuleName: String;
  StackFrameNumber, J, K, SubId, Id: Integer;
  S, V: String;
  CallStackLineNumber: Integer;
  CallStackModuleName: String;
begin
 // Memo2.Lines.Clear;
  if PaxCompilerDebugger1.IsPaused then
  begin
    ModuleName := PaxCompilerDebugger1.ModuleName;
    SourceLineNumber := PaxCompilerDebugger1.SourceLineNumber;

    Memo2.Lines.Add('Paused at line ' + IntTosTr(SourceLineNumber));
    Memo2.Lines.Add(PaxCompiler1.Modules[ModuleName][SourceLineNumber]);
    Memo2.Lines.Add('------------------------------------------------------');

    if PaxCompilerDebugger1.CallStackCount > 0 then
    begin
      Memo2.Lines.Add('Call stack:');
      for StackFrameNumber:=0 to PaxCompilerDebugger1.CallStackCount - 1 do
      begin
        SubId := PaxCompilerDebugger1.CallStack[StackFrameNumber];
        S := '(';
        K := PaxCompilerExplorer1.GetParamCount(SubId);
        for J:=0 to K - 1 do
        begin
          Id := PaxCompilerExplorer1.GetParamId(SubId, J);
          V := PaxCompilerDebugger1.GetValueAsString(StackFrameNumber, Id);
          S := S + V;
          if J < K - 1 then
            S := S + ',';
        end;
        S := PaxCompilerExplorer1.Names[SubId] + S + ')';

        CallStackLineNumber := PaxCompilerDebugger1.CallStackLineNumber[StackFrameNumber];
        CallStackModuleName := PaxCompilerDebugger1.CallStackModuleName[StackFrameNumber];

        S := S + '; // ' + PaxCompiler1.Modules[CallStackModuleName][CallStackLineNumber];

        Memo2.Lines.Add(S);
      end;
      Memo2.Lines.Add('------------------------------------------------------');

      Memo2.Lines.Add('Local scope:');
      StackFrameNumber := PaxCompilerDebugger1.CallStackCount - 1;
      SubId := PaxCompilerDebugger1.CallStack[StackFrameNumber];
      K := PaxCompilerExplorer1.GetLocalCount(SubId);
      for J:=0 to K - 1 do
      begin
        Id := PaxCompilerExplorer1.GetLocalId(SubId, J);
        V := PaxCompilerDebugger1.GetValueAsString(StackFrameNumber, Id);
        S := PaxCompilerExplorer1.Names[Id] + '=' + V;
        Memo2.Lines.Add(S);

        if Pos('X', S) > 0 then
        begin
          PaxCompilerDebugger1.PutValue(StackFrameNumber, Id, 258);

          V := PaxCompilerDebugger1.GetValueAsString(StackFrameNumber, Id);
          S := PaxCompilerExplorer1.Names[Id] + '=' + V;
          S := S + ' // modified';
          Memo2.Lines.Add(S);
        end;

        AddFields(StackFrameNumber, Id);
        AddPublishedProps(StackFrameNumber, Id);
        AddArrayElements(StackFrameNumber, Id);
        AddDynArrayElements(StackFrameNumber, Id);
      end;

      Memo2.Lines.Add('------------------------------------------------------');
    end;

    Memo2.Lines.Add('Global scope:');
    K := PaxCompilerExplorer1.GetGlobalCount(0);
    for J:=0 to K - 1 do
    begin
      Id := PaxCompilerExplorer1.GetGlobalId(0, J);
      V := PaxCompilerDebugger1.GetValueAsString(Id);
      S := PaxCompilerExplorer1.Names[Id] + '=' + V;
      Memo2.Lines.Add(S);

      AddFields(0, Id);
      AddPublishedProps(0, Id);
      AddArrayElements(0, Id);
      AddDynArrayElements(0, Id);
    end;
    Memo2.Lines.Add('------------------------------------------------------');

  end
  else
    Memo2.Lines.Add('Finished');

  Memo2.SelStart := 0;
  Memo2.SelLength := 0;
end;

{
procedure Print(I: Integer);
begin
  ShowMessage(IntToStr(I));
end;
}
procedure TAddCaseFrm.PaxProgram1PrintEvent(Sender: TPaxRunner;
  const Text: String);
begin
  AddCaseFrm.memo2.Lines.Add(Text);
end;

procedure TAddCaseFrm.btnBuildClick(Sender: TObject);
var
  I: Integer;
begin
  PaxCompiler1.Reset;
  PaxCompiler1.RegisterLanguage(PaxPascalLanguage1);
  PaxPascalLanguage1.SetCallConv(_ccREGISTER);
  PaxCompiler1.AddModule('1', PaxPascalLanguage1.LanguageName);
  PaxCompiler1.AddCode('1', SynMemo1.Lines.Text);
  PaxCompiler1.DebugMode := true;
  if PaxCompiler1.Compile(PaxProgram1) then
  begin
    Memo2.Lines.Add('Script has been successfully recompiled.');
    PaxCompilerExplorer1.RegisterCompiler(PaxCompiler1);
    PaxCompilerDebugger1.RegisterCompiler(PaxCompiler1, PaxProgram1);
  end
  else
    for I:=0 to PaxCompiler1.ErrorCount - 1 do
      Memo2.Lines.Add(PaxCompiler1.ErrorMessage[I]);
end;

procedure TAddCaseFrm.tbtnRunClick(Sender: TObject);
begin
  if not PaxCompilerDebugger1.Valid then
  begin
    Memo2.Lines.Add('You have to compile script. Press "Compile" button.');
    Exit;
  end;
  PaxCompilerDebugger1.RunMode := _rmRUN;
  if PaxCompilerDebugger1.IsPaused then
    ResumeRequest := true
  else
    PaxCompilerDebugger1.Run;
end;

procedure TAddCaseFrm.tbtnGotoCursorClick(Sender: TObject);
begin
  if not PaxCompilerDebugger1.Valid then
  begin
    Memo2.Lines.Add('You have to compile script. Press "Compile" button.');
    Exit;
  end;

 // Form2.ShowModal;

  PaxCompilerDebugger1.RunMode := _rmRUN_TO_CURSOR;
  if PaxCompilerDebugger1.IsPaused then
    ResumeRequest := true
  else
    PaxCompilerDebugger1.Run;
end;

procedure TAddCaseFrm.tbtnStepClick(Sender: TObject);
begin
  PaxCompilerDebugger1.RunMode := _rmSTEP_OVER;
  if PaxCompilerDebugger1.IsPaused then
    ResumeRequest := true
  else
    PaxCompilerDebugger1.Run;
end;

procedure TAddCaseFrm.btnStepIntoClick(Sender: TObject);
begin
  PaxCompilerDebugger1.RunMode := _rmTRACE_INTO;
  if PaxCompilerDebugger1.IsPaused then
    ResumeRequest := true
  else
    PaxCompilerDebugger1.Run;
end;

procedure TAddCaseFrm.FormCreate(Sender: TObject);
begin
  Memo2.Lines.Clear;
end;




procedure TAddCaseFrm.Button1Click(Sender: TObject);
begin
  // SynMemo1.;
end;



//initialization

//RegisterHeader(0, 'procedure Print(I: Integer);', @Print);

end.
