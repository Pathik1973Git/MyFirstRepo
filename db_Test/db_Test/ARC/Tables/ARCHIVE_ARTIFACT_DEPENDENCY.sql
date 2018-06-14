CREATE TABLE [ARC].[ARCHIVE_ARTIFACT_DEPENDENCY] (
    [CHG_ID]                    INT          NOT NULL,
    [CHG_LOAD_ID]               INT          NOT NULL,
    [CHG_DATETIME]              DATETIME     NOT NULL,
    [ART_CTRL_MASTER_ID]        INT          NOT NULL,
    [REFERENCED_CTRL_MASTER_ID] INT          NOT NULL,
    [DEPENDENCY_TYPE_VALUE_ID]  INT          NOT NULL,
    [DEPENDENCY_SEQUENCE]       INT          NOT NULL,
    [IS_ENABLED_IND]            BIT          NOT NULL,
    [CREATED_DTE]               DATETIME     NOT NULL,
    [CREATED_BY]                VARCHAR (50) NOT NULL,
    [LAST_UPDT_DTE]             DATETIME     NULL,
    [LAST_UPDT_BY]              VARCHAR (50) NULL,
    [CREATED_ARC_DTE]           DATETIME     NULL,
    CONSTRAINT [PK_ARC_ARTIFACT_DEPENDENCY] PRIMARY KEY CLUSTERED ([CHG_ID] ASC, [CHG_LOAD_ID] ASC, [ART_CTRL_MASTER_ID] ASC, [REFERENCED_CTRL_MASTER_ID] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for the change - refers to CHG_ID on  CHANGE_MASTER', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'CHG_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for the load process each time a migration of data occurs from one envonrment to the next a unique load id is assigned.', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'CHG_LOAD_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datetime of the change. ', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'CHG_DATETIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for all artifacts.  Identity column on the ARTIFACT table.', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'ART_CTRL_MASTER_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Artifact ID for the listed dependent artifact ID.  (The ID that must run before this artifact can run)', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'REFERENCED_CTRL_MASTER_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code Value ID for the type of dependency', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'DEPENDENCY_TYPE_VALUE_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code Value ID for the sequence the dependencies must run it. 0 "zero" or null can be defaulted', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'DEPENDENCY_SEQUENCE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Artifact is marked as inactive 0 = Active', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'IS_ENABLED_IND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'CREATED_DTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User name of the person or process that created the record', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'CREATED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last updated', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'LAST_UPDT_DTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User name of the person or process that last updated the record', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPENDENCY', @level2type = N'COLUMN', @level2name = N'LAST_UPDT_BY';

