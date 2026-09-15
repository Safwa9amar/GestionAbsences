unit uDB;

{ =============================================================================
  وحدة إنشاء وإدارة قاعدة بيانات Microsoft Access
  Creation / ouverture de la base Access (Jet 4.0 - ACE 12.0).

  عند أول تشغيل ينشئ البرنامج الملف Data\GestionAbsences.mdb
  ثم ينشئ الجداول ويملأ البيانات المرجعية تلقائيا.
  ============================================================================= }

interface

uses
  Windows, SysUtils, Classes, DB, ADODB, ComObj, Variants, Forms, Registry;

const
  PROV_JET    = 'Microsoft.Jet.OLEDB.4.0';
  PROV_ACE    = 'Microsoft.ACE.OLEDB.12.0';
  PROV_ACE16  = 'Microsoft.ACE.OLEDB.16.0';

  DB_FOLDER   = 'Data';
  DB_FILENAME = 'GestionAbsences.mdb';

  { العتبات الافتراضية للإشعارات }
  DEF_THRESHOLD_1 = 3;    { إشعار أول  }
  DEF_THRESHOLD_2 = 6;    { إشعار ثان  }
  DEF_THRESHOLD_3 = 10;   { إعذار بالشطب }

function  DatabasePath: string;
function  BuildConnectionString(const AFile: string): string;
function  DetectDbFormat(const AFile: string): string;
function  ProviderInstalled(const AProgID: string): Boolean;
function  AdoxAvailable: Boolean;
function  ProviderDiagnostics: string;
function  OpenDatabase(AConn: TADOConnection; const AFile: string;
                      out AError: string): Boolean;
function  DatabaseExists: Boolean;
function  CreateEmptyDatabase(const AFile: string;
                              out AError: string): Boolean;
procedure CreateSchema(AConn: TADOConnection);
function  TableRowCount(AConn: TADOConnection; const ATable: string): Integer;
procedure SeedReferenceData(AConn: TADOConnection);
function  EnsureDatabase(AConn: TADOConnection): Boolean;
type
  { حصيلة الإدراج التجريبي }
  TDemoCounts = record
    Students, Teachers, Users, Absences, Justified,
    Notices, Permits, Certificates : Integer;
  end;

function  ImportSampleStudents(AConn: TADOConnection;
                               out AError: string): Integer;
function  ImportDemoData(AConn: TADOConnection;
                         out AError: string): TDemoCounts;
function  BackupDatabase(const ATargetFile: string): Boolean;
function  RestoreDatabase(const ASourceFile: string): Boolean;

implementation

uses uUtils;

{ ------------------------------------------------------------------------ }

function DatabasePath: string;
var
  Dir : string;
begin
  Dir := AppDir + DB_FOLDER;
  if not DirectoryExists(Dir) then
    CreateDir(Dir);
  Result := IncludeTrailingPathDelimiter(Dir) + DB_FILENAME;
end;

{ ------------------------------------------------------------------------
  تشخيص المكونات المتوفرة على الجهاز
  Diagnostic des composants presents sur la machine
  ------------------------------------------------------------------------ }

{ الموفر مسجَّل إذا وُجد مفتاحه في HKEY_CLASSES_ROOT ومعه CLSID }
function ProviderInstalled(const AProgID: string): Boolean;
var
  Reg : TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKeyReadOnly(AProgID) then
    begin
      Reg.CloseKey;
      Result := Reg.KeyExists(AProgID + '\CLSID');
    end;
  except
    Result := False;
  end;
  Reg.Free;
end;

{ ADOX ضروري لإنشاء ملف قاعدة بيانات جديد }
function AdoxAvailable: Boolean;
var
  Cat : OleVariant;
begin
  try
    Cat := CreateOleObject('ADOX.Catalog');
    Cat := Unassigned;
    Result := True;
  except
    Result := False;
  end;
end;

function ProviderDiagnostics: string;

  function YN(AOk: Boolean): string;
  begin
    if AOk then Result := 'موجود / present' else Result := 'غير موجود / absent';
  end;

begin
  Result :=
    'ADOX (ADOX.Catalog)     : ' + YN(AdoxAvailable)                + #13#10 +
    PROV_JET   + ' : ' + YN(ProviderInstalled(PROV_JET))   + #13#10 +
    PROV_ACE   + ' : ' + YN(ProviderInstalled(PROV_ACE))   + #13#10 +
    PROV_ACE16 + ' : ' + YN(ProviderInstalled(PROV_ACE16));
end;

{ سلسلة الاتصال المستعملة عند الفتح }
function ConnStrFor(const AProvider, AFile: string): string;
begin
  Result := 'Provider=' + AProvider + ';Data Source=' + AFile +
            ';Persist Security Info=False;';
end;

{ سلسلة الاتصال المستعملة عند الإنشاء بواسطة ADOX.

  ملاحظة أساسية : الإجراء Catalog.Create لا يقبل إلا الخصائص الصالحة
  وقت الإنشاء. وجود 'Persist Security Info' يُنتج الخطأ :
  "Multiple-step OLE DB operation generated errors ... No work was done".
  لذلك تُستعمل هنا سلسلة مختصرة.

  كما يُفرض على موفر ACE إنتاج ملف بصيغة Jet 4 (MDB) عبر
  'Jet OLEDB:Engine Type=5'، وإلا أنشأ ملفا بصيغة ACCDB رغم الامتداد mdb. }
function ConnStrCreate(const AProvider, AFile: string): string;
begin
  Result := 'Provider=' + AProvider + ';Data Source=' + AFile;
  if (not SameText(AProvider, PROV_JET)) and
     SameText(ExtractFileExt(AFile), '.mdb') then
    Result := Result + ';Jet OLEDB:Engine Type=5';
end;

function BuildConnectionString(const AFile: string): string;
begin
  { يُختار الموفر حسب الصيغة الحقيقية للملف على القرص، لا حسب الامتداد،
    لأن موفر ACE قد ينشئ ملفا بصيغة ACCDB رغم أن امتداده mdb. }
  if SameText(DetectDbFormat(AFile), 'ACE') or
     SameText(ExtractFileExt(AFile), '.accdb') then
  begin
    if ProviderInstalled(PROV_ACE) then
      Result := ConnStrFor(PROV_ACE, AFile)
    else
      Result := ConnStrFor(PROV_ACE16, AFile);
  end
  else
    Result := ConnStrFor(PROV_JET, AFile);
end;

function DatabaseExists: Boolean;
begin
  Result := FileExists(DatabasePath);
end;

{ ------------------------------------------------------------------------
  التعرف على صيغة الملف من ترويسته :
  ملف Jet 4  يبدأ بالعبارة  "Standard Jet DB"
  ملف ACCDB يبدأ بالعبارة  "Standard ACE DB"
  ------------------------------------------------------------------------ }
function DetectDbFormat(const AFile: string): string;
var
  FS  : TFileStream;
  Buf : array[0..31] of AnsiChar;
  Sig : AnsiString;
begin
  Result := 'UNKNOWN';
  if not FileExists(AFile) then
  begin
    Result := 'NONE';
    Exit;
  end;
  try
    FS := TFileStream.Create(AFile, fmOpenRead or fmShareDenyNone);
    try
      if FS.Size < 32 then Exit;
      FS.ReadBuffer(Buf, 32);
    finally
      FS.Free;
    end;
  except
    Exit;
  end;
  SetString(Sig, PAnsiChar(@Buf[4]), 15);
  if Pos('Jet', string(Sig)) > 0 then
    Result := 'JET'
  else if Pos('ACE', string(Sig)) > 0 then
    Result := 'ACE';
end;

{ ------------------------------------------------------------------------
  فتح القاعدة : يُجرَّب الموفر المناسب ثم الآخر احتياطا
  ------------------------------------------------------------------------ }
function TryConnect(AConn: TADOConnection; const AFile, AProvider: string;
  out AError: string): Boolean;
begin
  Result := False;
  AError := '';
  try
    AConn.Connected        := False;
    AConn.LoginPrompt      := False;
    AConn.ConnectionString := ConnStrFor(AProvider, AFile);
    AConn.Connected        := True;
    Result := True;
  except
    on E: Exception do
    begin
      AError := E.Message;
      AConn.Connected := False;
    end;
  end;
end;

function OpenDatabase(AConn: TADOConnection; const AFile: string;
  out AError: string): Boolean;
var
  Errs : string;

  function Attempt(const AProvider: string): Boolean;
  var
    E : string;
  begin
    Result := TryConnect(AConn, AFile, AProvider, E);
    if (not Result) and (E <> '') then
      Errs := Errs + AProvider + ' : ' + E + #13#10;
  end;

begin
  Errs   := '';
  Result := False;

  { الموفر المناسب لصيغة الملف أولا، ثم البقية احتياطا }
  if SameText(DetectDbFormat(AFile), 'ACE') then
  begin
    if Attempt(PROV_ACE)   then Result := True
    else if Attempt(PROV_ACE16) then Result := True
    else if Attempt(PROV_JET)   then Result := True;
  end
  else
  begin
    if Attempt(PROV_JET)   then Result := True
    else if Attempt(PROV_ACE)   then Result := True
    else if Attempt(PROV_ACE16) then Result := True;
  end;

  if Result then
    AError := ''
  else
    AError := Errs;
end;

{ ------------------------------------------------------------------------
  إنشاء ملف قاعدة بيانات فارغ باستعمال ADOX
  ------------------------------------------------------------------------ }
function FileSizeOf(const AFile: string): Int64;
var
  SR : TSearchRec;
begin
  Result := -1;
  if FindFirst(AFile, faAnyFile, SR) = 0 then
  begin
    Result := SR.Size;
    FindClose(SR);
  end;
end;

function CreateEmptyDatabase(const AFile: string;
  out AError: string): Boolean;
var
  Errs : string;

  { محاولة الإنشاء بموفر واحد، مع إرجاع نص الخطأ الحقيقي بدل ابتلاعه }
  function TryCreate(const AProvider: string): Boolean;
  var
    Cat : OleVariant;
    Sz  : Int64;
  begin
    Result := False;
    try
      if FileExists(AFile) then
        DeleteFile(PChar(AFile));

      Cat := CreateOleObject('ADOX.Catalog');
      Cat.Create(ConnStrCreate(AProvider, AFile));

      { مهم : ADOX يترك الاتصال مفتوحا بعد Create فيبقى الملف مقفلا،
        وعندها تفشل أي قراءة لاحقة لترويسة الملف. }
      try
        Cat.ActiveConnection.Close;
      except
        { بعض الإصدارات لا تُبقي الاتصال مفتوحا - يُتجاهل }
      end;
      Cat := Unassigned;

      Sz     := FileSizeOf(AFile);
      Result := Sz > 0;
      if not Result then
        Errs := Errs + AProvider + ' : لم يُنشأ الملف (الحجم = ' +
                IntToStr(Sz) + ')' + #13#10;
    except
      on E: Exception do
        Errs := Errs + AProvider + ' : ' + E.Message + #13#10;
    end;
  end;

begin
  Errs   := '';
  AError := '';
  Result := False;

  { التأكد من المجلد قبل أي محاولة }
  if not DirectoryExists(ExtractFileDir(AFile)) then
    if not ForceDirectories(ExtractFileDir(AFile)) then
    begin
      AError := 'تعذر إنشاء المجلد : ' + ExtractFileDir(AFile);
      Exit;
    end;

  Result := TryCreate(PROV_JET);
  if not Result then Result := TryCreate(PROV_ACE);
  if not Result then Result := TryCreate(PROV_ACE16);

  if not Result then
  begin
    AError := Errs;
    if FileExists(AFile) then
      DeleteFile(PChar(AFile));
  end;
end;

procedure CreateSchema(AConn: TADOConnection);
const
  DDL : array[0..20] of string = (

  { 1 - المستخدمون }
  'CREATE TABLE AppUsers (' +
  ' UserID COUNTER CONSTRAINT PK_AppUsers PRIMARY KEY,' +
  ' UserLogin TEXT(50) NOT NULL,' +
  ' PassHash TEXT(64) NOT NULL,' +
  ' FullName TEXT(80),' +
  ' UserRole TEXT(20) NOT NULL,' +
  ' IsActive BIT NOT NULL,' +
  ' CreatedAt DATETIME )',

  'CREATE UNIQUE INDEX IX_AppUsers_Login ON AppUsers (UserLogin)',

  { 2 - السنوات الدراسية }
  'CREATE TABLE SchoolYears (' +
  ' YearID COUNTER CONSTRAINT PK_SchoolYears PRIMARY KEY,' +
  ' YearLabel TEXT(20) NOT NULL,' +
  ' StartDate DATETIME,' +
  ' EndDate DATETIME,' +
  ' IsCurrent BIT NOT NULL )',

  { 3 - المستويات }
  'CREATE TABLE GradeLevels (' +
  ' LevelID COUNTER CONSTRAINT PK_GradeLevels PRIMARY KEY,' +
  ' LevelName TEXT(40) NOT NULL,' +
  ' SortOrder INTEGER )',

  { 4 - الأقسام }
  'CREATE TABLE Classes (' +
  ' ClassID COUNTER CONSTRAINT PK_Classes PRIMARY KEY,' +
  ' ClassName TEXT(40) NOT NULL,' +
  ' LevelID INTEGER,' +
  ' YearID INTEGER,' +
  ' RoomName TEXT(40),' +
  ' Capacity INTEGER,' +
  ' CONSTRAINT FK_Classes_Level FOREIGN KEY (LevelID) REFERENCES GradeLevels (LevelID),' +
  ' CONSTRAINT FK_Classes_Year FOREIGN KEY (YearID) REFERENCES SchoolYears (YearID) )',

  { 5 - المواد }
  'CREATE TABLE Subjects (' +
  ' SubjectID COUNTER CONSTRAINT PK_Subjects PRIMARY KEY,' +
  ' SubjectName TEXT(60) NOT NULL,' +
  ' Coefficient INTEGER )',

  { 6 - الأساتذة }
  'CREATE TABLE Teachers (' +
  ' TeacherID COUNTER CONSTRAINT PK_Teachers PRIMARY KEY,' +
  ' LastName TEXT(40) NOT NULL,' +
  ' FirstName TEXT(40),' +
  ' Phone TEXT(20),' +
  ' Email TEXT(60),' +
  ' SubjectID INTEGER,' +
  ' CONSTRAINT FK_Teachers_Subject FOREIGN KEY (SubjectID) REFERENCES Subjects (SubjectID) )',

  { 7 - الحصص }
  'CREATE TABLE TimeSlots (' +
  ' SlotID COUNTER CONSTRAINT PK_TimeSlots PRIMARY KEY,' +
  ' SlotLabel TEXT(30) NOT NULL,' +
  ' DayPart TEXT(20),' +
  ' StartTime TEXT(5),' +
  ' EndTime TEXT(5),' +
  ' SortOrder INTEGER )',

  { 8 - التلاميذ }
  'CREATE TABLE Students (' +
  ' StudentID COUNTER CONSTRAINT PK_Students PRIMARY KEY,' +
  ' MatriculeNat TEXT(20),' +
  ' RegNumber TEXT(20),' +
  ' LastName TEXT(40) NOT NULL,' +
  ' FirstName TEXT(40) NOT NULL,' +
  ' Gender TEXT(10),' +
  ' BirthDate DATETIME,' +
  ' BirthPlace TEXT(60),' +
  ' ClassID INTEGER,' +
  ' RegimeStatus TEXT(20),' +
  ' FatherName TEXT(60),' +
  ' MotherName TEXT(60),' +
  ' SocialStatus TEXT(30),' +
  ' SiblingsCount INTEGER,' +
  ' SiblingsSchooled INTEGER,' +
  ' GuardianName TEXT(60),' +
  ' GuardianPhone TEXT(20),' +
  ' GuardianEmail TEXT(60),' +
  ' GuardianAddr TEXT(120),' +
  ' EnrollDate DATETIME,' +
  ' ExitDate DATETIME,' +
  ' IsActive BIT NOT NULL,' +
  ' PhotoPath TEXT(150),' +
  ' Notes MEMO,' +
  ' CONSTRAINT FK_Students_Class FOREIGN KEY (ClassID) REFERENCES Classes (ClassID) )',

  'CREATE INDEX IX_Students_Class ON Students (ClassID)',
  'CREATE INDEX IX_Students_Name ON Students (LastName, FirstName)',

  { 9 - الغيابات والتأخرات }
  'CREATE TABLE Absences (' +
  ' AbsenceID COUNTER CONSTRAINT PK_Absences PRIMARY KEY,' +
  ' StudentID INTEGER NOT NULL,' +
  ' AbsDate DATETIME NOT NULL,' +
  ' SlotID INTEGER NOT NULL,' +
  ' SubjectID INTEGER,' +
  ' TeacherID INTEGER,' +
  ' AbsKind TEXT(20) NOT NULL,' +
  ' LateMinutes INTEGER,' +
  ' Justified BIT NOT NULL,' +
  ' JustifyDate DATETIME,' +
  ' JustifyReason TEXT(120),' +
  ' RecordedBy INTEGER,' +
  ' RecordedAt DATETIME,' +
  ' Notes TEXT(150),' +
  ' CONSTRAINT FK_Abs_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID),' +
  ' CONSTRAINT FK_Abs_Slot FOREIGN KEY (SlotID) REFERENCES TimeSlots (SlotID) )',

  'CREATE UNIQUE INDEX IX_Abs_Unique ON Absences (StudentID, AbsDate, SlotID)',
  'CREATE INDEX IX_Abs_Date ON Absences (AbsDate)',

  { 10 - الإشعارات }
  'CREATE TABLE Notices (' +
  ' NoticeID COUNTER CONSTRAINT PK_Notices PRIMARY KEY,' +
  ' StudentID INTEGER NOT NULL,' +
  ' NoticeKind TEXT(30) NOT NULL,' +
  ' NoticeNo TEXT(20),' +
  ' IssueDate DATETIME NOT NULL,' +
  ' MeetDate DATETIME,' +
  ' MeetTime TEXT(5),' +
  ' NoticeTopic TEXT(150),' +
  ' RefNoticeID INTEGER,' +
  ' AbsCount INTEGER,' +
  ' IssuedBy INTEGER,' +
  ' Delivered BIT NOT NULL,' +
  ' Notes MEMO,' +
  ' CONSTRAINT FK_Notice_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID) )',

  'CREATE INDEX IX_Notices_Student ON Notices (StudentID)',

  { 11 - ورقة الدخول }
  'CREATE TABLE EntryPermits (' +
  ' PermitID COUNTER CONSTRAINT PK_EntryPermits PRIMARY KEY,' +
  ' StudentID INTEGER NOT NULL,' +
  ' PermitDate DATETIME NOT NULL,' +
  ' EntryTime TEXT(5),' +
  ' Reason TEXT(120),' +
  ' IssuedBy INTEGER,' +
  ' CONSTRAINT FK_Permit_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID) )',

  { 12 - الشهادات المدرسية }
  'CREATE TABLE Certificates (' +
  ' CertID COUNTER CONSTRAINT PK_Certificates PRIMARY KEY,' +
  ' CertNo INTEGER,' +
  ' StudentID INTEGER NOT NULL,' +
  ' IssueDate DATETIME NOT NULL,' +
  ' YearID INTEGER,' +
  ' Purpose TEXT(100),' +
  ' CopiesNo INTEGER,' +
  ' IssuedBy INTEGER,' +
  ' CONSTRAINT FK_Cert_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID) )',

  { 13 - إعدادات المؤسسة }
  'CREATE TABLE AppSettings (' +
  ' SettingKey TEXT(50) CONSTRAINT PK_AppSettings PRIMARY KEY,' +
  ' SettingValue TEXT(200) )',

  'CREATE UNIQUE INDEX IX_Years_Label ON SchoolYears (YearLabel)',
  'CREATE UNIQUE INDEX IX_Classes_Name ON Classes (ClassName, YearID)'
  );
  REQUIRED : array[0..12] of string = (
    'AppUsers', 'SchoolYears', 'GradeLevels', 'Classes', 'Subjects',
    'Teachers', 'TimeSlots', 'Students', 'Absences', 'Notices',
    'EntryPermits', 'Certificates', 'AppSettings');
var
  I       : Integer;
  Missing : string;
begin
  { كل تعليمة على حدة : وجود الجدول أو الفهرس مسبقا لا يُعطّل الباقي.
    هذا يجعل البرنامج قادرا على إكمال هيكل ناقص خلّفه تشغيل سابق فاشل. }
  for I := Low(DDL) to High(DDL) do
  try
    AConn.Execute(DDL[I]);
  except
    { موجود مسبقا - يُتجاهل }
  end;

  { التحقق من أن كل الجداول المطلوبة أصبحت موجودة فعلا }
  Missing := '';
  for I := Low(REQUIRED) to High(REQUIRED) do
    if TableRowCount(AConn, REQUIRED[I]) < 0 then
      Missing := Missing + REQUIRED[I] + ' ';

  if Missing <> '' then
    raise Exception.Create('تعذر إنشاء الجداول التالية : ' + Missing);
end;

{ عدد الأسطر في جدول، أو -1 إذا كان الجدول غير موجود }
function TableRowCount(AConn: TADOConnection; const ATable: string): Integer;
var
  Q : TADOQuery;
begin
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text   := 'SELECT COUNT(*) FROM [' + ATable + ']';
    try
      Q.Open;
      Result := Q.Fields[0].AsInteger;
      Q.Close;
    except
      Result := -1;
    end;
  finally
    Q.Free;
  end;
end;

function LookupID(AConn: TADOConnection; const ASql: string): Integer;
var
  Q : TADOQuery;
begin
  Result := 0;
  Q := TADOQuery.Create(nil);
  try
    Q.Connection := AConn;
    Q.SQL.Text   := ASql;
    try
      Q.Open;
      if (not Q.IsEmpty) and (not Q.Fields[0].IsNull) then
        Result := Q.Fields[0].AsInteger;
      Q.Close;
    except
      Result := 0;
    end;
  finally
    Q.Free;
  end;
end;

{ ------------------------------------------------------------------------
  البيانات المرجعية الأولية
  ------------------------------------------------------------------------ }
procedure SeedReferenceData(AConn: TADOConnection);

  procedure Exec(const ASql: string);
  begin
    AConn.Execute(ASql);
  end;

  function Empty(const ATable: string): Boolean;
  begin
    Result := TableRowCount(AConn, ATable) = 0;
  end;

  procedure AddSetting(const AKey, AValue: string);
  begin
    { لا تُلمس قيمة ضبطها المستخدم من قبل }
    if LookupID(AConn, 'SELECT COUNT(*) FROM AppSettings WHERE SettingKey = ' +
                SqlStr(AKey)) = 0 then
      Exec('INSERT INTO AppSettings (SettingKey, SettingValue) VALUES (' +
           SqlStr(AKey) + ', ' + SqlStr(AValue) + ')');
  end;

  procedure AddLevel(const AName: string; AOrder: Integer);
  begin
    Exec('INSERT INTO GradeLevels (LevelName, SortOrder) VALUES (' +
         SqlStr(AName) + ', ' + IntToStr(AOrder) + ')');
  end;

  procedure AddSubject(const AName: string; ACoef: Integer);
  begin
    Exec('INSERT INTO Subjects (SubjectName, Coefficient) VALUES (' +
         SqlStr(AName) + ', ' + IntToStr(ACoef) + ')');
  end;

  procedure AddSlot(const ALabel, APart, AStart, AEnd: string; AOrder: Integer);
  begin
    Exec('INSERT INTO TimeSlots (SlotLabel, DayPart, StartTime, EndTime, SortOrder)' +
         ' VALUES (' + SqlStr(ALabel) + ', ' + SqlStr(APart) + ', ' +
         SqlStr(AStart) + ', ' + SqlStr(AEnd) + ', ' + IntToStr(AOrder) + ')');
  end;

  { القسم يُربط بمستواه وسنته بالبحث عن المعرّف، لا بافتراض ترقيم ثابت }
  procedure AddClass(const AName, ALevelName: string);
  var
    Lid, Yid : Integer;
  begin
    Lid := LookupID(AConn, 'SELECT TOP 1 LevelID FROM GradeLevels' +
                           ' WHERE LevelName = ' + SqlStr(ALevelName));
    Yid := LookupID(AConn, 'SELECT TOP 1 YearID FROM SchoolYears' +
                           ' WHERE IsCurrent = True');
    if (Lid = 0) or (Yid = 0) then Exit;
    Exec('INSERT INTO Classes (ClassName, LevelID, YearID, Capacity) VALUES (' +
         SqlStr(AName) + ', ' + IntToStr(Lid) + ', ' + IntToStr(Yid) + ', 40)');
  end;

var
  Y, M, D   : Word;
  YearLabel : string;
begin
  { --- 1. المستخدم الافتراضي : admin / admin ---
    الشرط ليس "الجدول فارغ" بل "لا يوجد حساب مسؤول نشط".
    الشرط القديم كان يترك المستخدم بلا وسيلة دخول في كل حالة يكون فيها
    الجدول غير فارغ لكن بلا حساب صالح : حُذف المسؤول، أو أُوقف، أو غُيّرت
    صلاحيته، أو بقي في الجدول سطر من محاولة تهيئة فاشلة. }
  if LookupID(AConn, 'SELECT COUNT(*) FROM AppUsers' +
                     ' WHERE UserRole = ' + SqlStr('ADMIN') +
                     ' AND IsActive = True') = 0 then
  begin
    if LookupID(AConn, 'SELECT COUNT(*) FROM AppUsers WHERE UserLogin = ' +
                       SqlStr('admin')) > 0 then
      { الحساب موجود لكنه موقوف أو بصلاحية أخرى : يُعاد ضبطه }
      Exec('UPDATE AppUsers SET PassHash = ' + SqlStr(SHA1Hash('admin')) +
           ', UserRole = ' + SqlStr('ADMIN') + ', IsActive = True' +
           ' WHERE UserLogin = ' + SqlStr('admin'))
    else
      Exec('INSERT INTO AppUsers (UserLogin, PassHash, FullName, UserRole,' +
           ' IsActive, CreatedAt) VALUES (' +
           SqlStr('admin') + ', ' + SqlStr(SHA1Hash('admin')) + ', ' +
           SqlStr('مسؤول النظام') + ', ' + SqlStr('ADMIN') + ', True, ' +
           SqlDate(Date) + ')');
  end;

  { --- 2. السنة الدراسية الجارية --- }
  if Empty('SchoolYears') then
  begin
    DecodeDate(Date, Y, M, D);
    if M >= 9 then
      YearLabel := IntToStr(Y) + '/' + IntToStr(Y + 1)
    else
      YearLabel := IntToStr(Y - 1) + '/' + IntToStr(Y);
    Exec('INSERT INTO SchoolYears (YearLabel, StartDate, EndDate, IsCurrent)' +
         ' VALUES (' + SqlStr(YearLabel) + ', ' +
         SqlDate(EncodeDate(StrToInt(Copy(YearLabel, 1, 4)), 9, 1)) + ', ' +
         SqlDate(EncodeDate(StrToInt(Copy(YearLabel, 6, 4)), 7, 5)) + ', True)');
  end;

  { --- 3. المستويات --- }
  if Empty('GradeLevels') then
  begin
    AddLevel('الأولى متوسط',  1);
    AddLevel('الثانية متوسط', 2);
    AddLevel('الثالثة متوسط', 3);
    AddLevel('الرابعة متوسط', 4);
  end;

  { --- 4. الأقسام --- }
  if Empty('Classes') then
  begin
    AddClass('1م1', 'الأولى متوسط');   AddClass('1م2', 'الأولى متوسط');
    AddClass('2م1', 'الثانية متوسط');  AddClass('2م2', 'الثانية متوسط');
    AddClass('3م1', 'الثالثة متوسط');  AddClass('3م2', 'الثالثة متوسط');
    AddClass('4م1', 'الرابعة متوسط');  AddClass('4م2', 'الرابعة متوسط');
  end;

  { --- 5. المواد --- }
  if Empty('Subjects') then
  begin
    AddSubject('اللغة العربية', 5);
    AddSubject('الرياضيات', 4);
    AddSubject('اللغة الفرنسية', 3);
    AddSubject('اللغة الإنجليزية', 2);
    AddSubject('التربية الإسلامية', 2);
    AddSubject('التاريخ والجغرافيا', 3);
    AddSubject('العلوم الطبيعية', 2);
    AddSubject('العلوم الفيزيائية', 2);
    AddSubject('التربية المدنية', 1);
    AddSubject('التربية البدنية والرياضية', 1);
    AddSubject('التربية التشكيلية', 1);
    AddSubject('التربية الموسيقية', 1);
    AddSubject('الإعلام الآلي', 1);
  end;

  { --- 6. الحصص --- }
  if Empty('TimeSlots') then
  begin
    AddSlot('الحصة الأولى',   'صباحية', '08:00', '09:00', 1);
    AddSlot('الحصة الثانية',  'صباحية', '09:00', '10:00', 2);
    AddSlot('الحصة الثالثة',  'صباحية', '10:00', '11:00', 3);
    AddSlot('الحصة الرابعة',  'صباحية', '11:00', '12:00', 4);
    AddSlot('الحصة الخامسة',  'مسائية', '13:00', '14:00', 5);
    AddSlot('الحصة السادسة',  'مسائية', '14:00', '15:00', 6);
    AddSlot('الحصة السابعة',  'مسائية', '15:00', '16:00', 7);
    AddSlot('الحصة الثامنة',  'مسائية', '16:00', '17:00', 8);
  end;

  { --- 7. إعدادات المؤسسة (كل مفتاح على حدة) --- }
  AddSetting('SCHOOL_NAME',   'متوسطة الشهيد بالعربي أحمد');
  AddSetting('DIRECTION',     'مديرية التربية لولاية البيض');
  AddSetting('ADDRESS',       'بلدية سيدي طيفور - ولاية البيض');
  AddSetting('PHONE',         '049657909');
  AddSetting('FAX',           '049657926');
  AddSetting('EMAIL',         'cembelarbi@gmail.com');
  AddSetting('DIRECTOR',      '');
  AddSetting('ADVISOR',       '');
  AddSetting('THRESHOLD_1',   IntToStr(DEF_THRESHOLD_1));
  AddSetting('THRESHOLD_2',   IntToStr(DEF_THRESHOLD_2));
  AddSetting('THRESHOLD_3',   IntToStr(DEF_THRESHOLD_3));
  AddSetting('LOGO_FILE',     '');
  AddSetting('COVER_FILE',    '');
  AddSetting('LANG',          'AR');
  AddSetting('DB_VERSION',    '1.0');
end;

function EnsureDatabase(AConn: TADOConnection): Boolean;
var
  F, Err, CrErr : string;
begin
  Result := False;
  F      := DatabasePath;

  { 1) ملف موجود لكن ترويسته غير معروفة -> ملف تالف، يُحذف بعد موافقة المستخدم }
  if FileExists(F) and SameText(DetectDbFormat(F), 'UNKNOWN') then
  begin
    if not AskYesNo('ملف قاعدة البيانات تالف أو غير صالح :' + #13#10 + F +
                    #13#10 + #13#10 +
                    'هل تريد حذفه وإنشاء قاعدة بيانات جديدة ؟') then
      Exit;
    if not DeleteFile(PChar(F)) then
    begin
      ShowError('تعذر حذف الملف. أغلق أي برنامج يستعمله ثم أعد المحاولة.');
      Exit;
    end;
  end;

  { 2) إنشاء الملف إن لم يكن موجودا }
  if not FileExists(F) then
  begin
    if not CreateEmptyDatabase(F, CrErr) then
    begin
      ShowError('تعذر إنشاء ملف قاعدة البيانات :' + #13#10 + F + #13#10 + #13#10 +
                'سبب الفشل عند كل موفر :' + #13#10 + CrErr + #13#10 +
                'حالة المكونات على هذا الجهاز :' + #13#10 +
                ProviderDiagnostics);
      Exit;
    end;
  end;

  { 3) الفتح : يُختار الموفر حسب الصيغة الحقيقية للملف }
  if not OpenDatabase(AConn, F, Err) then
  begin
    ShowError('تعذر فتح قاعدة البيانات :' + #13#10 + F + #13#10 + #13#10 + Err);
    Exit;
  end;

  { 4) الهيكل والبيانات المرجعية : يُنفَّذان في كل تشغيل، فكلاهما لا يعيد
       إنشاء ما هو موجود، ويكملان أي نقص خلّفه تشغيل سابق فاشل
       (جداول بلا بيانات مثلا). }
  try
    CreateSchema(AConn);
    SeedReferenceData(AConn);
  except
    on E: Exception do
    begin
      ShowError('خطأ أثناء تهيئة قاعدة البيانات :' + #13#10 + E.Message);
      AConn.Connected := False;
      Exit;
    end;
  end;

  Result := True;
end;

{ ------------------------------------------------------------------------
  النسخ الاحتياطي والاسترجاع
  ------------------------------------------------------------------------ }
{ ------------------------------------------------------------------------
  قائمة تلاميذ نموذجية : ناجحو شهادة التعليم المتوسط دورة 2026
  بمتوسطة الشهيد بالعربي أحمد - سيدي طيفور (90 تلميذا).
  الحقول : رقم التسجيل | اللقب | الاسم | تاريخ الميلاد | الجنس | المعدل | الملاحظة
  ------------------------------------------------------------------------ }
function ImportSampleStudents(AConn: TADOConnection; out AError: string): Integer;
const
  SAMPLE : array[0..89] of string = (
    '28436701|حناشي|آية|2009-11-17|F|11,87|مقبول',
    '28436702|مخطاري|آية|2011-06-14|F|17,90|جيد جدا',
    '28436703|محبوبي|آية|2012-02-22|F|13,83|قريب من الجيد',
    '28436706|بالعربي|أحمد الصديق|2010-08-20|M|11,05|مقبول',
    '28436714|سماني|أمينة|2009-03-16|F|12,00|قريب من الجيد',
    '28436718|بن سيرة|أيوب|2011-08-28|M|11,88|مقبول',
    '28436801|الوزاني|إسماعيل|2011-07-23|M|10,08|مقبول',
    '28436802|مخطاري|إشراق جهان|2011-04-05|F|12,06|قريب من الجيد',
    '28436803|قندوزي|إيمان|2009-12-22|F|11,80|مقبول',
    '28436805|بالحاجي|إيمان|2011-06-14|F|12,53|قريب من الجيد',
    '28436806|مجروني|إيمان|2012-03-11|F|15,91|جيد',
    '28436809|زيوش|إيناس|2011-10-23|F|12,78|قريب من الجيد',
    '28436814|مقدم|اكرام|2009-12-21|F|11,52|مقبول',
    '28436816|يعقوبي|الحسن|2011-03-11|M|13,76|قريب من الجيد',
    '28436817|حساني|الحسين|2009-02-18|M|11,83|مقبول',
    '28436902|حساني|بوبكر|2009-12-21|M|10,29|مقبول',
    '28436903|زياني|بوبكر|2010-04-13|M|10,94|مقبول',
    '28436909|بن سليمان|حليمة|2009-01-01|F|11,67|مقبول',
    '28436910|بن سعد|حليمة|2009-08-25|F|11,91|مقبول',
    '28436914|بلخضر|حنان|2008-09-08|F|10,45|مقبول',
    '28436915|حدي|حنان|2011-09-02|F|11,53|مقبول',
    '28436916|طرشي|حورية|2009-11-20|F|12,66|قريب من الجيد',
    '28436918|حناشي|خديجة|2011-01-14|F|12,67|قريب من الجيد',
    '28436919|مخطاري|خديجة|2011-05-14|F|12,93|قريب من الجيد',
    '28437004|بن يوسف|رؤى تسنيم|2011-06-25|F|15,00|جيد',
    '28437005|بوجليدة|رانيا|2010-10-07|F|11,00|مقبول',
    '28437007|بالحاجي|رجاء نور الهدى|2009-04-18|F|11,06|مقبول',
    '28437010|بن يمينة|رفيدة|2011-03-18|F|12,54|قريب من الجيد',
    '28437011|حدي|رفيق|2010-09-18|M|10,48|مقبول',
    '28437017|بوجليدة|زينب|2010-05-09|F|12,68|قريب من الجيد',
    '28437018|بالعربي|سارة|2011-04-27|F|13,85|قريب من الجيد',
    '28437019|بن بغداد|سجى نور اليقين|2011-09-16|F|16,23|جيد جدا',
    '28437020|حواسين|سعاد|2011-02-03|F|13,88|قريب من الجيد',
    '28437101|مجروني|سلسبيل قطر الندى|2011-11-25|F|13,88|قريب من الجيد',
    '28437103|مجروني|سندس|2010-04-23|F|11,79|مقبول',
    '28437104|بن تومي|سوسن|2011-10-18|F|13,77|قريب من الجيد',
    '28437107|حساني|شيماء|2010-09-11|F|10,43|مقبول',
    '28437108|زديمي|شيماء|2011-08-24|F|12,09|قريب من الجيد',
    '28437109|بن تومي|صابرينة|2011-02-08|F|13,77|قريب من الجيد',
    '28437111|زيوش|صورية|2011-08-31|F|12,72|قريب من الجيد',
    '28437114|بن سعد|طه ياسين|2011-07-04|M|10,41|مقبول',
    '28437118|نوي|عامرة|2010-10-26|F|10,88|مقبول',
    '28437119|عبد الغاني|عامرة|2011-11-20|F|12,36|قريب من الجيد',
    '28437201|مجروني|عبد الحق|2011-10-01|M|11,40|مقبول',
    '28437202|بن سليمان|عبد الحكيم|2010-08-02|M|10,31|مقبول',
    '28437210|زديمي|عبد القادر|2011-02-26|M|12,21|قريب من الجيد',
    '28437211|بن سيرة|عبد القادر|2011-08-11|M|11,27|مقبول',
    '28437216|حساني|عبد المطلب|2011-01-10|M|14,16|جيد',
    '28437219|حساني|علاء الدين|2011-06-24|M|12,65|قريب من الجيد',
    '28437303|بن نعيمة|عمر عبد السعيد|2009-09-11|M|10,11|مقبول',
    '28437304|بوصبيع|عيسى|2011-08-19|M|10,31|مقبول',
    '28437308|الهواري|فاطمة الزهراء|2010-11-17|F|11,37|مقبول',
    '28437309|مخطاري|فاطمة الزهراء|2010-12-22|F|12,69|قريب من الجيد',
    '28437310|حساني|فاطمة الزهراء|2011-08-22|F|13,13|قريب من الجيد',
    '28437311|حميدو|فاطمة الزهراء|2011-09-13|F|12,88|قريب من الجيد',
    '28437312|سماني|فاطمة الزهرة|2010-09-25|F|12,15|قريب من الجيد',
    '28437314|معوش|فاطمة شيماء|2011-02-14|F|11,37|مقبول',
    '28437315|حواسين|فاطيمة|2010-01-04|F|12,24|قريب من الجيد',
    '28437316|بالحاجي|فاطيمة|2010-01-13|F|10,00|مقبول',
    '28437317|بن سعد|فاطيمة|2010-04-14|F|12,62|قريب من الجيد',
    '28437318|يعقوبي|فضيلة|2011-08-15|F|16,19|جيد جدا',
    '28437401|بالحاجي|كنزة|2011-08-04|F|11,26|مقبول',
    '28437405|عبد الغاني|كوثر|2011-08-15|F|13,79|قريب من الجيد',
    '28437407|حساني|لطيفة|2010-08-25|F|13,06|قريب من الجيد',
    '28437414|بن سعد|محمد|2011-06-01|M|12,87|قريب من الجيد',
    '28437415|بن تومي|محمد|2011-12-13|M|11,67|مقبول',
    '28437416|مخطاري|محمد أحمد ياسين|2010-08-26|M|10,74|مقبول',
    '28437419|الوزاني|محمد طه|2011-10-06|M|13,35|قريب من الجيد',
    '28437501|نوي|محمد عبد الله|2008-02-04|M|11,09|مقبول',
    '28437502|دربالي|محمد محي الدين|2011-01-30|M|11,13|مقبول',
    '28437507|حواسين|مروة|2010-07-24|F|12,68|قريب من الجيد',
    '28437511|حواسين|مسعودة|2011-04-24|F|11,27|مقبول',
    '28437513|حساني|مصطفى|2009-09-14|M|11,97|مقبول',
    '28437516|حساني|مصطفى مداني|2011-01-31|M|12,54|قريب من الجيد',
    '28437517|حبيبي|منى|2011-10-20|F|10,10|مقبول',
    '28437518|بن سليمان|منير|2009-08-09|M|12,10|قريب من الجيد',
    '28437520|حساني|نجاة|2011-07-25|F|14,62|جيد',
    '28437603|حواسين|نور الدين|2009-05-01|M|10,78|مقبول',
    '28437604|طراشي|نور الهدى|2011-11-01|F|14,33|جيد',
    '28437607|حساني|هدى نور اليقين|2011-05-18|F|15,46|جيد',
    '28437608|بن سعد|هدية|2011-01-03|F|14,98|جيد',
    '28437610|حساني|هديل فاطمة الزهراء|2011-10-03|F|12,48|قريب من الجيد',
    '28437612|مخطاري|هناء|2011-09-28|F|15,64|جيد',
    '28437613|الوزاني|هيثم|2011-08-21|M|10,71|مقبول',
    '28437615|بن سيرة|وفاء|2011-08-05|F|14,15|جيد',
    '28437616|حدي|وفاء رهف|2011-07-09|F|10,72|مقبول',
    '28437617|حساني|ياسر عرفات|2010-08-28|M|10,47|مقبول',
    '28437618|بالعربي|ياسين|2009-10-13|M|12,10|قريب من الجيد',
    '28437619|حواسين|ياسين|2010-10-17|M|13,12|قريب من الجيد',
    '28437620|بن تومي|يحي|2008-07-26|M|10,91|مقبول'
  );
var
  I, Cid1, Cid2, Cid : Integer;
  Parts : TStringList;
  Line, Mat, Nom, Prenom, Sexe, Moy, Men : string;
  Bd : TDateTime;

  { تقسيم السطر على الفاصل | }
  procedure SplitLine(const ALine: string; AList: TStringList);
  var
    K : Integer;
    Cur : string;
  begin
    AList.Clear;
    Cur := '';
    for K := 1 to Length(ALine) do
      if ALine[K] = '|' then
      begin
        AList.Add(Cur);
        Cur := '';
      end
      else
        Cur := Cur + ALine[K];
    AList.Add(Cur);
  end;

begin
  Result := 0;
  AError := '';

  Cid1 := LookupID(AConn, 'SELECT TOP 1 ClassID FROM Classes WHERE ClassName = ' +
                          SqlStr('4م1'));
  Cid2 := LookupID(AConn, 'SELECT TOP 1 ClassID FROM Classes WHERE ClassName = ' +
                          SqlStr('4م2'));
  if (Cid1 = 0) and (Cid2 = 0) then
  begin
    AError := 'لم يُعثر على قسمي 4م1 و 4م2.';
    Exit;
  end;
  if Cid1 = 0 then Cid1 := Cid2;
  if Cid2 = 0 then Cid2 := Cid1;

  Parts := TStringList.Create;
  try
    for I := Low(SAMPLE) to High(SAMPLE) do
    begin
      Line := SAMPLE[I];
      SplitLine(Line, Parts);
      if Parts.Count < 7 then Continue;

      Mat    := Parts[0];
      Nom    := Parts[1];
      Prenom := Parts[2];
      Sexe   := Parts[4];
      Moy    := Parts[5];
      Men    := Parts[6];

      { تجاهل التلميذ إن كان رقم تسجيله مُدرجا من قبل }
      if LookupID(AConn, 'SELECT COUNT(*) FROM Students WHERE MatriculeNat = ' +
                         SqlStr(Mat)) > 0 then
        Continue;

      { تاريخ الميلاد بصيغة yyyy-mm-dd }
      try
        Bd := EncodeDate(StrToInt(Copy(Parts[3], 1, 4)),
                         StrToInt(Copy(Parts[3], 6, 2)),
                         StrToInt(Copy(Parts[3], 9, 2)));
      except
        Continue;
      end;

      { النصف الأول في 4م1 والنصف الثاني في 4م2 }
      if I < 45 then Cid := Cid1 else Cid := Cid2;

      if Sexe = 'M' then Sexe := 'ذكر' else Sexe := 'أنثى';

      try
        AConn.Execute(
          'INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName,' +
          ' Gender, BirthDate, ClassID, RegimeStatus, IsActive, EnrollDate, Notes)' +
          ' VALUES (' +
          SqlStr(Mat) + ', ' + SqlStr(Mat) + ', ' + SqlStr(Nom) + ', ' +
          SqlStr(Prenom) + ', ' + SqlStr(Sexe) + ', ' + SqlDate(Bd) + ', ' +
          IntToStr(Cid) + ', ' + SqlStr('خارجي') + ', True, ' + SqlDate(Date) +
          ', ' + SqlStr('معدل شهادة التعليم المتوسط 2026 : ' + Moy +
                        ' - ' + Men) + ')');
        Inc(Result);
      except
        on E: Exception do
          AError := AError + Mat + ' : ' + E.Message + #13#10;
      end;
    end;
  finally
    Parts.Free;
  end;
end;

{ ------------------------------------------------------------------------
  بيانات تجريبية كاملة : أساتذة، مستخدمون، غيابات وتأخرات، تبريرات،
  إشعارات، أوراق دخول وشهادات مدرسية.

  التوليد شبه عشوائي لكنه ثابت (RandSeed محدد)، فتُنتج نفس البيانات في
  كل مرة، وهو ما يناسب العرض والاختبار. كل خطوة تُتخطى إذا كان جدولها
  يحتوي على بيانات، حتى لا تتضاعف السجلات عند إعادة الضغط على الزر.
  ------------------------------------------------------------------------ }
function ImportDemoData(AConn: TADOConnection;
  out AError: string): TDemoCounts;
const
  TEACHERS : array[0..11] of string = (
    'حساني|عبد الرحمان|اللغة العربية',
    'مخطاري|نادية|الرياضيات',
    'بن سعد|كمال|اللغة الفرنسية',
    'حواسين|سميرة|اللغة الإنجليزية',
    'مجروني|الطيب|التربية الإسلامية',
    'بالحاجي|فاطمة|التاريخ والجغرافيا',
    'زيوش|مراد|العلوم الطبيعية',
    'الوزاني|ليلى|العلوم الفيزيائية',
    'بن تومي|يوسف|التربية المدنية',
    'يعقوبي|رشيد|التربية البدنية والرياضية',
    'سماني|حورية|التربية التشكيلية',
    'بلخضر|عمر|الإعلام الآلي');

  REASONS : array[0..4] of string = (
    'شهادة طبية', 'سبب عائلي', 'مرض', 'ظرف طارئ', 'موعد طبي');

  PERMIT_REASONS : array[0..3] of string = (
    'تأخر عن الدخول', 'موعد طبي', 'سبب عائلي', 'تأخر وسيلة النقل');

  CERT_PURPOSES : array[0..2] of string = (
    'للاستعمال فيما يخدم مصلحة المعني',
    'لتقديمها إلى مصالح الضمان الاجتماعي',
    'لتقديمها إلى البلدية');

var
  C            : TDemoCounts;
  Parts        : TStringList;
  I, J, K, N   : Integer;
  Sid, Slot, Subj, Tch, Nb, Unj : Integer;
  D            : TDateTime;
  Kind, Reason, Kd : string;
  Ids, Slots, Subjs, Tchs : TStringList;
  T1, T2, T3   : Integer;

  procedure Split(const ALine: string; AList: TStringList);
  var
    X : Integer;
    Cur : string;
  begin
    AList.Clear;
    Cur := '';
    for X := 1 to Length(ALine) do
      if ALine[X] = '|' then
      begin
        AList.Add(Cur);
        Cur := '';
      end
      else
        Cur := Cur + ALine[X];
    AList.Add(Cur);
  end;

  { أعمدة جدول في قائمة نصية }
  procedure LoadCol(const ASql: string; AList: TStringList);
  var
    Q : TADOQuery;
  begin
    AList.Clear;
    Q := TADOQuery.Create(nil);
    try
      Q.Connection := AConn;
      Q.SQL.Text := ASql;
      try
        Q.Open;
        while not Q.Eof do
        begin
          AList.Add(Q.Fields[0].AsString);
          Q.Next;
        end;
        Q.Close;
      except
      end;
    finally
      Q.Free;
    end;
  end;

  { يوم عمل : من الأحد إلى الخميس (1=الأحد .. 6=الجمعة، 7=السبت) }
  function IsWorkDay(ADate: TDateTime): Boolean;
  begin
    Result := not (DayOfWeek(ADate) in [6, 7]);
  end;

begin
  FillChar(C, SizeOf(C), 0);
  AError := '';
  RandSeed := 20260915;   { توليد ثابت قابل للتكرار }

  { --- 1) التلاميذ --- }
  C.Students := ImportSampleStudents(AConn, AError);

  Parts := TStringList.Create;
  Ids   := TStringList.Create;
  Slots := TStringList.Create;
  Subjs := TStringList.Create;
  Tchs  := TStringList.Create;
  try
    { --- 2) الأساتذة --- }
    if TableRowCount(AConn, 'Teachers') = 0 then
      for I := Low(TEACHERS) to High(TEACHERS) do
      begin
        Split(TEACHERS[I], Parts);
        if Parts.Count < 3 then Continue;
        Subj := LookupID(AConn, 'SELECT TOP 1 SubjectID FROM Subjects' +
                                ' WHERE SubjectName = ' + SqlStr(Parts[2]));
        try
          AConn.Execute(
            'INSERT INTO Teachers (LastName, FirstName, Phone, SubjectID)' +
            ' VALUES (' + SqlStr(Parts[0]) + ', ' + SqlStr(Parts[1]) + ', ' +
            SqlStr('05' + Format('%.8d', [10000000 + Random(89999999)])) + ', ' +
            IfThenStr(Subj = 0, 'NULL', IntToStr(Subj)) + ')');
          Inc(C.Teachers);
        except
        end;
      end;

    { --- 3) مستخدمون إضافيون --- }
    if LookupID(AConn, 'SELECT COUNT(*) FROM AppUsers WHERE UserLogin = ' +
                       SqlStr('conseiller')) = 0 then
    begin
      AConn.Execute('INSERT INTO AppUsers (UserLogin, PassHash, FullName,' +
        ' UserRole, IsActive, CreatedAt) VALUES (' + SqlStr('conseiller') +
        ', ' + SqlStr(SHA1Hash('conseiller')) + ', ' +
        SqlStr('حواسين فاطيمة') + ', ' + SqlStr('ADVISOR') + ', True, ' +
        SqlDate(Date) + ')');
      Inc(C.Users);
    end;
    if LookupID(AConn, 'SELECT COUNT(*) FROM AppUsers WHERE UserLogin = ' +
                       SqlStr('surveillant')) = 0 then
    begin
      AConn.Execute('INSERT INTO AppUsers (UserLogin, PassHash, FullName,' +
        ' UserRole, IsActive, CreatedAt) VALUES (' + SqlStr('surveillant') +
        ', ' + SqlStr(SHA1Hash('surveillant')) + ', ' +
        SqlStr('بن سعد محمد') + ', ' + SqlStr('SUPERV') + ', True, ' +
        SqlDate(Date) + ')');
      Inc(C.Users);
    end;

    LoadCol('SELECT StudentID FROM Students WHERE IsActive = True', Ids);
    LoadCol('SELECT SlotID FROM TimeSlots ORDER BY SortOrder', Slots);
    LoadCol('SELECT SubjectID FROM Subjects', Subjs);
    LoadCol('SELECT TeacherID FROM Teachers', Tchs);

    if (Ids.Count = 0) or (Slots.Count = 0) then
    begin
      AError := AError + 'لا يوجد تلاميذ أو حصص لتوليد الغيابات.' + #13#10;
      Result := C;
      Exit;
    end;

    { --- 4) الغيابات والتأخرات خلال آخر 80 يوما --- }
    if TableRowCount(AConn, 'Absences') = 0 then
      for I := 0 to Ids.Count - 1 do
      begin
        Sid := StrToIntDef(Ids[I], 0);
        if Sid = 0 then Continue;

        N := Random(11);            { من 0 إلى 10 حالات لكل تلميذ }
        for J := 1 to N do
        begin
          { يوم عمل عشوائي ضمن آخر 80 يوما }
          K := 0;
          repeat
            D := Date - Random(80);
            Inc(K);
          until IsWorkDay(D) or (K > 20);
          if not IsWorkDay(D) then Continue;

          Slot := StrToIntDef(Slots[Random(Slots.Count)], 0);
          if Slot = 0 then Continue;

          if Random(100) < 18 then Kind := 'LATE' else Kind := 'ABS';

          if Random(100) < 40 then
          begin
            Kd     := 'True';
            Reason := REASONS[Random(High(REASONS) + 1)];
          end
          else
          begin
            Kd     := 'False';
            Reason := '';
          end;

          if Subjs.Count > 0 then
            Subj := StrToIntDef(Subjs[Random(Subjs.Count)], 0)
          else
            Subj := 0;
          if Tchs.Count > 0 then
            Tch := StrToIntDef(Tchs[Random(Tchs.Count)], 0)
          else
            Tch := 0;

          try
            { الفهرس الفريد يمنع تكرار نفس التلميذ/التاريخ/الحصة،
              والاستثناء يُتجاهل ببساطة }
            AConn.Execute(
              'INSERT INTO Absences (StudentID, AbsDate, SlotID, SubjectID,' +
              ' TeacherID, AbsKind, LateMinutes, Justified, JustifyDate,' +
              ' JustifyReason, RecordedAt) VALUES (' +
              IntToStr(Sid) + ', ' + SqlDate(D) + ', ' + IntToStr(Slot) + ', ' +
              IfThenStr(Subj = 0, 'NULL', IntToStr(Subj)) + ', ' +
              IfThenStr(Tch = 0, 'NULL', IntToStr(Tch)) + ', ' +
              SqlStr(Kind) + ', ' +
              IfThenStr(Kind = 'LATE', IntToStr(5 + Random(26)), '0') + ', ' +
              Kd + ', ' +
              IfThenStr(Kd = 'True', SqlDate(D + 1), 'NULL') + ', ' +
              SqlStr(Reason) + ', ' + SqlDate(D) + ')');
            Inc(C.Absences);
            if Kd = 'True' then Inc(C.Justified);
          except
          end;
        end;
      end;

    { --- 5) الإشعارات حسب العتبات --- }
    T1 := 3; T2 := 6; T3 := 10;
    if TableRowCount(AConn, 'Notices') = 0 then
      for I := 0 to Ids.Count - 1 do
      begin
        Sid := StrToIntDef(Ids[I], 0);
        if Sid = 0 then Continue;
        Unj := LookupID(AConn, 'SELECT COUNT(*) FROM Absences WHERE StudentID = ' +
                               IntToStr(Sid) + ' AND AbsKind = ' + SqlStr('ABS') +
                               ' AND Justified = False');
        Kind := '';
        if Unj >= T3 then Kind := 'RAD'
        else if Unj >= T2 then Kind := 'N2'
        else if Unj >= T1 then Kind := 'N1';
        if Kind = '' then Continue;

        try
          AConn.Execute(
            'INSERT INTO Notices (StudentID, NoticeKind, NoticeNo, IssueDate,' +
            ' MeetDate, MeetTime, NoticeTopic, AbsCount, Delivered) VALUES (' +
            IntToStr(Sid) + ', ' + SqlStr(Kind) + ', ' +
            SqlStr(Format('%.3d/2026', [C.Notices + 1])) + ', ' +
            SqlDate(Date - Random(20)) + ', ' + SqlDate(Date + 3) + ', ' +
            SqlStr('10:00') + ', ' +
            SqlStr('إشعار بالغياب وتبرير أسباب عدم مزاولة الدراسة') + ', ' +
            IntToStr(Unj) + ', ' + IfThenStr(Random(100) < 60, 'True', 'False') +
            ')');
          Inc(C.Notices);
        except
        end;
      end;

    { --- 6) أوراق الدخول --- }
    if TableRowCount(AConn, 'EntryPermits') = 0 then
      for J := 1 to 18 do
      begin
        Sid := StrToIntDef(Ids[Random(Ids.Count)], 0);
        if Sid = 0 then Continue;
        K := 0;
        repeat
          D := Date - Random(40);
          Inc(K);
        until IsWorkDay(D) or (K > 20);
        try
          AConn.Execute(
            'INSERT INTO EntryPermits (StudentID, PermitDate, EntryTime, Reason)' +
            ' VALUES (' + IntToStr(Sid) + ', ' + SqlDate(D) + ', ' +
            SqlStr(Format('%.2d:%.2d', [8 + Random(3), Random(2) * 30])) + ', ' +
            SqlStr(PERMIT_REASONS[Random(High(PERMIT_REASONS) + 1)]) + ')');
          Inc(C.Permits);
        except
        end;
      end;

    { --- 7) الشهادات المدرسية --- }
    if TableRowCount(AConn, 'Certificates') = 0 then
      for J := 1 to 12 do
      begin
        Sid := StrToIntDef(Ids[Random(Ids.Count)], 0);
        if Sid = 0 then Continue;
        try
          AConn.Execute(
            'INSERT INTO Certificates (CertNo, StudentID, IssueDate, YearID,' +
            ' Purpose, CopiesNo) VALUES (' + IntToStr(J) + ', ' + IntToStr(Sid) +
            ', ' + SqlDate(Date - Random(50)) + ', ' +
            IntToStr(LookupID(AConn, 'SELECT TOP 1 YearID FROM SchoolYears' +
                                     ' WHERE IsCurrent = True')) + ', ' +
            SqlStr(CERT_PURPOSES[Random(High(CERT_PURPOSES) + 1)]) + ', 3)');
          Inc(C.Certificates);
        except
        end;
      end;

  finally
    Parts.Free; Ids.Free; Slots.Free; Subjs.Free; Tchs.Free;
  end;

  Result := C;
end;

function BackupDatabase(const ATargetFile: string): Boolean;
begin
  Result := CopyFile(PChar(DatabasePath), PChar(ATargetFile), False);
end;

function RestoreDatabase(const ASourceFile: string): Boolean;
begin
  Result := CopyFile(PChar(ASourceFile), PChar(DatabasePath), False);
end;

end.
