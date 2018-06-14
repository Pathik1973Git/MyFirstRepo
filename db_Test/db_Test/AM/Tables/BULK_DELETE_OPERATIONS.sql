CREATE TABLE [AM].[BULK_DELETE_OPERATIONS] (
    [OPERATION_ID]        INT           IDENTITY (1, 1) NOT NULL,
    [LOAD_ID]             INT           NULL,
    [SERVER_NAME]         VARCHAR (200) NOT NULL,
    [DATABASE_NAME]       VARCHAR (200) NOT NULL,
    [TABLE_NAME]          VARCHAR (200) NOT NULL,
    [COLUMN_NAME]         VARCHAR (200) NOT NULL,
    [DATEPART]            VARCHAR (2)   NOT NULL,
    [COMPARISON_OPERATOR] VARCHAR (2)   NOT NULL,
    [THRESHOLD_VALUE]     INT           NOT NULL,
    [NOTES]               VARCHAR (400) NULL,
    [IS_ENABLED_IND]      BIT           NOT NULL,
    [CREATED_DTE]         DATETIME      NOT NULL,
    [CREATED_BY]          VARCHAR (50)  NOT NULL,
    [LAST_UPDT_DTE]       DATETIME      NULL,
    [LAST_UPDT_BY]        VARCHAR (50)  NULL,
    [LAST_EXECUTED_DTE]   DATETIME      NULL
);

