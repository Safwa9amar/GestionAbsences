unit uMain;

{ النافذة الرئيسية / Fenetre principale }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ExtCtrls, StdCtrls, Buttons, ImgList;

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
    miBackup        : TMenuItem;
    miRestore       : TMenuItem;
    miHelp          : TMenuItem;
    miAbout         : TMenuItem;
    sb              : TStatusBar;
    pnlSide         : TPanel;
    btnStudents     : TSpeedButton;
    btnAbsence      : TSpeedButton;
    btnJustify      : TSpeedButton;
    btnNotices      : TSpeedButton;
    btnReports      : TSpeedButton;
    btnRefData      : TSpeedButton;
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
    procedure miBackupClick(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miLangClick(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure pnlCardsResize(Sender: TObject);
    procedure CardClick(Sender: TObject);
    procedure CardMouseEnter(Sender: TObject);
    procedure CardMouseLeave(Sender: TObject);
  private
    FCards     : array[0..8] of TPanel;
    FCardTitle : array[0..8] of TLabel;
    FCardSub   : array[0..8] of TLabel;
    FCardValue : array[0..8] of TLabel;
    procedure ApplyCaptions;
    procedure ApplyRights;
    procedure BuildCards;
    procedure LayoutCards;
    procedure UpdateCardTexts;
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
  miBackup.Caption   := R_MnuBackup;
  miRestore.Caption  := R_MnuRestore;

  miHelp.Caption     := R_MnuHelp;
  miAbout.Caption    := R_MnuAbout;

  btnStudents.Caption := R_MnuStudents;
  btnAbsence.Caption  := R_MnuDailyAbs;
  btnJustify.Caption  := R_MnuJustify;
  btnNotices.Caption  := R_MnuNotices;
  btnReports.Caption  := R_MnuReports;
  btnRefData.Caption  := R_RefTitle;

end;

procedure TfrmMain.ApplyRights;
var
  Admin : Boolean;
begin
  Admin := dm.IsAdmin;
  miUsers.Enabled    := Admin;
  miSettings.Enabled := Admin;
  miRestore.Enabled  := Admin;
  if FCards[7] <> nil then FCards[7].Enabled := Admin;
  if FCards[8] <> nil then FCards[8].Enabled := Admin;
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
  { ألوان خلفية البطاقات، ثم لون التمرير فوقها }
  CARD_BG : array[0..8] of TColor =
    ($00F5ECE2, $00E2ECF5, $00E2F5E9, $00E9E2F5, $00F5F2E2,
     $00E2F0F5, $00F0F0F0, $00F0F0F0, $00F0F0F0);
  CARD_HOVER : array[0..8] of TColor =
    ($00E8DCCB, $00CBDCE8, $00CBE8D6, $00D6CBE8, $00E8E2CB,
     $00CBE4E8, $00E0E0E0, $00E0E0E0, $00E0E0E0);

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
    P.Color            := CARD_BG[I];
    P.ParentBackground := False;
    P.Cursor           := crHandPoint;
    P.Tag              := I;
    P.OnClick          := CardClick;
    P.OnMouseEnter     := CardMouseEnter;
    P.OnMouseLeave     := CardMouseLeave;
    FCards[I] := P;

    { التسميات مكونات رسومية (TGraphicControl) فلا تسرق مؤشر الفأرة
      من اللوحة، لذلك يبقى تأثير التمرير سليما. }
    FCardTitle[I] := NewLabel(P, -16, True,  clWindowText, I);
    FCardSub[I]   := NewLabel(P, -11, False, clGrayText,   I);
    FCardSub[I].WordWrap := True;
    FCardValue[I] := NewLabel(P, -27, True,  clHighlight,  I);
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
  if CH > 160 then CH := 160;

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
    FCardTitle[I].SetBounds(8, 14, CW - 16, 24);
    FCardSub[I].SetBounds(8, 40, CW - 16, 34);
    FCardValue[I].SetBounds(8, CH - 48, CW - 16, 36);
  end;
end;

procedure TfrmMain.pnlCardsResize(Sender: TObject);
begin
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
    TPanel(Sender).Color := CARD_HOVER[TPanel(Sender).Tag];
end;

procedure TfrmMain.CardMouseLeave(Sender: TObject);
begin
  if Sender is TPanel then
    TPanel(Sender).Color := CARD_BG[TPanel(Sender).Tag];
end;

{ --- شعار المؤسسة وصورتها --------------------------------------------- }
procedure TfrmMain.LoadBranding;
var
  LogoFile, CoverFile : string;
begin
  LogoFile  := dm.GetSetting('LOGO_FILE', '');
  CoverFile := dm.GetSetting('COVER_FILE', '');

  LoadImageInto(imgLogo, LogoFile);
  imgLogo.Visible := (LogoFile <> '') and FileExists(MediaPath(LogoFile));

  LoadImageInto(imgCover, CoverFile);
  imgCover.Visible := (CoverFile <> '') and FileExists(MediaPath(CoverFile));

  { نفس الشعار يُدرج في ترويسة الوثائق المطبوعة }
  ReportLogoFile := MediaPath(LogoFile);
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
