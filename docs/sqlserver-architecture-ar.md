# الهيكلية البرمجية المقترحة لـ Secure Registry v3 (SQL Server)

هذا المستند يقدّم نموذجًا متكاملًا ومُنظّمًا لقاعدة بيانات سيادية على **SQL Server**، مستخلصًا من أفضل الممارسات المذكورة في المتطلبات، مع التركيز على:

- توحيد الهوية الرقمية (الأفراد/المواقع)
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

خصائص الجودة:
- `UNIQUE` على `NationalId` و`LocationExternalRef`
- فهرس مركب يمنع تكرار الاسم/تاريخ الميلاد
- `CHECK` لقيم الجنس والاسم الرئيسي

## 2) Security Schema (`security`)

مرجعية التصميم:
- JumpServer (RBAC)
- VibeNVR / Shinobi CE (مراقبة الأجهزة والكاميرات والأحداث)

الجداول:
- `security.Role`, `security.Permission`, `security.RolePermission`
- `security.UserAccount`, `security.UserRole`
- `security.Device`, `security.Camera`, `security.SecurityEvent`

خصائص الجودة:
- نموذج RBAC كامل بعلاقات many-to-many
- ربط المستخدم بالشخص في `core.Person`
- منع تكرار أسماء المستخدمين والأدوار والصلاحيات

## 3) Enforcement Schema (`enforcement`)

مرجعية التصميم:
- DEMS (الأدلة الرقمية + Chain of Custody)
- CIMS (Incident-Based Reporting)

الجداول:
- `enforcement.Incident`
- `enforcement.CrimeReport`
- `enforcement.DigitalEvidence`
- `enforcement.ChainOfCustodyEvent`

خصائص الجودة:
- كل بلاغ (`CrimeReport`) مرتبط بحادث (`Incident`)
- كل دليل رقمي مرتبط بحادث وقد يرتبط بكاميرا
- سلسلة حيازة متعاقبة مع طرف مُسلم وطرف مستلم

## 4) Justice Schema (`justice`)

مرجعية التصميم:
- Open Case Filing System (القضايا + الدوكت)
- Suitor-Law-Firm-DBMS (الجلسات وحالات القضايا)

الجداول:
- `justice.CaseFile`
- `justice.DocketEntry`
- `justice.Hearing`
- `justice.CaseOutcome`

خصائص الجودة:
- ملف القضية مرتبط بحادث أمني
- تتبع إجرائي عبر `DocketEntry`
- نتيجة القضية مضبوطة بقيم معيارية (`Won`, `Lost`, `Settled`, `Pending`)

## 5) Corrections Schema (`corrections`)

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
- `sql/03_enforcement_schema.sql`
- `sql/04_justice_schema.sql`
- `sql/05_corrections_schema.sql`
- `sql/99_all_in_one.sql`

