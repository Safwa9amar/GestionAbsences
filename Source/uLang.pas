unit uLang;

{ =============================================================================
  وحدة النصوص العربية لواجهة البرنامج
  Unite des libelles arabes de l'interface.

  كل النصوص العربية مجمعة هنا حتى تبقى ملفات .dfm بمحارف ASCII فقط،
  وهو ما يمنع اي مشكل في ترميز المحارف عند فتح المشروع على اجهزة مختلفة.
  ============================================================================= }

interface

const
  { --- عام / General --------------------------------------------------- }
  R_AppTitle        = 'برنامج متابعة الغيابات اليومية للتلاميذ';
  R_AppShort        = 'تسيير الغيابات';
  R_SchoolDefault   = 'متوسطة الشهيد بالعربي أحمد';
  R_PlaceDefault    = 'سيدي طيفور - البيض';

  R_Ok              = 'موافق';
  R_Cancel          = 'إلغاء';
  R_Close           = 'إغلاق';
  R_Save            = 'حفظ';
  R_New             = 'جديد';
  R_Edit            = 'تعديل';
  R_Delete          = 'حذف';
  R_Search          = 'بحث';
  R_Refresh         = 'تحديث';
  R_Print           = 'طباعة';
  R_Export          = 'تصدير';
  R_Yes             = 'نعم';
  R_No              = 'لا';
  R_All             = '- الكل -';
  R_None            = '- بدون -';

  R_MsgConfirmDel   = 'هل تريد فعلا حذف السجل المحدد ؟';
  R_MsgSaved        = 'تم حفظ البيانات بنجاح.';
  R_MsgDeleted      = 'تم حذف السجل بنجاح.';
  R_MsgNoRecord     = 'لا يوجد سجل محدد.';
  R_MsgRequired     = 'يرجى ملء الحقول الإجبارية.';
  R_MsgErrTitle     = 'خطأ';
  R_MsgInfoTitle    = 'إعلام';
  R_MsgConfirmTitle = 'تأكيد';

  { --- تسجيل الدخول / Login -------------------------------------------- }
  R_LoginTitle      = 'تسجيل الدخول';
  R_LoginUser       = 'اسم المستخدم :';
  R_LoginPass       = 'كلمة المرور :';
  R_LoginBtn        = 'دخول';
  R_LoginFailed     = 'اسم المستخدم أو كلمة المرور غير صحيحة.';
  R_LoginDisabled   = 'هذا الحساب موقوف. اتصل بمسؤول النظام.';
  R_LoginWelcome    = 'مرحبا بك : ';

  { --- القائمة الرئيسية / Menu principal -------------------------------- }
  R_MnuFile         = 'ملف';
  R_MnuData         = 'البيانات الأساسية';
  R_MnuAbsence      = 'الغيابات';
  R_MnuDocs         = 'الوثائق';
  R_MnuReports      = 'التقارير والإحصائيات';
  R_MnuTools        = 'أدوات';
  R_MnuHelp         = 'مساعدة';

  R_MnuStudents     = 'التلاميذ';
  R_MnuClasses      = 'الأقسام والمستويات';
  R_MnuSubjects     = 'المواد والأساتذة';
  R_MnuSlots        = 'الحصص والتوقيت';
  R_MnuYears        = 'السنوات الدراسية';

  R_MnuDailyAbs     = 'تسجيل الغيابات اليومية';
  R_MnuJustify      = 'تبرير الغيابات';
  R_MnuLate         = 'التأخرات';

  R_MnuNotices      = 'الإشعارات والاستدعاءات';
  R_MnuPermit       = 'ورقة الدخول';
  R_MnuCertificate  = 'الشهادة المدرسية';

  R_MnuDailyRep     = 'التقرير اليومي';
  R_MnuAbsRegister  = 'سجل الغيابات والتأخرات';
  R_MnuStats        = 'إحصائيات ونسب الحضور';

  R_MnuUsers        = 'المستخدمون';
  R_MnuSettings     = 'إعدادات المؤسسة';
  R_MnuBackup       = 'نسخة احتياطية لقاعدة البيانات';
  R_MnuRestore      = 'استرجاع نسخة احتياطية';
  R_MnuLogout       = 'تغيير المستخدم';
  R_MnuExit         = 'خروج';
  R_MnuAbout        = 'حول البرنامج';

  R_StatUser        = 'المستخدم : ';
  R_StatDate        = 'التاريخ : ';
  R_StatDB          = 'قاعدة البيانات : ';

  { --- التلاميذ / Eleves ------------------------------------------------ }
  R_StuTitle        = 'تسيير ملفات التلاميذ';
  R_StuMatricule    = 'رقم التعريف المدرسي';
  R_StuRegNo        = 'رقم التسجيل';
  R_StuLastName     = 'اللقب';
  R_StuFirstName    = 'الاسم';
  R_StuGender       = 'الجنس';
  R_StuMale         = 'ذكر';
  R_StuFemale       = 'أنثى';
  R_StuBirthDate    = 'تاريخ الميلاد';
  R_StuBirthPlace   = 'مكان الميلاد';
  R_StuClass        = 'القسم';
  R_StuRegime       = 'الصفة';
  R_StuExtern       = 'خارجي';
  R_StuSemiIntern   = 'نصف داخلي';
  R_StuIntern       = 'داخلي';
  R_StuFather       = 'اسم الأب';
  R_StuMother       = 'اسم ولقب الأم';
  R_StuSocial       = 'الحالة الاجتماعية';
  R_StuSocNormal    = 'عادية';
  R_StuSocOrphan    = 'يتيم';
  R_StuSocDivorced  = 'مطلق الأبوين';
  R_StuSocNeedy     = 'معوز';
  R_StuSiblings     = 'عدد الإخوة';
  R_StuSibSchooled  = 'الإخوة المتمدرسون';
  R_StuGuardian     = 'الولي';
  R_StuGuardPhone   = 'هاتف الولي';
  R_StuGuardEmail   = 'البريد الإلكتروني';
  R_StuGuardAddr    = 'العنوان الشخصي للولي';
  R_StuEnrollDate   = 'تاريخ التسجيل';
  R_StuExitDate     = 'تاريخ الخروج';
  R_StuActive       = 'يزاول دراسته';
  R_StuNotes        = 'ملاحظات';
  R_StuSearchHint   = 'اكتب اللقب أو الاسم أو رقم التعريف ...';
  R_StuCount        = 'عدد التلاميذ : ';
  R_StuFileTab      = 'استمارة معلومات التلميذ';
  R_StuListTab      = 'قائمة التلاميذ';
  R_StuAbsTab       = 'غيابات التلميذ';

  { --- البيانات الأساسية / Donnees de reference ------------------------- }
  R_RefTitle        = 'البيانات الأساسية';
  R_RefLevels       = 'المستويات';
  R_RefClasses      = 'الأقسام';
  R_RefSubjects     = 'المواد';
  R_RefTeachers     = 'الأساتذة';
  R_RefSlots        = 'الحصص';
  R_RefYears        = 'السنوات الدراسية';

  R_LevName         = 'تسمية المستوى';
  R_LevOrder        = 'الترتيب';
  R_ClsName         = 'تسمية القسم';
  R_ClsLevel        = 'المستوى';
  R_ClsYear         = 'السنة الدراسية';
  R_ClsRoom         = 'القاعة';
  R_ClsCapacity     = 'الطاقة الاستيعابية';
  R_SubName         = 'تسمية المادة';
  R_SubCoef         = 'المعامل';
  R_TchLastName     = 'اللقب';
  R_TchFirstName    = 'الاسم';
  R_TchPhone        = 'الهاتف';
  R_TchEmail        = 'البريد الإلكتروني';
  R_TchSubject      = 'المادة';
  R_SltLabel        = 'تسمية الحصة';
  R_SltPart         = 'الفترة';
  R_SltMorning      = 'صباحية';
  R_SltEvening      = 'مسائية';
  R_SltStart        = 'من الساعة';
  R_SltEnd          = 'إلى الساعة';
  R_YrLabel         = 'السنة الدراسية';
  R_YrStart         = 'تاريخ البداية';
  R_YrEnd           = 'تاريخ النهاية';
  R_YrCurrent       = 'السنة الجارية';

  { --- الغيابات / Absences ---------------------------------------------- }
  R_AbsTitle        = 'تسجيل الغيابات اليومية';
  R_AbsDate         = 'التاريخ';
  R_AbsClass        = 'القسم';
  R_AbsSlot         = 'الحصة';
  R_AbsSubject      = 'المادة';
  R_AbsTeacher      = 'الأستاذ';
  R_AbsLoad         = 'عرض قائمة التلاميذ';
  R_AbsSaveAll      = 'حفظ كشف الغيابات';
  R_AbsPresent      = 'حاضر';
  R_AbsAbsent       = 'غائب';
  R_AbsLate         = 'متأخر';
  R_AbsState        = 'الحالة';
  R_AbsMinutes      = 'دقائق التأخر';
  R_AbsJustified    = 'مبرر';
  R_AbsReason       = 'سبب الغياب';
  R_AbsMarkAllPres  = 'تعليم الكل حاضر';
  R_AbsMarkAllAbs   = 'تعليم الكل غائب';
  R_AbsSummary      = 'الحاضرون : %d   الغائبون : %d   المتأخرون : %d';
  R_AbsNoClass      = 'يرجى اختيار القسم والحصة أولا.';
  R_AbsNoStudents   = 'لا يوجد تلاميذ مسجلون في هذا القسم.';
  R_AbsSavedFmt     = 'تم حفظ كشف الغيابات : %d عملية.';

  R_JusTitle        = 'تبرير الغيابات';
  R_JusFrom         = 'من تاريخ';
  R_JusTo           = 'إلى تاريخ';
  R_JusOnlyUnjust   = 'غير المبررة فقط';
  R_JusMarkJust     = 'تبرير المحدد';
  R_JusMarkUnjust   = 'إلغاء التبرير';
  R_JusReasonAsk    = 'أدخل سبب التبرير (شهادة طبية، سبب عائلي ...) :';

  { --- الوثائق / Documents ---------------------------------------------- }
  R_NotTitle        = 'الإشعارات والاستدعاءات';
  R_NotKind         = 'نوع الوثيقة';
  R_NotFirst        = 'إشعار أول بالغياب';
  R_NotSecond       = 'إشعار ثان بالغياب';
  R_NotRadiation    = 'إعذار بالشطب';
  R_NotSummon       = 'استدعاء الولي';
  R_NotNo           = 'رقم الإرسال';
  R_NotIssueDate    = 'تاريخ التحرير';
  R_NotMeetDate     = 'تاريخ الحضور';
  R_NotMeetTime     = 'الساعة';
  R_NotTopic        = 'الموضوع';
  R_NotAbsCount     = 'عدد الغيابات';
  R_NotDelivered    = 'تم التبليغ';
  R_NotGenerate     = 'اقتراح الإشعارات آليا';
  R_NotPrintDoc     = 'طباعة الوثيقة';
  R_NotGenDone      = 'تم اقتراح %d إشعار حسب عتبات النظام الداخلي.';
  R_NotGenNone      = 'لا يوجد تلميذ بلغ عتبة الإشعار حاليا.';

  R_PrmTitle        = 'ورقة الدخول إلى القسم';
  R_PrmDate         = 'التاريخ';
  R_PrmTime         = 'على الساعة';
  R_PrmReason       = 'السبب';

  R_CrtTitle        = 'الشهادة المدرسية';
  R_CrtNo           = 'الرقم التسلسلي';
  R_CrtPurpose      = 'الغرض من الشهادة';
  R_CrtCopies       = 'عدد النسخ';

  { --- التقارير / Etats -------------------------------------------------- }
  R_RepTitle        = 'التقارير والإحصائيات';
  R_RepDaily        = 'التقرير اليومي للغيابات';
  R_RepRegister     = 'سجل الغيابات والتأخرات';
  R_RepByClass      = 'حوصلة حسب القسم';
  R_RepTopAbsent    = 'التلاميذ الأكثر غيابا';
  R_RepAttendRate   = 'نسبة الحضور والغياب';
  R_RepPeriod       = 'الفترة';
  R_RepGenerate     = 'إنشاء التقرير';
  R_RepNoData       = 'لا توجد معطيات مطابقة للمعايير المختارة.';
  R_RepOpened       = 'تم إنشاء التقرير وفتحه في المتصفح للطباعة.';

  { --- المستخدمون والإعدادات / Utilisateurs et parametres --------------- }
  R_UsrTitle        = 'تسيير المستخدمين';
  R_UsrLogin        = 'اسم المستخدم';
  R_UsrFullName     = 'الاسم الكامل';
  R_UsrRole         = 'الصلاحية';
  R_UsrRoleAdmin    = 'مسؤول النظام';
  R_UsrRoleAdvisor  = 'مستشار التربية';
  R_UsrRoleSuperv   = 'مشرف التربية';
  R_UsrActive       = 'نشط';
  R_UsrNewPass      = 'كلمة المرور الجديدة';
  R_UsrConfirmPass  = 'تأكيد كلمة المرور';
  R_UsrPassMismatch = 'كلمتا المرور غير متطابقتين.';
  R_UsrNoRights     = 'ليست لديك الصلاحية للقيام بهذه العملية.';
  R_UsrLastAdmin    = 'لا يمكن حذف أو توقيف آخر حساب لمسؤول النظام.';

  R_SetTitle        = 'إعدادات المؤسسة';
  R_SetDirection    = 'مديرية التربية';
  R_SetSchool       = 'تسمية المؤسسة';
  R_SetAddress      = 'العنوان';
  R_SetPhone        = 'الهاتف';
  R_SetFax          = 'الفاكس';
  R_SetEmail        = 'البريد الإلكتروني';
  R_SetDirector     = 'مدير المؤسسة';
  R_SetAdvisor      = 'مستشار التربية';
  R_SetThresholds   = 'عتبات الإشعار (عدد الغيابات غير المبررة)';
  R_SetThr1         = 'الإشعار الأول';
  R_SetThr2         = 'الإشعار الثاني';
  R_SetThr3         = 'الإعذار بالشطب';

  { --- النسخ الاحتياطي / Sauvegarde ------------------------------------- }
  R_BakDone         = 'تم إنشاء النسخة الاحتياطية في : ';
  R_BakConfirmRest  = 'سيتم استبدال قاعدة البيانات الحالية بالنسخة المختارة.' + #13#10 +
                      'هل تريد المتابعة ؟';
  R_BakRestDone     = 'تم استرجاع النسخة الاحتياطية. سيتم إغلاق البرنامج، أعد تشغيله.';

  { --- حول البرنامج / A propos ------------------------------------------ }
  R_AboutText =
    'برنامج متابعة الغيابات اليومية للتلاميذ' + #13#10 + #13#10 +
    'مذكرة تخرج لنيل شهادة تقني سامي في الإعلام الآلي' + #13#10 +
    'تخصص : قاعدة معطيات' + #13#10 +
    'المعهد الوطني المتخصص في التكوين المهني - بن سعيدي عبد العاطي - البيض' + #13#10 + #13#10 +
    'مؤسسة التربص : متوسطة الشهيد بالعربي أحمد - سيدي طيفور' + #13#10 + #13#10 +
    'أدوات الإنجاز : Delphi (Object Pascal) + Microsoft Access' + #13#10 +
    'منهجية التصميم : MERISE (MCD / MLD)';

implementation

end.
