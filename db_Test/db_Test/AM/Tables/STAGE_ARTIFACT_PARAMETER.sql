﻿CREATE TABLE [AM].[STAGE_ARTIFACT_PARAMETER] (
    [ART_CTRL_MASTER_ID]        INT           NOT NULL,
    [PARM_ID]                   CHAR (4)      NOT NULL,
    [LOAD_ID]                   INT           NULL,
    [PARM_NME]                  VARCHAR (30)  NOT NULL,
    [PARM_VALUE_DATA_TYPE_CODE] CHAR (1)      NOT NULL,
    [PARM_CHAR_VALUE]           VARCHAR (200) NULL,
    [PARM_INT_VALUE]            INT           NULL,
    [PARM_DTE_VALUE]            DATETIME      NULL,
    [PARM_DESC]                 VARCHAR (200) NOT NULL,
    [IS_ENABLED_IND]            BIT           CONSTRAINT [STG_DF_PARAM_IS_ENABLED] DEFAULT ('True') NOT NULL,
    [CREATED_DTE]               DATETIME      CONSTRAINT [STG_DF_PARAM_CREATEDTE] DEFAULT (getdate()) NOT NULL,
    [CREATED_BY]                VARCHAR (50)  NOT NULL,
    [LAST_UPDT_DTE]             DATETIME      NULL,
    [LAST_UPDT_BY]              VARCHAR (50)  NULL,
    [LAST_CHG_LOAD_ID]          INT           NULL,
    CONSTRAINT [STG_PK_ARTIFACT_PARAMETER-ART_ID-PARM_ID] PRIMARY KEY CLUSTERED ([ART_CTRL_MASTER_ID] ASC, [PARM_ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [STG_CK_PARM_CODE] CHECK ([PARM_VALUE_DATA_TYPE_CODE]='D' OR [PARM_VALUE_DATA_TYPE_CODE]='I' OR [PARM_VALUE_DATA_TYPE_CODE]='C')
);

