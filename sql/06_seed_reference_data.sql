/*
Reference seed data for first-time deployments.
This script is idempotent and safe to re-run.
*/

-- Risk levels (Corrections)
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

-- Role-Permission mapping (RBAC baseline)
INSERT INTO security.RolePermission (RoleId, PermissionId)
SELECT r.RoleId, p.PermissionId
FROM security.Role r
JOIN security.Permission p ON p.PermissionName IN (N'incident.read', N'incident.write', N'evidence.manage', N'case.manage', N'booking.manage', N'security.monitor')
WHERE r.RoleName = N'SystemAdmin'
  AND NOT EXISTS (
      SELECT 1 FROM security.RolePermission rp
      WHERE rp.RoleId = r.RoleId AND rp.PermissionId = p.PermissionId
  );

INSERT INTO security.RolePermission (RoleId, PermissionId)
SELECT r.RoleId, p.PermissionId
FROM security.Role r
JOIN security.Permission p ON p.PermissionName IN (N'incident.read', N'incident.write', N'evidence.manage')
WHERE r.RoleName = N'Investigator'
  AND NOT EXISTS (
      SELECT 1 FROM security.RolePermission rp
      WHERE rp.RoleId = r.RoleId AND rp.PermissionId = p.PermissionId
  );

INSERT INTO security.RolePermission (RoleId, PermissionId)
SELECT r.RoleId, p.PermissionId
FROM security.Role r
JOIN security.Permission p ON p.PermissionName IN (N'incident.read', N'case.manage')
WHERE r.RoleName = N'CaseOfficer'
  AND NOT EXISTS (
      SELECT 1 FROM security.RolePermission rp
      WHERE rp.RoleId = r.RoleId AND rp.PermissionId = p.PermissionId
  );

INSERT INTO security.RolePermission (RoleId, PermissionId)
SELECT r.RoleId, p.PermissionId
FROM security.Role r
JOIN security.Permission p ON p.PermissionName IN (N'booking.manage', N'incident.read')
WHERE r.RoleName = N'CorrectionsOfficer'
  AND NOT EXISTS (
      SELECT 1 FROM security.RolePermission rp
      WHERE rp.RoleId = r.RoleId AND rp.PermissionId = p.PermissionId
  );
GO
