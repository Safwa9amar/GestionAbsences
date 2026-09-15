unit uJustify;

{ تبرير الغيابات / Justification des absences }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, DB;

type
  TfrmJustify = class(TForm)
    pnlTop     : TPanel;
    lblFrom    : TLabel;  dtFrom   : TDateTimePicker;
    lblTo      : TLabel;  dtTo     : TDateTimePicker;
    lblClass   : TLabel;  cbClass  : TComboBox;
    chkOnlyUnj : TCheckBox;
    edSearch   : TEdit;
    lblSearch  : TLabel;
    btnApply   : TButton;
    grd        : TDBGrid;
    pnlBottom  : TPanel;
    lblCount   : TLabel;
    btnJustify : TButton;
    btnUnjust  : TButton;
    btnPrint   : TButton;
    btnClose   : TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnApplyClick(Sender: TObject);
    procedure btnJustifyClick(Sender: TObject);
    procedure btnUnjustClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FClassKeys : TStringList;
    procedure ApplyCaptions;
    procedure SetupGrid;
    procedure LoadData;
    function  SelClassID: Integer;
    procedure ApplyJustification(AJustified: Boolean; const AReason: string);
  end;

procedure ShowJustifyForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

procedure ShowJustifyForm;
var
  F : TfrmJustify;
begin
  F := TfrmJustify.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmJustify.ApplyCaptions;
begin
  Caption            := R_JusTitle;
  lblFrom.Caption    := R_JusFrom;
  lblTo.Caption      := R_JusTo;
  lblClass.Caption   := R_AbsClass;
  lblSearch.Caption  := R_Search;
  chkOnlyUnj.Caption := R_JusOnlyUnjust;
  btnApply.Caption   := R_Refresh;
  btnJustify.Caption := R_JusMarkJust;
  btnUnjust.Caption  := R_JusMarkUnjust;
  btnPrint.Caption   := R_Print;
  btnClose.Caption   := R_Close;
end;

procedure TfrmJustify.FormCreate(Sender: TObject);
begin
  FClassKeys := TStringList.Create;
  ApplyCaptions;

  dm.RefreshClasses;
  FillCombo(cbClass.Items, dm.qClasses, 'ClassName', 'ClassID', FClassKeys, R_All);
  cbClass.ItemIndex := 0;

  dtFrom.Date := Date - 30;
  dtTo.Date   := Date;

  SetupGrid;
  LoadData;
  ApplyRTL(Self);
end;

procedure TfrmJustify.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FClassKeys.Free;
end;

procedure TfrmJustify.SetupGrid;

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
  AddCol('AbsDate',       R_AbsDate,      100);
  AddCol('ClassName',     R_AbsClass,      80);
  AddCol('LastName',      R_StuLastName,  140);
  AddCol('FirstName',     R_StuFirstName, 140);
  AddCol('SlotLabel',     R_AbsSlot,      130);
  AddCol('SubjectName',   R_AbsSubject,   150);
  AddCol('KindLabel',     R_AbsState,      80);
  AddCol('JustLabel',     R_AbsJustified,  70);
  AddCol('JustifyReason', R_AbsReason,    220);
end;

function TfrmJustify.SelClassID: Integer;
begin
  Result := 0;
  if (cbClass.ItemIndex >= 0) and (cbClass.ItemIndex < FClassKeys.Count) then
    Result := StrToIntDef(FClassKeys[cbClass.ItemIndex], 0);
end;

procedure TfrmJustify.LoadData;
var
  W : string;
begin
  W := ' WHERE a.AbsDate BETWEEN ' + SqlDate(dtFrom.Date) +
       ' AND ' + SqlDate(dtTo.Date);

  if chkOnlyUnj.Checked then
    W := W + ' AND a.Justified = False';
  if SelClassID > 0 then
    W := W + ' AND s.ClassID = ' + IntToStr(SelClassID);
  if Trim(edSearch.Text) <> '' then
    W := W + ' AND (s.LastName LIKE ' + SqlStr('%' + Trim(edSearch.Text) + '%') +
             ' OR s.FirstName LIKE ' + SqlStr('%' + Trim(edSearch.Text) + '%') + ')';

  dm.OpenQ(dm.qAbsences,
    'SELECT a.AbsenceID, a.AbsDate, c.ClassName, s.LastName, s.FirstName,' +
    ' t.SlotLabel, sub.SubjectName, a.JustifyReason,' +
    ' IIF(a.AbsKind = ''LATE'', ' + SqlStr(R_AbsLate) + ', ' +
        SqlStr(R_AbsAbsent) + ') AS KindLabel,' +
    ' IIF(a.Justified, ' + SqlStr(R_Yes) + ', ' + SqlStr(R_No) + ') AS JustLabel' +
    ' FROM (((Absences a INNER JOIN Students s ON a.StudentID = s.StudentID)' +
    ' LEFT JOIN Classes c ON s.ClassID = c.ClassID)' +
    ' LEFT JOIN TimeSlots t ON a.SlotID = t.SlotID)' +
    ' LEFT JOIN Subjects sub ON a.SubjectID = sub.SubjectID' +
    W + ' ORDER BY a.AbsDate DESC, c.ClassName, s.LastName');

  lblCount.Caption := R_JusCount + IntToStr(dm.qAbsences.RecordCount);
end;

procedure TfrmJustify.btnApplyClick(Sender: TObject);
begin
  LoadData;
end;

{ ------------------------------------------------------------------------
  تطبيق التبرير على السطر الحالي أو على الأسطر المحددة
  ------------------------------------------------------------------------ }
procedure TfrmJustify.ApplyJustification(AJustified: Boolean;
  const AReason: string);
var
  I, N   : Integer;
  Ids    : TStringList;
  Bm     : TBookmark;
  JustSql, ReasonSql, DateSql : string;
begin
  if dm.qAbsences.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;

  Ids := TStringList.Create;
  try
    if grd.SelectedRows.Count > 0 then
    begin
      { عدة أسطر محددة : نمر على مجموعة البيانات ونختبر كل سطر }
      Bm := dm.qAbsences.GetBookmark;
      dm.qAbsences.DisableControls;
      try
        dm.qAbsences.First;
        while not dm.qAbsences.Eof do
        begin
          if grd.SelectedRows.CurrentRowSelected then
            Ids.Add(dm.qAbsences.FieldByName('AbsenceID').AsString);
          dm.qAbsences.Next;
        end;
        if Bm <> nil then
        begin
          dm.qAbsences.GotoBookmark(Bm);
          dm.qAbsences.FreeBookmark(Bm);
        end;
      finally
        dm.qAbsences.EnableControls;
      end;
    end
    else
      Ids.Add(dm.qAbsences.FieldByName('AbsenceID').AsString);

    JustSql := BoolSql(AJustified);
    if AJustified then
    begin
      ReasonSql := SqlStr(AReason);
      DateSql   := SqlDate(Date);
    end
    else
    begin
      ReasonSql := 'NULL';
      DateSql   := 'NULL';
    end;

    N := 0;
    for I := 0 to Ids.Count - 1 do
    begin
      dm.ExecSQL('UPDATE Absences SET Justified = ' + JustSql +
        ', JustifyReason = ' + ReasonSql +
        ', JustifyDate = '   + DateSql +
        ' WHERE AbsenceID = ' + Ids[I]);
      Inc(N);
    end;

    LoadData;
    ShowInfo(R_JusProcessed + IntToStr(N) + R_SuffixRecords);
  finally
    Ids.Free;
  end;
end;

procedure TfrmJustify.btnJustifyClick(Sender: TObject);
var
  Reason : string;
begin
  if dm.qAbsences.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  Reason := R_JusMedCert;
  if not InputQuery(R_JusMarkJust, R_JusReasonAsk, Reason) then Exit;
  ApplyJustification(True, Reason);
end;

procedure TfrmJustify.btnUnjustClick(Sender: TObject);
begin
  if not AskYesNo(R_JusConfirmUnjust) then Exit;
  ApplyJustification(False, '');
end;

{ ------------------------------------------------------------------------ }
procedure TfrmJustify.btnPrintClick(Sender: TObject);
var
  Rep : TReportBuilder;
  N   : Integer;
  Bm  : TBookmark;
begin
  if dm.qAbsences.IsEmpty then
  begin
    ShowInfo(R_RepNoData);
    Exit;
  end;

  Rep := TReportBuilder.Create('سجل الغيابات والتأخرات');
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               R_FromLbl + FormatDateTime('dd/mm/yyyy', dtFrom.Date) +
               R_ToLbl + FormatDateTime('dd/mm/yyyy', dtTo.Date) +
               '   -   ' + R_AbsClass + ' : ' + cbClass.Text);
    Rep.OpenTable([R_ColNum, R_AbsDate, R_AbsClass, R_StuLastName, R_StuFirstName,
                   R_AbsSlot, R_AbsSubject, R_AbsState, R_AbsJustified, R_AbsReason]);
    N  := 0;
    Bm := dm.qAbsences.GetBookmark;
    dm.qAbsences.DisableControls;
    try
      dm.qAbsences.First;
      while not dm.qAbsences.Eof do
      begin
        Inc(N);
        Rep.RowClass([IntToStr(N),
          FormatDateTime('dd/mm/yyyy', dm.qAbsences.FieldByName('AbsDate').AsDateTime),
          dm.qAbsences.FieldByName('ClassName').AsString,
          dm.qAbsences.FieldByName('LastName').AsString,
          dm.qAbsences.FieldByName('FirstName').AsString,
          dm.qAbsences.FieldByName('SlotLabel').AsString,
          dm.qAbsences.FieldByName('SubjectName').AsString,
          dm.qAbsences.FieldByName('KindLabel').AsString,
          dm.qAbsences.FieldByName('JustLabel').AsString,
          dm.qAbsences.FieldByName('JustifyReason').AsString],
          IfThenStr(dm.qAbsences.FieldByName('JustLabel').AsString = R_Yes,
                    'ok', 'warn'));
        dm.qAbsences.Next;
      end;
      if Bm <> nil then
      begin
        dm.qAbsences.GotoBookmark(Bm);
        dm.qAbsences.FreeBookmark(Bm);
      end;
    finally
      dm.qAbsences.EnableControls;
    end;
    Rep.CloseTable;
    Rep.Paragraph(R_TotalPrefix + '<b>' + IntToStr(N) + '</b>' + R_SuffixRecords);
    Rep.Signature('', R_SignAdvisor + dm.GetSetting('ADVISOR', ''));
    Rep.SaveAndOpen('Registre_Absences.html');
  finally
    Rep.Free;
  end;
end;

procedure TfrmJustify.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
