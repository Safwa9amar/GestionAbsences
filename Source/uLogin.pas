unit uLogin;

{ نافذة تسجيل الدخول / Fenetre d'authentification }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TfrmLogin = class(TForm)
    pnlTop      : TPanel;
    lblApp      : TLabel;
    lblSchool   : TLabel;
    pnlBody     : TPanel;
    lblUser     : TLabel;
    lblPass     : TLabel;
    edUser      : TEdit;
    edPass      : TEdit;
    pnlBottom   : TPanel;
    btnLogin    : TButton;
    btnCancel   : TButton;
    lblHint     : TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edPassKeyPress(Sender: TObject; var Key: Char);
  private
    FTries : Integer;
  end;

var
  frmLogin : TfrmLogin;

function DoLogin: Boolean;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

function DoLogin: Boolean;
var
  F : TfrmLogin;
begin
  F := TfrmLogin.Create(nil);
  try
    Result := F.ShowModal = mrOk;
  finally
    F.Free;
  end;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FTries         := 0;
  Caption        := R_LoginTitle;
  lblApp.Caption := R_AppTitle;
  lblUser.Caption  := R_LoginUser;
  lblPass.Caption  := R_LoginPass;
  btnLogin.Caption := R_LoginBtn;
  btnCancel.Caption:= R_Cancel;
  lblHint.Caption  := 'الحساب الافتراضي : admin / admin';

  if Assigned(dm) then
    lblSchool.Caption := dm.GetSetting('SCHOOL_NAME', R_SchoolDefault)
  else
    lblSchool.Caption := R_SchoolDefault;

  ApplyRTL(Self);
  edUser.Text := 'admin';
  ActiveControl := edPass;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  Err : string;
begin
  if Trim(edUser.Text) = '' then
  begin
    ShowError(R_MsgRequired);
    edUser.SetFocus;
    Exit;
  end;

  if dm.Login(edUser.Text, edPass.Text, Err) then
    ModalResult := mrOk
  else
  begin
    Inc(FTries);
    ShowError(Err);
    edPass.Clear;
    edPass.SetFocus;
    if FTries >= 3 then
    begin
      ShowError('تم تجاوز عدد المحاولات المسموح بها. سيتم إغلاق البرنامج.');
      ModalResult := mrCancel;
    end;
  end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmLogin.edPassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btnLoginClick(nil);
  end;
end;

end.
