/*
Reference seed data for first-time deployments.
This script is idempotent and safe to re-run.
*/

-- Risk levels (Corrections)
-- Priority uses 1-10 scale (higher value = higher risk severity).
IF NOT EXISTS (SELECT 1 FROM corrections.RiskLevel WHERE RiskCode = N'LOW')
    INSERT INTO corrections.RiskLevel (RiskCode, RiskName, Priority) VALUES (N'LOW', N'Low Risk', 3);

IF NOT EXISTS (SELECT 1 FROM corrections.RiskLevel WHERE RiskCode = N'MEDIUM')
    INSERT INTO corrections.RiskLevel (RiskCode, RiskName, Priority) VALUES (N'MEDIUM', N'Medium Risk', 6);

IF NOT EXISTS (SELECT 1 FROM corrections.RiskLevel WHERE RiskCode = N'HIGH')
    INSERT INTO corrections.RiskLevel (RiskCode, RiskName, Priority) VALUES (N'HIGH', N'High Risk', 9);
GO

-- Roles (Security)
IF NOT EXISTS (SELECT 1 FROM security.Role WHERE RoleName = N'SystemAdmin')
    INSERT INTO security.Role (RoleName, RoleDescription, IsSystemRole)
    VALUES (N'SystemAdmin', N'Full administrative access', 1);

IF NOT EXISTS (SELECT 1 FROM security.Role WHERE RoleName = N'Investigator')
    INSERT INTO security.Role (RoleName, RoleDescription, IsSystemRole)
    VALUES (N'Investigator', N'Incident and evidence handling', 1);

IF NOT EXISTS (SELECT 1 FROM security.Role WHERE RoleName = N'CaseOfficer')
    INSERT INTO security.Role (RoleName, RoleDescription, IsSystemRole)
    VALUES (N'CaseOfficer', N'Case and docket lifecycle management', 1);

IF NOT EXISTS (SELECT 1 FROM security.Role WHERE RoleName = N'CorrectionsOfficer')
    INSERT INTO security.Role (RoleName, RoleDescription, IsSystemRole)
    VALUES (N'CorrectionsOfficer', N'Booking and inmate supervision', 1);
GO

-- Organizations (Core)
IF NOT EXISTS (SELECT 1 FROM core.Organization WHERE OrganizationCode = N'MOI')
    INSERT INTO core.Organization (OrganizationCode, OrganizationName, OrganizationType)
    VALUES (N'MOI', N'وزارة الداخلية', N'جهة سيادية');

IF NOT EXISTS (SELECT 1 FROM core.Organization WHERE OrganizationCode = N'PPO')
    INSERT INTO core.Organization (OrganizationCode, OrganizationName, OrganizationType)
    VALUES (N'PPO', N'النيابة العامة', N'جهة عدلية');

IF NOT EXISTS (SELECT 1 FROM core.Organization WHERE OrganizationCode = N'SJC')
    INSERT INTO core.Organization (OrganizationCode, OrganizationName, OrganizationType)
    VALUES (N'SJC', N'السلطة القضائية', N'جهة قضائية');

IF NOT EXISTS (SELECT 1 FROM core.Organization WHERE OrganizationCode = N'PRS')
    INSERT INTO core.Organization (OrganizationCode, OrganizationName, OrganizationType)
    VALUES (N'PRS', N'مصلحة السجون', N'جهة تنفيذية');
GO

-- Permissions (Security)
IF NOT EXISTS (SELECT 1 FROM security.Permission WHERE PermissionName = N'incident.read')
    INSERT INTO security.Permission (PermissionName, PermissionDescription)
    VALUES (N'incident.read', N'Read incidents and reports');

IF NOT EXISTS (SELECT 1 FROM security.Permission WHERE PermissionName = N'incident.write')
    INSERT INTO security.Permission (PermissionName, PermissionDescription)
    VALUES (N'incident.write', N'Create/update incidents and reports');

IF NOT EXISTS (SELECT 1 FROM security.Permission WHERE PermissionName = N'evidence.manage')
    INSERT INTO security.Permission (PermissionName, PermissionDescription)
    VALUES (N'evidence.manage', N'Manage digital evidence and chain of custody');

IF NOT EXISTS (SELECT 1 FROM security.Permission WHERE PermissionName = N'case.manage')
    INSERT INTO security.Permission (PermissionName, PermissionDescription)
    VALUES (N'case.manage', N'Manage case files, hearings, and outcomes');

IF NOT EXISTS (SELECT 1 FROM security.Permission WHERE PermissionName = N'booking.manage')
    INSERT INTO security.Permission (PermissionName, PermissionDescription)
    VALUES (N'booking.manage', N'Manage inmate bookings and releases');

IF NOT EXISTS (SELECT 1 FROM security.Permission WHERE PermissionName = N'security.monitor')
    INSERT INTO security.Permission (PermissionName, PermissionDescription)
    VALUES (N'security.monitor', N'Monitor devices, cameras, and security events');
GO

-- Action dictionary baseline (inspired by v2 sys_action_types governance pattern)
IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'open')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'open', N'فتح', 10);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'view')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'view', N'عرض', 20);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'create')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'create', N'إضافة', 30);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'update')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'update', N'تعديل', 40);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'approve')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'approve', N'اعتماد', 50);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'reject')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'reject', N'رفض', 60);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'export')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'export', N'تصدير', 70);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'restore')
    INSERT INTO security.ActionType (ActionCode, ActionName, SortOrder)
    VALUES (N'restore', N'استعادة', 80);
GO

-- Governance catalogs
IF NOT EXISTS (SELECT 1 FROM governance.LegalInstrumentType WHERE TypeCode = N'CONSTITUTION')
    INSERT INTO governance.LegalInstrumentType (TypeCode, TypeName)
    VALUES (N'CONSTITUTION', N'دستور');

IF NOT EXISTS (SELECT 1 FROM governance.LegalInstrumentType WHERE TypeCode = N'LAW')
    INSERT INTO governance.LegalInstrumentType (TypeCode, TypeName)
    VALUES (N'LAW', N'قانون');

IF NOT EXISTS (SELECT 1 FROM governance.LegalInstrumentType WHERE TypeCode = N'REGULATION')
    INSERT INTO governance.LegalInstrumentType (TypeCode, TypeName)
    VALUES (N'REGULATION', N'لائحة');

IF NOT EXISTS (SELECT 1 FROM governance.LegalInstrumentType WHERE TypeCode = N'PROCEDURE')
    INSERT INTO governance.LegalInstrumentType (TypeCode, TypeName)
    VALUES (N'PROCEDURE', N'إجراء');

IF NOT EXISTS (SELECT 1 FROM governance.NationalSecurityDomain WHERE DomainCode = N'COUNTER_TERROR')
    INSERT INTO governance.NationalSecurityDomain (DomainCode, DomainName, DomainDescription)
    VALUES (N'COUNTER_TERROR', N'مكافحة الإرهاب', N'حماية الدولة والمجتمع من التنظيمات والأعمال الإرهابية');

IF NOT EXISTS (SELECT 1 FROM governance.NationalSecurityDomain WHERE DomainCode = N'CYBER_SECURITY')
    INSERT INTO governance.NationalSecurityDomain (DomainCode, DomainName, DomainDescription)
    VALUES (N'CYBER_SECURITY', N'الأمن السيبراني', N'حماية البنية المعلوماتية والأنظمة من الاختراق والتخريب');

IF NOT EXISTS (SELECT 1 FROM governance.NationalSecurityDomain WHERE DomainCode = N'ORGANIZED_CRIME')
    INSERT INTO governance.NationalSecurityDomain (DomainCode, DomainName, DomainDescription)
    VALUES (N'ORGANIZED_CRIME', N'الجريمة المنظمة', N'مكافحة الشبكات الإجرامية والاتجار والتهريب');

IF NOT EXISTS (SELECT 1 FROM governance.ThreatCategory WHERE ThreatCategoryCode = N'TERROR_CELL')
    INSERT INTO governance.ThreatCategory (DomainId, ThreatCategoryCode, ThreatCategoryName)
    SELECT d.DomainId, N'TERROR_CELL', N'خلايا إرهابية'
    FROM governance.NationalSecurityDomain d
    WHERE d.DomainCode = N'COUNTER_TERROR';

IF NOT EXISTS (SELECT 1 FROM governance.ThreatCategory WHERE ThreatCategoryCode = N'MALWARE')
    INSERT INTO governance.ThreatCategory (DomainId, ThreatCategoryCode, ThreatCategoryName)
    SELECT d.DomainId, N'MALWARE', N'برمجيات خبيثة'
    FROM governance.NationalSecurityDomain d
    WHERE d.DomainCode = N'CYBER_SECURITY';

IF NOT EXISTS (SELECT 1 FROM governance.ThreatCategory WHERE ThreatCategoryCode = N'TRAFFICKING')
    INSERT INTO governance.ThreatCategory (DomainId, ThreatCategoryCode, ThreatCategoryName)
    SELECT d.DomainId, N'TRAFFICKING', N'شبكات تهريب واتجار'
    FROM governance.NationalSecurityDomain d
    WHERE d.DomainCode = N'ORGANIZED_CRIME';

IF NOT EXISTS (SELECT 1 FROM governance.Threat WHERE ThreatCode = N'EXPLOSIVE_PLOT')
    INSERT INTO governance.Threat (ThreatCategoryId, ThreatCode, ThreatName, ThreatDescription, SeverityLevel)
    SELECT c.ThreatCategoryId, N'EXPLOSIVE_PLOT', N'مخطط تفجير', N'تخطيط أو تجهيز أو تمويل تفجير أو عمل إرهابي', 10
    FROM governance.ThreatCategory c
    WHERE c.ThreatCategoryCode = N'TERROR_CELL';

IF NOT EXISTS (SELECT 1 FROM governance.Threat WHERE ThreatCode = N'CRITICAL_SYSTEM_INTRUSION')
    INSERT INTO governance.Threat (ThreatCategoryId, ThreatCode, ThreatName, ThreatDescription, SeverityLevel)
    SELECT c.ThreatCategoryId, N'CRITICAL_SYSTEM_INTRUSION', N'اختراق بنية حرجة', N'اختراق أو تعطيل أنظمة معلوماتية سيادية أو حرجة', 9
    FROM governance.ThreatCategory c
    WHERE c.ThreatCategoryCode = N'MALWARE';

IF NOT EXISTS (SELECT 1 FROM governance.Threat WHERE ThreatCode = N'CROSS_BORDER_TRAFFICKING')
    INSERT INTO governance.Threat (ThreatCategoryId, ThreatCode, ThreatName, ThreatDescription, SeverityLevel)
    SELECT c.ThreatCategoryId, N'CROSS_BORDER_TRAFFICKING', N'تهريب عابر للحدود', N'نشاط منظم لنقل أشخاص أو أسلحة أو أموال بطرق غير مشروعة', 8
    FROM governance.ThreatCategory c
    WHERE c.ThreatCategoryCode = N'TRAFFICKING';

IF NOT EXISTS (SELECT 1 FROM governance.LegalInstrument WHERE InstrumentNumber = N'الدستور-1')
    INSERT INTO governance.LegalInstrument (LegalInstrumentTypeId, InstrumentNumber, InstrumentName, IssuingAuthorityId)
    SELECT t.LegalInstrumentTypeId, N'الدستور-1', N'الدستور', o.OrganizationId
    FROM governance.LegalInstrumentType t
    CROSS JOIN core.Organization o
    WHERE t.TypeCode = N'CONSTITUTION'
      AND o.OrganizationCode = N'SJC';

IF NOT EXISTS (SELECT 1 FROM governance.LegalInstrument WHERE InstrumentNumber = N'قانون-الأمن-1')
    INSERT INTO governance.LegalInstrument (LegalInstrumentTypeId, InstrumentNumber, InstrumentName, IssuingAuthorityId)
    SELECT t.LegalInstrumentTypeId, N'قانون-الأمن-1', N'قانون حماية الأمن القومي', o.OrganizationId
    FROM governance.LegalInstrumentType t
    CROSS JOIN core.Organization o
    WHERE t.TypeCode = N'LAW'
      AND o.OrganizationCode = N'MOI';

IF NOT EXISTS (SELECT 1 FROM governance.LegalArticle WHERE ArticleNumber = N'15'
    AND LegalInstrumentId = (SELECT TOP 1 LegalInstrumentId FROM governance.LegalInstrument WHERE InstrumentNumber = N'قانون-الأمن-1'))
    INSERT INTO governance.LegalArticle (LegalInstrumentId, ArticleNumber, ArticleTitle, ArticleText)
    SELECT i.LegalInstrumentId, N'15', N'أعمال تهدد الأمن القومي', N'تحدد هذه المادة صور الأعمال الماسة بالأمن القومي وإجراءات مواجهتها.'
    FROM governance.LegalInstrument i
    WHERE i.InstrumentNumber = N'قانون-الأمن-1';

IF NOT EXISTS (
    SELECT 1
    FROM governance.AuthorityJurisdiction aj
    JOIN core.Organization o ON o.OrganizationId = aj.OrganizationId
    JOIN governance.NationalSecurityDomain d ON d.DomainId = aj.DomainId
    WHERE o.OrganizationCode = N'MOI'
      AND d.DomainCode = N'COUNTER_TERROR'
)
    INSERT INTO governance.AuthorityJurisdiction (OrganizationId, DomainId, ResponsibilityName, ResponsibilityDetails)
    SELECT o.OrganizationId, d.DomainId, N'ضبط واستدلال', N'اختصاص جمع المعلومات والاستدلال الأولي والقبض وفق القانون'
    FROM core.Organization o
    CROSS JOIN governance.NationalSecurityDomain d
    WHERE o.OrganizationCode = N'MOI'
      AND d.DomainCode = N'COUNTER_TERROR';

IF NOT EXISTS (
    SELECT 1
    FROM governance.AuthorityJurisdiction aj
    JOIN core.Organization o ON o.OrganizationId = aj.OrganizationId
    JOIN governance.NationalSecurityDomain d ON d.DomainId = aj.DomainId
    WHERE o.OrganizationCode = N'PPO'
      AND d.DomainCode = N'COUNTER_TERROR'
)
    INSERT INTO governance.AuthorityJurisdiction (OrganizationId, DomainId, ResponsibilityName, ResponsibilityDetails)
    SELECT o.OrganizationId, d.DomainId, N'تحقيق وادعاء', N'اختصاص الإشراف على التحقيق والتصرف في ملف القضية والإحالة للمحكمة'
    FROM core.Organization o
    CROSS JOIN governance.NationalSecurityDomain d
    WHERE o.OrganizationCode = N'PPO'
      AND d.DomainCode = N'COUNTER_TERROR';

IF NOT EXISTS (
    SELECT 1
    FROM governance.AuthorityJurisdiction aj
    JOIN core.Organization o ON o.OrganizationId = aj.OrganizationId
    JOIN governance.NationalSecurityDomain d ON d.DomainId = aj.DomainId
    WHERE o.OrganizationCode = N'PRS'
      AND d.DomainCode = N'COUNTER_TERROR'
)
    INSERT INTO governance.AuthorityJurisdiction (OrganizationId, DomainId, ResponsibilityName, ResponsibilityDetails)
    SELECT o.OrganizationId, d.DomainId, N'إيداع وتنفيذ', N'اختصاص تنفيذ أوامر الإيداع والحبس وتنفيذ الأحكام السالبة للحرية'
    FROM core.Organization o
    CROSS JOIN governance.NationalSecurityDomain d
    WHERE o.OrganizationCode = N'PRS'
      AND d.DomainCode = N'COUNTER_TERROR';
GO

-- Role-Permission mapping (RBAC baseline)
DECLARE @RolePermissionSeed TABLE (
    -- Keep NVARCHAR lengths aligned with security.Role.RoleName and security.Permission.PermissionName.
    -- This table variable centralizes mappings so one idempotent INSERT can join current Role/Permission records.
    RoleName NVARCHAR(128) NOT NULL,
    PermissionName NVARCHAR(128) NOT NULL,
    PRIMARY KEY (RoleName, PermissionName)
);

INSERT INTO @RolePermissionSeed (RoleName, PermissionName)
VALUES
    (N'SystemAdmin', N'incident.read'),
    (N'SystemAdmin', N'incident.write'),
    (N'SystemAdmin', N'evidence.manage'),
    (N'SystemAdmin', N'case.manage'),
    (N'SystemAdmin', N'booking.manage'),
    (N'SystemAdmin', N'security.monitor'),
    (N'Investigator', N'incident.read'),
    (N'Investigator', N'incident.write'),
    (N'Investigator', N'evidence.manage'),
    (N'CaseOfficer', N'incident.read'),
    (N'CaseOfficer', N'case.manage'),
    (N'CorrectionsOfficer', N'booking.manage'),
    (N'CorrectionsOfficer', N'incident.read');

INSERT INTO security.RolePermission (RoleId, PermissionId)
SELECT r.RoleId, p.PermissionId
FROM @RolePermissionSeed s
JOIN security.Role r ON r.RoleName = s.RoleName
JOIN security.Permission p ON p.PermissionName = s.PermissionName
WHERE NOT EXISTS (
    SELECT 1
    FROM security.RolePermission rp
    WHERE rp.RoleId = r.RoleId
      AND rp.PermissionId = p.PermissionId
);
GO
