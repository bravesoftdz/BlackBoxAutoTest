unit testcase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, Grids, DBGrids, Menus, StdCtrls, Buttons,
  SynEdit, SynDBEdit, DBCtrls, Mask, SynEditHighlighter, SynHighlighterPas,
  ActnList, ImgList;

type
  TfrmTestCase1 = class(TForm)
    pnl1: TPanel;
    mm1: TMainMenu;
    N1: TMenuItem;
    stat1: TStatusBar;
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    Panel2: TPanel;
    pnlInfo: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    pnltools: TPanel;
    GroupBox1: TGroupBox;
    dbmContent: TDBSynEdit;
    SynPasSyn1: TSynPasSyn;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    N2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N3: TMenuItem;
    ActionList1: TActionList;
    acAdd: TAction;
    acAddChild: TAction;
    acDelete: TAction;
    acEdit: TAction;
    Label4: TLabel;
    mmosummary: TMemo;
    cbbproject: TComboBox;
    cbbsystem: TComboBox;
    mmoTitle: TMemo;
    pnl2: TPanel;
    btnDebug: TBitBtn;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    PopupMenu2: TPopupMenu;
    N11: TMenuItem;
    N21: TMenuItem;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure btnDebugClick(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTestCase1: TfrmTestCase1;

implementation

uses AddCaseUnit;

procedure TfrmtestCase1.CreateParams(var params: TCreateParams);
//窗体不随主窗体最小化
begin
  inherited CreateParams(Params);
  with Params do
    WndParent := GetDesktopWindow();
end;

{$R *.dfm}

procedure TfrmTestCase1.btnDebugClick(Sender: TObject);
begin
  addcaseFrm.ShowModal;
end;

procedure TfrmTestCase1.N7Click(Sender: TObject);
begin
  close;
end;

end.
