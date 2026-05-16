CREATE TABLE enforcement.IntakeRecord (
    IntakeRecordId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IntakeNumber NVARCHAR(64) NOT NULL,
    IntakeType NVARCHAR(32) NOT NULL,
    ReceivedAt DATETIME2(3) NOT NULL,
    ReporterPersonId BIGINT NULL,
    ReporterOrganizationId BIGINT NULL,
    LocationId BIGINT NULL,
    Summary NVARCHAR(MAX) NULL,
    Status NVARCHAR(32) NOT NULL CONSTRAINT DF_enforcement_IntakeRecord_Status DEFAULT N'Recorded',
    CONSTRAINT UQ_enforcement_IntakeRecord_IntakeNumber UNIQUE (IntakeNumber),
    CONSTRAINT FK_enforcement_IntakeRecord_ReporterPerson FOREIGN KEY (ReporterPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_IntakeRecord_ReporterOrganization FOREIGN KEY (ReporterOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT FK_enforcement_IntakeRecord_Location FOREIGN KEY (LocationId) REFERENCES core.Location(LocationId),
    CONSTRAINT CK_enforcement_IntakeRecord_IntakeType CHECK (IntakeType IN (N'Report', N'Event', N'Activity')),
    CONSTRAINT CK_enforcement_IntakeRecord_Status CHECK (Status IN (N'Recorded', N'Triage', N'Referred', N'Closed'))
);
GO

CREATE TABLE enforcement.Incident (
    IncidentId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IntakeRecordId BIGINT NULL,
    IncidentNumber NVARCHAR(64) NOT NULL,
    IncidentType NVARCHAR(128) NOT NULL,
    ReportedAt DATETIME2(3) NOT NULL,
    OccurredAt DATETIME2(3) NULL,
    ReportingPersonId BIGINT NULL,
    LocationId BIGINT NULL,
    Description NVARCHAR(MAX) NULL,
    Status NVARCHAR(32) NOT NULL CONSTRAINT DF_enforcement_Incident_Status DEFAULT N'Open',
    CONSTRAINT UQ_enforcement_Incident_IncidentNumber UNIQUE (IncidentNumber),
    CONSTRAINT FK_enforcement_Incident_IntakeRecord FOREIGN KEY (IntakeRecordId) REFERENCES enforcement.IntakeRecord(IntakeRecordId),
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

CREATE TABLE enforcement.IncidentParty (
    IncidentPartyId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentId BIGINT NOT NULL,
    PersonId BIGINT NULL,
    OrganizationId BIGINT NULL,
    PartyRole NVARCHAR(64) NOT NULL,
    IsPrimaryParty BIT NOT NULL CONSTRAINT DF_enforcement_IncidentParty_IsPrimaryParty DEFAULT 0,
    Notes NVARCHAR(1024) NULL,
    CONSTRAINT FK_enforcement_IncidentParty_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_enforcement_IncidentParty_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_IncidentParty_Organization FOREIGN KEY (OrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT CK_enforcement_IncidentParty_Subject CHECK (
        (CASE WHEN PersonId IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN OrganizationId IS NULL THEN 0 ELSE 1 END) = 1
    )
);
GO

CREATE TABLE enforcement.ArrestAction (
    ArrestActionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentId BIGINT NOT NULL,
    PersonId BIGINT NOT NULL,
    ArrestedAt DATETIME2(3) NOT NULL,
    ArrestLocationId BIGINT NULL,
    ArrestingOrganizationId BIGINT NULL,
    ArrestingOfficerPersonId BIGINT NULL,
    ArrestBasis NVARCHAR(1024) NULL,
    Status NVARCHAR(32) NOT NULL CONSTRAINT DF_enforcement_ArrestAction_Status DEFAULT N'Custody',
    CONSTRAINT FK_enforcement_ArrestAction_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_enforcement_ArrestAction_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_ArrestAction_Location FOREIGN KEY (ArrestLocationId) REFERENCES core.Location(LocationId),
    CONSTRAINT FK_enforcement_ArrestAction_Organization FOREIGN KEY (ArrestingOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT FK_enforcement_ArrestAction_Officer FOREIGN KEY (ArrestingOfficerPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT CK_enforcement_ArrestAction_Status CHECK (Status IN (N'Custody', N'Released', N'Transferred', N'Referred'))
);
GO

CREATE TABLE enforcement.EvidenceCollectionRecord (
    EvidenceCollectionRecordId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentId BIGINT NOT NULL,
    DigitalEvidenceId BIGINT NULL,
    RecordedAt DATETIME2(3) NOT NULL,
    RecordedByPersonId BIGINT NULL,
    CollectionLocationId BIGINT NULL,
    CollectionMethod NVARCHAR(256) NULL,
    RecordText NVARCHAR(MAX) NOT NULL,
    CONSTRAINT FK_enforcement_EvidenceCollectionRecord_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_enforcement_EvidenceCollectionRecord_DigitalEvidence FOREIGN KEY (DigitalEvidenceId) REFERENCES enforcement.DigitalEvidence(DigitalEvidenceId),
    CONSTRAINT FK_enforcement_EvidenceCollectionRecord_Person FOREIGN KEY (RecordedByPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_enforcement_EvidenceCollectionRecord_Location FOREIGN KEY (CollectionLocationId) REFERENCES core.Location(LocationId)
);
GO

CREATE INDEX IX_enforcement_Incident_IntakeRecordId
    ON enforcement.Incident(IntakeRecordId);
GO

CREATE INDEX IX_enforcement_IncidentParty_IncidentId
    ON enforcement.IncidentParty(IncidentId);
GO

CREATE INDEX IX_enforcement_ArrestAction_IncidentId_PersonId
    ON enforcement.ArrestAction(IncidentId, PersonId);
GO
