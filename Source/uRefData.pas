unit uRefData;

{ البيانات الأساسية : المستويات، الأقسام، المواد، الأساتذة، الحصص، السنوات
  Donnees de reference }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, DBCtrls, DB, Buttons;

type
  TfrmRefData = class(TForm)
    pc           : TPageControl;
    tabLevels    : TTabSheet;
    tabClasses   : TTabSheet;
    tabSubjects  : TTabSheet;
    tabTeachers  : TTabSheet;
    tabSlots     : TTabSheet;
    tabYears     : TTabSheet;
    { levels }
    grdLevels    : TDBGrid;
    navLevels    : TDBNavigator;
    { subjects }
    grdSubjects  : TDBGrid;
    navSubjects  : TDBNavigator;
    { slots }
    grdSlots     : TDBGrid;
    navSlots     : TDBNavigator;
    { years }
    grdYears     : TDBGrid;
    navYears     : TDBNavigator;
    pnlYears     : TPanel;
    btnSetCurrent: TButton;
    { classes }
    grdClasses   : TDBGrid;
    pnlCls       : TPanel;
    lblClsName   : TLabel;  edClsName  : TEdit;
    lblClsLevel  : TLabel;  cbClsLevel : TComboBox;
    lblClsYear   : TLabel;  cbClsYear  : TComboBox;
    lblClsRoom   : TLabel;  edClsRoom  : TEdit;
    lblClsCap    : TLabel;  edClsCap   : TEdit;
    btnClsNew    : TButton;
    btnClsSave   : TButton;
    btnClsDel    : TButton;
    { teachers }
    grdTeachers  : TDBGrid;
    pnlTch       : TPanel;
    lblTchLast   : TLabel;  edTchLast  : TEdit;
    lblTchFirst  : TLabel;  edTchFirst : TEdit;
    lblTchPhone  : TLabel;  edTchPhone : TEdit;
    lblTchEmail  : TLabel;  edTchEmail : TEdit;
    lblTchSubj   : TLabel;  cbTchSubj  : TComboBox;
    btnTchNew    : TButton;
    btnTchSave   : TButton;
    btnTchDel    : TButton;
    { commun }
    pnlBottom    : TPanel;
    btnClose     : TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSetCurrentClick(Sender: TObject);
    procedure btnClsNewClick(Sender: TObject);
    procedure btnClsSaveClick(Sender: TObject);
    procedure btnClsDelClick(Sender: TObject);
    procedure grdClassesCellClick(Column: TColumn);
    procedure btnTchNewClick(Sender: TObject);
    procedure btnTchSaveClick(Sender: TObject);
    procedure btnTchDelClick(Sender: TObject);
    procedure grdTeachersCellClick(Column: TColumn);
  private
    FClassID   : Integer;
    FTeacherID : Integer;
    FLevelKeys : TStringList;
    FYearKeys  : TStringList;
    FSubjKeys  : TStringList;
    procedure ApplyCaptions;
    procedure SetupGrids;
    procedure LoadCombos;
    procedure LoadClassFields;
    procedure LoadTeacherFields;
    procedure ClearClassFields;
    procedure ClearTeacherFields;
  end;

procedure ShowRefDataForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

procedure ShowRefDataForm;
var
  F : TfrmRefData;
begin
  F := TfrmRefData.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ --- إعداد عناوين الأعمدة ---------------------------------------------- }
procedure SetCols(AGrid: TDBGrid; const AFields, ATitles: array of string;
  const AWidths: array of Integer);
var
  I : Integer;
  C : TColumn;
begin
  AGrid.Columns.Clear;
  for I := Low(AFields) to High(AFields) do
  begin
    C := AGrid.Columns.Add;
    C.FieldName     := AFields[I];
    C.Title.Caption := ATitles[I];
    C.Width         := AWidths[I];
    C.Title.Alignment := taCenter;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmRefData.ApplyCaptions;
begin
  Caption            := R_RefTitle;
  tabLevels.Caption  := R_RefLevels;
  tabClasses.Caption := R_RefClasses;
  tabSubjects.Caption:= R_RefSubjects;
  tabTeachers.Caption:= R_RefTeachers;
  tabSlots.Caption   := R_RefSlots;
  tabYears.Caption   := R_RefYears;

  btnSetCurrent.Caption := 'تعيين كسنة جارية';
  btnClose.Caption      := R_Close;

  lblClsName.Caption  := R_ClsName;
  lblClsLevel.Caption := R_ClsLevel;
  lblClsYear.Caption  := R_ClsYear;
  lblClsRoom.Caption  := R_ClsRoom;
  lblClsCap.Caption   := R_ClsCapacity;
  btnClsNew.Caption   := R_New;
  btnClsSave.Caption  := R_Save;
  btnClsDel.Caption   := R_Delete;

  lblTchLast.Caption  := R_TchLastName;
  lblTchFirst.Caption := R_TchFirstName;
  lblTchPhone.Caption := R_TchPhone;
  lblTchEmail.Caption := R_TchEmail;
  lblTchSubj.Caption  := R_TchSubject;
  btnTchNew.Caption   := R_New;
  btnTchSave.Caption  := R_Save;
  btnTchDel.Caption   := R_Delete;
end;

procedure TfrmRefData.SetupGrids;
begin
  SetCols(grdLevels,   ['LevelName', 'SortOrder'],
                       [R_LevName, R_LevOrder], [280, 100]);

  SetCols(grdSubjects, ['SubjectName', 'Coefficient'],
                       [R_SubName, R_SubCoef], [320, 100]);

  SetCols(grdSlots,    ['SlotLabel', 'DayPart', 'StartTime', 'EndTime', 'SortOrder'],
                       [R_SltLabel, R_SltPart, R_SltStart, R_SltEnd, R_LevOrder],
                       [200, 120, 110, 110, 90]);

  SetCols(grdYears,    ['YearLabel', 'StartDate', 'EndDate', 'IsCurrent'],
                       [R_YrLabel, R_YrStart, R_YrEnd, R_YrCurrent],
                       [140, 130, 130, 110]);

  SetCols(grdClasses,  ['ClassName', 'LevelName', 'YearLabel', 'RoomName', 'Capacity'],
                       [R_ClsName, R_ClsLevel, R_ClsYear, R_ClsRoom, R_ClsCapacity],
                       [130, 170, 130, 150, 120]);

  SetCols(grdTeachers, ['LastName', 'FirstName', 'SubjectName', 'Phone', 'Email'],
                       [R_TchLastName, R_TchFirstName, R_TchSubject,
                        R_TchPhone, R_TchEmail],
                       [150, 150, 200, 130, 200]);
end;

procedure TfrmRefData.LoadCombos;
begin
  FillCombo(cbClsLevel.Items, dm.tblLevels,   'LevelName',   'LevelID',   FLevelKeys, R_None);
  FillCombo(cbClsYear.Items,  dm.tblYears,    'YearLabel',   'YearID',    FYearKeys,  R_None);
  FillCombo(cbTchSubj.Items,  dm.tblSubjects, 'SubjectName', 'SubjectID', FSubjKeys,  R_None);
  cbClsLevel.ItemIndex := 0;
  cbClsYear.ItemIndex  := 0;
  cbTchSubj.ItemIndex  := 0;
end;

procedure TfrmRefData.FormCreate(Sender: TObject);
begin
  FLevelKeys := TStringList.Create;
  FYearKeys  := TStringList.Create;
  FSubjKeys  := TStringList.Create;
  FClassID   := 0;
  FTeacherID := 0;

  ApplyCaptions;
  dm.OpenLookups;
  SetupGrids;
  LoadCombos;
  LoadClassFields;
  LoadTeacherFields;
  ApplyRTL(Self);
  pc.ActivePage := tabLevels;
end;

procedure TfrmRefData.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  { حفظ أي تعديل معلق في الجداول القابلة للتحرير }
  if dm.tblLevels.State   in [dsEdit, dsInsert] then dm.tblLevels.Post;
  if dm.tblSubjects.State in [dsEdit, dsInsert] then dm.tblSubjects.Post;
  if dm.tblSlots.State    in [dsEdit, dsInsert] then dm.tblSlots.Post;
  if dm.tblYears.State    in [dsEdit, dsInsert] then dm.tblYears.Post;

  FLevelKeys.Free;
  FYearKeys.Free;
  FSubjKeys.Free;
end;

procedure TfrmRefData.btnCloseClick(Sender: TObject);
begin
  Close;
end;

{ --- السنة الجارية ------------------------------------------------------ }
procedure TfrmRefData.btnSetCurrentClick(Sender: TObject);
var
  Id : Integer;
begin
  if dm.tblYears.IsEmpty then Exit;
  if dm.tblYears.State in [dsEdit, dsInsert] then dm.tblYears.Post;
  Id := dm.tblYears.FieldByName('YearID').AsInteger;
  dm.ExecSQL('UPDATE SchoolYears SET IsCurrent = False');
  dm.ExecSQL('UPDATE SchoolYears SET IsCurrent = True WHERE YearID = ' + IntToStr(Id));
  dm.tblYears.Requery;
  ShowInfo(R_MsgSaved);
end;

{ --- الأقسام ------------------------------------------------------------ }
procedure TfrmRefData.ClearClassFields;
begin
  FClassID := 0;
  edClsName.Clear;
  edClsRoom.Clear;
  edClsCap.Text := '40';
  cbClsLevel.ItemIndex := 0;
  if FYearKeys.Count > 0 then
  begin
    cbClsYear.ItemIndex := FYearKeys.IndexOf(IntToStr(dm.CurrentYearID));
    if cbClsYear.ItemIndex < 0 then cbClsYear.ItemIndex := 0;
  end;
end;

procedure TfrmRefData.LoadClassFields;
var
  I : Integer;
begin
  if dm.qClasses.IsEmpty then
  begin
    ClearClassFields;
    Exit;
  end;
  FClassID      := dm.qClasses.FieldByName('ClassID').AsInteger;
  edClsName.Text:= dm.qClasses.FieldByName('ClassName').AsString;
  edClsRoom.Text:= dm.qClasses.FieldByName('RoomName').AsString;
  edClsCap.Text := dm.qClasses.FieldByName('Capacity').AsString;

  I := FLevelKeys.IndexOf(dm.qClasses.FieldByName('LevelID').AsString);
  if I >= 0 then cbClsLevel.ItemIndex := I else cbClsLevel.ItemIndex := 0;

  I := FYearKeys.IndexOf(dm.qClasses.FieldByName('YearID').AsString);
  if I >= 0 then cbClsYear.ItemIndex := I else cbClsYear.ItemIndex := 0;
end;

procedure TfrmRefData.grdClassesCellClick(Column: TColumn);
begin
  LoadClassFields;
end;

procedure TfrmRefData.btnClsNewClick(Sender: TObject);
begin
  ClearClassFields;
  edClsName.SetFocus;
end;

procedure TfrmRefData.btnClsSaveClick(Sender: TObject);
var
  LevVal, YrVal : string;
begin
  if Trim(edClsName.Text) = '' then
  begin
    ShowError(R_MsgRequired);
    edClsName.SetFocus;
    Exit;
  end;

  LevVal := 'NULL';
  if (cbClsLevel.ItemIndex > 0) and (cbClsLevel.ItemIndex < FLevelKeys.Count) then
    LevVal := FLevelKeys[cbClsLevel.ItemIndex];

  YrVal := 'NULL';
  if (cbClsYear.ItemIndex > 0) and (cbClsYear.ItemIndex < FYearKeys.Count) then
    YrVal := FYearKeys[cbClsYear.ItemIndex];

  try
    if FClassID = 0 then
      dm.ExecSQL('INSERT INTO Classes (ClassName, LevelID, YearID, RoomName, Capacity)' +
        ' VALUES (' + SqlStr(Trim(edClsName.Text)) + ', ' + LevVal + ', ' + YrVal +
        ', ' + SqlStr(Trim(edClsRoom.Text)) + ', ' +
        IntToStr(StrToIntDef(edClsCap.Text, 0)) + ')')
    else
      dm.ExecSQL('UPDATE Classes SET ClassName = ' + SqlStr(Trim(edClsName.Text)) +
        ', LevelID = ' + LevVal + ', YearID = ' + YrVal +
        ', RoomName = ' + SqlStr(Trim(edClsRoom.Text)) +
        ', Capacity = ' + IntToStr(StrToIntDef(edClsCap.Text, 0)) +
        ' WHERE ClassID = ' + IntToStr(FClassID));

    dm.RefreshClasses;
    ShowInfo(R_MsgSaved);
    ClearClassFields;
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmRefData.btnClsDelClick(Sender: TObject);
var
  Nb : Integer;
begin
  if dm.qClasses.IsEmpty then Exit;
  FClassID := dm.qClasses.FieldByName('ClassID').AsInteger;

  Nb := dm.ScalarInt('SELECT COUNT(*) FROM Students WHERE ClassID = ' +
                     IntToStr(FClassID), 0);
  if Nb > 0 then
  begin
    ShowError('لا يمكن حذف هذا القسم : يوجد به ' + IntToStr(Nb) + ' تلميذ.');
    Exit;
  end;
  if not AskYesNo(R_MsgConfirmDel) then Exit;

  dm.ExecSQL('DELETE FROM Classes WHERE ClassID = ' + IntToStr(FClassID));
  dm.RefreshClasses;
  ClearClassFields;
  ShowInfo(R_MsgDeleted);
end;

{ --- الأساتذة ----------------------------------------------------------- }
procedure TfrmRefData.ClearTeacherFields;
begin
  FTeacherID := 0;
  edTchLast.Clear;
  edTchFirst.Clear;
  edTchPhone.Clear;
  edTchEmail.Clear;
  cbTchSubj.ItemIndex := 0;
end;

procedure TfrmRefData.LoadTeacherFields;
var
  I : Integer;
begin
  if dm.qTeachers.IsEmpty then
  begin
    ClearTeacherFields;
    Exit;
  end;
  FTeacherID      := dm.qTeachers.FieldByName('TeacherID').AsInteger;
  edTchLast.Text  := dm.qTeachers.FieldByName('LastName').AsString;
  edTchFirst.Text := dm.qTeachers.FieldByName('FirstName').AsString;
  edTchPhone.Text := dm.qTeachers.FieldByName('Phone').AsString;
  edTchEmail.Text := dm.qTeachers.FieldByName('Email').AsString;

  I := FSubjKeys.IndexOf(dm.qTeachers.FieldByName('SubjectID').AsString);
  if I >= 0 then cbTchSubj.ItemIndex := I else cbTchSubj.ItemIndex := 0;
end;

procedure TfrmRefData.grdTeachersCellClick(Column: TColumn);
begin
  LoadTeacherFields;
end;

procedure TfrmRefData.btnTchNewClick(Sender: TObject);
begin
  ClearTeacherFields;
  edTchLast.SetFocus;
end;

procedure TfrmRefData.btnTchSaveClick(Sender: TObject);
var
  SubVal : string;
begin
  if Trim(edTchLast.Text) = '' then
  begin
    ShowError(R_MsgRequired);
    edTchLast.SetFocus;
    Exit;
  end;

  SubVal := 'NULL';
  if (cbTchSubj.ItemIndex > 0) and (cbTchSubj.ItemIndex < FSubjKeys.Count) then
    SubVal := FSubjKeys[cbTchSubj.ItemIndex];

  try
    if FTeacherID = 0 then
      dm.ExecSQL('INSERT INTO Teachers (LastName, FirstName, Phone, Email, SubjectID)' +
        ' VALUES (' + SqlStr(Trim(edTchLast.Text)) + ', ' +
        SqlStr(Trim(edTchFirst.Text)) + ', ' + SqlStr(Trim(edTchPhone.Text)) +
        ', ' + SqlStr(Trim(edTchEmail.Text)) + ', ' + SubVal + ')')
    else
      dm.ExecSQL('UPDATE Teachers SET LastName = ' + SqlStr(Trim(edTchLast.Text)) +
        ', FirstName = ' + SqlStr(Trim(edTchFirst.Text)) +
        ', Phone = '     + SqlStr(Trim(edTchPhone.Text)) +
        ', Email = '     + SqlStr(Trim(edTchEmail.Text)) +
        ', SubjectID = ' + SubVal +
        ' WHERE TeacherID = ' + IntToStr(FTeacherID));

    dm.RefreshTeachers;
    ShowInfo(R_MsgSaved);
    ClearTeacherFields;
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmRefData.btnTchDelClick(Sender: TObject);
begin
  if dm.qTeachers.IsEmpty then Exit;
  FTeacherID := dm.qTeachers.FieldByName('TeacherID').AsInteger;
  if not AskYesNo(R_MsgConfirmDel) then Exit;
  try
    dm.ExecSQL('UPDATE Absences SET TeacherID = NULL WHERE TeacherID = ' +
               IntToStr(FTeacherID));
    dm.ExecSQL('DELETE FROM Teachers WHERE TeacherID = ' + IntToStr(FTeacherID));
    dm.RefreshTeachers;
    ClearTeacherFields;
    ShowInfo(R_MsgDeleted);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

end.
