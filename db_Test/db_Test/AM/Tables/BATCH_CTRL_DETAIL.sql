CREATE TABLE [AM].[BATCH_CTRL_DETAIL] (
    [LOG_ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [LOAD_ID]                INT           NOT NULL,
    [BATCH_DTE]              DATE          NOT NULL,
    [START_DTE]              DATETIME      NOT NULL,
    [END_DTE]                DATETIME      NULL,
    [SCHEDULE_TYPE_VALUE_ID] INT           NOT NULL,
    [STATUS_CODE_VALUE_ID]   INT           NOT NULL,
    [BATCH_RETRY_COUNTER]    TINYINT       NOT NULL,
    [BATCH_MSG]              VARCHAR (400) NULL,
    [CREATED_DTE]            DATETIME      NOT NULL,
    CONSTRAINT [PK_BATCH_CTRL_DETAIL-LOG_ID] PRIMARY KEY CLUSTERED ([LOG_ID] ASC) WITH (FILLFACTOR = 95)
);

