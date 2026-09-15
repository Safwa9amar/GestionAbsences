unit uAbsence;

{ تسجيل الغيابات اليومية / Saisie des absences journalieres

  الواجهة الأساسية للبرنامج : يختار المستخدم التاريخ والقسم والحصة،
  فتعرض قائمة تلاميذ القسم، ويحدد لكل تلميذ حالته (حاضر / غائب / متأخر).
  عند الحفظ يقارن البرنامج الحالة الجديدة بما هو مسجل في القاعدة
  فيضيف أو يعدل أو يحذف حسب الحاجة. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DB;

const
  ST_PRESENT = 0;
  ST_ABSENT  = 1;
  ST_LATE    = 2;

  COL_NUM    = 0;
  COL_LAST   = 1;
  COL_FIRST  = 2;
  COL_STATE  = 3;
  COL_MIN    = 4;
  COL_JUST   = 5;
  COL_REASON = 6;

type
  TfrmAbsence = class(TForm)
    pnlTop      : TPanel;
    lblDate     : TLabel;   dtDate    : TDateTimePicker;
    lblClass    : TLabel;   cbClass   : TComboBox;
    lblSlot     : TLabel;   cbSlot    : TComboBox;
    lblSubject  : TLabel;   cbSubject : TComboBox;
    lblTeacher  : TLabel;   cbTeacher : TComboBox;
    btnLoad     : TButton;
    grd         : TStringGrid;
    pnlBottom   : TPanel;
    lblSummary  : TLabel;
    lblHint     : TLabel;
    btnAllPres  : TButton;
    btnAllAbs   : TButton;
    btnSave     : TButton;
    btnPrint    : TButton;
    btnClose    : TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnAllPresClick(Sender: TObject);
    procedure btnAllAbsClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure grdDrawCell(Sender: TObject; ACol, ARow: Integer;
                          Rect: TRect; State: TGridDrawState);
    procedure grdMouseDown(Sender: TObject; Button: TMouseButton;
                           Shift: TShiftState; X, Y: Integer);
    procedure grdSelectCell(Sender: TObject; ACol, ARow: Integer;
                            var CanSelect: Boolean);
    procedure FilterChange(Sender: TObject);
  private
    FIds        : TStringList;   { StudentID لكل سطر            }
    FStates     : TStringList;   { الحالة الحالية لكل سطر       }
    FOrigStates : TStringList;   { الحالة المسجلة في القاعدة    }
    FOrigAbsIds : TStringList;   { AbsenceID المسجل لكل سطر     }
    FClassKeys  : TStringList;
    FSlotKeys   : TStringList;
    FSubjKeys   : TStringList;
    FTchKeys    : TStringList;
    FLoaded     : Boolean;
    procedure ApplyCaptions;
    procedure LoadCombos;
    procedure InitGrid;
    function  SelClassID: Integer;
    function  SelSlotID: Integer;
    function  SelSubjectID: Integer;
    function  SelTeacherID: Integer;
    function  StateText(AState: Integer): string;
    procedure SetRowState(ARow, AState: Integer);
    procedure UpdateSummary;
    procedure MarkAll(AState: Integer);
  end;

procedure ShowAbsenceForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

procedure ShowAbsenceForm;
var
  F : TfrmAbsence;
begin
  F := TfrmAbsence.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmAbsence.ApplyCaptions;
begin
  Caption            := R_AbsTitle;
  lblDate.Caption    := R_AbsDate;
  lblClass.Caption   := R_AbsClass;
  lblSlot.Caption    := R_AbsSlot;
  lblSubject.Caption := R_AbsSubject;
  lblTeacher.Caption := R_AbsTeacher;
  btnLoad.Caption    := R_AbsLoad;
  btnAllPres.Caption := R_AbsMarkAllPres;
  btnAllAbs.Caption  := R_AbsMarkAllAbs;
  btnSave.Caption    := R_AbsSaveAll;
  btnPrint.Caption   := R_MnuDailyRep;
  btnClose.Caption   := R_Close;
  lblHint.Caption    := R_AbsHint;
end;

procedure TfrmAbsence.FormCreate(Sender: TObject);
begin
  FIds        := TStringList.Create;
  FStates     := TStringList.Create;
  FOrigStates := TStringList.Create;
  FOrigAbsIds := TStringList.Create;
  FClassKeys  := TStringList.Create;
  FSlotKeys   := TStringList.Create;
  FSubjKeys   := TStringList.Create;
  FTchKeys    := TStringList.Create;
  FLoaded     := False;

  ApplyCaptions;
  LoadCombos;
  InitGrid;
  dtDate.Date := Date;
  ApplyRTL(Self);
end;

procedure TfrmAbsence.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FIds.Free;        FStates.Free;
  FOrigStates.Free; FOrigAbsIds.Free;
  FClassKeys.Free;  FSlotKeys.Free;
  FSubjKeys.Free;   FTchKeys.Free;
end;

procedure TfrmAbsence.LoadCombos;
begin
  dm.OpenLookups;
  FillCombo(cbClass.Items, dm.qClasses, 'ClassName', 'ClassID', FClassKeys, '');
  dm.OpenQ(dm.qWork, 'SELECT SlotID, SlotLabel, DayPart FROM TimeSlots ORDER BY SortOrder');
  FillCombo(cbSlot.Items, dm.qWork, 'SlotLabel', 'SlotID', FSlotKeys, '');
  dm.qWork.Close;
  FillCombo(cbSubject.Items, dm.tblSubjects, 'SubjectName', 'SubjectID', FSubjKeys, R_None);

  dm.OpenQ(dm.qWork,
    'SELECT TeacherID, LastName & '' '' & FirstName AS TchName FROM Teachers' +
    ' ORDER BY LastName, FirstName');
  FillCombo(cbTeacher.Items, dm.qWork, 'TchName', 'TeacherID', FTchKeys, R_None);
  dm.qWork.Close;

  if cbClass.Items.Count > 0 then cbClass.ItemIndex := 0;
  if cbSlot.Items.Count  > 0 then cbSlot.ItemIndex  := 0;
  cbSubject.ItemIndex := 0;
  cbTeacher.ItemIndex := 0;
end;

procedure TfrmAbsence.InitGrid;
begin
  grd.ColCount  := 7;
  grd.RowCount  := 2;
  grd.FixedRows := 1;
  grd.FixedCols := 0;
  grd.DefaultRowHeight := 24;

  grd.ColWidths[COL_NUM]    := 45;
  grd.ColWidths[COL_LAST]   := 160;
  grd.ColWidths[COL_FIRST]  := 160;
  grd.ColWidths[COL_STATE]  := 110;
  grd.ColWidths[COL_MIN]    := 80;
  grd.ColWidths[COL_JUST]   := 70;
  grd.ColWidths[COL_REASON] := 280;

  grd.Cells[COL_NUM,    0] := R_ColNum;
  grd.Cells[COL_LAST,   0] := R_StuLastName;
  grd.Cells[COL_FIRST,  0] := R_StuFirstName;
  grd.Cells[COL_STATE,  0] := R_AbsState;
  grd.Cells[COL_MIN,    0] := R_AbsMinutes;
  grd.Cells[COL_JUST,   0] := R_AbsJustified;
  grd.Cells[COL_REASON, 0] := R_AbsReason;
end;

{ --- قراءة القيم المختارة ----------------------------------------------- }
function TfrmAbsence.SelClassID: Integer;
begin
  Result := 0;
  if (cbClass.ItemIndex >= 0) and (cbClass.ItemIndex < FClassKeys.Count) then
    Result := StrToIntDef(FClassKeys[cbClass.ItemIndex], 0);
end;

function TfrmAbsence.SelSlotID: Integer;
begin
  Result := 0;
  if (cbSlot.ItemIndex >= 0) and (cbSlot.ItemIndex < FSlotKeys.Count) then
    Result := StrToIntDef(FSlotKeys[cbSlot.ItemIndex], 0);
end;

function TfrmAbsence.SelSubjectID: Integer;
begin
  Result := 0;
  if (cbSubject.ItemIndex > 0) and (cbSubject.ItemIndex < FSubjKeys.Count) then
    Result := StrToIntDef(FSubjKeys[cbSubject.ItemIndex], 0);
end;

function TfrmAbsence.SelTeacherID: Integer;
begin
  Result := 0;
  if (cbTeacher.ItemIndex > 0) and (cbTeacher.ItemIndex < FTchKeys.Count) then
    Result := StrToIntDef(FTchKeys[cbTeacher.ItemIndex], 0);
end;

function TfrmAbsence.StateText(AState: Integer): string;
begin
  case AState of
    ST_ABSENT : Result := R_AbsAbsent;
    ST_LATE   : Result := R_AbsLate;
  else
    Result := R_AbsPresent;
  end;
end;

procedure TfrmAbsence.FilterChange(Sender: TObject);
begin
  FLoaded := False;
  lblSummary.Caption := R_AbsPressLoad;
end;

{ ------------------------------------------------------------------------
  تحميل قائمة التلاميذ مع حالاتهم المسجلة مسبقا
  ------------------------------------------------------------------------ }
procedure TfrmAbsence.btnLoadClick(Sender: TObject);
var
  Cid, Sid, R : Integer;
  Q : TDataSet;
  Kind : string;
begin
  Cid := SelClassID;
  Sid := SelSlotID;
  if (Cid = 0) or (Sid = 0) then
  begin
    ShowError(R_AbsNoClass);
    Exit;
  end;

  FIds.Clear; FStates.Clear; FOrigStates.Clear; FOrigAbsIds.Clear;
  grd.RowCount := 2;
  grd.Rows[1].Clear;

  Q := dm.OpenQ(dm.qWork,
    'SELECT StudentID, LastName, FirstName FROM Students' +
    ' WHERE ClassID = ' + IntToStr(Cid) + ' AND IsActive = True' +
    ' ORDER BY LastName, FirstName');

  if Q.IsEmpty then
  begin
    dm.qWork.Close;
    ShowInfo(R_AbsNoStudents);
    FLoaded := False;
    Exit;
  end;

  R := 0;
  while not Q.Eof do
  begin
    Inc(R);
    grd.RowCount := R + 1;
    grd.Cells[COL_NUM,    R] := IntToStr(R);
    grd.Cells[COL_LAST,   R] := Q.FieldByName('LastName').AsString;
    grd.Cells[COL_FIRST,  R] := Q.FieldByName('FirstName').AsString;
    grd.Cells[COL_STATE,  R] := StateText(ST_PRESENT);
    grd.Cells[COL_MIN,    R] := '';
    grd.Cells[COL_JUST,   R] := R_No;
    grd.Cells[COL_REASON, R] := '';

    FIds.Add(Q.FieldByName('StudentID').AsString);
    FStates.Add(IntToStr(ST_PRESENT));
    FOrigStates.Add(IntToStr(ST_PRESENT));
    FOrigAbsIds.Add('0');
    Q.Next;
  end;
  dm.qWork.Close;

  { --- استرجاع ما هو مسجل فعلا لهذا التاريخ وهذه الحصة --- }
  Q := dm.OpenQ(dm.qWork,
    'SELECT AbsenceID, StudentID, AbsKind, LateMinutes, Justified, JustifyReason' +
    ' FROM Absences WHERE AbsDate = ' + SqlDate(dtDate.Date) +
    ' AND SlotID = ' + IntToStr(Sid));

  while not Q.Eof do
  begin
    R := FIds.IndexOf(Q.FieldByName('StudentID').AsString);
    if R >= 0 then
    begin
      Kind := Q.FieldByName('AbsKind').AsString;
      if SameText(Kind, 'LATE') then
        FStates[R] := IntToStr(ST_LATE)
      else
        FStates[R] := IntToStr(ST_ABSENT);
      FOrigStates[R] := FStates[R];
      FOrigAbsIds[R] := Q.FieldByName('AbsenceID').AsString;

      grd.Cells[COL_STATE,  R + 1] := StateText(StrToIntDef(FStates[R], 0));
      grd.Cells[COL_MIN,    R + 1] := Q.FieldByName('LateMinutes').AsString;
      if Q.FieldByName('Justified').AsBoolean then
        grd.Cells[COL_JUST, R + 1] := R_Yes
      else
        grd.Cells[COL_JUST, R + 1] := R_No;
      grd.Cells[COL_REASON, R + 1] := Q.FieldByName('JustifyReason').AsString;
    end;
    Q.Next;
  end;
  dm.qWork.Close;

  FLoaded := True;
  UpdateSummary;
  grd.Invalidate;
end;

{ ------------------------------------------------------------------------
  تغيير حالة السطر
  ------------------------------------------------------------------------ }
procedure TfrmAbsence.SetRowState(ARow, AState: Integer);
begin
  if (ARow < 1) or (ARow > FIds.Count) then Exit;
  FStates[ARow - 1] := IntToStr(AState);
  grd.Cells[COL_STATE, ARow] := StateText(AState);
  if AState <> ST_LATE then
    grd.Cells[COL_MIN, ARow] := '';
  if AState = ST_PRESENT then
  begin
    grd.Cells[COL_JUST, ARow]   := R_No;
    grd.Cells[COL_REASON, ARow] := '';
  end;
  UpdateSummary;
end;

procedure TfrmAbsence.grdMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  C, R, S : Integer;
begin
  if not FLoaded then Exit;
  grd.MouseToCell(X, Y, C, R);
  if (R < 1) or (R > FIds.Count) then Exit;

  if C = COL_STATE then
  begin
    S := (StrToIntDef(FStates[R - 1], 0) + 1) mod 3;
    SetRowState(R, S);
  end
  else if C = COL_JUST then
  begin
    if StrToIntDef(FStates[R - 1], 0) = ST_PRESENT then Exit;
    if grd.Cells[COL_JUST, R] = R_Yes then
      grd.Cells[COL_JUST, R] := R_No
    else
      grd.Cells[COL_JUST, R] := R_Yes;
  end;
end;

procedure TfrmAbsence.grdSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  { لا يسمح بالكتابة إلا في خانتي دقائق التأخر وسبب الغياب }
  if (ACol = COL_MIN) or (ACol = COL_REASON) then
    grd.Options := grd.Options + [goEditing]
  else
    grd.Options := grd.Options - [goEditing];
end;

procedure TfrmAbsence.grdDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Txt : string;
  Bg  : TColor;
  St  : Integer;
begin
  with grd.Canvas do
  begin
    Txt := grd.Cells[ACol, ARow];

    if ARow = 0 then
      Bg := $00E8D8C8
    else
    begin
      St := ST_PRESENT;
      if (ARow - 1) < FStates.Count then
        St := StrToIntDef(FStates[ARow - 1], ST_PRESENT);
      case St of
        ST_ABSENT : Bg := $00D0D0FF;
        ST_LATE   : Bg := $00B0E8FF;
      else
        Bg := clWindow;
      end;
      if gdSelected in State then
        Bg := $00F0C0A0;
    end;

    Brush.Color := Bg;
    FillRect(Rect);
    Font.Color := clBlack;
    if (ARow = 0) or (ACol = COL_STATE) then
      Font.Style := [fsBold]
    else
      Font.Style := [];
    TextRect(Rect, Rect.Left + 4,
             Rect.Top + ((Rect.Bottom - Rect.Top - TextHeight(Txt)) div 2), Txt);
  end;
end;

procedure TfrmAbsence.UpdateSummary;
var
  I, P, A, L : Integer;
begin
  P := 0; A := 0; L := 0;
  for I := 0 to FStates.Count - 1 do
    case StrToIntDef(FStates[I], 0) of
      ST_ABSENT : Inc(A);
      ST_LATE   : Inc(L);
    else
      Inc(P);
    end;
  lblSummary.Caption := Format(R_AbsSummary, [P, A, L]);
end;

procedure TfrmAbsence.MarkAll(AState: Integer);
var
  I : Integer;
begin
  if not FLoaded then Exit;
  for I := 1 to FIds.Count do
    SetRowState(I, AState);
  grd.Invalidate;
end;

procedure TfrmAbsence.btnAllPresClick(Sender: TObject);
begin
  MarkAll(ST_PRESENT);
end;

procedure TfrmAbsence.btnAllAbsClick(Sender: TObject);
begin
  MarkAll(ST_ABSENT);
end;

{ ------------------------------------------------------------------------
  الحفظ : مقارنة الحالة الجديدة بالمسجلة ثم إضافة / تعديل / حذف
  ------------------------------------------------------------------------ }
procedure TfrmAbsence.btnSaveClick(Sender: TObject);
var
  I, NewSt, AbsId, Ops : Integer;
  Sid, SlotId, SubId, TchId : Integer;
  Kind, SubVal, TchVal, JustVal, Mins : string;
begin
  if not FLoaded then
  begin
    ShowError(R_AbsNoClass);
    Exit;
  end;

  SlotId := SelSlotID;
  SubId  := SelSubjectID;
  TchId  := SelTeacherID;
  if SubId = 0 then SubVal := 'NULL' else SubVal := IntToStr(SubId);
  if TchId = 0 then TchVal := 'NULL' else TchVal := IntToStr(TchId);

  Ops := 0;
  try
    for I := 0 to FIds.Count - 1 do
    begin
      Sid    := StrToIntDef(FIds[I], 0);
      NewSt  := StrToIntDef(FStates[I], ST_PRESENT);
      AbsId  := StrToIntDef(FOrigAbsIds[I], 0);

      if grd.Cells[COL_JUST, I + 1] = R_Yes then
        JustVal := 'True'
      else
        JustVal := 'False';

      Mins := IntToStr(StrToIntDef(grd.Cells[COL_MIN, I + 1], 0));

      if NewSt = ST_LATE then Kind := 'LATE' else Kind := 'ABS';

      { 1) كان مسجلا وأصبح حاضرا  -->  حذف }
      if (NewSt = ST_PRESENT) and (AbsId > 0) then
      begin
        dm.ExecSQL('DELETE FROM Absences WHERE AbsenceID = ' + IntToStr(AbsId));
        Inc(Ops);
      end

      { 2) غائب أو متأخر ولم يكن مسجلا  -->  إضافة }
      else if (NewSt <> ST_PRESENT) and (AbsId = 0) then
      begin
        dm.ExecSQL(
          'INSERT INTO Absences (StudentID, AbsDate, SlotID, SubjectID, TeacherID,' +
          ' AbsKind, LateMinutes, Justified, JustifyReason, RecordedBy, RecordedAt)' +
          ' VALUES (' + IntToStr(Sid) + ', ' + SqlDate(dtDate.Date) + ', ' +
          IntToStr(SlotId) + ', ' + SubVal + ', ' + TchVal + ', ' +
          SqlStr(Kind) + ', ' + Mins + ', ' + JustVal + ', ' +
          SqlStr(grd.Cells[COL_REASON, I + 1]) + ', ' +
          IntToStr(dm.CurrentUserID) + ', ' + SqlDate(Date) + ')');
        Inc(Ops);
      end

      { 3) مسجل مسبقا  -->  تعديل }
      else if (NewSt <> ST_PRESENT) and (AbsId > 0) then
      begin
        dm.ExecSQL(
          'UPDATE Absences SET AbsKind = ' + SqlStr(Kind) +
          ', SubjectID = '     + SubVal +
          ', TeacherID = '     + TchVal +
          ', LateMinutes = '   + Mins +
          ', Justified = '     + JustVal +
          ', JustifyReason = ' + SqlStr(grd.Cells[COL_REASON, I + 1]) +
          ', RecordedBy = '    + IntToStr(dm.CurrentUserID) +
          ', RecordedAt = '    + SqlDate(Date) +
          ' WHERE AbsenceID = '+ IntToStr(AbsId));
        Inc(Ops);
      end;
    end;

    ShowInfo(Format(R_AbsSavedFmt, [Ops]));
    btnLoadClick(nil);   { إعادة التحميل لتحديث المعرّفات }
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

{ ------------------------------------------------------------------------
  التقرير اليومي / وثيقة غياب التلاميذ
  ------------------------------------------------------------------------ }
procedure TfrmAbsence.btnPrintClick(Sender: TObject);
var
  Rep : TReportBuilder;
  Q   : TDataSet;
  N   : Integer;
begin
  Q := dm.OpenQ(dm.qRep,
    'SELECT c.ClassName, s.LastName, s.FirstName, t.SlotLabel, t.StartTime,' +
    ' t.EndTime, sub.SubjectName, a.AbsKind, a.LateMinutes, a.Justified' +
    ' FROM (((Absences a INNER JOIN Students s ON a.StudentID = s.StudentID)' +
    ' LEFT JOIN Classes c ON s.ClassID = c.ClassID)' +
    ' LEFT JOIN TimeSlots t ON a.SlotID = t.SlotID)' +
    ' LEFT JOIN Subjects sub ON a.SubjectID = sub.SubjectID' +
    ' WHERE a.AbsDate = ' + SqlDate(dtDate.Date) +
    ' ORDER BY c.ClassName, t.SortOrder, s.LastName');

  if Q.IsEmpty then
  begin
    dm.qRep.Close;
    ShowInfo(R_RepNoData);
    Exit;
  end;

  Rep := TReportBuilder.Create(R_RepDailyAbs);
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               FormatArabicDate(dtDate.Date));
    Rep.OpenTable([R_ColNum, R_StuClass, R_StuLastName, R_StuFirstName,
                   R_AbsSlot, R_ColTime, R_AbsSubject, R_AbsState,
                   R_AbsMinutes, R_AbsJustified]);
    N := 0;
    while not Q.Eof do
    begin
      Inc(N);
      Rep.RowClass([IntToStr(N),
        Q.FieldByName('ClassName').AsString,
        Q.FieldByName('LastName').AsString,
        Q.FieldByName('FirstName').AsString,
        Q.FieldByName('SlotLabel').AsString,
        Q.FieldByName('StartTime').AsString + ' - ' + Q.FieldByName('EndTime').AsString,
        Q.FieldByName('SubjectName').AsString,
        IfThenStr(SameText(Q.FieldByName('AbsKind').AsString, 'LATE'),
                  R_AbsLate, R_AbsAbsent),
        Q.FieldByName('LateMinutes').AsString,
        IfThenStr(Q.FieldByName('Justified').AsBoolean, R_Yes, R_No)],
        IfThenStr(Q.FieldByName('Justified').AsBoolean, 'ok', 'warn'));
      Q.Next;
    end;
    Rep.CloseTable;
    Rep.Paragraph(R_AbsDayTotal + '<b>' + IntToStr(N) + '</b>');
    Rep.Signature(R_SignSupervisor, R_SignAdvisor + dm.GetSetting('ADVISOR', ''));
    Rep.SaveAndOpen('Rapport_Journalier.html');
  finally
    Rep.Free;
    dm.qRep.Close;
  end;
end;

procedure TfrmAbsence.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
