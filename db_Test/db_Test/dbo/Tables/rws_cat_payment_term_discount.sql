CREATE TABLE [dbo].[rws_cat_payment_term_discount] (
    [organization_id]  INT             NOT NULL,
    [payment_type]     VARCHAR (30)    NOT NULL,
    [payment_seq]      INT             NOT NULL,
    [days_effective]   INT             NULL,
    [discount_percent] DECIMAL (17, 6) NULL,
    [create_date]      DATETIME        NULL,
    [create_user_id]   VARCHAR (20)    NULL,
    [update_date]      DATETIME        NULL,
    [update_user_id]   VARCHAR (20)    NULL,
    [record_state]     VARCHAR (30)    NULL,
    CONSTRAINT [pk_rws_cat_payment_term_discount] PRIMARY KEY CLUSTERED ([organization_id] ASC, [payment_type] ASC, [payment_seq] ASC) WITH (ALLOW_PAGE_LOCKS = OFF)
);


GO
ALTER TABLE [dbo].[rws_cat_payment_term_discount] SET (LOCK_ESCALATION = DISABLE);

