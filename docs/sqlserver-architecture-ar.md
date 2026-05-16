# الهيكلية البرمجية المقترحة لـ Secure Registry v3 (SQL Server)

هذا المستند يقدّم نموذجًا متكاملًا ومُنظّمًا لقاعدة بيانات سيادية على **SQL Server**، مستخلصًا من أفضل الممارسات المذكورة في المتطلبات، مع التركيز على:

- توحيد الهوية الرقمية (الأفراد/المواقع)
- توثيق الجهات والقوانين ومجالات الأمن القومي والتهديدات
- منع التكرار عبر التطبيع (Normalization)
- فرض التكامل المرجعي (Referential Integrity)
- دعم الأمن والتحكم (RBAC + مراقبة الأجهزة)
- قابلية التوسع بين الأمني/العدلي/الإصلاحي

## 1) Core Schema (`core`)

مرجعية التصميم:
- NIEM (`PersonType`, `LocationType`)
- IACP (Master Name Record)

الجداول:
- `core.Person`: هوية موحدة للفرد (NationalId, GivenName, FamilyName, BirthDate, GenderCode)
- `core.Location`: تمثيل موحد للمواقع (AddressLine1, City, Region, PostalCode, GeoLat/GeoLon)
- `core.MasterNameRecord`: سجل الأسماء الرئيسية والبدائل مع منع التكرار
- `core.Organization`: تمثيل الجهات المختصة والجهات الأطراف في القضايا

خصائص الجودة:
- `UNIQUE` على `NationalId` و`LocationExternalRef`
- فهرس مركب يمنع تكرار الاسم/تاريخ الميلاد
- `CHECK` لقيم الجنس والاسم الرئيسي وصحة نطاق الإحداثيات الجغرافية (Latitude/Longitude)

## 2) Security Schema (`security`)

مرجعية التصميم:
- JumpServer (RBAC)
- VibeNVR / Shinobi CE (مراقبة الأجهزة والكاميرات والأحداث)

الجداول:
- `security.Role`, `security.Permission`, `security.RolePermission`
- `security.ActionType` (قاموس أفعال قياسي بإسم عربي موحد)
- `security.UserAccount`, `security.UserRole`
- `security.Device`, `security.Camera`, `security.SecurityEvent`

خصائص الجودة:
- نموذج RBAC كامل بعلاقات many-to-many
- ربط المستخدم بالشخص في `core.Person`
- منع تكرار أسماء المستخدمين والأدوار والصلاحيات
- توحيد قاموس الإجراءات عبر أكواد مستقرة مع اسم عربي واحد لكل إجراء
- دعم تخزين بيانات المصادقة بشكل أكثر أمانًا عبر `PasswordHashAlgorithm` و`PasswordSalt` بجانب `PasswordHash`

## 3) Governance Schema (`governance`)

الجداول:
- `governance.NationalSecurityDomain`
- `governance.ThreatCategory`
- `governance.Threat`
- `governance.LegalInstrumentType`
- `governance.LegalInstrument`
- `governance.LegalArticle`
- `governance.AuthorityJurisdiction`

خصائص الجودة:
- تهيئة مجالات الأمن القومي والمهددات والتهديدات بشكل مرجعي
- توثيق القوانين والدساتير واللوائح والإجراءات والمواد القانونية
- ربط الاختصاص القانوني والتنفيذي بالجهات في `core.Organization`

## 4) Enforcement Schema (`enforcement`)

مرجعية التصميم:
- DEMS (الأدلة الرقمية + Chain of Custody)
- CIMS (Incident-Based Reporting)

الجداول:
- `enforcement.Incident`
- `enforcement.IntakeRecord`
- `enforcement.CrimeReport`
- `enforcement.IncidentParty`
- `enforcement.ArrestAction`
- `enforcement.DigitalEvidence`
- `enforcement.EvidenceCollectionRecord`
- `enforcement.ChainOfCustodyEvent`

خصائص الجودة:
- يبدأ التدفق من سجل استقبال (`IntakeRecord`) لنوع بلاغ/حدث/نشاط
- كل بلاغ (`CrimeReport`) مرتبط بحادث (`Incident`)
- تمثيل مرن للأشخاص أو الجهات المرتبطة بالحالة عبر `IncidentParty`
- توثيق القبض وأساسه القانوني وجهة الضبط عبر `ArrestAction`
- كل دليل رقمي مرتبط بحادث وقد يرتبط بكاميرا
- سلسلة حيازة متعاقبة مع طرف مُسلم وطرف مستلم

## 5) Justice Schema (`justice`)

مرجعية التصميم:
- Open Case Filing System (القضايا + الدوكت)
- Suitor-Law-Firm-DBMS (الجلسات وحالات القضايا)

الجداول:
- `justice.CaseFile`
- `justice.DocketEntry`
- `justice.Hearing`
- `justice.CaseOutcome`
- `justice.CaseParty`
- `justice.ProsecutionReferral`
- `justice.InvestigationMemo`
- `justice.WitnessStatement`
- `justice.CaseLegalReference`
- `justice.Judgment`
- `justice.JudicialProcedure`

خصائص الجودة:
- ملف القضية مرتبط بحادث أمني
- ربط القضية بالأشخاص أو الجهات المعنية وبالمواد القانونية والمجالات الأمنية
- توثيق الإحالة للنيابة ومحاضر جمع الاستدلالات والتحقيق والشهود
- توثيق الأحكام والإجراءات القضائية بشكل منفصل وقابل للتتبع
- تتبع إجرائي عبر `DocketEntry`
- نتيجة القضية مضبوطة بقيم معيارية (`Won`, `Lost`, `Settled`, `Pending`)

## 6) Corrections Schema (`corrections`)

مرجعية التصميم:
- Prison-API (Bookings)
- Prison Management System (Risk Levels + السعة)

الجداول:
- `corrections.Facility`
- `corrections.HousingUnit`
- `corrections.InmateProfile`
- `corrections.RiskLevel`
- `corrections.Booking`

خصائص الجودة:
- ربط النزيل بالشخص في `core.Person`
- ربط الحجز بقضية قضائية (اختياري)
- ربط الإيداع بإجراء القبض أو الحكم عند توفره
- تتبع مستوى الخطورة وسعة الأجنحة

## التكامل المرجعي ومنع التكرار

- المفاتيح الأساسية: `IDENTITY` لكل كيان رئيسي
- المفاتيح الأجنبية: تربط المخططات الخمسة ببعضها
- الفهارس الفريدة: تمنع ازدواج الهويات والسجلات
- القيود: `CHECK` على الحالات والقيم الحساسة

## الملفات المنفذة

- `sql/00_create_schemas.sql`
- `sql/01_core_schema.sql`
- `sql/02_security_schema.sql`
- `sql/07_governance_schema.sql`
- `sql/03_enforcement_schema.sql`
- `sql/04_justice_schema.sql`
- `sql/05_corrections_schema.sql`
- `sql/06_seed_reference_data.sql`
- `sql/99_all_in_one.sql`

## التحليل التفصيلي للمصادر

تم توفير ملف تحليل مستقل يربط كل مشروع مرجعي بالنمط المطبق فعليًا داخل قاعدة البيانات:

- `docs/source-analysis-ar.md`
- `docs/v2-gap-analysis-ar.md`
- `docs/national-security-case-scenario-ar.md`
