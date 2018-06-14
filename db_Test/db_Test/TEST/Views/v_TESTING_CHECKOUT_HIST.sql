



CREATE VIEW [TEST].[v_TESTING_CHECKOUT_HIST]
AS
	SELECT 
	   [CHECK_ID]
      ,[CHECK_OUT_DTE]
      ,[CHECK_OUT_BY]
      ,[CHECK_OUT_DESC]
      ,[CHECK_IN_DTE]
      ,[CHECK_IN_BY]
      ,[CHECK_IN_DESC]
      ,[CREATED_DTE]
      ,[CREATED_BY]
      ,[LAST_UPDT_DTE]
      ,[LAST_UPDT_BY]
      ,[IS_CLOSED_IND]
  FROM [TEST].[TESTING_CHECKLOUT]






