CREATE TABLE enforcement.Incident (
    IncidentId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentNumber NVARCHAR(64) NOT NULL,
    IncidentType NVARCHAR(128) NOT NULL,
    ReportedAt DATETIME2(3) NOT NULL,
    OccurredAt DATETIME2(3) NULL,
    ReportingPersonId BIGINT NULL,
    LocationId BIGINT NULL,
    Description NVARCHAR(MAX) NULL,
    Status NVARCHAR(32) NOT NULL CONSTRAINT DF_enforcement_Incident_Status DEFAULT N'Open',
    CONSTRAINT UQ_enforcement_Incident_IncidentNumber UNIQUE (IncidentNumber),
    CONSTRAINT FK_enforcement_Incident_ReportingPerson FOREIGN KEY (ReportingPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_Incident_Location FOREIGN KEY (LocationId) REFERENCES core.Location(LocationId),
    CONSTRAINT CK_enforcement_Incident_Status CHECK (Status IN (N'Open', N'UnderReview', N'Closed', N'Archived'))
);
GO

CREATE TABLE enforcement.CrimeReport (
    CrimeReportId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentId BIGINT NOT NULL,
    OffenseCode NVARCHAR(64) NOT NULL,
    OffenseCategory NVARCHAR(128) NOT NULL,
    VictimPersonId BIGINT NULL,
    SuspectPersonId BIGINT NULL,
    ReportDetails NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2(3) NOT NULL CONSTRAINT DF_enforcement_CrimeReport_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_enforcement_CrimeReport_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_enforcement_CrimeReport_Victim FOREIGN KEY (VictimPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_CrimeReport_Suspect FOREIGN KEY (SuspectPersonId) REFERENCES core.Person(PersonId)
);
GO

CREATE TABLE enforcement.DigitalEvidence (
    DigitalEvidenceId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentId BIGINT NOT NULL,
    CameraId BIGINT NULL,
    EvidenceType NVARCHAR(64) NOT NULL,
    FileHashSHA256 CHAR(64) NOT NULL,
    FileUri NVARCHAR(1024) NULL,
    CollectedAt DATETIME2(3) NOT NULL,
    CollectedByPersonId BIGINT NULL,
    IntegrityVerified BIT NOT NULL CONSTRAINT DF_enforcement_DigitalEvidence_IntegrityVerified DEFAULT 0,
    CONSTRAINT FK_enforcement_DigitalEvidence_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_enforcement_DigitalEvidence_Camera FOREIGN KEY (CameraId) REFERENCES security.Camera(CameraId),
    CONSTRAINT FK_enforcement_DigitalEvidence_CollectedBy FOREIGN KEY (CollectedByPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT UQ_enforcement_DigitalEvidence_FileHash UNIQUE (FileHashSHA256),
    CONSTRAINT CK_enforcement_DigitalEvidence_FileHashSHA256_Hex CHECK (FileHashSHA256 NOT LIKE '%[^0-9A-Fa-f]%')
);
GO

CREATE TABLE enforcement.ChainOfCustodyEvent (
    ChainOfCustodyEventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    DigitalEvidenceId BIGINT NOT NULL,
    SequenceNo INT NOT NULL,
    FromPersonId BIGINT NULL,
    ToPersonId BIGINT NULL,
    TransferAt DATETIME2(3) NOT NULL,
    TransferReason NVARCHAR(512) NULL,
    SignatureHash NVARCHAR(256) NULL,
    CONSTRAINT FK_enforcement_ChainOfCustodyEvent_DigitalEvidence FOREIGN KEY (DigitalEvidenceId) REFERENCES enforcement.DigitalEvidence(DigitalEvidenceId),
    CONSTRAINT FK_enforcement_ChainOfCustodyEvent_FromPerson FOREIGN KEY (FromPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_ChainOfCustodyEvent_ToPerson FOREIGN KEY (ToPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT UQ_enforcement_ChainOfCustodyEvent_Sequence UNIQUE (DigitalEvidenceId, SequenceNo)
);
GO
