CREATE TABLE [AM].[ARTIFACT_DEPLOYMENT_BKP_608] (
    [ART_DEPLOYMENT_ID]    INT            IDENTITY (1, 1) NOT NULL,
    [ART_CTRL_MASTER_ID]   INT            NOT NULL,
    [ART_DEPLOYMENT_PATH]  VARCHAR (400)  NULL,
    [ART_FOLDER_VALUE_ID]  INT            NULL,
    [ART_PROJECT_VALUE_ID] INT            NULL,
    [DEPLOYMENT_COMMENTS]  VARCHAR (1000) NULL,
    [ART_VALIDATED]        BIT            NULL,
    [IS_ENABLED_IND]       BIT            NOT NULL,
    [LOAD_ID]              INT            NULL,
    [CREATED_DTE]          DATETIME       NOT NULL,
    [CREATED_BY]           VARCHAR (50)   NOT NULL,
    [LAST_UPDT_DTE]        DATETIME       NULL,
    [LAST_UPDT_BY]         VARCHAR (50)   NULL,
    [LAST_CHG_LOAD_ID]     INT            NULL
);

