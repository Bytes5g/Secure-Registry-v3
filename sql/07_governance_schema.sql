CREATE TABLE governance.NationalSecurityDomain (
    DomainId BIGINT IDENTITY(1,1) PRIMARY KEY,
    DomainCode NVARCHAR(64) NOT NULL,
    DomainName NVARCHAR(256) NOT NULL,
    DomainDescription NVARCHAR(1024) NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_governance_NationalSecurityDomain_IsActive DEFAULT 1,
    CONSTRAINT UQ_governance_NationalSecurityDomain_DomainCode UNIQUE (DomainCode)
);
GO

CREATE TABLE governance.ThreatCategory (
    ThreatCategoryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    DomainId BIGINT NOT NULL,
    ThreatCategoryCode NVARCHAR(64) NOT NULL,
    ThreatCategoryName NVARCHAR(256) NOT NULL,
    IsActive BIT NOT NULL CONSTRAINT DF_governance_ThreatCategory_IsActive DEFAULT 1,
    CONSTRAINT FK_governance_ThreatCategory_Domain FOREIGN KEY (DomainId) REFERENCES governance.NationalSecurityDomain(DomainId),
    CONSTRAINT UQ_governance_ThreatCategory_Code UNIQUE (ThreatCategoryCode),
    CONSTRAINT UQ_governance_ThreatCategory_Domain_Name UNIQUE (DomainId, ThreatCategoryName)
);
GO

CREATE TABLE governance.Threat (
    ThreatId BIGINT IDENTITY(1,1) PRIMARY KEY,
    ThreatCategoryId BIGINT NOT NULL,
    ThreatCode NVARCHAR(64) NOT NULL,
    ThreatName NVARCHAR(256) NOT NULL,
    ThreatDescription NVARCHAR(1024) NULL,
    SeverityLevel TINYINT NOT NULL CONSTRAINT DF_governance_Threat_SeverityLevel DEFAULT 5,
    IsActive BIT NOT NULL CONSTRAINT DF_governance_Threat_IsActive DEFAULT 1,
    CONSTRAINT FK_governance_Threat_Category FOREIGN KEY (ThreatCategoryId) REFERENCES governance.ThreatCategory(ThreatCategoryId),
    CONSTRAINT UQ_governance_Threat_Code UNIQUE (ThreatCode),
    CONSTRAINT CK_governance_Threat_SeverityLevel CHECK (SeverityLevel BETWEEN 1 AND 10)
);
GO

CREATE TABLE governance.LegalInstrumentType (
    LegalInstrumentTypeId BIGINT IDENTITY(1,1) PRIMARY KEY,
    TypeCode NVARCHAR(64) NOT NULL,
    TypeName NVARCHAR(128) NOT NULL,
    CONSTRAINT UQ_governance_LegalInstrumentType_TypeCode UNIQUE (TypeCode)
);
GO

CREATE TABLE governance.LegalInstrument (
    LegalInstrumentId BIGINT IDENTITY(1,1) PRIMARY KEY,
    LegalInstrumentTypeId BIGINT NOT NULL,
    InstrumentNumber NVARCHAR(64) NOT NULL,
    InstrumentName NVARCHAR(256) NOT NULL,
    IssuingAuthorityId BIGINT NULL,
    IssueDate DATE NULL,
    EffectiveFrom DATE NULL,
    EffectiveTo DATE NULL,
    Notes NVARCHAR(1024) NULL,
    CONSTRAINT FK_governance_LegalInstrument_Type FOREIGN KEY (LegalInstrumentTypeId) REFERENCES governance.LegalInstrumentType(LegalInstrumentTypeId),
    CONSTRAINT FK_governance_LegalInstrument_Authority FOREIGN KEY (IssuingAuthorityId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT UQ_governance_LegalInstrument_Type_Number UNIQUE (LegalInstrumentTypeId, InstrumentNumber),
    CONSTRAINT CK_governance_LegalInstrument_DateRange CHECK (EffectiveTo IS NULL OR (EffectiveFrom IS NOT NULL AND EffectiveTo >= EffectiveFrom))
);
GO

CREATE TABLE governance.LegalArticle (
    LegalArticleId BIGINT IDENTITY(1,1) PRIMARY KEY,
    LegalInstrumentId BIGINT NOT NULL,
    ArticleNumber NVARCHAR(64) NOT NULL,
    ArticleTitle NVARCHAR(256) NULL,
    ArticleText NVARCHAR(MAX) NULL,
    CONSTRAINT FK_governance_LegalArticle_Instrument FOREIGN KEY (LegalInstrumentId) REFERENCES governance.LegalInstrument(LegalInstrumentId),
    CONSTRAINT UQ_governance_LegalArticle_Number UNIQUE (LegalInstrumentId, ArticleNumber)
);
GO

CREATE TABLE governance.AuthorityJurisdiction (
    AuthorityJurisdictionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrganizationId BIGINT NOT NULL,
    DomainId BIGINT NOT NULL,
    LegalArticleId BIGINT NULL,
    ResponsibilityName NVARCHAR(256) NOT NULL,
    ResponsibilityDetails NVARCHAR(1024) NULL,
    EffectiveFrom DATE NULL,
    EffectiveTo DATE NULL,
    CONSTRAINT FK_governance_AuthorityJurisdiction_Organization FOREIGN KEY (OrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT FK_governance_AuthorityJurisdiction_Domain FOREIGN KEY (DomainId) REFERENCES governance.NationalSecurityDomain(DomainId),
    CONSTRAINT FK_governance_AuthorityJurisdiction_LegalArticle FOREIGN KEY (LegalArticleId) REFERENCES governance.LegalArticle(LegalArticleId),
    CONSTRAINT CK_governance_AuthorityJurisdiction_DateRange CHECK (EffectiveTo IS NULL OR (EffectiveFrom IS NOT NULL AND EffectiveTo >= EffectiveFrom))
);
GO

CREATE INDEX IX_governance_ThreatCategory_DomainId
    ON governance.ThreatCategory(DomainId);
GO

CREATE INDEX IX_governance_Threat_ThreatCategoryId
    ON governance.Threat(ThreatCategoryId);
GO

CREATE INDEX IX_governance_AuthorityJurisdiction_Organization_Domain
    ON governance.AuthorityJurisdiction(OrganizationId, DomainId);
GO
