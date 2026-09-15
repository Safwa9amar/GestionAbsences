unit uNotices;

{ الإشعارات والاستدعاءات / Notifications et convocations

  يقترح البرنامج آليا الإشعارات حسب عتبات النظام الداخلي :
    - إشعار أول بالغياب   عند بلوغ العتبة 1
    - إشعار ثان بالغياب   عند بلوغ العتبة 2
    - إعذار بالشطب        عند بلوغ العتبة 3
  كما يمكن تحرير استدعاء الولي يدويا. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, DB;

type
  TfrmNotices = class(TForm)
    pnlTop      : TPanel;
    lblFKind    : TLabel;  cbFKind   : TComboBox;
    lblFClass   : TLabel;  cbFClass  : TComboBox;
    lblFFrom    : TLabel;  dtFFrom   : TDateTimePicker;
    lblFTo      : TLabel;  dtFTo     : TDateTimePicker;
    btnApply    : TButton;
    btnGenerate : TButton;
    grd         : TDBGrid;
    pnlEdit     : TPanel;
    lblClass    : TLabel;  cbClass   : TComboBox;
    lblStudent  : TLabel;  cbStudent : TComboBox;
    lblKind     : TLabel;  cbKind    : TComboBox;
    lblNo       : TLabel;  edNo      : TEdit;
    lblIssue    : TLabel;  dtIssue   : TDateTimePicker;
    lblMeet     : TLabel;  dtMeet    : TDateTimePicker;
    lblMeetTime : TLabel;  edMeetTime: TEdit;
    lblAbsCount : TLabel;  edAbsCount: TEdit;
    lblTopic    : TLabel;  edTopic   : TEdit;
    chkDelivered: TCheckBox;
    btnNew      : TButton;
    btnSave     : TButton;
    btnDelete   : TButton;
    btnPrintDoc : TButton;
    btnClose    : TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnApplyClick(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnPrintDocClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cbClassChange(Sender: TObject);
    procedure grdCellClick(Column: TColumn);
    procedure cbKindChange(Sender: TObject);
  private
    FNoticeID   : Integer;
    FFClassKeys : TStringList;
    FClassKeys  : TStringList;
    FStudKeys   : TStringList;
    procedure ApplyCaptions;
    procedure SetupGrid;
    procedure LoadStudents;
    procedure LoadData;
    procedure ClearFields;
    procedure LoadFields;
    function  KindCode(AIndex: Integer): string;
    function  KindIndex(const ACode: string): Integer;
    function  KindLabel(const ACode: string): string;
    function  DefaultTopic(const ACode: string): string;
  end;

procedure ShowNoticesForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain, uDB;

const
  KINDS : array[0..3] of string = ('N1', 'N2', 'RAD', 'SUM');

procedure ShowNoticesForm;
var
  F : TfrmNotices;
begin
  F := TfrmNotices.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

function TfrmNotices.KindCode(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex <= High(KINDS)) then
    Result := KINDS[AIndex]
  else
    Result := 'N1';
end;

function TfrmNotices.KindIndex(const ACode: string): Integer;
var
  I : Integer;
begin
  Result := 0;
  for I := Low(KINDS) to High(KINDS) do
    if SameText(KINDS[I], ACode) then
    begin
      Result := I;
      Exit;
    end;
end;

function TfrmNotices.KindLabel(const ACode: string): string;
begin
  if SameText(ACode, 'N1')  then Result := R_NotFirst
  else if SameText(ACode, 'N2')  then Result := R_NotSecond
  else if SameText(ACode, 'RAD') then Result := R_NotRadiation
  else Result := R_NotSummon;
end;

function TfrmNotices.DefaultTopic(const ACode: string): string;
begin
  if SameText(ACode, 'N1') then
    Result := 'إشعار أول بالغياب وتبرير أسباب عدم مزاولة الدراسة'
  else if SameText(ACode, 'N2') then
    Result := 'إشعار ثان بالغياب وتبرير أسباب عدم مزاولة الدراسة'
  else if SameText(ACode, 'RAD') then
    Result := 'إعذار بالشطب من قوائم المؤسسة لكثرة الغيابات غير المبررة'
  else
    Result := 'استدعاء ولي التلميذ للحضور إلى المؤسسة';
end;

{ ------------------------------------------------------------------------ }

procedure TfrmNotices.ApplyCaptions;
var
  I : Integer;
begin
  Caption             := R_NotTitle;
  lblFKind.Caption    := R_NotKind;
  lblFClass.Caption   := R_AbsClass;
  lblFFrom.Caption    := R_JusFrom;
  lblFTo.Caption      := R_JusTo;
  btnApply.Caption    := R_Refresh;
  btnGenerate.Caption := R_NotGenerate;

  lblClass.Caption    := R_AbsClass;
  lblStudent.Caption  := 'التلميذ';
  lblKind.Caption     := R_NotKind;
  lblNo.Caption       := R_NotNo;
  lblIssue.Caption    := R_NotIssueDate;
  lblMeet.Caption     := R_NotMeetDate;
  lblMeetTime.Caption := R_NotMeetTime;
  lblAbsCount.Caption := R_NotAbsCount;
  lblTopic.Caption    := R_NotTopic;
  chkDelivered.Caption:= R_NotDelivered;

  btnNew.Caption      := R_New;
  btnSave.Caption     := R_Save;
  btnDelete.Caption   := R_Delete;
  btnPrintDoc.Caption := R_NotPrintDoc;
  btnClose.Caption    := R_Close;

  cbKind.Items.Clear;
  cbFKind.Items.Clear;
  cbFKind.Items.Add(R_All);
  for I := Low(KINDS) to High(KINDS) do
  begin
    cbKind.Items.Add(KindLabel(KINDS[I]));
    cbFKind.Items.Add(KindLabel(KINDS[I]));
  end;
  cbKind.ItemIndex  := 0;
  cbFKind.ItemIndex := 0;
end;

procedure TfrmNotices.FormCreate(Sender: TObject);
begin
  FFClassKeys := TStringList.Create;
  FClassKeys  := TStringList.Create;
  FStudKeys   := TStringList.Create;
  FNoticeID   := 0;

  ApplyCaptions;
  dm.RefreshClasses;
  FillCombo(cbFClass.Items, dm.qClasses, 'ClassName', 'ClassID', FFClassKeys, R_All);
  FillCombo(cbClass.Items,  dm.qClasses, 'ClassName', 'ClassID', FClassKeys,  R_All);
  cbFClass.ItemIndex := 0;
  cbClass.ItemIndex  := 0;

  dtFFrom.Date := Date - 90;
  dtFTo.Date   := Date;

  SetupGrid;
  LoadStudents;
  LoadData;
  ClearFields;
  ApplyRTL(Self);
end;

procedure TfrmNotices.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FFClassKeys.Free;
  FClassKeys.Free;
  FStudKeys.Free;
end;

procedure TfrmNotices.SetupGrid;

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
  AddCol('NoticeNo',    R_NotNo,         90);
  AddCol('IssueDate',   R_NotIssueDate, 100);
  AddCol('KindLabel',   R_NotKind,      160);
  AddCol('ClassName',   R_AbsClass,      80);
  AddCol('LastName',    R_StuLastName,  130);
  AddCol('FirstName',   R_StuFirstName, 130);
  AddCol('AbsCount',    R_NotAbsCount,   80);
  AddCol('MeetDate',    R_NotMeetDate,  100);
  AddCol('DelivLabel',  R_NotDelivered,  80);
end;

procedure TfrmNotices.LoadStudents;
var
  Cid : Integer;
  W   : string;
begin
  Cid := 0;
  if (cbClass.ItemIndex > 0) and (cbClass.ItemIndex < FClassKeys.Count) then
    Cid := StrToIntDef(FClassKeys[cbClass.ItemIndex], 0);

  W := ' WHERE s.IsActive = True';
  if Cid > 0 then
    W := W + ' AND s.ClassID = ' + IntToStr(Cid);

  dm.OpenQ(dm.qWork,
    'SELECT s.StudentID, s.LastName & '' '' & s.FirstName & '' ('' &' +
    ' IIF(IsNull(c.ClassName), ''-'', c.ClassName) & '')'' AS StudName' +
    ' FROM Students s LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
    W + ' ORDER BY s.LastName, s.FirstName');

  FillCombo(cbStudent.Items, dm.qWork, 'StudName', 'StudentID', FStudKeys, R_None);
  dm.qWork.Close;
  cbStudent.ItemIndex := 0;
end;

procedure TfrmNotices.cbClassChange(Sender: TObject);
begin
  LoadStudents;
end;

procedure TfrmNotices.cbKindChange(Sender: TObject);
begin
  if Trim(edTopic.Text) = '' then
    edTopic.Text := DefaultTopic(KindCode(cbKind.ItemIndex));
end;

procedure TfrmNotices.LoadData;
var
  W : string;
  Cid : Integer;
begin
  W := ' WHERE n.IssueDate BETWEEN ' + SqlDate(dtFFrom.Date) +
       ' AND ' + SqlDate(dtFTo.Date);

  if cbFKind.ItemIndex > 0 then
    W := W + ' AND n.NoticeKind = ' + SqlStr(KindCode(cbFKind.ItemIndex - 1));

  Cid := 0;
  if (cbFClass.ItemIndex > 0) and (cbFClass.ItemIndex < FFClassKeys.Count) then
    Cid := StrToIntDef(FFClassKeys[cbFClass.ItemIndex], 0);
  if Cid > 0 then
    W := W + ' AND s.ClassID = ' + IntToStr(Cid);

  dm.OpenQ(dm.qNotices,
    'SELECT n.NoticeID, n.NoticeNo, n.IssueDate, n.NoticeKind, n.MeetDate,' +
    ' n.MeetTime, n.NoticeTopic, n.AbsCount, n.Delivered, n.StudentID,' +
    ' s.LastName, s.FirstName, s.ClassID, c.ClassName,' +
    ' IIF(n.NoticeKind = ''N1'', ' + SqlStr(R_NotFirst) +
    ', IIF(n.NoticeKind = ''N2'', ' + SqlStr(R_NotSecond) +
    ', IIF(n.NoticeKind = ''RAD'', ' + SqlStr(R_NotRadiation) +
    ', ' + SqlStr(R_NotSummon) + '))) AS KindLabel,' +
    ' IIF(n.Delivered, ' + SqlStr(R_Yes) + ', ' + SqlStr(R_No) + ') AS DelivLabel' +
    ' FROM (Notices n INNER JOIN Students s ON n.StudentID = s.StudentID)' +
    ' LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
    W + ' ORDER BY n.IssueDate DESC, n.NoticeID DESC');
end;

procedure TfrmNotices.btnApplyClick(Sender: TObject);
begin
  LoadData;
end;

{ ------------------------------------------------------------------------
  الاقتراح الآلي للإشعارات حسب العتبات
  ------------------------------------------------------------------------ }
procedure TfrmNotices.btnGenerateClick(Sender: TObject);
var
  T1, T2, T3, Nb, Sid, Created : Integer;
  Kind : string;
  DFrom, DTo : TDateTime;
  Q : TDataSet;
begin
  T1 := dm.GetSettingInt('THRESHOLD_1', DEF_THRESHOLD_1);
  T2 := dm.GetSettingInt('THRESHOLD_2', DEF_THRESHOLD_2);
  T3 := dm.GetSettingInt('THRESHOLD_3', DEF_THRESHOLD_3);

  DFrom := dtFFrom.Date;
  DTo   := dtFTo.Date;
  Created := 0;

  Q := dm.OpenQ(dm.qRep,
    'SELECT StudentID FROM Students WHERE IsActive = True ORDER BY StudentID');

  try
    while not Q.Eof do
    begin
      Sid := Q.FieldByName('StudentID').AsInteger;
      Nb  := dm.CountUnjustified(Sid, DFrom, DTo);

      Kind := '';
      if Nb >= T3 then Kind := 'RAD'
      else if Nb >= T2 then Kind := 'N2'
      else if Nb >= T1 then Kind := 'N1';

      if Kind <> '' then
      begin
        { لا يعاد إنشاء نفس النوع إذا كان موجودا في نفس الفترة }
        if dm.ScalarInt('SELECT COUNT(*) FROM Notices WHERE StudentID = ' +
             IntToStr(Sid) + ' AND NoticeKind = ' + SqlStr(Kind) +
             ' AND IssueDate BETWEEN ' + SqlDate(DFrom) + ' AND ' +
             SqlDate(DTo), 0) = 0 then
        begin
          dm.ExecSQL(
            'INSERT INTO Notices (StudentID, NoticeKind, NoticeNo, IssueDate,' +
            ' MeetDate, MeetTime, NoticeTopic, AbsCount, IssuedBy, Delivered)' +
            ' VALUES (' + IntToStr(Sid) + ', ' + SqlStr(Kind) + ', ' +
            SqlStr(dm.NextNoticeNumber) + ', ' + SqlDate(Date) + ', ' +
            SqlDate(Date + 3) + ', ' + SqlStr('10:00') + ', ' +
            SqlStr(DefaultTopic(Kind)) + ', ' + IntToStr(Nb) + ', ' +
            IntToStr(dm.CurrentUserID) + ', False)');
          Inc(Created);
        end;
      end;
      Q.Next;
    end;
  finally
    dm.qRep.Close;
  end;

  LoadData;
  if Created > 0 then
    ShowInfo(Format(R_NotGenDone, [Created]))
  else
    ShowInfo(R_NotGenNone);
end;

{ ------------------------------------------------------------------------ }
procedure TfrmNotices.ClearFields;
begin
  FNoticeID := 0;
  cbStudent.ItemIndex := 0;
  cbKind.ItemIndex    := 0;
  edNo.Text           := dm.NextNoticeNumber;
  dtIssue.Date        := Date;
  dtMeet.Date         := Date + 3;
  edMeetTime.Text     := '10:00';
  edAbsCount.Text     := '0';
  edTopic.Text        := DefaultTopic('N1');
  chkDelivered.Checked:= False;
end;

procedure TfrmNotices.LoadFields;
var
  I : Integer;
begin
  if dm.qNotices.IsEmpty then
  begin
    ClearFields;
    Exit;
  end;

  FNoticeID := dm.qNotices.FieldByName('NoticeID').AsInteger;

  { ضبط القسم ثم التلميذ }
  I := FClassKeys.IndexOf(dm.qNotices.FieldByName('ClassID').AsString);
  if I >= 0 then cbClass.ItemIndex := I else cbClass.ItemIndex := 0;
  LoadStudents;

  I := FStudKeys.IndexOf(dm.qNotices.FieldByName('StudentID').AsString);
  if I >= 0 then cbStudent.ItemIndex := I else cbStudent.ItemIndex := 0;

  cbKind.ItemIndex := KindIndex(dm.qNotices.FieldByName('NoticeKind').AsString);
  edNo.Text        := dm.qNotices.FieldByName('NoticeNo').AsString;
  dtIssue.Date     := dm.qNotices.FieldByName('IssueDate').AsDateTime;
  if not dm.qNotices.FieldByName('MeetDate').IsNull then
    dtMeet.Date    := dm.qNotices.FieldByName('MeetDate').AsDateTime;
  edMeetTime.Text  := dm.qNotices.FieldByName('MeetTime').AsString;
  edAbsCount.Text  := dm.qNotices.FieldByName('AbsCount').AsString;
  edTopic.Text     := dm.qNotices.FieldByName('NoticeTopic').AsString;
  chkDelivered.Checked := dm.qNotices.FieldByName('Delivered').AsBoolean;
end;

procedure TfrmNotices.grdCellClick(Column: TColumn);
begin
  LoadFields;
end;

procedure TfrmNotices.btnNewClick(Sender: TObject);
begin
  ClearFields;
  cbClass.SetFocus;
end;

procedure TfrmNotices.btnSaveClick(Sender: TObject);
var
  Sid : Integer;
begin
  Sid := 0;
  if (cbStudent.ItemIndex > 0) and (cbStudent.ItemIndex < FStudKeys.Count) then
    Sid := StrToIntDef(FStudKeys[cbStudent.ItemIndex], 0);

  if Sid = 0 then
  begin
    ShowError('يرجى اختيار التلميذ.');
    Exit;
  end;

  try
    if FNoticeID = 0 then
      dm.ExecSQL(
        'INSERT INTO Notices (StudentID, NoticeKind, NoticeNo, IssueDate,' +
        ' MeetDate, MeetTime, NoticeTopic, AbsCount, IssuedBy, Delivered)' +
        ' VALUES (' + IntToStr(Sid) + ', ' +
        SqlStr(KindCode(cbKind.ItemIndex)) + ', ' + SqlStr(Trim(edNo.Text)) +
        ', ' + SqlDate(dtIssue.Date) + ', ' + SqlDate(dtMeet.Date) + ', ' +
        SqlStr(Trim(edMeetTime.Text)) + ', ' + SqlStr(Trim(edTopic.Text)) +
        ', ' + IntToStr(StrToIntDef(edAbsCount.Text, 0)) + ', ' +
        IntToStr(dm.CurrentUserID) + ', ' + BoolSql(chkDelivered.Checked) + ')')
    else
      dm.ExecSQL(
        'UPDATE Notices SET StudentID = ' + IntToStr(Sid) +
        ', NoticeKind = '  + SqlStr(KindCode(cbKind.ItemIndex)) +
        ', NoticeNo = '    + SqlStr(Trim(edNo.Text)) +
        ', IssueDate = '   + SqlDate(dtIssue.Date) +
        ', MeetDate = '    + SqlDate(dtMeet.Date) +
        ', MeetTime = '    + SqlStr(Trim(edMeetTime.Text)) +
        ', NoticeTopic = ' + SqlStr(Trim(edTopic.Text)) +
        ', AbsCount = '    + IntToStr(StrToIntDef(edAbsCount.Text, 0)) +
        ', Delivered = '   + BoolSql(chkDelivered.Checked) +
        ' WHERE NoticeID = ' + IntToStr(FNoticeID));

    LoadData;
    ShowInfo(R_MsgSaved);
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmNotices.btnDeleteClick(Sender: TObject);
begin
  if dm.qNotices.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  if not AskYesNo(R_MsgConfirmDel) then Exit;
  dm.ExecSQL('DELETE FROM Notices WHERE NoticeID = ' +
             dm.qNotices.FieldByName('NoticeID').AsString);
  LoadData;
  ClearFields;
  ShowInfo(R_MsgDeleted);
end;

{ ------------------------------------------------------------------------
  طباعة الوثيقة الرسمية
  ------------------------------------------------------------------------ }
procedure TfrmNotices.btnPrintDocClick(Sender: TObject);
var
  Rep  : TReportBuilder;
  Kind, StudName, ClassName, Guardian, Addr : string;
  Nb   : Integer;
  Q    : TDataSet;
begin
  if dm.qNotices.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;

  Kind      := dm.qNotices.FieldByName('NoticeKind').AsString;
  StudName  := dm.qNotices.FieldByName('LastName').AsString + ' ' +
               dm.qNotices.FieldByName('FirstName').AsString;
  ClassName := dm.qNotices.FieldByName('ClassName').AsString;
  Nb        := dm.qNotices.FieldByName('AbsCount').AsInteger;

  Q := dm.OpenQ(dm.qWork,
    'SELECT GuardianName, GuardianAddr FROM Students WHERE StudentID = ' +
    dm.qNotices.FieldByName('StudentID').AsString);
  Guardian := '';
  Addr     := '';
  if not Q.IsEmpty then
  begin
    Guardian := Q.FieldByName('GuardianName').AsString;
    Addr     := Q.FieldByName('GuardianAddr').AsString;
  end;
  dm.qWork.Close;

  Rep := TReportBuilder.Create(KindLabel(Kind));
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               'السنة الدراسية : ' + dm.CurrentYearLabel);

    Rep.OpenTable(['البيان', 'القيمة']);
    Rep.Row([R_NotNo,        dm.qNotices.FieldByName('NoticeNo').AsString]);
    Rep.Row([R_NotIssueDate, FormatDateTime('dd/mm/yyyy',
                             dm.qNotices.FieldByName('IssueDate').AsDateTime)]);
    Rep.Row(['المرسل',       'مدير المؤسسة : ' + dm.GetSetting('DIRECTOR', '')]);
    Rep.Row(['المرسل إليه',  'ولي التلميذ : ' + Guardian]);
    Rep.Row(['العنوان',      Addr]);
    Rep.Row(['اسم ولقب التلميذ', StudName]);
    Rep.Row([R_StuClass,     ClassName]);
    Rep.Row([R_NotTopic,     dm.qNotices.FieldByName('NoticeTopic').AsString]);
    Rep.CloseTable;

    if SameText(Kind, 'RAD') then
      Rep.Paragraph(
        'يشرفني أن أحيطكم علما أن ابنكم <b>' + HtmlEscape(StudName) +
        '</b> المسجل بقسم <b>' + HtmlEscape(ClassName) + '</b> قد تغيب عن الدراسة ' +
        '<b>' + IntToStr(Nb) + '</b> مرة دون تبرير مقبول، ورغم الإشعارات السابقة ' +
        'لم يلتحق بمقعده الدراسي.<br>وعليه فإنني أعذركم بأنه سيتم شطب اسمه من ' +
        'قوائم المؤسسة ابتداء من تاريخ <b>' +
        FormatDateTime('dd/mm/yyyy', dm.qNotices.FieldByName('MeetDate').AsDateTime) +
        '</b> ما لم تلتحقوا بالمؤسسة لتسوية وضعيته.')
    else if SameText(Kind, 'SUM') then
      Rep.Paragraph(
        'يشرفني أن أستدعيكم للحضور إلى مقر المؤسسة يوم <b>' +
        HtmlEscape(FormatArabicDate(dm.qNotices.FieldByName('MeetDate').AsDateTime)) +
        '</b> على الساعة <b>' +
        HtmlEscape(dm.qNotices.FieldByName('MeetTime').AsString) +
        '</b>، وذلك لمقابلة مستشار التربية بخصوص ابنكم <b>' +
        HtmlEscape(StudName) + '</b> المسجل بقسم <b>' + HtmlEscape(ClassName) +
        '</b>.<br>' + HtmlEscape(dm.qNotices.FieldByName('NoticeTopic').AsString))
    else
      Rep.Paragraph(
        'يشرفني أن أحيطكم علما أن ابنكم <b>' + HtmlEscape(StudName) +
        '</b> المسجل بقسم <b>' + HtmlEscape(ClassName) +
        '</b> قد سجلت عليه <b>' + IntToStr(Nb) +
        '</b> حالة غياب غير مبررة.<br>' +
        'لذا يرجى منكم الحضور إلى المؤسسة يوم <b>' +
        HtmlEscape(FormatArabicDate(dm.qNotices.FieldByName('MeetDate').AsDateTime)) +
        '</b> على الساعة <b>' +
        HtmlEscape(dm.qNotices.FieldByName('MeetTime').AsString) +
        '</b> لتبرير أسباب الغياب وعدم مزاولة الدراسة.<br>' +
        'وفي حالة عدم الاستجابة ستتخذ الإجراءات المنصوص عليها في النظام ' +
        'الداخلي للمؤسسة.');

    Rep.Paragraph('&nbsp;');
    Rep.Signature('مدير المؤسسة' + #13#10 + dm.GetSetting('DIRECTOR', ''),
                  dm.GetSetting('ADDRESS', '') + ' في : ' +
                  FormatDateTime('dd/mm/yyyy', Date));
    Rep.SaveAndOpen('Notice_' + Kind + '.html');
  finally
    Rep.Free;
  end;
end;

procedure TfrmNotices.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
