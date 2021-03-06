﻿






CREATE PROCEDURE [AM].[USP_PROCEDURE_START]
	@ART_CTRL_MASTER_ID Int,
	@SCHEDULE_TYPE_VALUE_ID Int NULL, 
	@RTN INT = Null OUTPUT

AS

BEGIN TRY
	DECLARE @LOAD_ID INTEGER
	SELECT @LOAD_ID = (SELECT LOAD_ID FROM AM.BATCH_CTRL_MASTER WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
		
	BEGIN
		UPDATE AM.ARTIFACT_CTRL_MASTER
			SET 
			LAST_LOAD_ID = @LOAD_ID,
			ART_BATCH_RETRY_COUNTER = ART_BATCH_RETRY_COUNTER + 1,
			LAST_BATCH_DTE = GETDATE(),
			LAST_PROCESS_DTE = GETDATE(),
			LAST_STATUS_CODE_VALUE_ID = 1,
			LAST_START_TIME = GETDATE(),
			LAST_MESSAGE ='Procedure Running'
			WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID
	END

	Select @RTN = 1
	RETURN @RTN

END TRY

BEGIN CATCH
	Begin
		 DECLARE @ProcName AS NVARCHAR(128) = ISNULL(ERROR_PROCEDURE(), 'UNKNOWN');
		 DECLARE @ER_PLAT as VARCHAR(128) = 'MSSQL DB ENGINE'
		 DECLARE @ER_NBR AS INTEGER = ISNULL(ERROR_NUMBER(),0)
		 DECLARE @ER_LINE AS INTEGER = ISNULL(ERROR_LINE(),0)
		 DECLARE @ER_SEV AS INTEGER = ISNULL(ERROR_SEVERITY(),0)
		 DECLARE @ER_ST AS INTEGER = ISNULL(ERROR_STATE(),0)
		 DECLARE @ER_MSG AS NVARCHAR(4000) = ISNULL(ERROR_MESSAGE(), 'A MESSAGE WAS NOT PROVIDED');
		 DECLARE @ER_USR AS VARCHAR(255) = ISNULL(CURRENT_USER, 'UNKONWN')

		 EXECUTE @RTN =  AM.USP_ERR_LOG @ProcName, @ER_PLAT, @ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR	
		 --RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
	END
	
	RETURN @RTN

END CATCH;




