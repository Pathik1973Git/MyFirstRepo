CREATE TABLE [AM].[QUEUE_EXECUTION_LOG] (
    [LOG_ID]                INT           IDENTITY (1, 1) NOT NULL,
    [PROC_START_TIME]       DATETIME      NOT NULL,
    [PROC_END_TIME]         DATETIME      NOT NULL,
    [EXECUTION_COUNT]       INT           NOT NULL,
    [EXECUTION_SCALE]       INT           NOT NULL,
    [AUDIT_COUNT]           INT           NOT NULL,
    [AUDIT_SCALE]           INT           NOT NULL,
    [SKIP_COUNT]            INT           NOT NULL,
    [SKIP_SCALE]            INT           NOT NULL,
    [STARTING_RUN_COUNT]    INT           NOT NULL,
    [STARTING_RUN_SCALE]    INT           NOT NULL,
    [ENDING_RUN_COUNT]      INT           NOT NULL,
    [ENDING_RUN_SCALE]      INT           NOT NULL,
    [REMAINING_QUEUE_COUNT] INT           NOT NULL,
    [REMAINING_QUEUE_SCALE] INT           NOT NULL,
    [LOG_MSG_VALUE]         INT           NOT NULL,
    [LOG_MSG_DESC]          VARCHAR (200) NOT NULL,
    [ENV_SCALE_THRESHOLD]   INT           NOT NULL,
    [SKIP_THRESHOLD]        INT           NOT NULL,
    CONSTRAINT [PK-Q_EXEC_LOG-LOG_ID] PRIMARY KEY CLUSTERED ([LOG_ID] ASC) WITH (FILLFACTOR = 95)
);

