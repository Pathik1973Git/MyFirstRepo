CREATE TABLE [ARC].[ARCHIVE_ARTIFACT_DEPLOYMENT] (
    [CHG_ID]               INT            NOT NULL,
    [CHG_LOAD_ID]          INT            NOT NULL,
    [CHG_DATETIME]         DATETIME       NOT NULL,
    [ART_DEPLOYMENT_ID]    INT            NOT NULL,
    [ART_CTRL_MASTER_ID]   INT            NOT NULL,
    [ART_DEPLOYMENT_PATH]  VARCHAR (400)  NULL,
    [ART_FOLDER_VALUE_ID]  INT            NULL,
    [ART_PROJECT_VALUE_ID] INT            NULL,
    [DEPLOYMENT_COMMENTS]  VARCHAR (1000) NULL,
    [ART_VALIDATED]        BIT            NULL,
    [IS_ENABLED_IND]       BIT            DEFAULT ('FALSE') NOT NULL,
    [CREATED_DTE]          DATETIME       DEFAULT (getdate()) NOT NULL,
    [CREATED_BY]           VARCHAR (50)   NOT NULL,
    [LAST_UPDT_DTE]        DATETIME       NULL,
    [LAST_UPDT_BY]         VARCHAR (50)   NULL,
    [CREATED_ARC_DTE]      DATETIME       NULL,
    CONSTRAINT [PK_ARC_ARTIFACT_DEPLOYMENT] PRIMARY KEY CLUSTERED ([CHG_ID] ASC, [CHG_LOAD_ID] ASC, [ART_DEPLOYMENT_ID] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for the change - refers to CHG_ID on  CHANGE_MASTER', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'CHG_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for the load process each time a migration of data occurs from one envonrment to the next a unique load id is assigned.', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'CHG_LOAD_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datetime of the change. ', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'CHG_DATETIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique ID for the ARTIFACT_DEPLOYMENT table', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'ART_DEPLOYMENT_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique identifier for all artifacts.  Identity column on the ARTIFACT_CTRL_MASTER table.', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'ART_CTRL_MASTER_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Full Qualified Path (File Server, DB, URL)  examples \\Server\Share\Foder\Name, Database.Schema.ArtifactName, https://www.google.com/', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'ART_DEPLOYMENT_PATH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Developer comments on the deployment', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'DEPLOYMENT_COMMENTS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Has the artifact path been systematically validated', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'ART_VALIDATED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = Artifact is marked as inactive 0 = Active', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'IS_ENABLED_IND';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'CREATED_DTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User name of the person or process that created the record', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'CREATED_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last updated', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'LAST_UPDT_DTE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User name of the person or process that last updated the record', @level0type = N'SCHEMA', @level0name = N'ARC', @level1type = N'TABLE', @level1name = N'ARCHIVE_ARTIFACT_DEPLOYMENT', @level2type = N'COLUMN', @level2name = N'LAST_UPDT_BY';

