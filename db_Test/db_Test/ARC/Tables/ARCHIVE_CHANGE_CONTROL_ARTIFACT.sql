﻿CREATE TABLE [ARC].[ARCHIVE_CHANGE_CONTROL_ARTIFACT] (
    [ARC_CHG_ID]         INT          NOT NULL,
    [ARC_CHG_LOAD_ID]    INT          NOT NULL,
    [ARC_CHG_DATETIME]   DATETIME     NOT NULL,
    [CHG_ID]             INT          NOT NULL,
    [ART_CTRL_MASTER_ID] INT          NOT NULL,
    [IS_ACTIVE_IND]      BIT          DEFAULT ((0)) NOT NULL,
    [CREATED_DTE]        DATETIME     NOT NULL,
    [CREATED_BY]         VARCHAR (50) NOT NULL,
    [LAST_UPDT_DTE]      DATETIME     NULL,
    [LAST_UPDT_BY]       VARCHAR (50) NULL,
    [CREATED_ARC_DTE]    DATETIME     NULL,
    CONSTRAINT [PK_CHANGE_ARTIFACT] PRIMARY KEY CLUSTERED ([ARC_CHG_ID] ASC, [ARC_CHG_LOAD_ID] ASC, [CHG_ID] ASC, [ART_CTRL_MASTER_ID] ASC) WITH (FILLFACTOR = 95)
);
