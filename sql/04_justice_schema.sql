CREATE TABLE justice.CaseFile (
    CaseFileId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseNumber NVARCHAR(64) NOT NULL,
    IncidentId BIGINT NOT NULL,
    PlaintiffPersonId BIGINT NULL,
    DefendantPersonId BIGINT NULL,
    OpenedAt DATETIME2(3) NOT NULL,
    ClosedAt DATETIME2(3) NULL,
    Status NVARCHAR(32) NOT NULL CONSTRAINT DF_justice_CaseFile_Status DEFAULT N'Open',
    CONSTRAINT UQ_justice_CaseFile_CaseNumber UNIQUE (CaseNumber),
    CONSTRAINT FK_justice_CaseFile_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_justice_CaseFile_Plaintiff FOREIGN KEY (PlaintiffPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_justice_CaseFile_Defendant FOREIGN KEY (DefendantPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT CK_justice_CaseFile_DateRange CHECK (ClosedAt IS NULL OR ClosedAt >= OpenedAt),
    CONSTRAINT CK_justice_CaseFile_Status CHECK (Status IN (N'Open', N'InTrial', N'Closed', N'Appealed'))
);
GO

CREATE TABLE justice.DocketEntry (
    DocketEntryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    EntryNo INT NOT NULL,
    EntryType NVARCHAR(64) NOT NULL,
    EntryAt DATETIME2(3) NOT NULL,
    Summary NVARCHAR(1024) NULL,
    FiledByPersonId BIGINT NULL,
    CONSTRAINT FK_justice_DocketEntry_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_DocketEntry_FiledBy FOREIGN KEY (FiledByPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT UQ_justice_DocketEntry_UniquePerCase UNIQUE (CaseFileId, EntryNo)
);
GO

CREATE TABLE justice.Hearing (
    HearingId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    HearingAt DATETIME2(3) NOT NULL,
    Courtroom NVARCHAR(128) NULL,
    HearingType NVARCHAR(64) NOT NULL,
    JudgePersonId BIGINT NULL,
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT FK_justice_Hearing_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_Hearing_Judge FOREIGN KEY (JudgePersonId) REFERENCES core.Person(PersonId)
);
GO

CREATE TABLE justice.CaseOutcome (
    CaseOutcomeId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    OutcomeStatus NVARCHAR(32) NOT NULL,
    OutcomeDate DATE NOT NULL,
    OutcomeDetails NVARCHAR(MAX) NULL,
    CONSTRAINT FK_justice_CaseOutcome_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT UQ_justice_CaseOutcome_CaseFile UNIQUE (CaseFileId),
    CONSTRAINT CK_justice_CaseOutcome_Status CHECK (OutcomeStatus IN (N'Won', N'Lost', N'Settled', N'Pending'))
);
GO
