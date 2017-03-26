(*********************************************************************
    About.pas
     -- About dialog for example program

    History:   Date       Author         Comment
               3/9/98     Casper         Wrote it.

**********************************************************************)

unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAboutFrm = class(TForm)
    AboutLabel: TLabel;
    Label2: TLabel;
    AboutOK: TButton;
    procedure AboutOKClick(Sender: TObject);
    procedure AboutOKEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutFrm: TAboutFrm;

implementation

uses ExGlobal;
{$R *.DFM}

procedure TAboutFrm.AboutOKClick(Sender: TObject);
begin
  Close();
end;


procedure TAboutFrm.AboutOKEnter(Sender: TObject);
begin
  //AboutLabel.Caption := 'PComm ' + GszAppName +' Example11111';
end;

procedure TAboutFrm.FormCreate(Sender: TObject);
begin
Label2.Caption:='20170212';
end;

end.
