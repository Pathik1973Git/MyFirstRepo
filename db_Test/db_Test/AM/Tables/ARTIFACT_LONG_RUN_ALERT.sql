CREATE TABLE [AM].[ARTIFACT_LONG_RUN_ALERT] (
    [ART_CTRL_MASTER_ID] INT      NULL,
    [INFO_LVL]           INT      NULL,
    [WARN_LVL]           INT      NULL,
    [CRIT_LVL]           INT      NULL,
    [INFO_SENT]          BIT      NULL,
    [WARN_SENT]          BIT      NULL,
    [CRIT_SENT]          BIT      NULL,
    [BATCH_DTE]          DATETIME NULL,
    [OVERRIDE_ALERT]     BIT      NULL,
    [OVERRIDE_LVL]       INT      NULL,
    [CREATED_DTE]        DATETIME NULL,
    [LST_UPD_DTE]        DATETIME NULL
);

