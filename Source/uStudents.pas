unit uStudents;

{ تسيير ملفات التلاميذ / Gestion des dossiers eleves }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, DB, Mask, Buttons;

type
  TEditMode = (emNone, emNew, emEdit);

  TfrmStudents = class(TForm)
    pc            : TPageControl;
    tabList       : TTabSheet;
    tabFile       : TTabSheet;
    tabAbs        : TTabSheet;
    { --- قائمة التلاميذ --- }
    pnlFilter     : TPanel;
    lblFClass     : TLabel;
    cbFClass      : TComboBox;
    lblFSearch    : TLabel;
    edFSearch     : TEdit;
    chkFActive    : TCheckBox;
    btnFApply     : TButton;
    lblCount      : TLabel;
    grdStudents   : TDBGrid;
    pnlListBtn    : TPanel;
    btnNew        : TButton;
    btnEdit       : TButton;
    btnDelete     : TButton;
    btnPrintList  : TButton;
    btnCloseList  : TButton;
    { --- استمارة التلميذ --- }
    scr           : TScrollBox;
    lblMatricule  : TLabel;   edMatricule  : TEdit;
    lblRegNo      : TLabel;   edRegNo      : TEdit;
    lblLastName   : TLabel;   edLastName   : TEdit;
    lblFirstName  : TLabel;   edFirstName  : TEdit;
    lblGender     : TLabel;   cbGender     : TComboBox;
    lblBirth      : TLabel;   dtBirth      : TDateTimePicker;
    lblBirthPlace : TLabel;   edBirthPlace : TEdit;
    lblClass      : TLabel;   cbClass      : TComboBox;
    lblRegime     : TLabel;   cbRegime     : TComboBox;
    lblEnroll     : TLabel;   dtEnroll     : TDateTimePicker;
    lblFather     : TLabel;   edFather     : TEdit;
    lblMother     : TLabel;   edMother     : TEdit;
    lblSocial     : TLabel;   cbSocial     : TComboBox;
    lblSiblings   : TLabel;   edSiblings   : TEdit;
    lblSibSch     : TLabel;   edSibSch     : TEdit;
    lblGuardian   : TLabel;   edGuardian   : TEdit;
    lblGPhone     : TLabel;   edGPhone     : TEdit;
    lblGEmail     : TLabel;   edGEmail     : TEdit;
    lblGAddr      : TLabel;   edGAddr      : TEdit;
    chkActive     : TCheckBox;
    lblNotes      : TLabel;   mmNotes      : TMemo;
    pnlFileBtn    : TPanel;
    btnSave       : TButton;
    btnCancel     : TButton;
    btnPrintFile  : TButton;
    { --- غيابات التلميذ --- }
    pnlAbsTop     : TPanel;
    lblAbsStudent : TLabel;
    lblAbsSummary : TLabel;
    btnAbsRefresh : TButton;
    grdAbs        : TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFApplyClick(Sender: TObject);
    procedure edFSearchChange(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseListClick(Sender: TObject);
    procedure btnPrintListClick(Sender: TObject);
    procedure btnPrintFileClick(Sender: TObject);
    procedure btnAbsRefreshClick(Sender: TObject);
    procedure pcChange(Sender: TObject);
    procedure grdStudentsDblClick(Sender: TObject);
  private
    FMode       : TEditMode;
    FStudentID  : Integer;
    FClassKeys  : TStringList;
    FFClassKeys : TStringList;
    procedure ApplyCaptions;
    procedure LoadClassCombos;
    procedure SetupGrid;
    procedure LoadList;
    procedure ClearFields;
    procedure LoadFields(AStudentID: Integer);
    function  ValidateFields: Boolean;
    function  SelectedClassID: Integer;
    procedure SetMode(AMode: TEditMode);
    procedure LoadStudentAbsences;
  end;

procedure ShowStudentsForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

procedure ShowStudentsForm;
var
  F : TfrmStudents;
begin
  F := TfrmStudents.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmStudents.ApplyCaptions;
begin
  Caption          := R_StuTitle;
  tabList.Caption  := R_StuListTab;
  tabFile.Caption  := R_StuFileTab;
  tabAbs.Caption   := R_StuAbsTab;

  lblFClass.Caption  := R_StuClass;
  lblFSearch.Caption := R_Search;
  edFSearch.Hint     := R_StuSearchHint;
  chkFActive.Caption := R_StuActive;
  btnFApply.Caption  := R_Refresh;

  btnNew.Caption       := R_New;
  btnEdit.Caption      := R_Edit;
  btnDelete.Caption    := R_Delete;
  btnPrintList.Caption := R_Print;
  btnCloseList.Caption := R_Close;

  lblMatricule.Caption  := R_StuMatricule;
  lblRegNo.Caption      := R_StuRegNo;
  lblLastName.Caption   := R_StuLastName;
  lblFirstName.Caption  := R_StuFirstName;
  lblGender.Caption     := R_StuGender;
  lblBirth.Caption      := R_StuBirthDate;
  lblBirthPlace.Caption := R_StuBirthPlace;
  lblClass.Caption      := R_StuClass;
  lblRegime.Caption     := R_StuRegime;
  lblEnroll.Caption     := R_StuEnrollDate;
  lblFather.Caption     := R_StuFather;
  lblMother.Caption     := R_StuMother;
  lblSocial.Caption     := R_StuSocial;
  lblSiblings.Caption   := R_StuSiblings;
  lblSibSch.Caption     := R_StuSibSchooled;
  lblGuardian.Caption   := R_StuGuardian;
  lblGPhone.Caption     := R_StuGuardPhone;
  lblGEmail.Caption     := R_StuGuardEmail;
  lblGAddr.Caption      := R_StuGuardAddr;
  chkActive.Caption     := R_StuActive;
  lblNotes.Caption      := R_StuNotes;

  btnSave.Caption      := R_Save;
  btnCancel.Caption    := R_Cancel;
  btnPrintFile.Caption := R_Print;
  btnAbsRefresh.Caption:= R_Refresh;

  cbGender.Items.Clear;
  cbGender.Items.Add(R_StuMale);
  cbGender.Items.Add(R_StuFemale);

  cbRegime.Items.Clear;
  cbRegime.Items.Add(R_StuExtern);
  cbRegime.Items.Add(R_StuSemiIntern);
  cbRegime.Items.Add(R_StuIntern);

  cbSocial.Items.Clear;
  cbSocial.Items.Add(R_StuSocNormal);
  cbSocial.Items.Add(R_StuSocOrphan);
  cbSocial.Items.Add(R_StuSocDivorced);
  cbSocial.Items.Add(R_StuSocNeedy);
end;

procedure TfrmStudents.FormCreate(Sender: TObject);
begin
  FClassKeys  := TStringList.Create;
  FFClassKeys := TStringList.Create;
  FMode       := emNone;
  FStudentID  := 0;

  ApplyCaptions;
  LoadClassCombos;
  SetupGrid;
  LoadList;
  SetMode(emNone);
  ApplyRTL(Self);
  pc.ActivePage := tabList;
end;

procedure TfrmStudents.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FClassKeys.Free;
  FFClassKeys.Free;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmStudents.LoadClassCombos;
begin
  dm.RefreshClasses;
  FillCombo(cbClass.Items,  dm.qClasses, 'ClassName', 'ClassID', FClassKeys,  R_None);
  FillCombo(cbFClass.Items, dm.qClasses, 'ClassName', 'ClassID', FFClassKeys, R_All);
  cbClass.ItemIndex  := 0;
  cbFClass.ItemIndex := 0;
end;

procedure TfrmStudents.SetupGrid;

  procedure AddCol(const AField, ATitle: string; AWidth: Integer);
  var
    C : TColumn;
  begin
    C := grdStudents.Columns.Add;
    C.FieldName    := AField;
    C.Title.Caption:= ATitle;
    C.Width        := AWidth;
    C.Title.Alignment := taCenter;
  end;

begin
  grdStudents.Columns.Clear;
  AddCol('MatriculeNat', R_StuMatricule, 120);
  AddCol('LastName',     R_StuLastName,  130);
  AddCol('FirstName',    R_StuFirstName, 130);
  AddCol('Gender',       R_StuGender,     60);
  AddCol('BirthDate',    R_StuBirthDate,  95);
  AddCol('ClassName',    R_StuClass,      80);
  AddCol('RegimeStatus', R_StuRegime,     90);
  AddCol('GuardianPhone',R_StuGuardPhone,100);

  grdAbs.Columns.Clear;
end;

procedure TfrmStudents.LoadList;
begin
  dm.RefreshStudents(SelectedClassID, edFSearch.Text, chkFActive.Checked);
  lblCount.Caption := R_StuCount + IntToStr(dm.qStudents.RecordCount);
end;

function TfrmStudents.SelectedClassID: Integer;
begin
  Result := 0;
  if (cbFClass.ItemIndex >= 0) and (cbFClass.ItemIndex < FFClassKeys.Count) then
    Result := StrToIntDef(FFClassKeys[cbFClass.ItemIndex], 0);
end;

procedure TfrmStudents.btnFApplyClick(Sender: TObject);
begin
  LoadList;
end;

procedure TfrmStudents.edFSearchChange(Sender: TObject);
begin
  LoadList;
end;

{ ------------------------------------------------------------------------
  إدارة وضع التحرير
  ------------------------------------------------------------------------ }
procedure TfrmStudents.SetMode(AMode: TEditMode);
var
  CanEdit : Boolean;
begin
  FMode   := AMode;
  CanEdit := AMode <> emNone;

  scr.Enabled          := CanEdit;
  btnSave.Enabled      := CanEdit;
  btnCancel.Enabled    := CanEdit;
  btnPrintFile.Enabled := (AMode = emNone) and (FStudentID > 0);

  btnNew.Enabled    := not CanEdit;
  btnEdit.Enabled   := not CanEdit;
  btnDelete.Enabled := not CanEdit;
  tabList.Enabled   := not CanEdit;
end;

procedure TfrmStudents.ClearFields;
begin
  edMatricule.Clear;  edRegNo.Clear;
  edLastName.Clear;   edFirstName.Clear;
  cbGender.ItemIndex := 0;
  dtBirth.Date  := EncodeDate(2010, 1, 1);
  edBirthPlace.Clear;
  cbClass.ItemIndex  := 0;
  cbRegime.ItemIndex := 0;
  dtEnroll.Date := Date;
  edFather.Clear;     edMother.Clear;
  cbSocial.ItemIndex := 0;
  edSiblings.Text := '0';
  edSibSch.Text   := '0';
  edGuardian.Clear;   edGPhone.Clear;
  edGEmail.Clear;     edGAddr.Clear;
  chkActive.Checked := True;
  mmNotes.Clear;
end;

procedure TfrmStudents.LoadFields(AStudentID: Integer);
var
  Q : TDataSet;
  I : Integer;
begin
  ClearFields;
  FStudentID := AStudentID;
  if AStudentID <= 0 then Exit;

  Q := dm.OpenQ(dm.qWork, 'SELECT * FROM Students WHERE StudentID = ' +
                IntToStr(AStudentID));
  if Q.IsEmpty then Exit;

  edMatricule.Text  := Q.FieldByName('MatriculeNat').AsString;
  edRegNo.Text      := Q.FieldByName('RegNumber').AsString;
  edLastName.Text   := Q.FieldByName('LastName').AsString;
  edFirstName.Text  := Q.FieldByName('FirstName').AsString;

  cbGender.ItemIndex := cbGender.Items.IndexOf(Q.FieldByName('Gender').AsString);
  if cbGender.ItemIndex < 0 then cbGender.ItemIndex := 0;

  if not Q.FieldByName('BirthDate').IsNull then
    dtBirth.Date := Q.FieldByName('BirthDate').AsDateTime;
  edBirthPlace.Text := Q.FieldByName('BirthPlace').AsString;

  I := FClassKeys.IndexOf(Q.FieldByName('ClassID').AsString);
  if I >= 0 then cbClass.ItemIndex := I else cbClass.ItemIndex := 0;

  cbRegime.ItemIndex := cbRegime.Items.IndexOf(Q.FieldByName('RegimeStatus').AsString);
  if cbRegime.ItemIndex < 0 then cbRegime.ItemIndex := 0;

  if not Q.FieldByName('EnrollDate').IsNull then
    dtEnroll.Date := Q.FieldByName('EnrollDate').AsDateTime;

  edFather.Text := Q.FieldByName('FatherName').AsString;
  edMother.Text := Q.FieldByName('MotherName').AsString;

  cbSocial.ItemIndex := cbSocial.Items.IndexOf(Q.FieldByName('SocialStatus').AsString);
  if cbSocial.ItemIndex < 0 then cbSocial.ItemIndex := 0;

  edSiblings.Text := Q.FieldByName('SiblingsCount').AsString;
  edSibSch.Text   := Q.FieldByName('SiblingsSchooled').AsString;
  edGuardian.Text := Q.FieldByName('GuardianName').AsString;
  edGPhone.Text   := Q.FieldByName('GuardianPhone').AsString;
  edGEmail.Text   := Q.FieldByName('GuardianEmail').AsString;
  edGAddr.Text    := Q.FieldByName('GuardianAddr').AsString;
  chkActive.Checked := Q.FieldByName('IsActive').AsBoolean;
  mmNotes.Text    := Q.FieldByName('Notes').AsString;

  dm.qWork.Close;
end;

function TfrmStudents.ValidateFields: Boolean;
begin
  Result := False;
  if Trim(edLastName.Text) = '' then
  begin
    ShowError(R_MsgRequired);
    pc.ActivePage := tabFile;
    edLastName.SetFocus;
    Exit;
  end;
  if Trim(edFirstName.Text) = '' then
  begin
    ShowError(R_MsgRequired);
    pc.ActivePage := tabFile;
    edFirstName.SetFocus;
    Exit;
  end;
  Result := True;
end;

{ ------------------------------------------------------------------------
  العمليات
  ------------------------------------------------------------------------ }
procedure TfrmStudents.btnNewClick(Sender: TObject);
begin
  ClearFields;
  FStudentID := 0;
  SetMode(emNew);
  pc.ActivePage := tabFile;
  edMatricule.SetFocus;
end;

procedure TfrmStudents.btnEditClick(Sender: TObject);
begin
  if dm.qStudents.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  LoadFields(dm.qStudents.FieldByName('StudentID').AsInteger);
  SetMode(emEdit);
  pc.ActivePage := tabFile;
  edLastName.SetFocus;
end;

procedure TfrmStudents.grdStudentsDblClick(Sender: TObject);
begin
  btnEditClick(nil);
end;

procedure TfrmStudents.btnDeleteClick(Sender: TObject);
var
  Id, NbAbs : Integer;
begin
  if dm.qStudents.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  Id := dm.qStudents.FieldByName('StudentID').AsInteger;

  NbAbs := dm.ScalarInt('SELECT COUNT(*) FROM Absences WHERE StudentID = ' +
                        IntToStr(Id), 0);
  if NbAbs > 0 then
  begin
    if not AskYesNo('هذا التلميذ مسجل عليه ' + IntToStr(NbAbs) +
                    ' غياب / تأخر.' + #13#10 +
                    'سيتم حذف كل هذه السجلات كذلك. هل تريد المتابعة ؟') then
      Exit;
  end
  else
    if not AskYesNo(R_MsgConfirmDel) then Exit;

  try
    dm.ExecSQL('DELETE FROM Absences     WHERE StudentID = ' + IntToStr(Id));
    dm.ExecSQL('DELETE FROM Notices      WHERE StudentID = ' + IntToStr(Id));
    dm.ExecSQL('DELETE FROM EntryPermits WHERE StudentID = ' + IntToStr(Id));
    dm.ExecSQL('DELETE FROM Certificates WHERE StudentID = ' + IntToStr(Id));
    dm.ExecSQL('DELETE FROM Students     WHERE StudentID = ' + IntToStr(Id));
    LoadList;
    ShowInfo(R_MsgDeleted);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmStudents.btnSaveClick(Sender: TObject);
var
  Sql, ClassVal : string;
  Cid : Integer;
begin
  if not ValidateFields then Exit;

  Cid := 0;
  if (cbClass.ItemIndex >= 0) and (cbClass.ItemIndex < FClassKeys.Count) then
    Cid := StrToIntDef(FClassKeys[cbClass.ItemIndex], 0);
  if Cid = 0 then
    ClassVal := 'NULL'
  else
    ClassVal := IntToStr(Cid);

  try
    if FMode = emNew then
    begin
      Sql :=
        'INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName,' +
        ' Gender, BirthDate, BirthPlace, ClassID, RegimeStatus, FatherName,' +
        ' MotherName, SocialStatus, SiblingsCount, SiblingsSchooled,' +
        ' GuardianName, GuardianPhone, GuardianEmail, GuardianAddr,' +
        ' EnrollDate, IsActive, Notes) VALUES (' +
        SqlStr(Trim(edMatricule.Text)) + ', ' +
        SqlStr(Trim(edRegNo.Text))     + ', ' +
        SqlStr(Trim(edLastName.Text))  + ', ' +
        SqlStr(Trim(edFirstName.Text)) + ', ' +
        SqlStr(cbGender.Text)          + ', ' +
        SqlDate(dtBirth.Date)          + ', ' +
        SqlStr(Trim(edBirthPlace.Text))+ ', ' +
        ClassVal                       + ', ' +
        SqlStr(cbRegime.Text)          + ', ' +
        SqlStr(Trim(edFather.Text))    + ', ' +
        SqlStr(Trim(edMother.Text))    + ', ' +
        SqlStr(cbSocial.Text)          + ', ' +
        IntToStr(StrToIntDef(edSiblings.Text, 0)) + ', ' +
        IntToStr(StrToIntDef(edSibSch.Text, 0))   + ', ' +
        SqlStr(Trim(edGuardian.Text))  + ', ' +
        SqlStr(Trim(edGPhone.Text))    + ', ' +
        SqlStr(Trim(edGEmail.Text))    + ', ' +
        SqlStr(Trim(edGAddr.Text))     + ', ' +
        SqlDate(dtEnroll.Date)         + ', ' +
        BoolSql(chkActive.Checked)     + ', ' +
        SqlStr(mmNotes.Text) + ')';
      dm.ExecSQL(Sql);
      FStudentID := dm.ScalarInt('SELECT @@IDENTITY', 0);
    end
    else
    begin
      Sql :=
        'UPDATE Students SET' +
        ' MatriculeNat = '    + SqlStr(Trim(edMatricule.Text)) +
        ', RegNumber = '      + SqlStr(Trim(edRegNo.Text)) +
        ', LastName = '       + SqlStr(Trim(edLastName.Text)) +
        ', FirstName = '      + SqlStr(Trim(edFirstName.Text)) +
        ', Gender = '         + SqlStr(cbGender.Text) +
        ', BirthDate = '      + SqlDate(dtBirth.Date) +
        ', BirthPlace = '     + SqlStr(Trim(edBirthPlace.Text)) +
        ', ClassID = '        + ClassVal +
        ', RegimeStatus = '   + SqlStr(cbRegime.Text) +
        ', FatherName = '     + SqlStr(Trim(edFather.Text)) +
        ', MotherName = '     + SqlStr(Trim(edMother.Text)) +
        ', SocialStatus = '   + SqlStr(cbSocial.Text) +
        ', SiblingsCount = '  + IntToStr(StrToIntDef(edSiblings.Text, 0)) +
        ', SiblingsSchooled = '+ IntToStr(StrToIntDef(edSibSch.Text, 0)) +
        ', GuardianName = '   + SqlStr(Trim(edGuardian.Text)) +
        ', GuardianPhone = '  + SqlStr(Trim(edGPhone.Text)) +
        ', GuardianEmail = '  + SqlStr(Trim(edGEmail.Text)) +
        ', GuardianAddr = '   + SqlStr(Trim(edGAddr.Text)) +
        ', EnrollDate = '     + SqlDate(dtEnroll.Date) +
        ', IsActive = '       + BoolSql(chkActive.Checked) +
        ', Notes = '          + SqlStr(mmNotes.Text) +
        ' WHERE StudentID = ' + IntToStr(FStudentID);
      dm.ExecSQL(Sql);
    end;

    SetMode(emNone);
    LoadList;
    dm.qStudents.Locate('StudentID', FStudentID, []);
    pc.ActivePage := tabList;
    ShowInfo(R_MsgSaved);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmStudents.btnCancelClick(Sender: TObject);
begin
  SetMode(emNone);
  pc.ActivePage := tabList;
end;

procedure TfrmStudents.btnCloseListClick(Sender: TObject);
begin
  Close;
end;

{ ------------------------------------------------------------------------
  التقارير
  ------------------------------------------------------------------------ }
procedure TfrmStudents.btnPrintListClick(Sender: TObject);
var
  Rep : TReportBuilder;
  N   : Integer;
  Bm  : TBookmark;
begin
  if dm.qStudents.IsEmpty then
  begin
    ShowInfo(R_RepNoData);
    Exit;
  end;

  Rep := TReportBuilder.Create('قائمة التلاميذ');
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               'السنة الدراسية : ' + dm.CurrentYearLabel + '   -   ' +
               'القسم : ' + cbFClass.Text);
    Rep.OpenTable(['الرقم', R_StuMatricule, R_StuLastName, R_StuFirstName,
                   R_StuGender, R_StuBirthDate, R_StuBirthPlace, R_StuClass,
                   R_StuRegime, R_StuGuardPhone]);
    N  := 0;
    Bm := dm.qStudents.GetBookmark;
    dm.qStudents.DisableControls;
    try
      dm.qStudents.First;
      while not dm.qStudents.Eof do
      begin
        Inc(N);
        Rep.Row([IntToStr(N),
          dm.qStudents.FieldByName('MatriculeNat').AsString,
          dm.qStudents.FieldByName('LastName').AsString,
          dm.qStudents.FieldByName('FirstName').AsString,
          dm.qStudents.FieldByName('Gender').AsString,
          FormatDateTime('dd/mm/yyyy', dm.qStudents.FieldByName('BirthDate').AsDateTime),
          dm.qStudents.FieldByName('BirthPlace').AsString,
          dm.qStudents.FieldByName('ClassName').AsString,
          dm.qStudents.FieldByName('RegimeStatus').AsString,
          dm.qStudents.FieldByName('GuardianPhone').AsString]);
        dm.qStudents.Next;
      end;
      if Bm <> nil then
      begin
        dm.qStudents.GotoBookmark(Bm);
        dm.qStudents.FreeBookmark(Bm);
      end;
    finally
      dm.qStudents.EnableControls;
    end;
    Rep.CloseTable;
    Rep.Paragraph('المجموع : <b>' + IntToStr(N) + '</b> تلميذ.');
    Rep.Signature('', 'مستشار التربية : ' + dm.GetSetting('ADVISOR', ''));
    Rep.SaveAndOpen('Liste_Eleves.html');
  finally
    Rep.Free;
  end;
end;

procedure TfrmStudents.btnPrintFileClick(Sender: TObject);
var
  Rep : TReportBuilder;
  Id  : Integer;
begin
  if dm.qStudents.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  Id := dm.qStudents.FieldByName('StudentID').AsInteger;
  LoadFields(Id);

  Rep := TReportBuilder.Create('استمارة معلومات التلميذ');
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               'السنة الدراسية : ' + dm.CurrentYearLabel);
    Rep.OpenTable(['البيان', 'القيمة']);
    Rep.Row([R_StuMatricule,  edMatricule.Text]);
    Rep.Row([R_StuRegNo,      edRegNo.Text]);
    Rep.Row([R_StuLastName,   edLastName.Text]);
    Rep.Row([R_StuFirstName,  edFirstName.Text]);
    Rep.Row([R_StuGender,     cbGender.Text]);
    Rep.Row([R_StuBirthDate,  FormatDateTime('dd/mm/yyyy', dtBirth.Date)]);
    Rep.Row([R_StuBirthPlace, edBirthPlace.Text]);
    Rep.Row([R_StuClass,      cbClass.Text]);
    Rep.Row([R_StuRegime,     cbRegime.Text]);
    Rep.Row([R_StuFather,     edFather.Text]);
    Rep.Row([R_StuMother,     edMother.Text]);
    Rep.Row([R_StuSocial,     cbSocial.Text]);
    Rep.Row([R_StuSiblings,   edSiblings.Text]);
    Rep.Row([R_StuSibSchooled,edSibSch.Text]);
    Rep.Row([R_StuGuardian,   edGuardian.Text]);
    Rep.Row([R_StuGuardPhone, edGPhone.Text]);
    Rep.Row([R_StuGuardEmail, edGEmail.Text]);
    Rep.Row([R_StuGuardAddr,  edGAddr.Text]);
    Rep.Row([R_StuEnrollDate, FormatDateTime('dd/mm/yyyy', dtEnroll.Date)]);
    Rep.CloseTable;
    Rep.Signature('', 'مستشار التربية : ' + dm.GetSetting('ADVISOR', ''));
    Rep.SaveAndOpen('Fiche_Eleve.html');
  finally
    Rep.Free;
  end;
end;

{ ------------------------------------------------------------------------
  غيابات التلميذ
  ------------------------------------------------------------------------ }
procedure TfrmStudents.pcChange(Sender: TObject);
begin
  if pc.ActivePage = tabAbs then
    LoadStudentAbsences;
end;

procedure TfrmStudents.btnAbsRefreshClick(Sender: TObject);
begin
  LoadStudentAbsences;
end;

procedure TfrmStudents.LoadStudentAbsences;
var
  Id, NbAbs, NbLate, NbUnj : Integer;

  procedure AddCol(const AField, ATitle: string; AWidth: Integer);
  var
    C : TColumn;
  begin
    C := grdAbs.Columns.Add;
    C.FieldName     := AField;
    C.Title.Caption := ATitle;
    C.Width         := AWidth;
    C.Title.Alignment := taCenter;
  end;

begin
  if dm.qStudents.IsEmpty then
  begin
    lblAbsStudent.Caption := R_MsgNoRecord;
    lblAbsSummary.Caption := '';
    Exit;
  end;

  Id := dm.qStudents.FieldByName('StudentID').AsInteger;
  lblAbsStudent.Caption :=
    dm.qStudents.FieldByName('LastName').AsString + ' ' +
    dm.qStudents.FieldByName('FirstName').AsString + '   -   ' +
    R_StuClass + ' : ' + dm.qStudents.FieldByName('ClassName').AsString;

  dm.OpenQ(dm.qAbsences,
    'SELECT a.AbsenceID, a.AbsDate, t.SlotLabel, s.SubjectName, a.AbsKind,' +
    ' a.LateMinutes, a.Justified, a.JustifyReason' +
    ' FROM ((Absences a LEFT JOIN TimeSlots t ON a.SlotID = t.SlotID)' +
    ' LEFT JOIN Subjects s ON a.SubjectID = s.SubjectID)' +
    ' WHERE a.StudentID = ' + IntToStr(Id) +
    ' ORDER BY a.AbsDate DESC, t.SortOrder');

  if grdAbs.Columns.Count = 0 then
  begin
    AddCol('AbsDate',      R_AbsDate,     100);
    AddCol('SlotLabel',    R_AbsSlot,     120);
    AddCol('SubjectName',  R_AbsSubject,  150);
    AddCol('AbsKind',      R_AbsState,     80);
    AddCol('LateMinutes',  R_AbsMinutes,   90);
    AddCol('Justified',    R_AbsJustified, 70);
    AddCol('JustifyReason',R_AbsReason,   220);
  end;

  NbAbs  := dm.CountAbsences(Id, EncodeDate(2000,1,1), EncodeDate(2100,1,1), 'ABS');
  NbLate := dm.CountAbsences(Id, EncodeDate(2000,1,1), EncodeDate(2100,1,1), 'LATE');
  NbUnj  := dm.CountUnjustified(Id, EncodeDate(2000,1,1), EncodeDate(2100,1,1));

  lblAbsSummary.Caption := Format(
    'مجموع الغيابات : %d   منها غير مبررة : %d   -   مجموع التأخرات : %d',
    [NbAbs, NbUnj, NbLate]);
end;

end.
