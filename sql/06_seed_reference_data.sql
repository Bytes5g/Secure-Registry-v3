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
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'open', N'فتح', N'Open', 10);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'view')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'view', N'عرض', N'View', 20);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'create')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'create', N'إضافة', N'Create', 30);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'update')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'update', N'تعديل', N'Update', 40);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'approve')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'approve', N'اعتماد', N'Approve', 50);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'reject')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'reject', N'رفض', N'Reject', 60);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'export')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'export', N'تصدير', N'Export', 70);

IF NOT EXISTS (SELECT 1 FROM security.ActionType WHERE ActionCode = N'restore')
    INSERT INTO security.ActionType (ActionCode, ActionNameAr, ActionNameEn, SortOrder)
    VALUES (N'restore', N'استعادة', N'Restore', 80);
GO

-- Role-Permission mapping (RBAC baseline)
DECLARE @RolePermissionSeed TABLE (
    -- Keep NVARCHAR lengths aligned with security.Role.RoleName and security.Permission.PermissionName.
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
