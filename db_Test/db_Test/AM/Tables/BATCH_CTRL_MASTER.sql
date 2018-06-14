CREATE TABLE [AM].[BATCH_CTRL_MASTER] (
    [LOAD_ID]                INT           NOT NULL,
    [BATCH_DTE]              DATE          NOT NULL,
    [START_DTE]              DATETIME      NOT NULL,
    [END_DTE]                DATETIME      NULL,
    [SCHEDULE_TYPE_VALUE_ID] INT           NOT NULL,
    [STATUS_CODE_VALUE_ID]   INT           NOT NULL,
    [BATCH_RETRY_COUNTER]    TINYINT       NOT NULL,
    [BATCH_MSG]              VARCHAR (400) NULL,
    [CREATED_DTE]            DATETIME      NOT NULL,
    [LAST_UPDT_DTE]          DATETIME      NULL,
    CONSTRAINT [PK_BATCH_CTRL_MASTER-LOAD_ID] PRIMARY KEY CLUSTERED ([LOAD_ID] ASC) WITH (FILLFACTOR = 95)
);

