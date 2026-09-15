unit dmMain;

{ =============================================================================
  وحدة المعطيات المركزية
  Module de donnees : connexion ADO + acces aux donnees partage.
  ============================================================================= }

interface

uses
  Windows, SysUtils, Classes, DB, ADODB, Variants, Forms;

type
  TdmMain = class(TDataModule)
    conn        : TADOConnection;
    { --- جداول قابلة للتعديل مباشرة في الشبكة --- }
    tblLevels   : TADOTable;
    tblSubjects : TADOTable;
    tblSlots    : TADOTable;
    tblYears    : TADOTable;
    dsLevels    : TDataSource;
    dsSubjects  : TDataSource;
    dsSlots     : TDataSource;
    dsYears     : TDataSource;
    { --- استعلامات العرض --- }
    qStudents   : TADOQuery;
    qClasses    : TADOQuery;
    qTeachers   : TADOQuery;
    qUsers      : TADOQuery;
    qAbsences   : TADOQuery;
    qNotices    : TADOQuery;
    dsStudents  : TDataSource;
    dsClasses   : TDataSource;
    dsTeachers  : TDataSource;
    dsUsers     : TDataSource;
    dsAbsences  : TDataSource;
    dsNotices   : TDataSource;
    { --- استعلامات خدمية --- }
    qWork       : TADOQuery;
    qRep        : TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FUserID   : Integer;
    FUserName : string;
    FUserRole : string;
  public
    property CurrentUserID   : Integer read FUserID;
    property CurrentUserName : string  read FUserName;
    property CurrentUserRole : string  read FUserRole;

    function  Connect: Boolean;
    function  Login(const ALogin, APassword: string; out AError: string): Boolean;
    procedure Logout;
    function  IsAdmin: Boolean;

    { --- تنفيذ الاستعلامات --- }
    function  ExecSQL(const ASql: string): Integer;
    function  OpenQ(AQuery: TADOQuery; const ASql: string): TADOQuery;
    function  ScalarInt(const ASql: string; ADefault: Integer = 0): Integer;
    function  ScalarStr(const ASql: string; const ADefault: string = ''): string;

    { --- الإعدادات --- }
    function  GetSetting(const AKey: string; const ADefault: string = ''): string;
    function  GetSettingInt(const AKey: string; ADefault: Integer = 0): Integer;
    procedure SetSetting(const AKey, AValue: string);

    { --- فتح مجموعات البيانات المرجعية --- }
    procedure OpenLookups;
    procedure RefreshClasses;
    procedure RefreshTeachers;
    procedure RefreshUsers;
    procedure RefreshStudents(const AFilterClassID: Integer = 0;
                              const ASearch: string = '';
                              AOnlyActive: Boolean = True);

    { --- الغيابات --- }
    function  CountUnjustified(AStudentID: Integer;
                               AFrom, ATo: TDateTime): Integer;
    function  CountAbsences(AStudentID: Integer; AFrom, ATo: TDateTime;
                            const AKind: string = ''): Integer;
    function  CurrentYearID: Integer;
    function  CurrentYearLabel: string;

    { --- الترقيم التسلسلي --- }
    function  NextNoticeNumber: string;
    function  NextCertNumber: Integer;
  end;

var
  dm : TdmMain;

implementation

{$R *.dfm}

uses uDB, uUtils, uLang;

{ ------------------------------------------------------------------------ }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  FUserID   := 0;
  FUserName := '';
  FUserRole := '';
end;

procedure TdmMain.DataModuleDestroy(Sender: TObject);
begin
  if conn.Connected then
    conn.Connected := False;
end;

function TdmMain.Connect: Boolean;
begin
  Result := EnsureDatabase(conn);
  if Result then
    OpenLookups;
end;

{ ------------------------------------------------------------------------
  المصادقة
  ------------------------------------------------------------------------ }
function TdmMain.Login(const ALogin, APassword: string;
  out AError: string): Boolean;
begin
  Result := False;
  AError := '';

  OpenQ(qWork,
    'SELECT UserID, UserLogin, PassHash, FullName, UserRole, IsActive' +
    ' FROM AppUsers WHERE UserLogin = ' + SqlStr(Trim(ALogin)));

  if qWork.IsEmpty then
  begin
    AError := R_LoginFailed;
    Exit;
  end;

  if not SameText(qWork.FieldByName('PassHash').AsString, SHA1Hash(APassword)) then
  begin
    AError := R_LoginFailed;
    Exit;
  end;

  if not qWork.FieldByName('IsActive').AsBoolean then
  begin
    AError := R_LoginDisabled;
    Exit;
  end;

  FUserID   := qWork.FieldByName('UserID').AsInteger;
  FUserName := qWork.FieldByName('FullName').AsString;
  if FUserName = '' then
    FUserName := qWork.FieldByName('UserLogin').AsString;
  FUserRole := qWork.FieldByName('UserRole').AsString;
  Result := True;

  qWork.Close;
end;

procedure TdmMain.Logout;
begin
  FUserID   := 0;
  FUserName := '';
  FUserRole := '';
end;

function TdmMain.IsAdmin: Boolean;
begin
  Result := SameText(FUserRole, 'ADMIN');
end;

{ ------------------------------------------------------------------------
  تنفيذ الاستعلامات
  ------------------------------------------------------------------------ }
function TdmMain.ExecSQL(const ASql: string): Integer;
var
  Affected : Integer;
begin
  Affected := 0;
  conn.Execute(ASql, Affected);
  Result := Affected;
end;

function TdmMain.OpenQ(AQuery: TADOQuery; const ASql: string): TADOQuery;
begin
  AQuery.Close;
  AQuery.SQL.Text := ASql;
  AQuery.Open;
  Result := AQuery;
end;

function TdmMain.ScalarInt(const ASql: string; ADefault: Integer): Integer;
begin
  Result := ADefault;
  try
    OpenQ(qWork, ASql);
    if (not qWork.IsEmpty) and (not qWork.Fields[0].IsNull) then
      Result := qWork.Fields[0].AsInteger;
    qWork.Close;
  except
    Result := ADefault;
  end;
end;

function TdmMain.ScalarStr(const ASql, ADefault: string): string;
begin
  Result := ADefault;
  try
    OpenQ(qWork, ASql);
    if (not qWork.IsEmpty) and (not qWork.Fields[0].IsNull) then
      Result := qWork.Fields[0].AsString;
    qWork.Close;
  except
    Result := ADefault;
  end;
end;

{ ------------------------------------------------------------------------
  الإعدادات
  ------------------------------------------------------------------------ }
function TdmMain.GetSetting(const AKey, ADefault: string): string;
begin
  Result := ScalarStr('SELECT SettingValue FROM AppSettings WHERE SettingKey = ' +
                      SqlStr(AKey), ADefault);
end;

function TdmMain.GetSettingInt(const AKey: string; ADefault: Integer): Integer;
var
  S : string;
begin
  S := GetSetting(AKey, '');
  if not TryStrToInt(S, Result) then
    Result := ADefault;
end;

procedure TdmMain.SetSetting(const AKey, AValue: string);
begin
  if ExecSQL('UPDATE AppSettings SET SettingValue = ' + SqlStr(AValue) +
             ' WHERE SettingKey = ' + SqlStr(AKey)) = 0 then
    ExecSQL('INSERT INTO AppSettings (SettingKey, SettingValue) VALUES (' +
            SqlStr(AKey) + ', ' + SqlStr(AValue) + ')');
end;

{ ------------------------------------------------------------------------
  البيانات المرجعية
  ------------------------------------------------------------------------ }
procedure TdmMain.OpenLookups;
begin
  tblLevels.Close;   tblLevels.Open;
  tblSubjects.Close; tblSubjects.Open;
  tblSlots.Close;    tblSlots.Open;
  tblYears.Close;    tblYears.Open;
  RefreshClasses;
  RefreshTeachers;
end;

procedure TdmMain.RefreshClasses;
begin
  OpenQ(qClasses,
    'SELECT c.ClassID, c.ClassName, c.LevelID, c.YearID, c.RoomName, c.Capacity,' +
    ' l.LevelName, y.YearLabel' +
    ' FROM (Classes c LEFT JOIN GradeLevels l ON c.LevelID = l.LevelID)' +
    ' LEFT JOIN SchoolYears y ON c.YearID = y.YearID' +
    ' ORDER BY l.SortOrder, c.ClassName');
end;

procedure TdmMain.RefreshTeachers;
begin
  OpenQ(qTeachers,
    'SELECT t.TeacherID, t.LastName, t.FirstName, t.Phone, t.Email,' +
    ' t.SubjectID, s.SubjectName' +
    ' FROM Teachers t LEFT JOIN Subjects s ON t.SubjectID = s.SubjectID' +
    ' ORDER BY t.LastName, t.FirstName');
end;

procedure TdmMain.RefreshUsers;
begin
  OpenQ(qUsers,
    'SELECT UserID, UserLogin, FullName, UserRole, IsActive, CreatedAt' +
    ' FROM AppUsers ORDER BY UserLogin');
end;

procedure TdmMain.RefreshStudents(const AFilterClassID: Integer;
  const ASearch: string; AOnlyActive: Boolean);
var
  Sql, W : string;
begin
  W := ' WHERE 1=1';
  if AOnlyActive then
    W := W + ' AND s.IsActive = True';
  if AFilterClassID > 0 then
    W := W + ' AND s.ClassID = ' + IntToStr(AFilterClassID);
  if Trim(ASearch) <> '' then
    W := W + ' AND (s.LastName LIKE ' + SqlStr('%' + Trim(ASearch) + '%') +
             ' OR s.FirstName LIKE ' + SqlStr('%' + Trim(ASearch) + '%') +
             ' OR s.MatriculeNat LIKE ' + SqlStr('%' + Trim(ASearch) + '%') +
             ' OR s.RegNumber LIKE ' + SqlStr('%' + Trim(ASearch) + '%') + ')';

  Sql :=
    'SELECT s.StudentID, s.MatriculeNat, s.RegNumber, s.LastName, s.FirstName,' +
    ' s.Gender, s.BirthDate, s.BirthPlace, s.ClassID, s.RegimeStatus,' +
    ' s.FatherName, s.MotherName, s.SocialStatus, s.SiblingsCount,' +
    ' s.SiblingsSchooled, s.GuardianName, s.GuardianPhone, s.GuardianEmail,' +
    ' s.GuardianAddr, s.EnrollDate, s.ExitDate, s.IsActive, s.Notes,' +
    ' c.ClassName' +
    ' FROM Students s LEFT JOIN Classes c ON s.ClassID = c.ClassID' +
    W + ' ORDER BY c.ClassName, s.LastName, s.FirstName';

  OpenQ(qStudents, Sql);
end;

{ ------------------------------------------------------------------------
  إحصاء الغيابات
  ------------------------------------------------------------------------ }
function TdmMain.CountUnjustified(AStudentID: Integer;
  AFrom, ATo: TDateTime): Integer;
begin
  Result := ScalarInt(
    'SELECT COUNT(*) FROM Absences WHERE StudentID = ' + IntToStr(AStudentID) +
    ' AND AbsKind = ' + SqlStr('ABS') +
    ' AND Justified = False' +
    ' AND AbsDate BETWEEN ' + SqlDate(AFrom) + ' AND ' + SqlDate(ATo), 0);
end;

function TdmMain.CountAbsences(AStudentID: Integer; AFrom, ATo: TDateTime;
  const AKind: string): Integer;
var
  S : string;
begin
  S := 'SELECT COUNT(*) FROM Absences WHERE StudentID = ' + IntToStr(AStudentID) +
       ' AND AbsDate BETWEEN ' + SqlDate(AFrom) + ' AND ' + SqlDate(ATo);
  if AKind <> '' then
    S := S + ' AND AbsKind = ' + SqlStr(AKind);
  Result := ScalarInt(S, 0);
end;

function TdmMain.CurrentYearID: Integer;
begin
  Result := ScalarInt('SELECT TOP 1 YearID FROM SchoolYears WHERE IsCurrent = True', 0);
  if Result = 0 then
    Result := ScalarInt('SELECT TOP 1 YearID FROM SchoolYears ORDER BY YearID DESC', 0);
end;

function TdmMain.CurrentYearLabel: string;
begin
  Result := ScalarStr('SELECT TOP 1 YearLabel FROM SchoolYears WHERE IsCurrent = True', '');
  if Result = '' then
    Result := ScalarStr('SELECT TOP 1 YearLabel FROM SchoolYears ORDER BY YearID DESC', '');
end;

{ ------------------------------------------------------------------------
  الترقيم التسلسلي
  ------------------------------------------------------------------------ }
function TdmMain.NextNoticeNumber: string;
var
  N, Y : Integer;
  M, D : Word;
  YY   : Word;
begin
  DecodeDate(Date, YY, M, D);
  Y := YY;
  N := ScalarInt('SELECT COUNT(*) FROM Notices WHERE Year(IssueDate) = ' +
                 IntToStr(Y), 0) + 1;
  Result := Format('%.3d/%d', [N, Y]);
end;

function TdmMain.NextCertNumber: Integer;
begin
  Result := ScalarInt('SELECT MAX(CertNo) FROM Certificates', 0) + 1;
end;

end.
