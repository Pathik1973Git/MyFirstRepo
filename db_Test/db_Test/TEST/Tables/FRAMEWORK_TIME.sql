﻿CREATE TABLE [TEST].[FRAMEWORK_TIME] (
    [TIME_ID]    INT           IDENTITY (1, 1) NOT NULL,
    [START_TIME] VARCHAR (200) NULL,
    [End_Time]   VARCHAR (200) NULL,
    CONSTRAINT [PK_ALERTS-ALERT_ID] PRIMARY KEY CLUSTERED ([TIME_ID] ASC) WITH (FILLFACTOR = 95)
);

