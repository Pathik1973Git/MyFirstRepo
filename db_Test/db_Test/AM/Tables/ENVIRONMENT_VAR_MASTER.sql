CREATE TABLE [AM].[ENVIRONMENT_VAR_MASTER] (
    [ID]                  INT           NOT NULL,
    [KeyValueName]        VARCHAR (20)  NULL,
    [KeyValueInt]         INT           NULL,
    [KeyValueVar]         VARCHAR (100) NULL,
    [KeyValueDate]        DATETIME      NULL,
    [KeyValueDescription] VARCHAR (200) NOT NULL,
    [IS_ENABLED_IND]      BIT           NOT NULL,
    [CREATED_DTE]         DATETIME      NOT NULL,
    [CREATED_BY]          VARCHAR (100) NOT NULL,
    [LAST_UPDT_DTE]       DATETIME      NULL,
    [LAST_UPDT_BY]        DATETIME      NULL,
    CONSTRAINT [PK_ENV_MASTER-_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

