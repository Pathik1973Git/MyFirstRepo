﻿
CREATE PROCEDURE [CHG].[USP_UI_ADD_CHANGE_MASTER]
	@CHG_OWNER varchar(100), 
	@CHG_DESCRIPTION varchar(2000),
	@CHG_CLOSE_DATE datetime = Null, 
	@RTN INT = Null OUTPUT

AS

	SET NOCOUNT ON

	DECLARE @IS_ACTIVE_IND BIT = 'TRUE'
	DECLARE @CREATED_DTE DATETIME = GETDATE()
	DECLARE @CREATED_BY VARCHAR(50) = SYSTEM_USER
	Declare @CHG_OPEN_DATE DATETIME = GETDATE()
	

	BEGIN TRY
		BEGIN
			INSERT INTO CHG.CHANGE_MASTER(CHG_OWNER, CHG_DESCRIPTION, CHG_OPEN_DATE,CHG_CLOSE_DATE, IS_ACTIVE_IND, CREATED_DTE, CREATED_BY) 
						VALUES(@CHG_OWNER, @CHG_DESCRIPTION, @CHG_OPEN_DATE, @CHG_CLOSE_DATE, @IS_ACTIVE_IND, @CREATED_DTE, @CREATED_BY)
		
			SET @RTN = 1
			RETURN @RTN --Positive Return
		END
	END TRY
	BEGIN CATCH
		 DECLARE @ProcName AS NVARCHAR(128) = ISNULL(ERROR_PROCEDURE(), 'UNKNOWN');
		 DECLARE @ER_PLAT as VARCHAR(128) = 'MSSQL DB ENGINE'
		 DECLARE @ER_NBR AS INTEGER = ISNULL(ERROR_NUMBER(),0)
		 DECLARE @ER_LINE AS INTEGER = ISNULL(ERROR_LINE(),0)
		 DECLARE @ER_SEV AS INTEGER = ISNULL(ERROR_SEVERITY(),0)
		 DECLARE @ER_ST AS INTEGER = ISNULL(ERROR_STATE(),0)
		 DECLARE @ER_MSG AS NVARCHAR(4000) = ISNULL(ERROR_MESSAGE(), 'A MESSAGE WAS NOT PROVIDED');
		 DECLARE @ER_USR AS VARCHAR(255) = ISNULL(CURRENT_USER, 'UNKONWN')

		 EXECUTE @RTN =  AM.USP_ERR_LOG @ProcName, @ER_PLAT, @ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR	
		 RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
	END CATCH;





