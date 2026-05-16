CREATE TABLE corrections.Facility (
    FacilityId BIGINT IDENTITY(1,1) PRIMARY KEY,
    FacilityCode NVARCHAR(64) NOT NULL,
    FacilityName NVARCHAR(256) NOT NULL,
    LocationId BIGINT NULL,
    TotalCapacity INT NOT NULL,
    CONSTRAINT FK_corrections_Facility_Location FOREIGN KEY (LocationId) REFERENCES core.Location(LocationId),
    CONSTRAINT UQ_corrections_Facility_FacilityCode UNIQUE (FacilityCode),
    CONSTRAINT CK_corrections_Facility_TotalCapacity CHECK (TotalCapacity >= 0)
);
GO

CREATE TABLE corrections.HousingUnit (
    HousingUnitId BIGINT IDENTITY(1,1) PRIMARY KEY,
    FacilityId BIGINT NOT NULL,
    UnitCode NVARCHAR(64) NOT NULL,
    UnitName NVARCHAR(128) NULL,
    Capacity INT NOT NULL,
    CONSTRAINT FK_corrections_HousingUnit_Facility FOREIGN KEY (FacilityId) REFERENCES corrections.Facility(FacilityId),
    CONSTRAINT UQ_corrections_HousingUnit_Facility_UnitCode UNIQUE (FacilityId, UnitCode),
    CONSTRAINT CK_corrections_HousingUnit_Capacity CHECK (Capacity >= 0)
);
GO

CREATE TABLE corrections.RiskLevel (
    RiskLevelId BIGINT IDENTITY(1,1) PRIMARY KEY,
    RiskCode NVARCHAR(32) NOT NULL,
    RiskName NVARCHAR(64) NOT NULL,
    Priority TINYINT NOT NULL,
    CONSTRAINT UQ_corrections_RiskLevel_RiskCode UNIQUE (RiskCode),
    CONSTRAINT CK_corrections_RiskLevel_Priority CHECK (Priority BETWEEN 1 AND 10)
);
GO

CREATE TABLE corrections.InmateProfile (
    InmateProfileId BIGINT IDENTITY(1,1) PRIMARY KEY,
    PersonId BIGINT NOT NULL,
    InmateNumber NVARCHAR(64) NOT NULL,
    PrimaryRiskLevelId BIGINT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_corrections_InmateProfile_IsActive DEFAULT 1,
    CONSTRAINT FK_corrections_InmateProfile_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_corrections_InmateProfile_RiskLevel FOREIGN KEY (PrimaryRiskLevelId) REFERENCES corrections.RiskLevel(RiskLevelId),
    CONSTRAINT UQ_corrections_InmateProfile_Person UNIQUE (PersonId),
    CONSTRAINT UQ_corrections_InmateProfile_InmateNumber UNIQUE (InmateNumber)
);
GO

CREATE TABLE corrections.Booking (
    BookingId BIGINT IDENTITY(1,1) PRIMARY KEY,
    InmateProfileId BIGINT NOT NULL,
    CaseFileId BIGINT NULL,
    HousingUnitId BIGINT NULL,
    BookedAt DATETIME2(3) NOT NULL,
    ReleasedAt DATETIME2(3) NULL,
    BookingStatus NVARCHAR(32) NOT NULL CONSTRAINT DF_corrections_Booking_Status DEFAULT N'Booked',
    CONSTRAINT FK_corrections_Booking_InmateProfile FOREIGN KEY (InmateProfileId) REFERENCES corrections.InmateProfile(InmateProfileId),
    CONSTRAINT FK_corrections_Booking_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_corrections_Booking_HousingUnit FOREIGN KEY (HousingUnitId) REFERENCES corrections.HousingUnit(HousingUnitId),
    CONSTRAINT CK_corrections_Booking_DateRange CHECK (ReleasedAt IS NULL OR ReleasedAt >= BookedAt),
    CONSTRAINT CK_corrections_Booking_Status CHECK (BookingStatus IN (N'Booked', N'Transferred', N'Released'))
);
GO
