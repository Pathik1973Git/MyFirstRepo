CREATE TABLE [dbo].[rws_factory_second_reference] (
    [organization_id]        INT          NOT NULL,
    [item_id]                VARCHAR (60) NOT NULL,
    [factory_second_item_id] VARCHAR (60) NULL,
    [create_date]            DATETIME     NULL,
    [create_user_id]         VARCHAR (20) NULL,
    [update_date]            DATETIME     NULL,
    [update_user_id]         VARCHAR (20) NULL,
    [record_state]           VARCHAR (30) NULL,
    CONSTRAINT [pk_rws_factory_second_reference] PRIMARY KEY CLUSTERED ([organization_id] ASC, [item_id] ASC)
);

