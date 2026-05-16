# تحليل المصادر المرجعية العالمية وتطبيقها على هيكلية SQL Server

يوضح هذا الملف كيف تم **الاعتماد على المشاريع المذكورة في الطلب** وتحويل ما يمكن الاستفادة منه إلى نماذج جداول عملية داخل Secure-Registry-v3.

## منهجية التحليل

1. تحديد النمط الوظيفي المفيد من كل مشروع مرجعي.
2. تحويل النمط إلى كيان/علاقة داخل SQL Server.
3. ربط الكيانات بالمخطط الموحد `core` لتفادي التكرار.
4. فرض قيود تكامل مرجعي وقيود جودة بيانات (`FK`, `UNIQUE`, `CHECK`).

## مصفوفة الربط بين المشاريع المرجعية والتطبيق الفعلي

| المشروع المرجعي | النمط المستخلص | التطبيق في Secure-Registry-v3 |
|---|---|---|
| NIEM (`PersonType`, `LocationType`) | هوية رقمية موحدة للأشخاص والمواقع | `core.Person`, `core.Location` |
| IACP (Master Name Record) | سجل الاسم الرئيسي والبدائل | `core.MasterNameRecord` + فهرس الاسم الرئيسي لكل شخص |
| DEMS | إدارة الأدلة الرقمية وسلسلة الحيازة | `enforcement.DigitalEvidence`, `enforcement.ChainOfCustodyEvent` |
| CIMS | ربط الحوادث بالبلاغات | `enforcement.Incident`, `enforcement.CrimeReport` |
| Open Case Filing System | ملفات القضايا وتتبع الدوكت | `justice.CaseFile`, `justice.DocketEntry` |
| Suitor-Law-Firm-DBMS | الجلسات ونتائج القضايا | `justice.Hearing`, `justice.CaseOutcome` |
| Prison-API (Nomis) | الحجز وربطه بالنزيل | `corrections.InmateProfile`, `corrections.Booking` |
| Prison Management System | مستويات الخطورة وسعة الوحدات | `corrections.RiskLevel`, `corrections.Facility`, `corrections.HousingUnit` |
| JumpServer | RBAC وإدارة الصلاحيات | `security.Role`, `security.Permission`, `security.RolePermission`, `security.UserRole` |
| VibeNVR / Shinobi CE | نمذجة الأجهزة/الكاميرات/الأحداث | `security.Device`, `security.Camera`, `security.SecurityEvent` |

## ترتيب البناء المنطقي (Dependency-First)

الترتيب التنفيذي المقترح داخل SQL Server:

1. إنشاء المخططات (Schemas): `sql/00_create_schemas.sql`
2. مخطط الأساس (Core): `sql/01_core_schema.sql`
3. مخطط الأمن (Security): `sql/02_security_schema.sql`
4. مخطط إنفاذ القانون (Enforcement): `sql/03_enforcement_schema.sql`
5. مخطط العدالة (Justice): `sql/04_justice_schema.sql`
6. مخطط المرافق الإصلاحية (Corrections): `sql/05_corrections_schema.sql`
7. تحميل بيانات مرجعية أساسية: `sql/06_seed_reference_data.sql`

## ما تمت إضافته لضمان التكامل والجودة

- مفاتيح خارجية عبر المخططات لضمان مسار بيانات موحد من البلاغ إلى القضية إلى الحجز.
- قيود منع التكرار للمعرفات الحساسة (`NationalId`, `Username`, `CaseNumber`, `IncidentNumber`).
- قيود جودة:
  - صحة إحداثيات المواقع (`GeoLat`, `GeoLon`).
  - صحة تنسيق `SHA256` للأدلة الرقمية.
  - توحيد حالات الكيانات التشغيلية عبر `CHECK`.
- بيانات مرجعية افتراضية للأدوار/الصلاحيات/مستويات الخطورة لتسريع التشغيل الأولي.
