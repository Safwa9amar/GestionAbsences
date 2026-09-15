program GestionAbsences;

{ =============================================================================
  برنامج متابعة الغيابات اليومية للتلاميذ
  Application de suivi des absences journalieres des eleves

  مذكرة نهاية التكوين لنيل شهادة تقني سامي في الإعلام الآلي
  تخصص : قاعدة معطيات
  مؤسسة التربص : متوسطة الشهيد بالعربي أحمد - سيدي طيفور

  أدوات الإنجاز : Delphi / Object Pascal  +  Microsoft Access (ADO)
  منهجية التصميم : MERISE (MCD / MLD)
  ============================================================================= }

uses
  Forms,
  SysUtils,
  uLang     in 'uLang.pas',
  uUtils    in 'uUtils.pas',
  uDB       in 'uDB.pas',
  dmMain    in 'dmMain.pas'    {dmMain: TDataModule},
  uLogin    in 'uLogin.pas'    {frmLogin},
  uMain     in 'uMain.pas'     {frmMain},
  uStudents in 'uStudents.pas' {frmStudents},
  uRefData  in 'uRefData.pas'  {frmRefData},
  uAbsence  in 'uAbsence.pas'  {frmAbsence},
  uJustify  in 'uJustify.pas'  {frmJustify},
  uNotices  in 'uNotices.pas'  {frmNotices},
  uDocs     in 'uDocs.pas'     {frmDocs},
  uReports  in 'uReports.pas'  {frmReports},
  uUsers    in 'uUsers.pas'    {frmUsers},
  uSettings in 'uSettings.pas' {frmSettings};

{$R *.res}

var
  IconFile : string;

begin
  Application.Initialize;
  Application.Title := R_AppShort;

  { الأيقونة مضمّنة في ملف المورد، وتُقرأ كذلك من Assets\app.ico إن وُجدت،
    حتى تبقى الأيقونة صحيحة لو أعاد المحرر توليد المورد. }
  IconFile := AssetPath('app.ico');
  if IconFile <> '' then
    try
      Application.Icon.LoadFromFile(IconFile);
    except
      { أيقونة تالفة أو صيغة غير مدعومة : تبقى أيقونة المورد }
    end;

  { 1) وحدة المعطيات : تنشئ قاعدة البيانات عند أول تشغيل ثم تفتحها }
  Application.CreateForm(TdmMain, dm);

  if dm.Connect then
  begin
    { 2) المصادقة }
    if DoLogin then
    begin
      { 3) النافذة الرئيسية }
      Application.CreateForm(TfrmMain, frmMain);
      Application.Run;
    end;
  end;
end.
