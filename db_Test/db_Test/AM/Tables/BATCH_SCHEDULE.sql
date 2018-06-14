﻿CREATE TABLE [AM].[BATCH_SCHEDULE] (
    [ART_CTRL_MASTER_ID]     INT          NOT NULL,
    [SCHEDULE_TYPE_VALUE_ID] TINYINT      NOT NULL,
    [CREATED_DTE]            DATETIME     NOT NULL,
    [CREATED_BY]             VARCHAR (50) NOT NULL,
    [LAST_UPDT_DTE]          DATETIME     NULL,
    [LAST_UPDT_BY]           VARCHAR (50) NULL,
    [LOAD_ID]                INT          NULL,
    CONSTRAINT [PK_ARTIFACT_SCHEDULE-ART_ID-SCH_ID] PRIMARY KEY CLUSTERED ([ART_CTRL_MASTER_ID] ASC, [SCHEDULE_TYPE_VALUE_ID] ASC)
);
