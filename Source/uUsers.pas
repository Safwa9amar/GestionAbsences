unit uUsers;

{ تسيير المستخدمين / Gestion des utilisateurs }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, DB;

type
  TfrmUsers = class(TForm)
    grd        : TDBGrid;
    pnlEdit    : TPanel;
    lblLogin   : TLabel;  edLogin   : TEdit;
    lblFull    : TLabel;  edFull    : TEdit;
    lblRole    : TLabel;  cbRole    : TComboBox;
    lblPass    : TLabel;  edPass    : TEdit;
    lblPass2   : TLabel;  edPass2   : TEdit;
    chkActive  : TCheckBox;
    lblHint    : TLabel;
    btnNew     : TButton;
    btnSave    : TButton;
    btnDelete  : TButton;
    btnClose   : TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure grdCellClick(Column: TColumn);
  private
    FUserID : Integer;
    procedure ApplyCaptions;
    procedure SetupGrid;
    procedure ClearFields;
    procedure LoadFields;
    function  RoleCode(AIndex: Integer): string;
    function  RoleIndex(const ACode: string): Integer;
    function  CountActiveAdmins(AExcludeID: Integer): Integer;
  end;

procedure ShowUsersForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

const
  ROLES : array[0..2] of string = ('ADMIN', 'ADVISOR', 'SUPERV');

procedure ShowUsersForm;
var
  F : TfrmUsers;
begin
  F := TfrmUsers.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

function TfrmUsers.RoleCode(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex <= High(ROLES)) then
    Result := ROLES[AIndex]
  else
    Result := 'SUPERV';
end;

function TfrmUsers.RoleIndex(const ACode: string): Integer;
var
  I : Integer;
begin
  Result := 2;
  for I := Low(ROLES) to High(ROLES) do
    if SameText(ROLES[I], ACode) then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TfrmUsers.ApplyCaptions;
begin
  Caption           := R_UsrTitle;
  lblLogin.Caption  := R_UsrLogin;
  lblFull.Caption   := R_UsrFullName;
  lblRole.Caption   := R_UsrRole;
  lblPass.Caption   := R_UsrNewPass;
  lblPass2.Caption  := R_UsrConfirmPass;
  chkActive.Caption := R_UsrActive;
  lblHint.Caption   := 'اترك خانتي كلمة المرور فارغتين للإبقاء على الكلمة الحالية.';
  btnNew.Caption    := R_New;
  btnSave.Caption   := R_Save;
  btnDelete.Caption := R_Delete;
  btnClose.Caption  := R_Close;

  cbRole.Items.Clear;
  cbRole.Items.Add(R_UsrRoleAdmin);
  cbRole.Items.Add(R_UsrRoleAdvisor);
  cbRole.Items.Add(R_UsrRoleSuperv);
  cbRole.ItemIndex := 2;
end;

procedure TfrmUsers.FormCreate(Sender: TObject);
begin
  FUserID := 0;
  ApplyCaptions;
  SetupGrid;
  dm.RefreshUsers;
  ClearFields;
  ApplyRTL(Self);
end;

procedure TfrmUsers.SetupGrid;

  procedure AddCol(const AField, ATitle: string; AWidth: Integer);
  var
    C : TColumn;
  begin
    C := grd.Columns.Add;
    C.FieldName       := AField;
    C.Title.Caption   := ATitle;
    C.Width           := AWidth;
    C.Title.Alignment := taCenter;
  end;

begin
  grd.Columns.Clear;
  AddCol('UserLogin', R_UsrLogin,    160);
  AddCol('FullName',  R_UsrFullName, 240);
  AddCol('UserRole',  R_UsrRole,     140);
  AddCol('IsActive',  R_UsrActive,    90);
  AddCol('CreatedAt', 'تاريخ الإنشاء',130);
end;

procedure TfrmUsers.ClearFields;
begin
  FUserID := 0;
  edLogin.Clear;
  edFull.Clear;
  edPass.Clear;
  edPass2.Clear;
  cbRole.ItemIndex  := 2;
  chkActive.Checked := True;
end;

procedure TfrmUsers.LoadFields;
begin
  if dm.qUsers.IsEmpty then
  begin
    ClearFields;
    Exit;
  end;
  FUserID           := dm.qUsers.FieldByName('UserID').AsInteger;
  edLogin.Text      := dm.qUsers.FieldByName('UserLogin').AsString;
  edFull.Text       := dm.qUsers.FieldByName('FullName').AsString;
  cbRole.ItemIndex  := RoleIndex(dm.qUsers.FieldByName('UserRole').AsString);
  chkActive.Checked := dm.qUsers.FieldByName('IsActive').AsBoolean;
  edPass.Clear;
  edPass2.Clear;
end;

procedure TfrmUsers.grdCellClick(Column: TColumn);
begin
  LoadFields;
end;

procedure TfrmUsers.btnNewClick(Sender: TObject);
begin
  ClearFields;
  edLogin.SetFocus;
end;

function TfrmUsers.CountActiveAdmins(AExcludeID: Integer): Integer;
begin
  Result := dm.ScalarInt(
    'SELECT COUNT(*) FROM AppUsers WHERE UserRole = ' + SqlStr('ADMIN') +
    ' AND IsActive = True AND UserID <> ' + IntToStr(AExcludeID), 0);
end;

procedure TfrmUsers.btnSaveClick(Sender: TObject);
var
  Login : string;
begin
  Login := Trim(edLogin.Text);
  if Login = '' then
  begin
    ShowError(R_MsgRequired);
    edLogin.SetFocus;
    Exit;
  end;

  if edPass.Text <> edPass2.Text then
  begin
    ShowError(R_UsrPassMismatch);
    edPass.SetFocus;
    Exit;
  end;

  if (FUserID = 0) and (edPass.Text = '') then
  begin
    ShowError('يجب تحديد كلمة مرور للمستخدم الجديد.');
    edPass.SetFocus;
    Exit;
  end;

  { لا يسمح بترك النظام دون مسؤول نشط }
  if (FUserID > 0) and
     ((not SameText(RoleCode(cbRole.ItemIndex), 'ADMIN')) or (not chkActive.Checked)) and
     (CountActiveAdmins(FUserID) = 0) then
  begin
    ShowError(R_UsrLastAdmin);
    Exit;
  end;

  { التحقق من عدم تكرار اسم المستخدم }
  if dm.ScalarInt('SELECT COUNT(*) FROM AppUsers WHERE UserLogin = ' +
       SqlStr(Login) + ' AND UserID <> ' + IntToStr(FUserID), 0) > 0 then
  begin
    ShowError('اسم المستخدم مستعمل من قبل.');
    edLogin.SetFocus;
    Exit;
  end;

  try
    if FUserID = 0 then
      dm.ExecSQL('INSERT INTO AppUsers (UserLogin, PassHash, FullName, UserRole,' +
        ' IsActive, CreatedAt) VALUES (' + SqlStr(Login) + ', ' +
        SqlStr(SHA1Hash(edPass.Text)) + ', ' + SqlStr(Trim(edFull.Text)) + ', ' +
        SqlStr(RoleCode(cbRole.ItemIndex)) + ', ' +
        BoolSql(chkActive.Checked) + ', ' + SqlDate(Date) + ')')
    else
    begin
      dm.ExecSQL('UPDATE AppUsers SET UserLogin = ' + SqlStr(Login) +
        ', FullName = ' + SqlStr(Trim(edFull.Text)) +
        ', UserRole = ' + SqlStr(RoleCode(cbRole.ItemIndex)) +
        ', IsActive = ' + BoolSql(chkActive.Checked) +
        ' WHERE UserID = ' + IntToStr(FUserID));
      if edPass.Text <> '' then
        dm.ExecSQL('UPDATE AppUsers SET PassHash = ' +
          SqlStr(SHA1Hash(edPass.Text)) +
          ' WHERE UserID = ' + IntToStr(FUserID));
    end;

    dm.RefreshUsers;
    ClearFields;
    ShowInfo(R_MsgSaved);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmUsers.btnDeleteClick(Sender: TObject);
var
  Id : Integer;
begin
  if dm.qUsers.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  Id := dm.qUsers.FieldByName('UserID').AsInteger;

  if Id = dm.CurrentUserID then
  begin
    ShowError('لا يمكنك حذف حسابك الخاص أثناء استعماله.');
    Exit;
  end;

  if SameText(dm.qUsers.FieldByName('UserRole').AsString, 'ADMIN') and
     (CountActiveAdmins(Id) = 0) then
  begin
    ShowError(R_UsrLastAdmin);
    Exit;
  end;

  if not AskYesNo(R_MsgConfirmDel) then Exit;

  dm.ExecSQL('DELETE FROM AppUsers WHERE UserID = ' + IntToStr(Id));
  dm.RefreshUsers;
  ClearFields;
  ShowInfo(R_MsgDeleted);
end;

procedure TfrmUsers.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
