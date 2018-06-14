﻿CREATE TABLE [AM].[STAGE_ARTIFACT_DEPENDENCY] (
    [ART_CTRL_MASTER_ID]        INT          NOT NULL,
    [REFERENCED_CTRL_MASTER_ID] INT          NOT NULL,
    [LOAD_ID]                   INT          NULL,
    [DEPENDENCY_TYPE_VALUE_ID]  INT          NOT NULL,
    [DEPENDENCY_SEQUENCE]       INT          NOT NULL,
    [IS_ENABLED_IND]            BIT          CONSTRAINT [STG_DF__ARTIFACT___IS_EN__37703C52] DEFAULT ('FALSE') NOT NULL,
    [CREATED_DTE]               DATETIME     CONSTRAINT [STG_DF__ARTIFACT___CREAT__367C1819] DEFAULT (getdate()) NOT NULL,
    [CREATED_BY]                VARCHAR (50) NOT NULL,
    [LAST_UPDT_DTE]             DATETIME     NULL,
    [LAST_UPDT_BY]              VARCHAR (50) NULL,
    [LAST_CHG_LOAD_ID]          INT          NULL,
    CONSTRAINT [STG_PK_ARTIFACT_DEPENDENCY-ART_IDs] PRIMARY KEY CLUSTERED ([ART_CTRL_MASTER_ID] ASC, [REFERENCED_CTRL_MASTER_ID] ASC) WITH (FILLFACTOR = 95)
);

