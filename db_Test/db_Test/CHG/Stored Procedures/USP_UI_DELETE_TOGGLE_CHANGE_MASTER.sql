﻿
CREATE PROCEDURE [CHG].[USP_UI_DELETE_TOGGLE_CHANGE_MASTER]
	@CHG_ID INTEGER,
	@IS_ACTIVE_IND INTEGER, 
	@RTN INT = Null OUTPUT

AS

	SET NOCOUNT ON
	
	DECLARE @LAST_UPDT_DTE DATETIME = GETDATE()
	DECLARE @LAST_UPDT_BY VARCHAR(50) = CURRENT_USER
	
	BEGIN TRY
		If @IS_ACTIVE_IND <> 1 AND @IS_ACTIVE_IND <> 0
			BEGIN
				RAISERROR ('IS_ACTIVE_IND Must be a 1 or 0.',16,1)
			END
		
		IF(SELECT COUNT(CHG_ID) FROM CHG.CHANGE_MASTER WHERE CHG_ID = @CHG_ID) <> 1
			BEGIN 
				RAISERROR ('No matching records found with this CHG_ID' ,16, 1)
			END
			 
		UPDATE CHG.CHANGE_MASTER
		SET IS_ACTIVE_IND = CAST(@IS_ACTIVE_IND AS BIT), LAST_UPDT_DTE = @LAST_UPDT_DTE, LAST_UPDT_BY = @LAST_UPDT_BY
		WHERE CHG_ID = @CHG_ID 			

		SET @RTN = 1
		RETURN @RTN --Positive Return
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
		 Rollback
	END CATCH;






