unit uMain;

{ النافذة الرئيسية / Fenetre principale }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ExtCtrls, StdCtrls, ImgList;

type
  TfrmMain = class(TForm)
    mnu             : TMainMenu;
    miFile          : TMenuItem;
    miLogout        : TMenuItem;
    miSep1          : TMenuItem;
    miExit          : TMenuItem;
    miData          : TMenuItem;
    miStudents      : TMenuItem;
    miRefData       : TMenuItem;
    miAbsence       : TMenuItem;
    miDailyAbs      : TMenuItem;
    miJustify       : TMenuItem;
    miDocs          : TMenuItem;
    miNotices       : TMenuItem;
    miPermit        : TMenuItem;
    miCertificate   : TMenuItem;
    miReports       : TMenuItem;
    miRepDaily      : TMenuItem;
    miRepRegister   : TMenuItem;
    miRepStats      : TMenuItem;
    miTools         : TMenuItem;
    miUsers         : TMenuItem;
    miSettings      : TMenuItem;
    miLang          : TMenuItem;
    miLangAR        : TMenuItem;
    miLangFR        : TMenuItem;
    miSep2          : TMenuItem;
    miSampleData    : TMenuItem;
    miBackup        : TMenuItem;
    miRestore       : TMenuItem;
    miHelp          : TMenuItem;
    miAbout         : TMenuItem;
    sb              : TStatusBar;
    pnlClient       : TPanel;
    imgCover        : TImage;
    pnlHeader       : TPanel;
    imgLogo         : TImage;
    lblWelcome      : TLabel;
    lblSchool       : TLabel;
    lblYear         : TLabel;
    pnlCards        : TPanel;
    tmr             : TTimer;
    dlgSave         : TSaveDialog;
    dlgOpen         : TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miExitClick(Sender: TObject);
    procedure miLogoutClick(Sender: TObject);
    procedure miStudentsClick(Sender: TObject);
    procedure miRefDataClick(Sender: TObject);
    procedure miDailyAbsClick(Sender: TObject);
    procedure miJustifyClick(Sender: TObject);
    procedure miNoticesClick(Sender: TObject);
    procedure miPermitClick(Sender: TObject);
    procedure miCertificateClick(Sender: TObject);
    procedure miReportsClick(Sender: TObject);
    procedure miUsersClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miSampleDataClick(Sender: TObject);
    procedure miBackupClick(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miLangClick(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure pnlCardsResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CardClick(Sender: TObject);
    procedure CardMouseEnter(Sender: TObject);
    procedure CardMouseLeave(Sender: TObject);
  private
    FCards     : array[0..8] of TPanel;
    FCardTitle : array[0..8] of TLabel;
    FCardSub   : array[0..8] of TLabel;
    FCardValue : array[0..8] of TLabel;
    FCardBar   : array[0..8] of TPanel;
    FCardBack  : array[0..8] of TImage;    { الخلفية المرسومة داخل البطاقة }
    FCardPhoto : array[0..8] of TBitmap;   { الصورة الأصلية، تُقرأ مرة واحدة }
    procedure ApplyCaptions;
    procedure ApplyRights;
    procedure BuildCards;
    procedure LayoutCards;
    procedure UpdateCardTexts;
    procedure RenderCardBack(AIndex: Integer; AHover: Boolean);
    procedure LoadBranding;
  public
    procedure RefreshDashboard;
  end;

var
  frmMain : TfrmMain;

implementation

{$R *.dfm}

uses
  uLang, uUtils, uDB, dmMain, uStudents, uRefData, uAbsence, uJustify,
  uNotices, uDocs, uReports, uUsers, uSettings, uLogin;

{ ------------------------------------------------------------------------ }

procedure TfrmMain.ApplyCaptions;
begin
  Caption            := R_AppTitle;

  miFile.Caption     := R_MnuFile;
  miLogout.Caption   := R_MnuLogout;
  miExit.Caption     := R_MnuExit;

  miData.Caption     := R_MnuData;
  miStudents.Caption := R_MnuStudents;
  miRefData.Caption  := R_RefTitle;

  miAbsence.Caption  := R_MnuAbsence;
  miDailyAbs.Caption := R_MnuDailyAbs;
  miJustify.Caption  := R_MnuJustify;

  miDocs.Caption        := R_MnuDocs;
  miNotices.Caption     := R_MnuNotices;
  miPermit.Caption      := R_MnuPermit;
  miCertificate.Caption := R_MnuCertificate;

  miReports.Caption     := R_MnuReports;
  miRepDaily.Caption    := R_MnuDailyRep;
  miRepRegister.Caption := R_MnuAbsRegister;
  miRepStats.Caption    := R_MnuStats;

  miTools.Caption    := R_MnuTools;
  miUsers.Caption    := R_MnuUsers;
  miSettings.Caption := R_MnuSettings;
  miLang.Caption     := R_LangMenu;
  miLangAR.Caption   := R_LangArabic;
  miLangFR.Caption   := R_LangFrench;
  miLangAR.Checked   := CurrentLang = langAR;
  miLangFR.Checked   := CurrentLang = langFR;
  miSampleData.Caption := R_MnuSampleData;
  miBackup.Caption   := R_MnuBackup;
  miRestore.Caption  := R_MnuRestore;

  miHelp.Caption     := R_MnuHelp;
  miAbout.Caption    := R_MnuAbout;

end;

procedure TfrmMain.ApplyRights;
var
  Admin : Boolean;
begin
  Admin := dm.IsAdmin;
  miUsers.Enabled    := Admin;
  miSettings.Enabled := Admin;
  miRestore.Enabled  := Admin;
  miSampleData.Enabled := Admin;
  if FCards[7] <> nil then FCards[7].Enabled := Admin;
  if FCards[8] <> nil then FCards[8].Enabled := Admin;
  RenderCardBack(7, False);
  RenderCardBack(8, False);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ApplyCaptions;
  ApplyRTL(Self);
  { البطاقات تُنشأ بعد عكس التخطيط : LayoutCards يتكفل بترتيبها حسب الاتجاه }
  BuildCards;
  WindowState := wsMaximized;

  dlgSave.Filter := 'Access Database (*.mdb)|*.mdb';
  dlgOpen.Filter := 'Access Database (*.mdb)|*.mdb';
  dlgSave.DefaultExt := 'mdb';
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  { الصور النقطية ليست مكوّنات، فلا يحرّرها النموذج تلقائيا }
  for I := 0 to 8 do
    FreeAndNil(FCardPhoto[I]);
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  ApplyRights;
  RefreshDashboard;
  tmrTimer(nil);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Application.Terminate;
end;

procedure TfrmMain.RefreshDashboard;
begin
  lblWelcome.Caption := R_LoginWelcome + dm.CurrentUserName;
  lblSchool.Caption  := dm.GetSetting('SCHOOL_NAME', R_SchoolDefault) + '  -  ' +
                        dm.GetSetting('ADDRESS', R_PlaceDefault);
  lblYear.Caption    := R_LblYear + dm.CurrentYearLabel;
  LoadBranding;
  UpdateCardTexts;
end;

{ ========================================================================
  بطاقات الصفحة الرئيسية : شبكة 3 × 3، كل بطاقة تفتح واجهة
  Cartes de l'accueil : grille 3 x 3, chaque carte ouvre un ecran
  ======================================================================== }

const
  { لون مميز لكل بطاقة : شريط علوي رفيع ورقم بارز.
    الخلفية بيضاء، وعند مرور الفأرة تأخذ درجة فاتحة جدا من لون البطاقة. }
  CARD_ACCENT : array[0..8] of TColor =
    ($00F97F2D,   { التلاميذ            - أزرق  }
     $004AA316,   { الغيابات اليومية    - أخضر  }
     $000677D9,   { تبرير الغيابات      - كهرماني }
     $00481DE1,   { الإشعارات           - وردي  }
     $0088940D,   { الوثائق             - فيروزي }
     $00E5464F,   { التقارير            - بنفسجي }
     $00B29108,   { البيانات الأساسية   - سماوي }
     $00695547,   { المستخدمون          - رمادي }
     $00ED377C);  { الإعدادات           - أرجواني }

  CARD_TINT : array[0..8] of TColor =
    ($00FEF2EA, $00EFF7E9, $00E7F3FD, $00EFEAFC, $00F3F4E6,
     $00FCECED, $00F8F4E6, $00F4F1EF, $00FDEBF1);

  { صورة خلفية لكل بطاقة، من مجلد Assets\Cards. البطاقة التي لا تجد
    صورتها تبقى بيضاء كما كانت، فلا يتعطل شيء إذا نقص ملف. }
  CARD_IMAGE : array[0..8] of string =
    ('Cards\students.jpg',   { التلاميذ           }
     'Cards\absence.jpg',    { الغيابات اليومية   }
     'Cards\justify.jpg',    { تبرير الغيابات     }
     'Cards\notices.jpg',    { الإشعارات          }
     'Cards\docs.jpg',       { الوثائق            }
     'Cards\reports.jpg',    { التقارير           }
     'Cards\refdata.jpg',    { البيانات الأساسية  }
     'Cards\users.jpg',      { المستخدمون         }
     'Cards\settings.jpg');  { الإعدادات          }

  { وزن اللون في مزج الخلفية : كلما ارتفع بهتت الصورة وزاد وضوح النص }
  WASH_NORMAL   = 224;
  WASH_HOVER    = 196;
  WASH_DISABLED = 244;

procedure TfrmMain.BuildCards;
var
  I : Integer;
  P : TPanel;

  function NewLabel(AParent: TWinControl; AFontHeight: Integer;
    ABold: Boolean; AColor: TColor; AIndex: Integer): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent      := AParent;
    Result.AutoSize    := False;
    Result.Alignment   := taCenter;
    Result.Layout      := tlCenter;
    Result.Transparent := True;
    Result.ParentFont  := False;
    Result.Font.Name    := 'Tahoma';
    Result.Font.Charset := ARABIC_CHARSET;
    Result.Font.Height  := AFontHeight;
    Result.Font.Color   := AColor;
    if ABold then
      Result.Font.Style := [fsBold];
    Result.Cursor  := crHandPoint;
    Result.Tag     := AIndex;
    Result.OnClick := CardClick;
  end;

begin
  for I := 0 to 8 do
  begin
    P := TPanel.Create(Self);
    P.Parent           := pnlCards;
    P.BevelOuter       := bvNone;
    P.BorderStyle      := bsSingle;
    P.Color            := clWhite;
    P.ParentBackground := False;
    P.Cursor           := crHandPoint;
    P.Tag              := I;
    P.OnClick          := CardClick;
    P.OnMouseEnter     := CardMouseEnter;
    P.OnMouseLeave     := CardMouseLeave;
    FCards[I] := P;

    { شريط علوي رفيع بلون البطاقة }
    FCardBar[I] := TPanel.Create(Self);
    FCardBar[I].Parent           := P;
    FCardBar[I].Align            := alTop;
    FCardBar[I].Height           := 5;
    FCardBar[I].BevelOuter       := bvNone;
    FCardBar[I].Color            := CARD_ACCENT[I];
    FCardBar[I].ParentBackground := False;
    FCardBar[I].Cursor           := crHandPoint;
    FCardBar[I].Tag              := I;
    FCardBar[I].OnClick          := CardClick;

    { الخلفية تُنشأ قبل التسميات : المكونات الرسومية تُرسم بترتيب إنشائها،
      فيبقى النص فوق الصورة. }
    FCardPhoto[I] := LoadPictureBitmap(AssetPath(CARD_IMAGE[I]));
    if FCardPhoto[I] <> nil then
    begin
      FCardBack[I] := TImage.Create(Self);
      FCardBack[I].Parent  := P;
      FCardBack[I].Align   := alClient;
      { معطّلة عمدا : الصورة تُرسم كما هي، لكن الفأرة تمرّ من فوقها إلى
        اللوحة، فيبقى النقر وتأثير التمرير من شأن البطاقة وحدها. }
      FCardBack[I].Enabled := False;
    end;

    { التسميات مكونات رسومية (TGraphicControl) فلا تسرق مؤشر الفأرة
      من اللوحة، لذلك يبقى تأثير التمرير سليما. }
    FCardTitle[I] := NewLabel(P, -17, True,  $00403020,        I);
    FCardSub[I]   := NewLabel(P, -12, False, clGrayText,       I);
    FCardSub[I].WordWrap := True;
    FCardValue[I] := NewLabel(P, -30, True,  CARD_ACCENT[I],   I);
  end;
  LayoutCards;
end;

procedure TfrmMain.LayoutCards;
const
  MARGIN = 20;
  GAP    = 14;
var
  I, Col, Row, CW, CH, X, Y, AvailW, AvailH : Integer;
begin
  if FCards[0] = nil then Exit;

  AvailW := pnlCards.ClientWidth  - 2 * MARGIN;
  AvailH := pnlCards.ClientHeight - 2 * MARGIN;
  if (AvailW < 240) or (AvailH < 180) then Exit;

  CW := (AvailW - 2 * GAP) div 3;
  CH := (AvailH - 2 * GAP) div 3;
  if CH > 175 then CH := 175;

  for I := 0 to 8 do
  begin
    Col := I mod 3;
    Row := I div 3;

    { في العربية يبدأ العمود الأول من اليمين }
    if IsRTL then
      X := MARGIN + (2 - Col) * (CW + GAP)
    else
      X := MARGIN + Col * (CW + GAP);
    Y := MARGIN + Row * (CH + GAP);

    FCards[I].SetBounds(X, Y, CW, CH);

    { البطاقات التي لا تحمل رقما يُتوسَّط نصها عموديا بدل ترك فراغ أسفلها }
    if Trim(FCardValue[I].Caption) = '' then
    begin
      FCardValue[I].Visible := False;
      FCardTitle[I].SetBounds(10, (CH - 52) div 2,      CW - 20, 26);
      FCardSub[I].SetBounds  (10, (CH - 52) div 2 + 28, CW - 20, 34);
    end
    else
    begin
      FCardValue[I].Visible := True;
      FCardTitle[I].SetBounds(10, 20, CW - 20, 26);
      FCardSub[I].SetBounds  (10, 48, CW - 20, 32);
      FCardValue[I].SetBounds(10, CH - 54, CW - 20, 40);
    end;

    { الصورة تُمزج بمقاس البطاقة، فتُعاد بعد كل تغيير في الأبعاد }
    RenderCardBack(I, False);
  end;
end;

{ رسم خلفية بطاقة : باهتة في الوضع العادي، أوضح قليلا عند مرور الفأرة،
  وشبه ممحوّة إذا كانت البطاقة معطّلة لأن المستخدم ليس مسؤولا. }
procedure TfrmMain.RenderCardBack(AIndex: Integer; AHover: Boolean);
var
  Wash : Byte;
begin
  if (FCardBack[AIndex] = nil) or (FCardPhoto[AIndex] = nil) then Exit;

  if not FCards[AIndex].Enabled then
    Wash := WASH_DISABLED
  else if AHover then
    Wash := WASH_HOVER
  else
    Wash := WASH_NORMAL;

  DrawWashedCover(FCardBack[AIndex], FCardPhoto[AIndex],
                  CARD_TINT[AIndex], Wash);
end;

procedure TfrmMain.pnlCardsResize(Sender: TObject);
begin
  LayoutCards;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  { صورة الواجهة تُرسم بمقاس المساحة، فتُعاد عند كل تغيير حجم }
  if imgCover.Visible then
    DrawCoverImage(imgCover, dm.GetSetting('COVER_FILE', ''));
  LayoutCards;
end;

procedure TfrmMain.UpdateCardTexts;
var
  NbStudents, NbClasses, NbAbsToday, NbUnjust, NbNotices : Integer;
begin
  if FCards[0] = nil then Exit;

  NbStudents := dm.ScalarInt('SELECT COUNT(*) FROM Students WHERE IsActive = True', 0);
  NbClasses  := dm.ScalarInt('SELECT COUNT(*) FROM Classes', 0);
  NbAbsToday := dm.ScalarInt('SELECT COUNT(*) FROM Absences WHERE AbsDate = ' +
                             SqlDate(Date) + ' AND AbsKind = ' + SqlStr('ABS'), 0);
  NbUnjust   := dm.ScalarInt('SELECT COUNT(*) FROM Absences WHERE Justified = False' +
                             ' AND AbsKind = ' + SqlStr('ABS'), 0);
  NbNotices  := dm.ScalarInt('SELECT COUNT(*) FROM Notices WHERE Delivered = False', 0);

  FCardTitle[0].Caption := R_MnuStudents;
  FCardSub[0].Caption   := R_CardSubStudents;
  FCardValue[0].Caption := IntToStr(NbStudents);

  FCardTitle[1].Caption := R_MnuDailyAbs;
  FCardSub[1].Caption   := R_CardSubAbsence;
  FCardValue[1].Caption := IntToStr(NbAbsToday);

  FCardTitle[2].Caption := R_MnuJustify;
  FCardSub[2].Caption   := R_CardSubJustify;
  FCardValue[2].Caption := IntToStr(NbUnjust);

  FCardTitle[3].Caption := R_MnuNotices;
  FCardSub[3].Caption   := R_CardSubNotices;
  FCardValue[3].Caption := IntToStr(NbNotices);

  FCardTitle[4].Caption := R_MnuDocs;
  FCardSub[4].Caption   := R_CardSubDocs;
  FCardValue[4].Caption := '';

  FCardTitle[5].Caption := R_MnuReports;
  FCardSub[5].Caption   := R_CardSubReports;
  FCardValue[5].Caption := '';

  FCardTitle[6].Caption := R_RefTitle;
  FCardSub[6].Caption   := R_CardSubRefData;
  FCardValue[6].Caption := IntToStr(NbClasses);

  FCardTitle[7].Caption := R_MnuUsers;
  FCardSub[7].Caption   := R_CardSubUsers;
  FCardValue[7].Caption := '';

  FCardTitle[8].Caption := R_MnuSettings;
  FCardSub[8].Caption   := R_CardSubSettings;
  FCardValue[8].Caption := '';

  { الأرقام أصبحت معروفة الآن، فيُعاد الترتيب لضبط البطاقات بلا رقم }
  LayoutCards;
end;

procedure TfrmMain.CardClick(Sender: TObject);
begin
  if not (Sender is TControl) then Exit;
  case TControl(Sender).Tag of
    0 : miStudentsClick(nil);
    1 : miDailyAbsClick(nil);
    2 : miJustifyClick(nil);
    3 : miNoticesClick(nil);
    4 : miPermitClick(nil);
    5 : miReportsClick(nil);
    6 : miRefDataClick(nil);
    7 : miUsersClick(nil);
    8 : miSettingsClick(nil);
  end;
end;

procedure TfrmMain.CardMouseEnter(Sender: TObject);
begin
  if (Sender is TPanel) and TPanel(Sender).Enabled then
  begin
    TPanel(Sender).Color := CARD_TINT[TPanel(Sender).Tag];
    RenderCardBack(TPanel(Sender).Tag, True);
  end;
end;

procedure TfrmMain.CardMouseLeave(Sender: TObject);
begin
  if Sender is TPanel then
  begin
    TPanel(Sender).Color := clWhite;
    RenderCardBack(TPanel(Sender).Tag, False);
  end;
end;

{ --- شعار المؤسسة وصورتها --------------------------------------------- }
procedure TfrmMain.LoadBranding;
var
  LogoFile, CoverFile, LogoPath : string;
begin
  LogoFile  := dm.GetSetting('LOGO_FILE', '');
  CoverFile := dm.GetSetting('COVER_FILE', '');

  { شعار المؤسسة إن ضبطه المستخدم في الإعدادات، وإلا شعار البرنامج المرفق }
  LogoPath := MediaPath(LogoFile);
  if (LogoPath = '') or (not FileExists(LogoPath)) then
    LogoPath := AssetPath('logo.png');

  imgLogo.Picture := nil;
  imgLogo.Visible := LogoPath <> '';
  if imgLogo.Visible then
    try
      imgLogo.Picture.LoadFromFile(LogoPath);
    except
      imgLogo.Visible := False;
    end;

  imgCover.Visible := (CoverFile <> '') and FileExists(MediaPath(CoverFile));
  if imgCover.Visible then
    DrawCoverImage(imgCover, CoverFile);

  { نفس الشعار يُدرج في ترويسة الوثائق المطبوعة }
  ReportLogoFile := LogoPath;
end;

procedure TfrmMain.tmrTimer(Sender: TObject);
begin
  sb.Panels[0].Text := R_StatUser + dm.CurrentUserName + '  (' +
                       dm.CurrentUserRole + ')';
  sb.Panels[1].Text := R_StatDate + FormatLongDate(Date) + '   ' +
                       FormatDateTime('hh:nn:ss', Now);
  sb.Panels[2].Text := R_StatDB + ExtractFileName(DatabasePath);
end;

{ --- عناصر القوائم ------------------------------------------------------ }

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.miLogoutClick(Sender: TObject);
begin
  dm.Logout;
  Hide;
  if not DoLogin then
    Close
  else
  begin
    Show;
    ApplyRights;
    RefreshDashboard;
  end;
end;

procedure TfrmMain.miStudentsClick(Sender: TObject);
begin
  ShowStudentsForm;
  RefreshDashboard;
end;

procedure TfrmMain.miRefDataClick(Sender: TObject);
begin
  ShowRefDataForm;
  RefreshDashboard;
end;

procedure TfrmMain.miDailyAbsClick(Sender: TObject);
begin
  ShowAbsenceForm;
  RefreshDashboard;
end;

procedure TfrmMain.miJustifyClick(Sender: TObject);
begin
  ShowJustifyForm;
  RefreshDashboard;
end;

procedure TfrmMain.miNoticesClick(Sender: TObject);
begin
  ShowNoticesForm;
end;

procedure TfrmMain.miPermitClick(Sender: TObject);
begin
  ShowDocsForm(0);
end;

procedure TfrmMain.miCertificateClick(Sender: TObject);
begin
  ShowDocsForm(1);
end;

procedure TfrmMain.miReportsClick(Sender: TObject);
var
  Tab : Integer;
begin
  Tab := 0;
  if Sender = miRepRegister then Tab := 1
  else if Sender = miRepStats then Tab := 2;
  ShowReportsForm(Tab);
end;

procedure TfrmMain.miUsersClick(Sender: TObject);
begin
  if not dm.IsAdmin then
  begin
    ShowError(R_UsrNoRights);
    Exit;
  end;
  ShowUsersForm;
end;

procedure TfrmMain.miSettingsClick(Sender: TObject);
begin
  if not dm.IsAdmin then
  begin
    ShowError(R_UsrNoRights);
    Exit;
  end;
  ShowSettingsForm;
  RefreshDashboard;
end;

procedure TfrmMain.miSampleDataClick(Sender: TObject);
var
  C   : TDemoCounts;
  Err : string;
  Msg : string;
begin
  if not dm.IsAdmin then
  begin
    ShowError(R_UsrNoRights);
    Exit;
  end;
  if not AskYesNo(R_SampleConfirm) then Exit;

  Screen.Cursor := crHourGlass;
  try
    C := ImportDemoData(dm.conn, Err);
  finally
    Screen.Cursor := crDefault;
  end;

  if Err <> '' then
    ShowError(Err);

  if (C.Students + C.Teachers + C.Users + C.Absences +
      C.Notices + C.Permits + C.Certificates) = 0 then
  begin
    if Err = '' then
      ShowInfo(R_SampleNone);
  end
  else
  begin
    Msg := R_SampleDone + #13#10 + #13#10 +
      R_MnuStudents    + ' : ' + IntToStr(C.Students)     + #13#10 +
      R_RefTeachers    + ' : ' + IntToStr(C.Teachers)     + #13#10 +
      R_MnuUsers       + ' : ' + IntToStr(C.Users)        + #13#10 +
      R_MnuAbsence     + ' : ' + IntToStr(C.Absences)     +
        '  (' + R_AbsJustified + ' : ' + IntToStr(C.Justified) + ')' + #13#10 +
      R_MnuNotices     + ' : ' + IntToStr(C.Notices)      + #13#10 +
      R_MnuPermit      + ' : ' + IntToStr(C.Permits)      + #13#10 +
      R_MnuCertificate + ' : ' + IntToStr(C.Certificates);
    ShowInfo(Msg);
  end;

  RefreshDashboard;
end;

procedure TfrmMain.miBackupClick(Sender: TObject);
begin
  dlgSave.FileName := 'Backup_' + FormatDateTime('yyyy-mm-dd_hhnn', Now) + '.mdb';
  if dlgSave.Execute then
  begin
    if BackupDatabase(dlgSave.FileName) then
      ShowInfo(R_BakDone + dlgSave.FileName)
    else
      ShowError(R_BakFailed);
  end;
end;

procedure TfrmMain.miRestoreClick(Sender: TObject);
begin
  if not dm.IsAdmin then
  begin
    ShowError(R_UsrNoRights);
    Exit;
  end;
  if dlgOpen.Execute then
  begin
    if not AskYesNo(R_BakConfirmRest) then Exit;
    dm.conn.Connected := False;
    if RestoreDatabase(dlgOpen.FileName) then
    begin
      ShowInfo(R_BakRestDone);
      Application.Terminate;
    end
    else
    begin
      ShowError(R_RestFailed);
      dm.Connect;
    end;
  end;
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  ShowInfo(R_AboutText);
end;

{ ------------------------------------------------------------------------
  تبديل لغة الواجهة أثناء التشغيل
  Changement de la langue de l'interface a chaud
  ------------------------------------------------------------------------ }
procedure TfrmMain.miLangClick(Sender: TObject);
var
  L : TAppLang;
begin
  if Sender = miLangFR then
    L := langFR
  else
    L := langAR;

  if L = CurrentLang then Exit;

  SetLanguage(L);
  dm.StoreLanguage;

  { إعادة بناء تسميات النافذة الرئيسية واتجاهها.
    باقي النوافذ تُنشأ عند الطلب فتأخذ اللغة الجديدة تلقائيا. }
  ApplyCaptions;

  { الاتجاه تغيّر حتما (خرجنا مبكرا لو كانت اللغة نفسها)، لذلك يُعكس
    التخطيط في الحالتين : من اليسار إلى اليمين أو العكس. }
  if IsRTL then
    BiDiMode := bdRightToLeft
  else
    BiDiMode := bdLeftToRight;
  MirrorFormLayout(Self);
  LayoutCards;          { ترتيب الأعمدة ينعكس مع الاتجاه }

  ApplyRights;
  RefreshDashboard;
  tmrTimer(nil);
end;

end.
