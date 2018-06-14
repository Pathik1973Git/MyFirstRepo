﻿CREATE TABLE [dbo].[ARTIFACT_CTRL_MASTER_BKP_0605] (
    [ART_CTRL_MASTER_ID]           INT            IDENTITY (1000, 1) NOT NULL,
    [ART_NME]                      VARCHAR (100)  NULL,
    [ART_PROCESS_DESC]             VARCHAR (1000) NULL,
    [ART_TYPE_VALUE_ID]            TINYINT        NOT NULL,
    [ART_SCALE_VALUE]              INT            NOT NULL,
    [ART_GROUP_VALUE_ID]           TINYINT        NOT NULL,
    [ART_LAYER_VALUE_ID]           TINYINT        NOT NULL,
    [SOURCE_SYSTEM_VALUE_ID]       TINYINT        NULL,
    [SCHEDULE_TYPE_VALUE_ID]       TINYINT        NOT NULL,
    [SCHEDULE_MODE_VALUE_ID]       TINYINT        NOT NULL,
    [SCHEDULE_RUN_TIME]            TIME (0)       NULL,
    [ART_BATCH_RETRY_THRESHOLD]    TINYINT        NULL,
    [ART_BATCH_RETRY_COUNTER]      TINYINT        NULL,
    [NEXT_PROCESS_TYPE_VALUE_ID]   TINYINT        NULL,
    [NEXT_PROCESS_DATE_TIME]       DATETIME       NULL,
    [LOAD_TARGET_NME]              VARCHAR (100)  NULL,
    [LAST_LOAD_ID]                 INT            NULL,
    [LAST_EXEC_ID]                 BIGINT         NULL,
    [LAST_EXEC_STATUS_VALUE_ID]    TINYINT        NULL,
    [LAST_BATCH_DTE]               DATE           NULL,
    [LAST_PROCESS_DTE]             DATETIME       NULL,
    [LAST_STATUS_CODE_VALUE_ID]    INT            NULL,
    [IS_STATUS_VALIDATED]          BIT            NULL,
    [LAST_START_TIME]              DATETIME       NULL,
    [LAST_END_TIME]                DATETIME       NULL,
    [LAST_SOURCE_NME]              VARCHAR (100)  NULL,
    [LAST_MESSAGE]                 VARCHAR (4000) NULL,
    [IS_ENABLED_IND]               BIT            NOT NULL,
    [CREATED_DTE]                  DATETIME       NOT NULL,
    [CREATED_BY]                   VARCHAR (50)   NOT NULL,
    [LAST_UPDT_DTE]                DATETIME       NULL,
    [LAST_UPDT_BY]                 VARCHAR (50)   NULL,
    [LAST_CHG_LOAD_ID]             INT            NULL,
    [IS_INCREMENTAL_LOAD]          BIT            NULL,
    [SOURCE_INCREMENT_LOAD_COLUMN] VARCHAR (200)  NULL,
    [LOAD_START_VALUE]             VARCHAR (200)  NULL,
    [LOAD_END_VALUE]               VARCHAR (200)  NULL
);

