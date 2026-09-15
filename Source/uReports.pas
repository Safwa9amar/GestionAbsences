unit uReports;

{ التقارير والإحصائيات / Etats et statistiques }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, DB;

type
  TfrmReports = class(TForm)
    pnlTop     : TPanel;
    lblType    : TLabel;  cbType   : TComboBox;
    lblFrom    : TLabel;  dtFrom   : TDateTimePicker;
    lblTo      : TLabel;  dtTo     : TDateTimePicker;
    lblClass   : TLabel;  cbClass  : TComboBox;
    lblTop     : TLabel;  edTop    : TEdit;
    btnPreview : TButton;
    btnPrint   : TButton;
    grd        : TDBGrid;
    dsRep      : TDataSource;
    pnlBottom  : TPanel;
    lblInfo    : TLabel;
    btnClose   : TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
  private
    FClassKeys : TStringList;
    procedure ApplyCaptions;
    function  SelClassID: Integer;
    function  BuildSql: string;
    procedure SetupGridFor(AType: Integer);
    procedure PrintDataset(const ATitle: string;
                           const ACols, AFields: array of string;
                           const AFileName: string);
    procedure PrintAttendanceRate;
  public
    procedure SelectType(AType: Integer);
  end;

procedure ShowReportsForm(ATab: Integer);

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

const
  RT_DAILY    = 0;
  RT_REGISTER = 1;
  RT_BYCLASS  = 2;
  RT_TOPABS   = 3;
  RT_RATE     = 4;

procedure ShowReportsForm(ATab: Integer);
var
  F : TfrmReports;
begin
  F := TfrmReports.Create(nil);
  try
    F.SelectType(ATab);
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmReports.ApplyCaptions;
begin
  Caption          := R_RepTitle;
  lblType.Caption  := R_RepType;
  lblFrom.Caption  := R_JusFrom;
  lblTo.Caption    := R_JusTo;
  lblClass.Caption := R_AbsClass;
  lblTop.Caption   := R_RepRows;
  btnPreview.Caption := R_RepPreview;
  btnPrint.Caption   := R_Print;
  btnClose.Caption   := R_Close;

  cbType.Items.Clear;
  cbType.Items.Add(R_RepDaily);
  cbType.Items.Add(R_RepRegister);
  cbType.Items.Add(R_RepByClass);
  cbType.Items.Add(R_RepTopAbsent);
  cbType.Items.Add(R_RepAttendRate);
  cbType.ItemIndex := 0;
end;

procedure TfrmReports.FormCreate(Sender: TObject);
begin
  FClassKeys := TStringList.Create;
  ApplyCaptions;

  dm.RefreshClasses;
  FillCombo(cbClass.Items, dm.qClasses, 'ClassName', 'ClassID', FClassKeys, R_All);
  cbClass.ItemIndex := 0;

  dtFrom.Date := Date - 30;
  dtTo.Date   := Date;
  edTop.Text  := '20';

  dsRep.DataSet := dm.qRep;
  cbTypeChange(nil);
  ApplyRTL(Self);
end;

procedure TfrmReports.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dm.qRep.Close;
  FClassKeys.Free;
end;

procedure TfrmReports.SelectType(AType: Integer);
begin
  if (AType >= 0) and (AType < cbType.Items.Count) then
    cbType.ItemIndex := AType;
  cbTypeChange(nil);
end;

procedure TfrmReports.cbTypeChange(Sender: TObject);
var
  T : Integer;
begin
  T := cbType.ItemIndex;
  lblTo.Visible   := T <> RT_DAILY;
  dtTo.Visible    := T <> RT_DAILY;
  lblTop.Visible  := T = RT_TOPABS;
  edTop.Visible   := T = RT_TOPABS;

  if T = RT_DAILY then
    lblFrom.Caption := R_AbsDate
  else
    lblFrom.Caption := R_JusFrom;

  case T of
    RT_DAILY : lblInfo.Caption := R_RepHintDaily;
    RT_REGISTER : lblInfo.Caption := R_RepHintReg;
    RT_BYCLASS  : lblInfo.Caption := R_RepHintClass;
    RT_TOPABS   : lblInfo.Caption := R_RepHintTop;
    RT_RATE     : lblInfo.Caption :=
      R_RepHintRate;
  end;

  dm.qRep.Close;
  grd.Columns.Clear;
end;

function TfrmReports.SelClassID: Integer;
begin
  Result := 0;
  if (cbClass.ItemIndex > 0) and (cbClass.ItemIndex < FClassKeys.Count) then
    Result := StrToIntDef(FClassKeys[cbClass.ItemIndex], 0);
end;

{ ------------------------------------------------------------------------
  بناء استعلام التقرير
  ------------------------------------------------------------------------ }
function TfrmReports.BuildSql: string;
var
  W, D1, D2 : string;
  N : Integer;
begin
  D1 := SqlDate(dtFrom.Date);
  if cbType.ItemIndex = RT_DAILY then
    D2 := D1
  else
    D2 := SqlDate(dtTo.Date);

  W := ' WHERE a.AbsDate BETWEEN ' + D1 + ' AND ' + D2;
  if SelClassID > 0 then
    W := W + ' AND s.ClassID = ' + IntToStr(SelClassID);

  case cbType.ItemIndex of

    RT_DAILY, RT_REGISTER :
      Result :=
        'SELECT a.AbsDate, c.ClassName, s.LastName, s.FirstName, t.SlotLabel,' +
        ' sub.SubjectName, a.LateMinutes, a.JustifyReason,' +
        ' IIF(a.AbsKind = ''LATE'', ' + SqlStr(R_AbsLate) + ', ' +
            SqlStr(R_AbsAbsent) + ') AS KindLabel,' +
        ' IIF(a.Justified, ' + SqlStr(R_Yes) + ', ' + SqlStr(R_No) +
            ') AS JustLabel' +
        ' FROM (((Absences a INNER JOIN Students s ON a.StudentID = s.StudentID)' +
        ' LEFT JOIN Classes c ON s.ClassID = c.ClassID)' +
        ' LEFT JOIN TimeSlots t ON a.SlotID = t.SlotID)' +
        ' LEFT JOIN Subjects sub ON a.SubjectID = sub.SubjectID' +
        W + ' ORDER BY a.AbsDate, c.ClassName, s.LastName';

    RT_BYCLASS :
      Result :=
        'SELECT c.ClassName,' +
        ' COUNT(*) AS NbTotal,' +
        ' SUM(IIF(a.AbsKind = ''ABS'', 1, 0)) AS NbAbs,' +
        ' SUM(IIF(a.AbsKind = ''LATE'', 1, 0)) AS NbLate,' +
        ' SUM(IIF(a.Justified, 1, 0)) AS NbJust,' +
        ' SUM(IIF(a.Justified, 0, 1)) AS NbUnjust' +
        ' FROM (Absences a INNER JOIN Students s ON a.StudentID = s.StudentID)' +
        ' LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
        W + ' GROUP BY c.ClassName ORDER BY COUNT(*) DESC';

    RT_TOPABS :
      begin
        N := StrToIntDef(edTop.Text, 20);
        if N < 1 then N := 20;
        Result :=
          'SELECT TOP ' + IntToStr(N) + ' c.ClassName, s.LastName, s.FirstName,' +
          ' COUNT(*) AS NbTotal,' +
          ' SUM(IIF(a.Justified, 1, 0)) AS NbJust,' +
          ' SUM(IIF(a.Justified, 0, 1)) AS NbUnjust' +
          ' FROM (Absences a INNER JOIN Students s ON a.StudentID = s.StudentID)' +
          ' LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
          W + ' AND a.AbsKind = ''ABS''' +
          ' GROUP BY c.ClassName, s.LastName, s.FirstName' +
          ' ORDER BY COUNT(*) DESC';
      end;
  else
    Result := '';
  end;
end;

procedure TfrmReports.SetupGridFor(AType: Integer);

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
  case AType of
    RT_DAILY, RT_REGISTER :
      begin
        AddCol('AbsDate',      R_AbsDate,      100);
        AddCol('ClassName',    R_AbsClass,      80);
        AddCol('LastName',     R_StuLastName,  140);
        AddCol('FirstName',    R_StuFirstName, 140);
        AddCol('SlotLabel',    R_AbsSlot,      130);
        AddCol('SubjectName',  R_AbsSubject,   150);
        AddCol('KindLabel',    R_AbsState,      80);
        AddCol('JustLabel',    R_AbsJustified,  70);
        AddCol('JustifyReason',R_AbsReason,    200);
      end;
    RT_BYCLASS :
      begin
        AddCol('ClassName', R_AbsClass,        120);
        AddCol('NbTotal',   R_ColTotal,         110);
        AddCol('NbAbs',     R_AbsAbsent,       110);
        AddCol('NbLate',    R_AbsLate,         110);
        AddCol('NbJust',    R_ColJust,           110);
        AddCol('NbUnjust',  R_ColUnjust,       110);
      end;
    RT_TOPABS :
      begin
        AddCol('ClassName', R_AbsClass,        100);
        AddCol('LastName',  R_StuLastName,     160);
        AddCol('FirstName', R_StuFirstName,    160);
        AddCol('NbTotal',   R_ColTotalAbs,  140);
        AddCol('NbJust',    R_ColJust,           110);
        AddCol('NbUnjust',  R_ColUnjust,       110);
      end;
  end;
end;

procedure TfrmReports.btnPreviewClick(Sender: TObject);
var
  Sql : string;
begin
  if cbType.ItemIndex = RT_RATE then
  begin
    ShowInfo(R_RepPrintOnly);
    Exit;
  end;

  Sql := BuildSql;
  if Sql = '' then Exit;

  try
    dm.OpenQ(dm.qRep, Sql);
    SetupGridFor(cbType.ItemIndex);
    lblInfo.Caption := R_RepRowCount + IntToStr(dm.qRep.RecordCount);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

{ ------------------------------------------------------------------------
  الطباعة
  ------------------------------------------------------------------------ }
procedure TfrmReports.PrintDataset(const ATitle: string;
  const ACols, AFields: array of string; const AFileName: string);
var
  Rep  : TReportBuilder;
  Vals : array of string;
  I, N : Integer;
  F    : TField;
begin
  if dm.qRep.IsEmpty then
  begin
    ShowInfo(R_RepNoData);
    Exit;
  end;

  Rep := TReportBuilder.Create(ATitle);
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               IfThenStr(cbType.ItemIndex = RT_DAILY,
                 FormatLongDate(dtFrom.Date),
                 R_FromLbl + FormatDateTime('dd/mm/yyyy', dtFrom.Date) +
                 R_ToLbl + FormatDateTime('dd/mm/yyyy', dtTo.Date)) +
               '   -   ' + R_AbsClass + ' : ' + cbClass.Text);

    SetLength(Vals, Length(AFields) + 1);
    Rep.OpenTable(ACols);

    N := 0;
    dm.qRep.DisableControls;
    try
      dm.qRep.First;
      while not dm.qRep.Eof do
      begin
        Inc(N);
        Vals[0] := IntToStr(N);
        for I := Low(AFields) to High(AFields) do
        begin
          F := dm.qRep.FindField(AFields[I]);
          if F = nil then
            Vals[I + 1] := ''
          else if F.DataType in [ftDate, ftDateTime] then
            Vals[I + 1] := FormatDateTime('dd/mm/yyyy', F.AsDateTime)
          else
            Vals[I + 1] := F.AsString;
        end;
        Rep.Row(Vals);
        dm.qRep.Next;
      end;
      dm.qRep.First;
    finally
      dm.qRep.EnableControls;
    end;

    Rep.CloseTable;
    Rep.Paragraph(R_RepRowCount + '<b>' + IntToStr(N) + '</b>');
    Rep.Signature('', R_SignAdvisor + dm.GetSetting('ADVISOR', ''));
    Rep.SaveAndOpen(AFileName);
  finally
    Rep.Free;
  end;
end;

{ --- نسبة الحضور والغياب حسب القسم --------------------------------------- }
procedure TfrmReports.PrintAttendanceRate;
var
  Rep      : TReportBuilder;
  Q        : TDataSet;
  D        : TDateTime;
  NbDays, NbSlots, NbStud, NbAbs, Poss : Integer;
  RateAbs, RatePres : Double;
  Cls      : string;
  TotPoss, TotAbs : Integer;
begin
  { عدد أيام العمل بين التاريخين (باستثناء الجمعة والسبت) }
  NbDays := 0;
  D := dtFrom.Date;
  while D <= dtTo.Date do
  begin
    if not (DayOfWeek(D) in [6, 7]) then   { 6 = الجمعة، 7 = السبت }
      Inc(NbDays);
    D := D + 1;
  end;
  if NbDays = 0 then NbDays := 1;

  NbSlots := dm.ScalarInt('SELECT COUNT(*) FROM TimeSlots', 1);
  if NbSlots = 0 then NbSlots := 1;

  Q := dm.OpenQ(dm.qRep,
    'SELECT c.ClassID, c.ClassName, COUNT(s.StudentID) AS NbStud' +
    ' FROM Classes c LEFT JOIN Students s' +
    ' ON (c.ClassID = s.ClassID AND s.IsActive = True)' +
    ' GROUP BY c.ClassID, c.ClassName ORDER BY c.ClassName');

  if Q.IsEmpty then
  begin
    dm.qRep.Close;
    ShowInfo(R_RepNoData);
    Exit;
  end;

  TotPoss := 0;
  TotAbs  := 0;

  Rep := TReportBuilder.Create(R_RepRateTitle);
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               R_FromLbl + FormatDateTime('dd/mm/yyyy', dtFrom.Date) +
               R_ToLbl + FormatDateTime('dd/mm/yyyy', dtTo.Date) +
               R_RepWorkDays + IntToStr(NbDays) +
               R_RepSlotsPerDay + IntToStr(NbSlots));

    Rep.OpenTable([R_ColNum, R_AbsClass, R_ColNbStudents, R_ColPossible,
                   R_ColAbsHours, R_ColRateAbs, R_ColRatePres]);

    NbStud := 0;
    while not Q.Eof do
    begin
      Cls    := Q.FieldByName('ClassName').AsString;
      NbStud := Q.FieldByName('NbStud').AsInteger;
      Poss   := NbStud * NbDays * NbSlots;

      NbAbs := dm.ScalarInt(
        'SELECT COUNT(*) FROM Absences a INNER JOIN Students s' +
        ' ON a.StudentID = s.StudentID' +
        ' WHERE s.ClassID = ' + Q.FieldByName('ClassID').AsString +
        ' AND a.AbsKind = ''ABS''' +
        ' AND a.AbsDate BETWEEN ' + SqlDate(dtFrom.Date) +
        ' AND ' + SqlDate(dtTo.Date), 0);

      if Poss > 0 then
        RateAbs := (NbAbs / Poss) * 100
      else
        RateAbs := 0;
      RatePres := 100 - RateAbs;

      Inc(TotPoss, Poss);
      Inc(TotAbs,  NbAbs);

      Rep.RowClass([IntToStr(Q.RecNo), Cls, IntToStr(NbStud), IntToStr(Poss),
                    IntToStr(NbAbs),
                    FormatFloat('0.00', RateAbs),
                    FormatFloat('0.00', RatePres)],
                   IfThenStr(RateAbs > 10, 'warn', 'ok'));
      Q.Next;
    end;
    Rep.CloseTable;

    if TotPoss > 0 then
      RateAbs := (TotAbs / TotPoss) * 100
    else
      RateAbs := 0;

    Rep.Paragraph(R_RepGlobalAbs + '<b>' +
                  FormatFloat('0.00', RateAbs) + ' %</b>' +
                  R_RepGlobalPres + '<b>' +
                  FormatFloat('0.00', 100 - RateAbs) + ' %</b>');
    Rep.Signature(R_SignDirector + #13#10 + dm.GetSetting('DIRECTOR', ''),
                  R_SignAdvisor + dm.GetSetting('ADVISOR', ''));
    Rep.SaveAndOpen('Taux_Presence.html');
  finally
    Rep.Free;
    dm.qRep.Close;
  end;
end;

procedure TfrmReports.btnPrintClick(Sender: TObject);
begin
  case cbType.ItemIndex of
    RT_DAILY :
      begin
        btnPreviewClick(nil);
        PrintDataset(R_RepDaily,
          [R_ColNum, R_AbsClass, R_StuLastName, R_StuFirstName, R_AbsSlot,
           R_AbsSubject, R_AbsState, R_AbsJustified, R_AbsReason],
          ['ClassName', 'LastName', 'FirstName', 'SlotLabel', 'SubjectName',
           'KindLabel', 'JustLabel', 'JustifyReason'],
          'Etat_Journalier.html');
      end;
    RT_REGISTER :
      begin
        btnPreviewClick(nil);
        PrintDataset(R_RepRegister,
          [R_ColNum, R_AbsDate, R_AbsClass, R_StuLastName, R_StuFirstName,
           R_AbsSlot, R_AbsState, R_AbsJustified, R_AbsReason],
          ['AbsDate', 'ClassName', 'LastName', 'FirstName', 'SlotLabel',
           'KindLabel', 'JustLabel', 'JustifyReason'],
          'Registre.html');
      end;
    RT_BYCLASS :
      begin
        btnPreviewClick(nil);
        PrintDataset(R_RepByClass,
          [R_ColNum, R_AbsClass, R_ColTotal, R_AbsAbsent, R_AbsLate,
           R_ColJust, R_ColUnjust],
          ['ClassName', 'NbTotal', 'NbAbs', 'NbLate', 'NbJust', 'NbUnjust'],
          'Synthese_Classes.html');
      end;
    RT_TOPABS :
      begin
        btnPreviewClick(nil);
        PrintDataset(R_RepTopAbsent,
          [R_ColNum, R_AbsClass, R_StuLastName, R_StuFirstName,
           R_ColTotalAbs, R_ColJust, R_ColUnjust],
          ['ClassName', 'LastName', 'FirstName', 'NbTotal', 'NbJust', 'NbUnjust'],
          'Top_Absents.html');
      end;
    RT_RATE :
      PrintAttendanceRate;
  end;
end;

procedure TfrmReports.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
