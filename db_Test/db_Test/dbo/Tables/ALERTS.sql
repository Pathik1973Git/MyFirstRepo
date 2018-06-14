CREATE TABLE [dbo].[ALERTS] (
    [ALERT_ID]           INT            IDENTITY (1, 1) NOT NULL,
    [LOAD_ID]            BIGINT         NULL,
    [EXECUTION_ID]       BIGINT         NULL,
    [BATCH_DATE]         DATE           NULL,
    [ART_TYPE_DESC]      VARCHAR (50)   NULL,
    [ALERT_PRIORITY]     VARCHAR (20)   NULL,
    [ALERT_CONTEXT]      VARCHAR (200)  NULL,
    [ART_CTRL_MASTER_ID] INT            NULL,
    [ARTIFACT_NAME]      VARCHAR (100)  NULL,
    [RETRY_COUNT]        INT            NULL,
    [RETRY_THRESHOLD]    INT            NULL,
    [ERROR_MSG]          VARCHAR (5000) NULL,
    [MSG_SOURCE]         VARCHAR (200)  NULL,
    [CREATED_DTE]        DATETIME       NOT NULL,
    [MSG_UPDATED_DTE]    DATETIME       NULL
);

