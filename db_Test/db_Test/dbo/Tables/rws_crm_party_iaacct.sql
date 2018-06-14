CREATE TABLE [dbo].[rws_crm_party_iaacct] (
    [organization_id] INT           NOT NULL,
    [party_id]        BIGINT        NOT NULL,
    [acct_id]         VARCHAR (60)  NOT NULL,
    [group_id]        VARCHAR (256) NULL,
    [enrolled_date]   DATETIME      NULL,
    [active_flag]     BIT           NULL,
    [create_date]     DATETIME      NULL,
    [create_user_id]  VARCHAR (20)  NULL,
    [update_date]     DATETIME      NULL,
    [update_user_id]  VARCHAR (20)  NULL,
    [record_state]    VARCHAR (30)  NULL,
    [program_id]      VARCHAR (60)  NULL
);


GO
ALTER TABLE [dbo].[rws_crm_party_iaacct] SET (LOCK_ESCALATION = DISABLE);

