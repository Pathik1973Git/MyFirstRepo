﻿

CREATE PROCEDURE [TEST].[USP_UI_DELETE_TOGGLE_TESTING_MASTER]
	@TEST_ID INTEGER,
	@IS_DEL_IND INTEGER, 
	@RTN INT = Null OUTPUT

AS

	SET NOCOUNT ON
	
	DECLARE @LAST_UPDT_DTE DATETIME = GETDATE()
	DECLARE @LAST_UPDT_BY VARCHAR(50) = SYSTEM_USER
	
	BEGIN TRY
		If @IS_DEL_IND <> 1 AND @IS_DEL_IND <> 0
			BEGIN
				RAISERROR ('IS_DEL_IND Must be a 1 or 0.',16,1)
			END
		
		IF(SELECT COUNT(TEST_ID) FROM TEST.TESTING_MASTER WHERE TEST_ID = @TEST_ID) <> 1
			BEGIN 
				RAISERROR ('No matching records found with this TEST_ID' ,16, 1)
			END
			 
		UPDATE TEST.TESTING_MASTER
		SET IS_DEL_IND = CAST(@IS_DEL_IND AS BIT), LAST_UPDT_DTE = @LAST_UPDT_DTE, LAST_UPDT_BY = @LAST_UPDT_BY
		WHERE TEST_ID = @TEST_ID 			

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





