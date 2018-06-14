CREATE TABLE [ARC].[ARCHIVE_CHANGE_MASTER] (
    [ARC_CHG_ID]                INT            NOT NULL,
    [ARC_CHG_LOAD_ID]           INT            NOT NULL,
    [ARC_CHG_DATETIME]          DATETIME       NOT NULL,
    [CHG_ID]                    INT            NOT NULL,
    [CHG_OPEN_DATE]             DATETIME       NOT NULL,
    [CHG_CLOSE_DATE]            DATETIME       NULL,
    [CHG_OWNER]                 VARCHAR (100)  NOT NULL,
    [CHG_DESCRIPTION]           VARCHAR (2000) NOT NULL,
    [LAST_CHG_LOAD_ID]          INT            NULL,
    [LAST_STATUS_CODE_VALUE_ID] TINYINT        NULL,
    [LAST_PROCESS_DATETIME]     DATETIME       NULL,
    [LAST_SOURCE_NME]           VARCHAR (100)  NULL,
    [LAST_TARGET_NME]           VARCHAR (100)  NULL,
    [LAST_MESSAGE]              VARCHAR (2000) NULL,
    [IS_ACTIVE_IND]             BIT            NOT NULL,
    [CREATED_DTE]               DATETIME       NOT NULL,
    [CREATED_BY]                VARCHAR (50)   NOT NULL,
    [LAST_UPDT_DTE]             DATETIME       NULL,
    [LAST_UPDT_BY]              VARCHAR (50)   NULL,
    [CREATED_ARC_DTE]           DATETIME       NULL,
    CONSTRAINT [PK_ARC_CHG_MASTER] PRIMARY KEY CLUSTERED ([ARC_CHG_ID] ASC, [ARC_CHG_LOAD_ID] ASC, [CHG_ID] ASC) WITH (FILLFACTOR = 95)
);

