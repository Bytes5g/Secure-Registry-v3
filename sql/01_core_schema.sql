CREATE TABLE core.Person (
    PersonId BIGINT IDENTITY(1,1) PRIMARY KEY,
    NationalId NVARCHAR(64) NOT NULL,
    GivenName NVARCHAR(128) NOT NULL,
    MiddleName NVARCHAR(128) NULL,
    FamilyName NVARCHAR(128) NOT NULL,
    BirthDate DATE NULL,
    GenderCode NVARCHAR(16) NULL,
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_core_Person_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2(3) NULL,
    CONSTRAINT UQ_core_Person_NationalId UNIQUE (NationalId),
    CONSTRAINT CK_core_Person_GenderCode CHECK (GenderCode IS NULL OR GenderCode IN (N'Male', N'Female', N'Other', N'Unknown'))
);
GO

CREATE TABLE core.Location (
    LocationId BIGINT IDENTITY(1,1) PRIMARY KEY,
    LocationExternalRef NVARCHAR(64) NULL,
    LocationName NVARCHAR(256) NULL,
    AddressLine1 NVARCHAR(256) NOT NULL,
    AddressLine2 NVARCHAR(256) NULL,
    City NVARCHAR(128) NOT NULL,
    Region NVARCHAR(128) NULL,
    PostalCode NVARCHAR(32) NULL,
    CountryCode CHAR(2) NOT NULL,
    GeoLat DECIMAL(9,6) NULL,
    GeoLon DECIMAL(9,6) NULL,
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_core_Location_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_core_Location_ExternalRef UNIQUE (LocationExternalRef)
);
GO

CREATE TABLE core.MasterNameRecord (
    MasterNameRecordId BIGINT IDENTITY(1,1) PRIMARY KEY,
    PersonId BIGINT NOT NULL,
    NameText NVARCHAR(256) NOT NULL,
    IsPrimaryName BIT NOT NULL CONSTRAINT DF_core_MasterNameRecord_IsPrimaryName DEFAULT 0,
    SourceSystem NVARCHAR(128) NULL,
    SourceRecordId NVARCHAR(128) NULL,
    EffectiveFrom DATETIME2(3) NOT NULL CONSTRAINT DF_core_MasterNameRecord_EffectiveFrom DEFAULT SYSUTCDATETIME(),
    EffectiveTo DATETIME2(3) NULL,
    CONSTRAINT FK_core_MasterNameRecord_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT CK_core_MasterNameRecord_DateRange CHECK (EffectiveTo IS NULL OR EffectiveTo >= EffectiveFrom)
);
GO

CREATE UNIQUE INDEX UX_core_MasterNameRecord_Person_Primary
    ON core.MasterNameRecord(PersonId, IsPrimaryName)
    WHERE IsPrimaryName = 1;
GO

CREATE INDEX IX_core_Person_Name_BirthDate
    ON core.Person(FamilyName, GivenName, BirthDate);
GO
