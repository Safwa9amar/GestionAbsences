unit uDocs;

{ الوثائق : ورقة الدخول والشهادة المدرسية
  Documents : billet d'entree et certificat de scolarite }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Grids, DBGrids, DB, ADODB;

type
  TfrmDocs = class(TForm)
    pc          : TPageControl;
    tabPermit   : TTabSheet;
    tabCert     : TTabSheet;
    { --- ورقة الدخول --- }
    grdPermit   : TDBGrid;
    pnlPermit   : TPanel;
    lblPClass   : TLabel;  cbPClass   : TComboBox;
    lblPStudent : TLabel;  cbPStudent : TComboBox;
    lblPDate    : TLabel;  dtPDate    : TDateTimePicker;
    lblPTime    : TLabel;  edPTime    : TEdit;
    lblPReason  : TLabel;  edPReason  : TEdit;
    btnPNew     : TButton;
    btnPSave    : TButton;
    btnPDel     : TButton;
    btnPPrint   : TButton;
    { --- الشهادة المدرسية --- }
    grdCert     : TDBGrid;
    pnlCert     : TPanel;
    lblCClass   : TLabel;  cbCClass   : TComboBox;
    lblCStudent : TLabel;  cbCStudent : TComboBox;
    lblCNo      : TLabel;  edCNo      : TEdit;
    lblCDate    : TLabel;  dtCDate    : TDateTimePicker;
    lblCPurpose : TLabel;  edCPurpose : TEdit;
    lblCCopies  : TLabel;  edCCopies  : TEdit;
    btnCNew     : TButton;
    btnCSave    : TButton;
    btnCDel     : TButton;
    btnCPrint   : TButton;
    pnlBottom   : TPanel;
    btnClose    : TButton;
    dsPermit    : TDataSource;
    dsCert      : TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure cbPClassChange(Sender: TObject);
    procedure cbCClassChange(Sender: TObject);
    procedure btnPNewClick(Sender: TObject);
    procedure btnPSaveClick(Sender: TObject);
    procedure btnPDelClick(Sender: TObject);
    procedure btnPPrintClick(Sender: TObject);
    procedure btnCNewClick(Sender: TObject);
    procedure btnCSaveClick(Sender: TObject);
    procedure btnCDelClick(Sender: TObject);
    procedure btnCPrintClick(Sender: TObject);
    procedure grdPermitCellClick(Column: TColumn);
    procedure grdCertCellClick(Column: TColumn);
  private
    FPermitID : Integer;
    FCertID   : Integer;
    FPClsKeys, FPStuKeys : TStringList;
    FCClsKeys, FCStuKeys : TStringList;
    FqPermit, FqCert : TADOQuery;
    procedure ApplyCaptions;
    procedure SetupGrids;
    procedure LoadStudentsInto(ACombo: TComboBox; AKeys: TStringList;
                               AClassCombo: TComboBox; AClsKeys: TStringList);
    procedure LoadPermits;
    procedure LoadCerts;
    procedure ClearPermit;
    procedure ClearCert;
    function  ComboKey(ACombo: TComboBox; AKeys: TStringList): Integer;
  end;

procedure ShowDocsForm(ATab: Integer);

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain;

procedure ShowDocsForm(ATab: Integer);
var
  F : TfrmDocs;
begin
  F := TfrmDocs.Create(nil);
  try
    if ATab = 1 then
      F.pc.ActivePage := F.tabCert
    else
      F.pc.ActivePage := F.tabPermit;
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmDocs.ApplyCaptions;
begin
  Caption           := R_MnuDocs;
  tabPermit.Caption := R_PrmTitle;
  tabCert.Caption   := R_CrtTitle;

  lblPClass.Caption   := R_AbsClass;
  lblPStudent.Caption := R_NotStudent;
  lblPDate.Caption    := R_PrmDate;
  lblPTime.Caption    := R_PrmTime;
  lblPReason.Caption  := R_PrmReason;
  btnPNew.Caption     := R_New;
  btnPSave.Caption    := R_Save;
  btnPDel.Caption     := R_Delete;
  btnPPrint.Caption   := R_Print;

  lblCClass.Caption   := R_AbsClass;
  lblCStudent.Caption := R_NotStudent;
  lblCNo.Caption      := R_CrtNo;
  lblCDate.Caption    := R_NotIssueDate;
  lblCPurpose.Caption := R_CrtPurpose;
  lblCCopies.Caption  := R_CrtCopies;
  btnCNew.Caption     := R_New;
  btnCSave.Caption    := R_Save;
  btnCDel.Caption     := R_Delete;
  btnCPrint.Caption   := R_Print;

  btnClose.Caption    := R_Close;
end;

procedure TfrmDocs.FormCreate(Sender: TObject);
begin
  FPClsKeys := TStringList.Create;  FPStuKeys := TStringList.Create;
  FCClsKeys := TStringList.Create;  FCStuKeys := TStringList.Create;
  FPermitID := 0;  FCertID := 0;

  FqPermit := TADOQuery.Create(Self);
  FqPermit.Connection := dm.conn;
  dsPermit.DataSet := FqPermit;

  FqCert := TADOQuery.Create(Self);
  FqCert.Connection := dm.conn;
  dsCert.DataSet := FqCert;

  ApplyCaptions;
  dm.RefreshClasses;
  FillCombo(cbPClass.Items, dm.qClasses, 'ClassName', 'ClassID', FPClsKeys, R_All);
  FillCombo(cbCClass.Items, dm.qClasses, 'ClassName', 'ClassID', FCClsKeys, R_All);
  cbPClass.ItemIndex := 0;
  cbCClass.ItemIndex := 0;

  LoadStudentsInto(cbPStudent, FPStuKeys, cbPClass, FPClsKeys);
  LoadStudentsInto(cbCStudent, FCStuKeys, cbCClass, FCClsKeys);

  SetupGrids;
  LoadPermits;
  LoadCerts;
  ClearPermit;
  ClearCert;
  ApplyRTL(Self);
end;

procedure TfrmDocs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FPClsKeys.Free; FPStuKeys.Free;
  FCClsKeys.Free; FCStuKeys.Free;
end;

procedure TfrmDocs.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TfrmDocs.ComboKey(ACombo: TComboBox; AKeys: TStringList): Integer;
begin
  Result := 0;
  if (ACombo.ItemIndex > 0) and (ACombo.ItemIndex < AKeys.Count) then
    Result := StrToIntDef(AKeys[ACombo.ItemIndex], 0);
end;

procedure TfrmDocs.LoadStudentsInto(ACombo: TComboBox; AKeys: TStringList;
  AClassCombo: TComboBox; AClsKeys: TStringList);
var
  Cid : Integer;
  W   : string;
begin
  Cid := ComboKey(AClassCombo, AClsKeys);
  W := ' WHERE s.IsActive = True';
  if Cid > 0 then
    W := W + ' AND s.ClassID = ' + IntToStr(Cid);

  dm.OpenQ(dm.qWork,
    'SELECT s.StudentID, s.LastName & '' '' & s.FirstName & '' ('' &' +
    ' IIF(IsNull(c.ClassName), ''-'', c.ClassName) & '')'' AS StudName' +
    ' FROM Students s LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
    W + ' ORDER BY s.LastName, s.FirstName');
  FillCombo(ACombo.Items, dm.qWork, 'StudName', 'StudentID', AKeys, R_None);
  dm.qWork.Close;
  ACombo.ItemIndex := 0;
end;

procedure TfrmDocs.cbPClassChange(Sender: TObject);
begin
  LoadStudentsInto(cbPStudent, FPStuKeys, cbPClass, FPClsKeys);
  LoadPermits;
end;

procedure TfrmDocs.cbCClassChange(Sender: TObject);
begin
  LoadStudentsInto(cbCStudent, FCStuKeys, cbCClass, FCClsKeys);
  LoadCerts;
end;

procedure TfrmDocs.SetupGrids;

  procedure AddCol(AGrid: TDBGrid; const AField, ATitle: string; AWidth: Integer);
  var
    C : TColumn;
  begin
    C := AGrid.Columns.Add;
    C.FieldName       := AField;
    C.Title.Caption   := ATitle;
    C.Width           := AWidth;
    C.Title.Alignment := taCenter;
  end;

begin
  grdPermit.Columns.Clear;
  AddCol(grdPermit, 'PermitDate', R_PrmDate,      110);
  AddCol(grdPermit, 'EntryTime',  R_PrmTime,       90);
  AddCol(grdPermit, 'ClassName',  R_AbsClass,      90);
  AddCol(grdPermit, 'LastName',   R_StuLastName,  150);
  AddCol(grdPermit, 'FirstName',  R_StuFirstName, 150);
  AddCol(grdPermit, 'Reason',     R_PrmReason,    300);

  grdCert.Columns.Clear;
  AddCol(grdCert, 'CertNo',     R_CrtNo,         90);
  AddCol(grdCert, 'IssueDate',  R_NotIssueDate, 110);
  AddCol(grdCert, 'ClassName',  R_AbsClass,      90);
  AddCol(grdCert, 'LastName',   R_StuLastName,  150);
  AddCol(grdCert, 'FirstName',  R_StuFirstName, 150);
  AddCol(grdCert, 'Purpose',    R_CrtPurpose,   250);
  AddCol(grdCert, 'CopiesNo',   R_CrtCopies,     80);
end;

{ --- ورقة الدخول -------------------------------------------------------- }

procedure TfrmDocs.LoadPermits;
var
  Cid : Integer;
  W   : string;
begin
  Cid := ComboKey(cbPClass, FPClsKeys);
  W := '';
  if Cid > 0 then
    W := ' WHERE s.ClassID = ' + IntToStr(Cid);

  dm.OpenQ(FqPermit,
    'SELECT p.PermitID, p.PermitDate, p.EntryTime, p.Reason, p.StudentID,' +
    ' s.LastName, s.FirstName, s.ClassID, c.ClassName' +
    ' FROM (EntryPermits p INNER JOIN Students s ON p.StudentID = s.StudentID)' +
    ' LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
    W + ' ORDER BY p.PermitDate DESC, p.PermitID DESC');
end;

procedure TfrmDocs.ClearPermit;
begin
  FPermitID := 0;
  cbPStudent.ItemIndex := 0;
  dtPDate.Date  := Date;
  edPTime.Text  := FormatDateTime('hh:nn', Now);
  edPReason.Text:= R_PrmDefReason;
end;

procedure TfrmDocs.grdPermitCellClick(Column: TColumn);
var
  I : Integer;
begin
  if FqPermit.IsEmpty then Exit;
  FPermitID     := FqPermit.FieldByName('PermitID').AsInteger;
  dtPDate.Date  := FqPermit.FieldByName('PermitDate').AsDateTime;
  edPTime.Text  := FqPermit.FieldByName('EntryTime').AsString;
  edPReason.Text:= FqPermit.FieldByName('Reason').AsString;
  I := FPStuKeys.IndexOf(FqPermit.FieldByName('StudentID').AsString);
  if I >= 0 then cbPStudent.ItemIndex := I;
end;

procedure TfrmDocs.btnPNewClick(Sender: TObject);
begin
  ClearPermit;
  cbPStudent.SetFocus;
end;

procedure TfrmDocs.btnPSaveClick(Sender: TObject);
var
  Sid : Integer;
begin
  Sid := ComboKey(cbPStudent, FPStuKeys);
  if Sid = 0 then
  begin
    ShowError(R_NotSelectStudent);
    Exit;
  end;
  try
    if FPermitID = 0 then
      dm.ExecSQL('INSERT INTO EntryPermits (StudentID, PermitDate, EntryTime,' +
        ' Reason, IssuedBy) VALUES (' + IntToStr(Sid) + ', ' +
        SqlDate(dtPDate.Date) + ', ' + SqlStr(Trim(edPTime.Text)) + ', ' +
        SqlStr(Trim(edPReason.Text)) + ', ' + IntToStr(dm.CurrentUserID) + ')')
    else
      dm.ExecSQL('UPDATE EntryPermits SET StudentID = ' + IntToStr(Sid) +
        ', PermitDate = ' + SqlDate(dtPDate.Date) +
        ', EntryTime = '  + SqlStr(Trim(edPTime.Text)) +
        ', Reason = '     + SqlStr(Trim(edPReason.Text)) +
        ' WHERE PermitID = ' + IntToStr(FPermitID));
    LoadPermits;
    ShowInfo(R_MsgSaved);
  except
    on E: Exception do ShowError(E.Message);
  end;
end;

procedure TfrmDocs.btnPDelClick(Sender: TObject);
begin
  if FqPermit.IsEmpty then Exit;
  if not AskYesNo(R_MsgConfirmDel) then Exit;
  dm.ExecSQL('DELETE FROM EntryPermits WHERE PermitID = ' +
             FqPermit.FieldByName('PermitID').AsString);
  LoadPermits;
  ClearPermit;
  ShowInfo(R_MsgDeleted);
end;

procedure TfrmDocs.btnPPrintClick(Sender: TObject);
var
  Rep : TReportBuilder;
begin
  if FqPermit.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;
  Rep := TReportBuilder.Create(R_PrmDocTitle);
  try
    Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
               dm.GetSetting('DIRECTION', ''),
               R_LblYear + dm.CurrentYearLabel);
    Rep.Paragraph('يسمح للتلميذ(ة) : <b>' +
      HtmlEscape(FqPermit.FieldByName('LastName').AsString + ' ' +
                 FqPermit.FieldByName('FirstName').AsString) +
      '</b><br>بالدخول إلى القسم : <b>' +
      HtmlEscape(FqPermit.FieldByName('ClassName').AsString) +
      '</b><br>بتاريخ : <b>' +
      HtmlEscape(FormatLongDate(FqPermit.FieldByName('PermitDate').AsDateTime)) +
      '</b>  على الساعة : <b>' +
      HtmlEscape(FqPermit.FieldByName('EntryTime').AsString) +
      '</b><br>السبب : <b>' +
      HtmlEscape(FqPermit.FieldByName('Reason').AsString) + '</b>');
    Rep.Signature('مستشار التربية' + #13#10 + dm.GetSetting('ADVISOR', ''),
                  R_AtDate + FormatDateTime('dd/mm/yyyy', Date));
    Rep.SaveAndOpen('Billet_Entree.html');
  finally
    Rep.Free;
  end;
end;

{ --- الشهادة المدرسية --------------------------------------------------- }

procedure TfrmDocs.LoadCerts;
var
  Cid : Integer;
  W   : string;
begin
  Cid := ComboKey(cbCClass, FCClsKeys);
  W := '';
  if Cid > 0 then
    W := ' WHERE s.ClassID = ' + IntToStr(Cid);

  dm.OpenQ(FqCert,
    'SELECT ce.CertID, ce.CertNo, ce.IssueDate, ce.Purpose, ce.CopiesNo,' +
    ' ce.StudentID, s.LastName, s.FirstName, s.BirthDate, s.BirthPlace,' +
    ' s.ClassID, c.ClassName' +
    ' FROM (Certificates ce INNER JOIN Students s ON ce.StudentID = s.StudentID)' +
    ' LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
    W + ' ORDER BY ce.CertNo DESC');
end;

procedure TfrmDocs.ClearCert;
begin
  FCertID := 0;
  cbCStudent.ItemIndex := 0;
  edCNo.Text      := IntToStr(dm.NextCertNumber);
  dtCDate.Date    := Date;
  edCPurpose.Text := R_CrtDefPurpose;
  edCCopies.Text  := '3';
end;

procedure TfrmDocs.grdCertCellClick(Column: TColumn);
var
  I : Integer;
begin
  if FqCert.IsEmpty then Exit;
  FCertID         := FqCert.FieldByName('CertID').AsInteger;
  edCNo.Text      := FqCert.FieldByName('CertNo').AsString;
  dtCDate.Date    := FqCert.FieldByName('IssueDate').AsDateTime;
  edCPurpose.Text := FqCert.FieldByName('Purpose').AsString;
  edCCopies.Text  := FqCert.FieldByName('CopiesNo').AsString;
  I := FCStuKeys.IndexOf(FqCert.FieldByName('StudentID').AsString);
  if I >= 0 then cbCStudent.ItemIndex := I;
end;

procedure TfrmDocs.btnCNewClick(Sender: TObject);
begin
  ClearCert;
  cbCStudent.SetFocus;
end;

procedure TfrmDocs.btnCSaveClick(Sender: TObject);
var
  Sid : Integer;
begin
  Sid := ComboKey(cbCStudent, FCStuKeys);
  if Sid = 0 then
  begin
    ShowError(R_NotSelectStudent);
    Exit;
  end;
  try
    if FCertID = 0 then
      dm.ExecSQL('INSERT INTO Certificates (CertNo, StudentID, IssueDate,' +
        ' YearID, Purpose, CopiesNo, IssuedBy) VALUES (' +
        IntToStr(StrToIntDef(edCNo.Text, dm.NextCertNumber)) + ', ' +
        IntToStr(Sid) + ', ' + SqlDate(dtCDate.Date) + ', ' +
        IntToStr(dm.CurrentYearID) + ', ' + SqlStr(Trim(edCPurpose.Text)) +
        ', ' + IntToStr(StrToIntDef(edCCopies.Text, 1)) + ', ' +
        IntToStr(dm.CurrentUserID) + ')')
    else
      dm.ExecSQL('UPDATE Certificates SET CertNo = ' +
        IntToStr(StrToIntDef(edCNo.Text, 0)) +
        ', StudentID = ' + IntToStr(Sid) +
        ', IssueDate = ' + SqlDate(dtCDate.Date) +
        ', Purpose = '   + SqlStr(Trim(edCPurpose.Text)) +
        ', CopiesNo = '  + IntToStr(StrToIntDef(edCCopies.Text, 1)) +
        ' WHERE CertID = ' + IntToStr(FCertID));
    LoadCerts;
    ShowInfo(R_MsgSaved);
  except
    on E: Exception do ShowError(E.Message);
  end;
end;

procedure TfrmDocs.btnCDelClick(Sender: TObject);
begin
  if FqCert.IsEmpty then Exit;
  if not AskYesNo(R_MsgConfirmDel) then Exit;
  dm.ExecSQL('DELETE FROM Certificates WHERE CertID = ' +
             FqCert.FieldByName('CertID').AsString);
  LoadCerts;
  ClearCert;
  ShowInfo(R_MsgDeleted);
end;

procedure TfrmDocs.btnCPrintClick(Sender: TObject);
var
  Rep : TReportBuilder;
  I, Copies : Integer;
begin
  if FqCert.IsEmpty then
  begin
    ShowInfo(R_MsgNoRecord);
    Exit;
  end;

  Copies := FqCert.FieldByName('CopiesNo').AsInteger;
  if Copies < 1 then Copies := 1;

  Rep := TReportBuilder.Create(R_CrtDocTitle);
  try
    for I := 1 to Copies do
    begin
      Rep.Header(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault),
                 dm.GetSetting('DIRECTION', ''),
                 R_CrtNoPrefix + FqCert.FieldByName('CertNo').AsString +
                 '   -   ' + R_LblYear + dm.CurrentYearLabel);
      Rep.Paragraph(
        'أنا الممضي أسفله، مدير متوسطة <b>' +
        HtmlEscape(dm.GetSetting('SCHOOL_NAME', R_SchoolDefault)) +
        '</b> أشهد أن التلميذ(ة) :<br>' +
        'الاسم واللقب : <b>' +
        HtmlEscape(FqCert.FieldByName('LastName').AsString + ' ' +
                   FqCert.FieldByName('FirstName').AsString) + '</b><br>' +
        'المولود(ة) بتاريخ : <b>' +
        HtmlEscape(FormatDateTime('dd/mm/yyyy',
                   FqCert.FieldByName('BirthDate').AsDateTime)) +
        '</b>  بـ : <b>' +
        HtmlEscape(FqCert.FieldByName('BirthPlace').AsString) + '</b><br>' +
        'يزاول(تزاول) دراسته(ها) بهذه المؤسسة بقسم : <b>' +
        HtmlEscape(FqCert.FieldByName('ClassName').AsString) +
        '</b> خلال السنة الدراسية <b>' + HtmlEscape(dm.CurrentYearLabel) +
        '</b>.<br><br>وسلمت له هذه الشهادة ' +
        HtmlEscape(FqCert.FieldByName('Purpose').AsString) + '.');
      Rep.Signature(R_SignDirector + #13#10 + dm.GetSetting('DIRECTOR', ''),
                    dm.GetSetting('ADDRESS', '') + R_AtDate +
                    FormatDateTime('dd/mm/yyyy',
                    FqCert.FieldByName('IssueDate').AsDateTime));
      if I < Copies then
        Rep.PageBreak;
    end;
    Rep.SaveAndOpen('Certificat_Scolarite.html');
  finally
    Rep.Free;
  end;
end;

end.
