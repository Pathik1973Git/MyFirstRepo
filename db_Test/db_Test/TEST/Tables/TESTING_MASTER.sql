CREATE TABLE [TEST].[TESTING_MASTER] (
    [TEST_ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [TEST_OPEN_DATE]            DATETIME       NOT NULL,
    [TEST_OWNER]                VARCHAR (100)  NOT NULL,
    [TEST_DESCRIPTION]          VARCHAR (2000) NOT NULL,
    [LAST_TEST_LOAD_ID]         INT            NULL,
    [LAST_STATUS_CODE_VALUE_ID] TINYINT        NULL,
    [LAST_PROCESS_DATETIME]     DATETIME       NULL,
    [LAST_SOURCE_NME]           VARCHAR (100)  NULL,
    [LAST_TARGET_NME]           VARCHAR (100)  NULL,
    [LAST_MESSAGE]              VARCHAR (2000) NULL,
    [IS_DEL_IND]                BIT            CONSTRAINT [DF_TESTING_DEL] DEFAULT ('FALSE') NOT NULL,
    [CREATED_DTE]               DATETIME       CONSTRAINT [DF_TESTING_DTE] DEFAULT (getdate()) NOT NULL,
    [CREATED_BY]                VARCHAR (50)   NOT NULL,
    [LAST_UPDT_DTE]             DATETIME       NULL,
    [LAST_UPDT_BY]              VARCHAR (50)   NULL,
    [LOAD_ID]                   INT            NULL,
    CONSTRAINT [PK_ARTIFACT-TESTING_ID] PRIMARY KEY CLUSTERED ([TEST_ID] ASC) WITH (FILLFACTOR = 95)
);

