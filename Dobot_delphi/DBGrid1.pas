unit DBGrid1;

interface

uses
  SysUtils, Classes, Controls, Grids, DBGrids, DBClient, DB, Types, Graphics;

type
  TDBGrid1 = class(TDBGrid)
  private
    { Private declarations }
    gbChange: Boolean;
    gbTitle: Boolean;
    procedure DBGTitleClick(Column: TColumn);
    procedure DBGColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure DBGCellClick(Column: TColumn);
    procedure DBGDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SAJET', [TDBGrid1]);
end;

constructor TDBGrid1.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  gbChange := True;
  gbTitle := False;
  OnTitleClick := DBGTitleClick;
  OnColumnMoved := DBGColumnMoved;
  OnCellClick := DBGCellClick;
  OnDrawColumnCell := DBGDrawColumnCell;
end;

procedure TDBGrid1.DBGTitleClick(Column: TColumn);
var bAesc: Boolean;
begin
  if gbChange then begin
    gbTitle := True;
    bAesc := True;
    if DataSource = nil then Exit;
    if DataSource.DataSet = nil then Exit;
    if not (DataSource.DataSet is TClientDataSet) then Exit;
    if (DataSource.DataSet as TClientDataSet).Active then
    begin
      if (DataSource.DataSet as TClientDataSet).IndexName <> '' then
      begin
        bAesc := True;
        if (DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then
          bAesc := False;
        (DataSource.DataSet as TClientDataSet).deleteIndex((DataSource.DataSet as TClientDataSet).Indexname);
      end;
      if bAesc then begin
        (DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName, Column.FieldName, [], '', '', 0);
        (DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName;
      end else begin
        (DataSource.DataSet as TClientDataSet).AddIndex(Column.FieldName + 'D', Column.FieldName, [ixDescending], '', '', 0);
        (DataSource.DataSet as TClientDataSet).IndexName := Column.FieldName + 'D';
      end;
      (DataSource.DataSet as TClientDataSet).IndexDefs.Update;
    end;
  end;
  gbChange := True;
end;

procedure TDBGrid1.DBGColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  gbChange := False;
end;

procedure TDBGrid1.DBGCellClick(Column: TColumn);
begin
  gbTitle := False;
end;

procedure TDBGrid1.DBGDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var tmpLeft:Integer;
begin
  if DataSource = nil then Exit;
  if DataSource.DataSet = nil then Exit;
  if not (DataSource.DataSet is TClientDataSet) then Exit;
  if not (DataSource.DataSet as TClientDataSet).Active then Exit;
  if (DataSource.DataSet as TClientDataSet).IndexName = Column.FieldName then // Asc order
//    ImgLst.Draw(DBGrid1.Canvas,Rect.Right - 18,2,1)
  begin
    with Canvas do
    begin
       //tmpLeft:=TextWidth(Column.DisplayName)+Rect.Left+15;
       tmpLeft := Rect.Right-15;
       Pen.Color:=clBtnHighlight;
       MoveTo(tmpLeft,12);//Rect.Bottom-5);
       LineTo(tmpLeft+8,12);//Rect.Bottom-5);
       Pen.Color:=clBtnHighlight;
       LineTo(tmpLeft+4,5); //Rect.Top+5);
       Pen.Color:=clBtnShadow;
       LineTo(tmpLeft,12); //Rect.Bottom-5);
    end;
  end
  else if (DataSource.DataSet as TClientdataSet).IndexName = Column.FieldName + 'D' then // Des order
//    ImgLst.Draw(DBGrid1.Canvas,Rect.Right - 18,2,0);
    with Canvas do
    begin
       //tmpLeft:=TextWidth(Column.DisplayName)+Rect.Left+15;
       tmpLeft := Rect.Right-15;
       Pen.Color:=clBtnShadow;
       MoveTo(tmpLeft,5);//Rect.Top+5);
       LineTo(tmpLeft+8,5);//Rect.Top+5);
       Pen.Color:=clBtnHighlight;
       LineTo(tmpLeft+4,12);//Rect.Bottom-5);
       Pen.Color:=clBtnShadow;
       LineTo(tmpLeft,5);//Rect.Top+5);
    end;
end;

end.
