unit uDB;

{ =============================================================================
  وحدة إنشاء وإدارة قاعدة بيانات Microsoft Access
  Creation / ouverture de la base Access (Jet 4.0 - ACE 12.0).

  عند أول تشغيل ينشئ البرنامج الملف Data\GestionAbsences.mdb
  ثم ينشئ الجداول ويملأ البيانات المرجعية تلقائيا.
  ============================================================================= }

interface

uses
  Windows, SysUtils, Classes, ADODB, ComObj, Variants, Forms, Registry;

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
procedure SeedReferenceData(AConn: TADOConnection);
function  EnsureDatabase(AConn: TADOConnection): Boolean;
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
var
  I : Integer;
begin
  for I := Low(DDL) to High(DDL) do
    AConn.Execute(DDL[I]);
end;

{ ------------------------------------------------------------------------
  البيانات المرجعية الأولية
  ------------------------------------------------------------------------ }
procedure SeedReferenceData(AConn: TADOConnection);

  procedure Exec(const ASql: string);
  begin
    AConn.Execute(ASql);
  end;

  procedure AddSetting(const AKey, AValue: string);
  begin
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

  procedure AddClass(const AName: string; ALevel: Integer);
  begin
    Exec('INSERT INTO Classes (ClassName, LevelID, YearID, Capacity) VALUES (' +
         SqlStr(AName) + ', ' + IntToStr(ALevel) + ', 1, 40)');
  end;

var
  Y : Word;
  M, D : Word;
  YearLabel : string;
begin
  { --- المستخدم الافتراضي : admin / admin --- }
  Exec('INSERT INTO AppUsers (UserLogin, PassHash, FullName, UserRole, IsActive, CreatedAt)' +
       ' VALUES (' + SqlStr('admin') + ', ' + SqlStr(SHA1Hash('admin')) + ', ' +
       SqlStr('مسؤول النظام') + ', ' + SqlStr('ADMIN') + ', True, ' +
       SqlDate(Date) + ')');

  { --- السنة الدراسية الجارية --- }
  DecodeDate(Date, Y, M, D);
  if M >= 9 then
    YearLabel := IntToStr(Y) + '/' + IntToStr(Y + 1)
  else
    YearLabel := IntToStr(Y - 1) + '/' + IntToStr(Y);
  Exec('INSERT INTO SchoolYears (YearLabel, StartDate, EndDate, IsCurrent) VALUES (' +
       SqlStr(YearLabel) + ', ' + SqlDate(EncodeDate(StrToInt(Copy(YearLabel,1,4)), 9, 1)) +
       ', ' + SqlDate(EncodeDate(StrToInt(Copy(YearLabel,6,4)), 7, 5)) + ', True)');

  { --- المستويات --- }
  AddLevel('الأولى متوسط',  1);
  AddLevel('الثانية متوسط', 2);
  AddLevel('الثالثة متوسط', 3);
  AddLevel('الرابعة متوسط', 4);

  { --- الأقسام --- }
  AddClass('1م1', 1);  AddClass('1م2', 1);
  AddClass('2م1', 2);  AddClass('2م2', 2);
  AddClass('3م1', 3);  AddClass('3م2', 3);
  AddClass('4م1', 4);  AddClass('4م2', 4);

  { --- المواد --- }
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

  { --- الحصص --- }
  AddSlot('الحصة الأولى',   'صباحية', '08:00', '09:00', 1);
  AddSlot('الحصة الثانية',  'صباحية', '09:00', '10:00', 2);
  AddSlot('الحصة الثالثة',  'صباحية', '10:00', '11:00', 3);
  AddSlot('الحصة الرابعة',  'صباحية', '11:00', '12:00', 4);
  AddSlot('الحصة الخامسة',  'مسائية', '13:00', '14:00', 5);
  AddSlot('الحصة السادسة',  'مسائية', '14:00', '15:00', 6);
  AddSlot('الحصة السابعة',  'مسائية', '15:00', '16:00', 7);
  AddSlot('الحصة الثامنة',  'مسائية', '16:00', '17:00', 8);

  { --- إعدادات المؤسسة --- }
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
  AddSetting('LANG',          'AR');   { AR = العربية / FR = الفرنسية }
  AddSetting('DB_VERSION',    '1.0');
end;

{ ------------------------------------------------------------------------
  التأكد من وجود القاعدة وإنشاؤها عند الحاجة
  ------------------------------------------------------------------------ }
function TableExists(AConn: TADOConnection; const ATable: string): Boolean;
var
  L : TStringList;
begin
  Result := False;
  L := TStringList.Create;
  try
    try
      AConn.GetTableNames(L, False);
      Result := L.IndexOf(ATable) >= 0;
    except
      Result := False;
    end;
  finally
    L.Free;
  end;
end;

function EnsureDatabase(AConn: TADOConnection): Boolean;
var
  F, Err, CrErr : string;
  Fresh         : Boolean;
begin
  Result := False;
  F      := DatabasePath;
  Fresh  := False;

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
    Fresh := True;
  end;

  { 3) الفتح : يُختار الموفر حسب الصيغة الحقيقية للملف }
  if not OpenDatabase(AConn, F, Err) then
  begin
    ShowError('تعذر فتح قاعدة البيانات :' + #13#10 + F + #13#10 + #13#10 + Err);
    Exit;
  end;

  { 4) إنشاء الهيكل إذا كانت القاعدة فارغة
       (ملف جديد، أو ملف ناقص خلّفه تشغيل سابق فاشل) }
  if Fresh or (not TableExists(AConn, 'AppUsers')) then
  begin
    try
      CreateSchema(AConn);
      SeedReferenceData(AConn);
    except
      on E: Exception do
      begin
        ShowError('خطأ أثناء إنشاء جداول قاعدة البيانات :' + #13#10 + E.Message);
        AConn.Connected := False;
        Exit;
      end;
    end;
  end;

  Result := True;
end;

{ ------------------------------------------------------------------------
  النسخ الاحتياطي والاسترجاع
  ------------------------------------------------------------------------ }
function BackupDatabase(const ATargetFile: string): Boolean;
begin
  Result := CopyFile(PChar(DatabasePath), PChar(ATargetFile), False);
end;

function RestoreDatabase(const ASourceFile: string): Boolean;
begin
  Result := CopyFile(PChar(ASourceFile), PChar(DatabasePath), False);
end;

end.
