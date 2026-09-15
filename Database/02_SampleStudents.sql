/* =========================================================================
   قائمة تلاميذ نموذجية : ناجحو شهادة التعليم المتوسط - دورة 2026
   متوسطة الشهيد بالعربي أحمد - سيدي طيفور، ولاية البيض
   المصدر : قوائم الناجحين حسب المؤسسة (5 صفحات، 90 تلميذا)

   هذا الملف للتوثيق. الإدراج داخل البرنامج من :
       أدوات  ←  إدراج قائمة تلاميذ نموذجية
   حيث تُوزَّع الدفعة على قسمي 4م1 و 4م2 ولا تتكرر السجلات الموجودة.

   ملاحظة : مكان الميلاد وبيانات الولي تُركت فارغة لأنها غير واردة في
   القائمة الأصلية؛ لم تُختلق أي معطيات.
   ========================================================================= */


INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436701', '28436701', 'حناشي', 'آية', 'أنثى', #11/17/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,87 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436702', '28436702', 'مخطاري', 'آية', 'أنثى', #06/14/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 17,90 - جيد جدا'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436703', '28436703', 'محبوبي', 'آية', 'أنثى', #02/22/2012#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,83 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436706', '28436706', 'بالعربي', 'أحمد الصديق', 'ذكر', #08/20/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,05 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436714', '28436714', 'سماني', 'أمينة', 'أنثى', #03/16/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,00 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436718', '28436718', 'بن سيرة', 'أيوب', 'ذكر', #08/28/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,88 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436801', '28436801', 'الوزاني', 'إسماعيل', 'ذكر', #07/23/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,08 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436802', '28436802', 'مخطاري', 'إشراق جهان', 'أنثى', #04/05/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,06 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436803', '28436803', 'قندوزي', 'إيمان', 'أنثى', #12/22/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,80 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436805', '28436805', 'بالحاجي', 'إيمان', 'أنثى', #06/14/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,53 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436806', '28436806', 'مجروني', 'إيمان', 'أنثى', #03/11/2012#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 15,91 - جيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436809', '28436809', 'زيوش', 'إيناس', 'أنثى', #10/23/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,78 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436814', '28436814', 'مقدم', 'اكرام', 'أنثى', #12/21/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,52 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436816', '28436816', 'يعقوبي', 'الحسن', 'ذكر', #03/11/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,76 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436817', '28436817', 'حساني', 'الحسين', 'ذكر', #02/18/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,83 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436902', '28436902', 'حساني', 'بوبكر', 'ذكر', #12/21/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,29 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436903', '28436903', 'زياني', 'بوبكر', 'ذكر', #04/13/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,94 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436909', '28436909', 'بن سليمان', 'حليمة', 'أنثى', #01/01/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,67 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436910', '28436910', 'بن سعد', 'حليمة', 'أنثى', #08/25/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,91 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436914', '28436914', 'بلخضر', 'حنان', 'أنثى', #09/08/2008#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,45 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436915', '28436915', 'حدي', 'حنان', 'أنثى', #09/02/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,53 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436916', '28436916', 'طرشي', 'حورية', 'أنثى', #11/20/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,66 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436918', '28436918', 'حناشي', 'خديجة', 'أنثى', #01/14/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,67 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28436919', '28436919', 'مخطاري', 'خديجة', 'أنثى', #05/14/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,93 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437004', '28437004', 'بن يوسف', 'رؤى تسنيم', 'أنثى', #06/25/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 15,00 - جيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437005', '28437005', 'بوجليدة', 'رانيا', 'أنثى', #10/07/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,00 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437007', '28437007', 'بالحاجي', 'رجاء نور الهدى', 'أنثى', #04/18/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,06 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437010', '28437010', 'بن يمينة', 'رفيدة', 'أنثى', #03/18/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,54 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437011', '28437011', 'حدي', 'رفيق', 'ذكر', #09/18/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,48 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437017', '28437017', 'بوجليدة', 'زينب', 'أنثى', #05/09/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,68 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437018', '28437018', 'بالعربي', 'سارة', 'أنثى', #04/27/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,85 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437019', '28437019', 'بن بغداد', 'سجى نور اليقين', 'أنثى', #09/16/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 16,23 - جيد جدا'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437020', '28437020', 'حواسين', 'سعاد', 'أنثى', #02/03/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,88 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437101', '28437101', 'مجروني', 'سلسبيل قطر الندى', 'أنثى', #11/25/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,88 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437103', '28437103', 'مجروني', 'سندس', 'أنثى', #04/23/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,79 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437104', '28437104', 'بن تومي', 'سوسن', 'أنثى', #10/18/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,77 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437107', '28437107', 'حساني', 'شيماء', 'أنثى', #09/11/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,43 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437108', '28437108', 'زديمي', 'شيماء', 'أنثى', #08/24/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,09 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437109', '28437109', 'بن تومي', 'صابرينة', 'أنثى', #02/08/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,77 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437111', '28437111', 'زيوش', 'صورية', 'أنثى', #08/31/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,72 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437114', '28437114', 'بن سعد', 'طه ياسين', 'ذكر', #07/04/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,41 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437118', '28437118', 'نوي', 'عامرة', 'أنثى', #10/26/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,88 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437119', '28437119', 'عبد الغاني', 'عامرة', 'أنثى', #11/20/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,36 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437201', '28437201', 'مجروني', 'عبد الحق', 'ذكر', #10/01/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,40 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437202', '28437202', 'بن سليمان', 'عبد الحكيم', 'ذكر', #08/02/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,31 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م1';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437210', '28437210', 'زديمي', 'عبد القادر', 'ذكر', #02/26/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,21 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437211', '28437211', 'بن سيرة', 'عبد القادر', 'ذكر', #08/11/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,27 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437216', '28437216', 'حساني', 'عبد المطلب', 'ذكر', #01/10/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 14,16 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437219', '28437219', 'حساني', 'علاء الدين', 'ذكر', #06/24/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,65 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437303', '28437303', 'بن نعيمة', 'عمر عبد السعيد', 'ذكر', #09/11/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,11 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437304', '28437304', 'بوصبيع', 'عيسى', 'ذكر', #08/19/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,31 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437308', '28437308', 'الهواري', 'فاطمة الزهراء', 'أنثى', #11/17/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,37 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437309', '28437309', 'مخطاري', 'فاطمة الزهراء', 'أنثى', #12/22/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,69 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437310', '28437310', 'حساني', 'فاطمة الزهراء', 'أنثى', #08/22/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,13 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437311', '28437311', 'حميدو', 'فاطمة الزهراء', 'أنثى', #09/13/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,88 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437312', '28437312', 'سماني', 'فاطمة الزهرة', 'أنثى', #09/25/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,15 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437314', '28437314', 'معوش', 'فاطمة شيماء', 'أنثى', #02/14/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,37 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437315', '28437315', 'حواسين', 'فاطيمة', 'أنثى', #01/04/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,24 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437316', '28437316', 'بالحاجي', 'فاطيمة', 'أنثى', #01/13/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,00 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437317', '28437317', 'بن سعد', 'فاطيمة', 'أنثى', #04/14/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,62 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437318', '28437318', 'يعقوبي', 'فضيلة', 'أنثى', #08/15/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 16,19 - جيد جدا'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437401', '28437401', 'بالحاجي', 'كنزة', 'أنثى', #08/04/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,26 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437405', '28437405', 'عبد الغاني', 'كوثر', 'أنثى', #08/15/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,79 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437407', '28437407', 'حساني', 'لطيفة', 'أنثى', #08/25/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,06 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437414', '28437414', 'بن سعد', 'محمد', 'ذكر', #06/01/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,87 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437415', '28437415', 'بن تومي', 'محمد', 'ذكر', #12/13/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,67 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437416', '28437416', 'مخطاري', 'محمد أحمد ياسين', 'ذكر', #08/26/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,74 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437419', '28437419', 'الوزاني', 'محمد طه', 'ذكر', #10/06/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,35 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437501', '28437501', 'نوي', 'محمد عبد الله', 'ذكر', #02/04/2008#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,09 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437502', '28437502', 'دربالي', 'محمد محي الدين', 'ذكر', #01/30/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,13 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437507', '28437507', 'حواسين', 'مروة', 'أنثى', #07/24/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,68 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437511', '28437511', 'حواسين', 'مسعودة', 'أنثى', #04/24/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,27 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437513', '28437513', 'حساني', 'مصطفى', 'ذكر', #09/14/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 11,97 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437516', '28437516', 'حساني', 'مصطفى مداني', 'ذكر', #01/31/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,54 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437517', '28437517', 'حبيبي', 'منى', 'أنثى', #10/20/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,10 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437518', '28437518', 'بن سليمان', 'منير', 'ذكر', #08/09/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,10 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437520', '28437520', 'حساني', 'نجاة', 'أنثى', #07/25/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 14,62 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437603', '28437603', 'حواسين', 'نور الدين', 'ذكر', #05/01/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,78 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437604', '28437604', 'طراشي', 'نور الهدى', 'أنثى', #11/01/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 14,33 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437607', '28437607', 'حساني', 'هدى نور اليقين', 'أنثى', #05/18/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 15,46 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437608', '28437608', 'بن سعد', 'هدية', 'أنثى', #01/03/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 14,98 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437610', '28437610', 'حساني', 'هديل فاطمة الزهراء', 'أنثى', #10/03/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,48 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437612', '28437612', 'مخطاري', 'هناء', 'أنثى', #09/28/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 15,64 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437613', '28437613', 'الوزاني', 'هيثم', 'ذكر', #08/21/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,71 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437615', '28437615', 'بن سيرة', 'وفاء', 'أنثى', #08/05/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 14,15 - جيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437616', '28437616', 'حدي', 'وفاء رهف', 'أنثى', #07/09/2011#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,72 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437617', '28437617', 'حساني', 'ياسر عرفات', 'ذكر', #08/28/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,47 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437618', '28437618', 'بالعربي', 'ياسين', 'ذكر', #10/13/2009#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 12,10 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437619', '28437619', 'حواسين', 'ياسين', 'ذكر', #10/17/2010#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 13,12 - قريب من الجيد'
  FROM Classes c WHERE c.ClassName = '4م2';

INSERT INTO Students (MatriculeNat, RegNumber, LastName, FirstName, Gender,
    BirthDate, ClassID, RegimeStatus, IsActive, Notes)
  SELECT '28437620', '28437620', 'بن تومي', 'يحي', 'ذكر', #07/26/2008#, c.ClassID, 'خارجي', True,
         'معدل شهادة التعليم المتوسط 2026 : 10,91 - مقبول'
  FROM Classes c WHERE c.ClassName = '4م2';
