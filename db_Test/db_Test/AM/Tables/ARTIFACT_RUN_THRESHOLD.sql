CREATE TABLE [AM].[ARTIFACT_RUN_THRESHOLD] (
    [FROM_RUN_TIME]            INT          NULL,
    [TO_RUN_TIME]              INT          NULL,
    [ALERT_INFO_THRESHOLD]     INT          NULL,
    [ALERT_WARN_THRESHOLD]     INT          NULL,
    [ALERT_CRITICAL_THRESHOLD] INT          NULL,
    [CREATED_DTE]              DATETIME     NOT NULL,
    [CREATED_BY]               VARCHAR (50) NOT NULL,
    [LAST_UPDT_DTE]            DATETIME     NULL,
    [LAST_UPDT_BY]             VARCHAR (50) NULL
);

