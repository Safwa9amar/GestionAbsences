/* =========================================================================
   قاعدة بيانات : تسيير الغيابات اليومية للتلاميذ
   Base de donnees : Gestion des absences journalieres des eleves
   SGBD : Microsoft Access (Jet 4.0 / ACE) -- Fichier : GestionAbsences.mdb
   -------------------------------------------------------------------------
   ملاحظة : برنامج Access لا ينفذ الا تعليمة واحدة في كل مرة.
   هذا الملف للتوثيق وللتنفيذ اليدوي. التطبيق ينشئ القاعدة تلقائيا (uDB.pas).
   ========================================================================= */

/* --- 1. المستخدمون / Utilisateurs ------------------------------------- */
CREATE TABLE AppUsers (
    UserID       COUNTER      CONSTRAINT PK_AppUsers PRIMARY KEY,
    UserLogin    TEXT(50)     NOT NULL,
    PassHash     TEXT(64)     NOT NULL,
    FullName     TEXT(80),
    UserRole     TEXT(20)     NOT NULL,
    IsActive     BIT          NOT NULL,
    CreatedAt    DATETIME
);
CREATE UNIQUE INDEX IX_AppUsers_Login ON AppUsers (UserLogin);

/* --- 2. السنوات الدراسية / Annees scolaires --------------------------- */
CREATE TABLE SchoolYears (
    YearID       COUNTER      CONSTRAINT PK_SchoolYears PRIMARY KEY,
    YearLabel    TEXT(20)     NOT NULL,
    StartDate    DATETIME,
    EndDate      DATETIME,
    IsCurrent    BIT          NOT NULL
);
CREATE UNIQUE INDEX IX_SchoolYears_Label ON SchoolYears (YearLabel);

/* --- 3. المستويات / Niveaux ------------------------------------------- */
CREATE TABLE GradeLevels (
    LevelID      COUNTER      CONSTRAINT PK_GradeLevels PRIMARY KEY,
    LevelName    TEXT(40)     NOT NULL,
    SortOrder    INTEGER
);

/* --- 4. الأقسام / Classes --------------------------------------------- */
CREATE TABLE Classes (
    ClassID      COUNTER      CONSTRAINT PK_Classes PRIMARY KEY,
    ClassName    TEXT(40)     NOT NULL,
    LevelID      INTEGER,
    YearID       INTEGER,
    RoomName     TEXT(40),
    Capacity     INTEGER,
    CONSTRAINT FK_Classes_Level  FOREIGN KEY (LevelID) REFERENCES GradeLevels (LevelID),
    CONSTRAINT FK_Classes_Year   FOREIGN KEY (YearID)  REFERENCES SchoolYears (YearID)
);

/* --- 5. المواد / Matieres --------------------------------------------- */
CREATE TABLE Subjects (
    SubjectID    COUNTER      CONSTRAINT PK_Subjects PRIMARY KEY,
    SubjectName  TEXT(60)     NOT NULL,
    Coefficient  INTEGER
);

/* --- 6. الأساتذة / Enseignants ---------------------------------------- */
CREATE TABLE Teachers (
    TeacherID    COUNTER      CONSTRAINT PK_Teachers PRIMARY KEY,
    LastName     TEXT(40)     NOT NULL,
    FirstName    TEXT(40),
    Phone        TEXT(20),
    Email        TEXT(60),
    SubjectID    INTEGER,
    CONSTRAINT FK_Teachers_Subject FOREIGN KEY (SubjectID) REFERENCES Subjects (SubjectID)
);

/* --- 7. الحصص / Creneaux horaires ------------------------------------- */
CREATE TABLE TimeSlots (
    SlotID       COUNTER      CONSTRAINT PK_TimeSlots PRIMARY KEY,
    SlotLabel    TEXT(30)     NOT NULL,
    DayPart      TEXT(20),
    StartTime    TEXT(5),
    EndTime      TEXT(5),
    SortOrder    INTEGER
);

/* --- 8. التلاميذ / Eleves --------------------------------------------- */
CREATE TABLE Students (
    StudentID        COUNTER   CONSTRAINT PK_Students PRIMARY KEY,
    MatriculeNat     TEXT(20),
    RegNumber        TEXT(20),
    LastName         TEXT(40)  NOT NULL,
    FirstName        TEXT(40)  NOT NULL,
    Gender           TEXT(10),
    BirthDate        DATETIME,
    BirthPlace       TEXT(60),
    ClassID          INTEGER,
    RegimeStatus     TEXT(20),
    FatherName       TEXT(60),
    MotherName       TEXT(60),
    SocialStatus     TEXT(30),
    SiblingsCount    INTEGER,
    SiblingsSchooled INTEGER,
    GuardianName     TEXT(60),
    GuardianPhone    TEXT(20),
    GuardianEmail    TEXT(60),
    GuardianAddr     TEXT(120),
    EnrollDate       DATETIME,
    ExitDate         DATETIME,
    IsActive         BIT       NOT NULL,
    PhotoPath        TEXT(150),
    Notes            MEMO,
    CONSTRAINT FK_Students_Class FOREIGN KEY (ClassID) REFERENCES Classes (ClassID)
);
CREATE INDEX IX_Students_Class ON Students (ClassID);
CREATE INDEX IX_Students_Name  ON Students (LastName, FirstName);

/* --- 9. الغيابات والتأخرات / Absences et retards ---------------------- */
CREATE TABLE Absences (
    AbsenceID     COUNTER     CONSTRAINT PK_Absences PRIMARY KEY,
    StudentID     INTEGER     NOT NULL,
    AbsDate       DATETIME    NOT NULL,
    SlotID        INTEGER     NOT NULL,
    SubjectID     INTEGER,
    TeacherID     INTEGER,
    AbsKind       TEXT(20)    NOT NULL,
    LateMinutes   INTEGER,
    Justified     BIT         NOT NULL,
    JustifyDate   DATETIME,
    JustifyReason TEXT(120),
    RecordedBy    INTEGER,
    RecordedAt    DATETIME,
    Notes         TEXT(150),
    CONSTRAINT FK_Abs_Student FOREIGN KEY (StudentID) REFERENCES Students  (StudentID),
    CONSTRAINT FK_Abs_Slot    FOREIGN KEY (SlotID)    REFERENCES TimeSlots (SlotID),
    CONSTRAINT FK_Abs_Subject FOREIGN KEY (SubjectID) REFERENCES Subjects  (SubjectID),
    CONSTRAINT FK_Abs_Teacher FOREIGN KEY (TeacherID) REFERENCES Teachers  (TeacherID)
);
CREATE UNIQUE INDEX IX_Abs_Unique ON Absences (StudentID, AbsDate, SlotID);
CREATE INDEX IX_Abs_Date ON Absences (AbsDate);

/* --- 10. الإشعارات / Notifications ------------------------------------ */
CREATE TABLE Notices (
    NoticeID     COUNTER      CONSTRAINT PK_Notices PRIMARY KEY,
    StudentID    INTEGER      NOT NULL,
    NoticeKind   TEXT(30)     NOT NULL,
    NoticeNo     TEXT(20),
    IssueDate    DATETIME     NOT NULL,
    MeetDate     DATETIME,
    MeetTime     TEXT(5),
    NoticeTopic  TEXT(150),
    RefNoticeID  INTEGER,
    AbsCount     INTEGER,
    IssuedBy     INTEGER,
    Delivered    BIT          NOT NULL,
    Notes        MEMO,
    CONSTRAINT FK_Notice_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);
CREATE INDEX IX_Notices_Student ON Notices (StudentID);

/* --- 11. ورقة الدخول / Billets d'entree ------------------------------- */
CREATE TABLE EntryPermits (
    PermitID     COUNTER      CONSTRAINT PK_EntryPermits PRIMARY KEY,
    StudentID    INTEGER      NOT NULL,
    PermitDate   DATETIME     NOT NULL,
    EntryTime    TEXT(5),
    Reason       TEXT(120),
    IssuedBy     INTEGER,
    CONSTRAINT FK_Permit_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

/* --- 12. الشهادات المدرسية / Certificats de scolarite ----------------- */
CREATE TABLE Certificates (
    CertID       COUNTER      CONSTRAINT PK_Certificates PRIMARY KEY,
    CertNo       INTEGER,
    StudentID    INTEGER      NOT NULL,
    IssueDate    DATETIME     NOT NULL,
    YearID       INTEGER,
    Purpose      TEXT(100),
    CopiesNo     INTEGER,
    IssuedBy     INTEGER,
    CONSTRAINT FK_Cert_Student FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

/* --- 13. إعدادات المؤسسة / Parametres --------------------------------- */
CREATE TABLE AppSettings (
    SettingKey   TEXT(50)     CONSTRAINT PK_AppSettings PRIMARY KEY,
    SettingValue TEXT(200)
);
