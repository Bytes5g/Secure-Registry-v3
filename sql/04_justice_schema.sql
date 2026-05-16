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
    CONSTRAINT CK_justice_CaseFile_DateRange CHECK (ClosedAt IS NULL OR (OpenedAt IS NOT NULL AND ClosedAt >= OpenedAt)),
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
    OutcomeDate DATETIME2(3) NOT NULL,
    OutcomeDetails NVARCHAR(MAX) NULL,
    CONSTRAINT FK_justice_CaseOutcome_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT UQ_justice_CaseOutcome_CaseFile UNIQUE (CaseFileId),
    CONSTRAINT CK_justice_CaseOutcome_Status CHECK (OutcomeStatus IN (N'Won', N'Lost', N'Settled', N'Pending'))
);
GO

CREATE TABLE justice.CaseParty (
    CasePartyId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    PersonId BIGINT NULL,
    OrganizationId BIGINT NULL,
    PartyRole NVARCHAR(64) NOT NULL,
    IsPrimaryParty BIT NOT NULL CONSTRAINT DF_justice_CaseParty_IsPrimaryParty DEFAULT 0,
    Notes NVARCHAR(1024) NULL,
    CONSTRAINT FK_justice_CaseParty_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_CaseParty_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_justice_CaseParty_Organization FOREIGN KEY (OrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT CK_justice_CaseParty_Subject CHECK (
        (CASE WHEN PersonId IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN OrganizationId IS NULL THEN 0 ELSE 1 END) = 1
    )
);
GO

CREATE TABLE justice.ProsecutionReferral (
    ProsecutionReferralId BIGINT IDENTITY(1,1) PRIMARY KEY,
    IncidentId BIGINT NOT NULL,
    CaseFileId BIGINT NULL,
    ReferringOrganizationId BIGINT NULL,
    ProsecutorOrganizationId BIGINT NULL,
    ReferralDate DATETIME2(3) NOT NULL,
    ReferralReason NVARCHAR(1024) NULL,
    ReferralStatus NVARCHAR(32) NOT NULL CONSTRAINT DF_justice_ProsecutionReferral_Status DEFAULT N'Prepared',
    CONSTRAINT FK_justice_ProsecutionReferral_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_justice_ProsecutionReferral_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_ProsecutionReferral_ReferringOrganization FOREIGN KEY (ReferringOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT FK_justice_ProsecutionReferral_ProsecutorOrganization FOREIGN KEY (ProsecutorOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT CK_justice_ProsecutionReferral_Status CHECK (ReferralStatus IN (N'Prepared', N'Sent', N'Accepted', N'Returned', N'Rejected'))
);
GO

CREATE TABLE justice.InvestigationMemo (
    InvestigationMemoId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    MemoType NVARCHAR(32) NOT NULL,
    PreparedByPersonId BIGINT NULL,
    PreparingOrganizationId BIGINT NULL,
    MemoDate DATETIME2(3) NOT NULL,
    MemoText NVARCHAR(MAX) NOT NULL,
    CONSTRAINT FK_justice_InvestigationMemo_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_InvestigationMemo_Person FOREIGN KEY (PreparedByPersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_justice_InvestigationMemo_Organization FOREIGN KEY (PreparingOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT CK_justice_InvestigationMemo_Type CHECK (MemoType IN (N'PoliceEvidence', N'Investigation', N'ProsecutionMemo'))
);
GO

CREATE TABLE justice.WitnessStatement (
    WitnessStatementId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    IncidentId BIGINT NULL,
    PersonId BIGINT NOT NULL,
    StatementDate DATETIME2(3) NOT NULL,
    StatementTakenByPersonId BIGINT NULL,
    StatementText NVARCHAR(MAX) NOT NULL,
    IsUnderProtection BIT NOT NULL CONSTRAINT DF_justice_WitnessStatement_IsUnderProtection DEFAULT 0,
    CONSTRAINT FK_justice_WitnessStatement_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_WitnessStatement_Incident FOREIGN KEY (IncidentId) REFERENCES enforcement.Incident(IncidentId),
    CONSTRAINT FK_justice_WitnessStatement_Person FOREIGN KEY (PersonId) REFERENCES core.Person(PersonId),
    CONSTRAINT FK_justice_WitnessStatement_TakenBy FOREIGN KEY (StatementTakenByPersonId) REFERENCES core.Person(PersonId)
);
GO

CREATE TABLE justice.CaseLegalReference (
    CaseLegalReferenceId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    DomainId BIGINT NULL,
    ThreatId BIGINT NULL,
    LegalArticleId BIGINT NULL,
    ResponsibleOrganizationId BIGINT NULL,
    ReferenceNote NVARCHAR(1024) NULL,
    CONSTRAINT FK_justice_CaseLegalReference_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_CaseLegalReference_Domain FOREIGN KEY (DomainId) REFERENCES governance.NationalSecurityDomain(DomainId),
    CONSTRAINT FK_justice_CaseLegalReference_Threat FOREIGN KEY (ThreatId) REFERENCES governance.Threat(ThreatId),
    CONSTRAINT FK_justice_CaseLegalReference_LegalArticle FOREIGN KEY (LegalArticleId) REFERENCES governance.LegalArticle(LegalArticleId),
    CONSTRAINT FK_justice_CaseLegalReference_Organization FOREIGN KEY (ResponsibleOrganizationId) REFERENCES core.Organization(OrganizationId)
);
GO

CREATE TABLE justice.Judgment (
    JudgmentId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    JudgmentNumber NVARCHAR(64) NOT NULL,
    JudgmentDate DATETIME2(3) NOT NULL,
    CourtOrganizationId BIGINT NULL,
    JudgmentText NVARCHAR(MAX) NOT NULL,
    SentenceSummary NVARCHAR(1024) NULL,
    IsFinal BIT NOT NULL CONSTRAINT DF_justice_Judgment_IsFinal DEFAULT 0,
    CONSTRAINT FK_justice_Judgment_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_Judgment_CourtOrganization FOREIGN KEY (CourtOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT UQ_justice_Judgment_JudgmentNumber UNIQUE (JudgmentNumber)
);
GO

CREATE TABLE justice.JudicialProcedure (
    JudicialProcedureId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CaseFileId BIGINT NOT NULL,
    ProcedureType NVARCHAR(64) NOT NULL,
    ProcedureDate DATETIME2(3) NOT NULL,
    PerformedByOrganizationId BIGINT NULL,
    PerformedByPersonId BIGINT NULL,
    ProcedureText NVARCHAR(MAX) NULL,
    CONSTRAINT FK_justice_JudicialProcedure_CaseFile FOREIGN KEY (CaseFileId) REFERENCES justice.CaseFile(CaseFileId),
    CONSTRAINT FK_justice_JudicialProcedure_Organization FOREIGN KEY (PerformedByOrganizationId) REFERENCES core.Organization(OrganizationId),
    CONSTRAINT FK_justice_JudicialProcedure_Person FOREIGN KEY (PerformedByPersonId) REFERENCES core.Person(PersonId)
);
GO

CREATE INDEX IX_justice_CaseParty_CaseFileId
    ON justice.CaseParty(CaseFileId);
GO

CREATE INDEX IX_justice_ProsecutionReferral_IncidentId
    ON justice.ProsecutionReferral(IncidentId);
GO

CREATE INDEX IX_justice_CaseLegalReference_CaseFileId
    ON justice.CaseLegalReference(CaseFileId);
GO
