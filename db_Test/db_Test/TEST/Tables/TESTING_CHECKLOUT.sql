﻿CREATE TABLE [TEST].[TESTING_CHECKLOUT] (
    [CHECK_ID]       INT           IDENTITY (1000, 1) NOT NULL,
    [CHECK_OUT_DTE]  DATE          NOT NULL,
    [CHECK_OUT_BY]   VARCHAR (50)  NOT NULL,
    [CHECK_OUT_DESC] VARCHAR (200) NOT NULL,
    [CHECK_IN_DTE]   DATE          NULL,
    [CHECK_IN_BY]    VARCHAR (50)  NULL,
    [CHECK_IN_DESC]  VARCHAR (200) NULL,
    [CREATED_DTE]    DATETIME      NOT NULL,
    [CREATED_BY]     VARCHAR (50)  NOT NULL,
    [LAST_UPDT_DTE]  DATETIME      NULL,
    [LAST_UPDT_BY]   VARCHAR (50)  NULL,
    [IS_CLOSED_IND]  BIT           NULL
);

