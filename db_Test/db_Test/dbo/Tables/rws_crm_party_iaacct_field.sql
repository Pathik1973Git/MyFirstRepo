CREATE TABLE [dbo].[rws_crm_party_iaacct_field] (
    [organization_id] INT           NOT NULL,
    [party_id]        BIGINT        NOT NULL,
    [acct_id]         VARCHAR (60)  NOT NULL,
    [field_label]     VARCHAR (256) NOT NULL,
    [field_order]     BIGINT        NULL,
    [field_content]   VARCHAR (256) NULL,
    [valid_flag]      BIT           NULL,
    [create_date]     DATETIME      NULL,
    [create_user_id]  VARCHAR (20)  NULL,
    [update_date]     DATETIME      NULL,
    [update_user_id]  VARCHAR (20)  NULL,
    [record_state]    VARCHAR (30)  NULL,
    [program_id]      VARCHAR (60)  NULL
);


GO
ALTER TABLE [dbo].[rws_crm_party_iaacct_field] SET (LOCK_ESCALATION = DISABLE);

