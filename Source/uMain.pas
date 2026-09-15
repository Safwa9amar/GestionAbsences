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
    lblWelcome      : TLabel;
    lblSchool       : TLabel;
    lblYear         : TLabel;
    pnlStats        : TPanel;
    lblStatTitle    : TLabel;
    lblStatStudents : TLabel;
    lblStatClasses  : TLabel;
    lblStatAbsToday : TLabel;
    lblStatUnjust   : TLabel;
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
  private
    procedure ApplyCaptions;
    procedure ApplyRights;
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

  lblStatTitle.Caption := R_DashTitle;
end;

procedure TfrmMain.ApplyRights;
var
  Admin : Boolean;
begin
  Admin := dm.IsAdmin;
  miUsers.Enabled    := Admin;
  miSettings.Enabled := Admin;
  miRestore.Enabled  := Admin;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ApplyCaptions;
  ApplyRTL(Self);
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
var
  NbStudents, NbClasses, NbAbsToday, NbUnjust : Integer;
begin
  lblWelcome.Caption := R_LoginWelcome + dm.CurrentUserName;
  lblSchool.Caption  := dm.GetSetting('SCHOOL_NAME', R_SchoolDefault) + '  -  ' +
                        dm.GetSetting('ADDRESS', R_PlaceDefault);
  lblYear.Caption    := R_LblYear + dm.CurrentYearLabel;

  NbStudents := dm.ScalarInt('SELECT COUNT(*) FROM Students WHERE IsActive = True', 0);
  NbClasses  := dm.ScalarInt('SELECT COUNT(*) FROM Classes', 0);
  NbAbsToday := dm.ScalarInt('SELECT COUNT(*) FROM Absences WHERE AbsDate = ' +
                             SqlDate(Date) + ' AND AbsKind = ' + SqlStr('ABS'), 0);
  NbUnjust   := dm.ScalarInt('SELECT COUNT(*) FROM Absences WHERE Justified = False' +
                             ' AND AbsKind = ' + SqlStr('ABS'), 0);

  lblStatStudents.Caption := R_DashStudents + IntToStr(NbStudents);
  lblStatClasses.Caption  := R_DashClasses + IntToStr(NbClasses);
  lblStatAbsToday.Caption := R_DashAbsToday + IntToStr(NbAbsToday);
  lblStatUnjust.Caption   := R_DashUnjust + IntToStr(NbUnjust);
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
  ApplyRTL(Self);
  ApplyRights;
  RefreshDashboard;
  tmrTimer(nil);
end;

end.
