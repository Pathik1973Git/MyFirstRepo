CREATE TABLE [ARC].[ARCHIVE_ARTIFACT_PARAMETER] (
    [CHG_ID]                    INT           NOT NULL,
    [CHG_LOAD_ID]               INT           NOT NULL,
    [CHG_DATETIME]              DATETIME      NOT NULL,
    [ART_CTRL_MASTER_ID]        INT           NOT NULL,
    [PARM_ID]                   CHAR (4)      NOT NULL,
    [LOAD_ID]                   INT           NULL,
    [PARM_NME]                  VARCHAR (30)  NOT NULL,
    [PARM_VALUE_DATA_TYPE_CODE] CHAR (1)      NOT NULL,
    [PARM_CHAR_VALUE]           VARCHAR (200) NULL,
    [PARM_INT_VALUE]            INT           NULL,
    [PARM_DTE_VALUE]            DATETIME      NULL,
    [PARM_DESC]                 VARCHAR (200) NOT NULL,
    [IS_ENABLED_IND]            BIT           CONSTRAINT [DF_PARAM_IS_ENABLED] DEFAULT ('True') NOT NULL,
    [CREATED_DTE]               DATETIME      CONSTRAINT [DF_PARAM_CREATEDTE] DEFAULT (getdate()) NOT NULL,
    [CREATED_BY]                VARCHAR (50)  NOT NULL,
    [LAST_UPDT_DTE]             DATETIME      NULL,
    [LAST_UPDT_BY]              VARCHAR (50)  NULL,
    [CREATED_ARC_DTE]           DATETIME      NULL,
    CONSTRAINT [PK_ARTIFACT_PARAMETER-ART_ID-PARM_ID] PRIMARY KEY CLUSTERED ([CHG_ID] ASC, [CHG_LOAD_ID] ASC, [ART_CTRL_MASTER_ID] ASC, [PARM_ID] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [CK_PARM_CODE] CHECK ([PARM_VALUE_DATA_TYPE_CODE]='D' OR [PARM_VALUE_DATA_TYPE_CODE]='I' OR [PARM_VALUE_DATA_TYPE_CODE]='C')
);

