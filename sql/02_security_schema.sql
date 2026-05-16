CREATE TABLE security.Role (
    RoleId BIGINT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(128) NOT NULL,
    RoleDescription NVARCHAR(512) NULL,
    IsSystemRole BIT NOT NULL CONSTRAINT DF_security_Role_IsSystemRole DEFAULT 0,
    CONSTRAINT UQ_security_Role_RoleName UNIQUE (RoleName)
);
GO

CREATE TABLE security.Permission (
    PermissionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(128) NOT NULL,
    PermissionDescription NVARCHAR(512) NULL,
    CONSTRAINT UQ_security_Permission_PermissionName UNIQUE (PermissionName)
);
GO

CREATE TABLE security.RolePermission (
    RoleId BIGINT NOT NULL,
    PermissionId BIGINT NOT NULL,
    GrantedAt DATETIME2(3) NOT NULL CONSTRAINT DF_security_RolePermission_GrantedAt DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (RoleId, PermissionId),
    CONSTRAINT FK_security_RolePermission_Role FOREIGN KEY (RoleId) REFERENCES security.Role(RoleId),
    CONSTRAINT FK_security_RolePermission_Permission FOREIGN KEY (PermissionId) REFERENCES security.Permission(PermissionId)
);
GO

CREATE TABLE security.UserAccount (
    UserAccountId BIGINT IDENTITY(1,1) PRIMARY KEY,
    PersonId BIGINT NOT NULL,
    Username NVARCHAR(128) NOT NULL,
    PasswordHashAlgorithm NVARCHAR(32) NOT NULL CONSTRAINT DF_security_UserAccount_PasswordHashAlgorithm DEFAULT N'argon2id',
    PasswordSalt NVARCHAR(256) NOT NULL,
    PasswordHash NVARCHAR(512) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_security_UserAccount_IsActive DEFAULT 1,
    LastLoginAt DATETIME2(3) NULL,
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_security_UserAccount_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_security_UserAccount_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT UQ_security_UserAccount_Username UNIQUE (Username)
);
GO

CREATE TABLE security.UserRole (
    UserAccountId BIGINT NOT NULL,
    RoleId BIGINT NOT NULL,
    AssignedAt DATETIME2(3) NOT NULL CONSTRAINT DF_security_UserRole_AssignedAt DEFAULT SYSUTCDATETIME(),
    PRIMARY KEY (UserAccountId, RoleId),
    CONSTRAINT FK_security_UserRole_UserAccount FOREIGN KEY (UserAccountId) REFERENCES security.UserAccount(UserAccountId),
    CONSTRAINT FK_security_UserRole_Role FOREIGN KEY (RoleId) REFERENCES security.Role(RoleId)
);
GO

CREATE TABLE security.Device (
    DeviceId BIGINT IDENTITY(1,1) PRIMARY KEY,
    DeviceCode NVARCHAR(128) NOT NULL,
    DeviceType NVARCHAR(64) NOT NULL,
    LocationId BIGINT NULL,
    IsOnline BIT NOT NULL CONSTRAINT DF_security_Device_IsOnline DEFAULT 0,
    LastSeenAt DATETIME2(3) NULL,
    CONSTRAINT FK_security_Device_Location FOREIGN KEY (LocationId) REFERENCES core.Location(LocationId),
    CONSTRAINT UQ_security_Device_DeviceCode UNIQUE (DeviceCode)
);
GO

CREATE TABLE security.Camera (
    CameraId BIGINT IDENTITY(1,1) PRIMARY KEY,
    DeviceId BIGINT NOT NULL,
    CameraName NVARCHAR(128) NOT NULL,
    StreamUrl NVARCHAR(1024) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_security_Camera_IsActive DEFAULT 1,
    CONSTRAINT FK_security_Camera_Device FOREIGN KEY (DeviceId) REFERENCES security.Device(DeviceId),
    CONSTRAINT UQ_security_Camera_Device_CameraName UNIQUE (DeviceId, CameraName)
);
GO

CREATE TABLE security.SecurityEvent (
    SecurityEventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    DeviceId BIGINT NULL,
    CameraId BIGINT NULL,
    EventType NVARCHAR(64) NOT NULL,
    Severity NVARCHAR(32) NOT NULL,
    EventAt DATETIME2(3) NOT NULL,
    EventPayload NVARCHAR(MAX) NULL,
    CONSTRAINT FK_security_SecurityEvent_Device FOREIGN KEY (DeviceId) REFERENCES security.Device(DeviceId),
    CONSTRAINT FK_security_SecurityEvent_Camera FOREIGN KEY (CameraId) REFERENCES security.Camera(CameraId),
    CONSTRAINT CK_security_SecurityEvent_Severity CHECK (Severity IN (N'Info', N'Low', N'Medium', N'High', N'Critical'))
);
GO
