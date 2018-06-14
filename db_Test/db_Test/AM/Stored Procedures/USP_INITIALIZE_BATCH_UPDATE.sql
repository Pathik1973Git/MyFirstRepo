
CREATE PROCEDURE [AM].[USP_INITIALIZE_BATCH_UPDATE]
	@LAST_STATUS_CODE_VALUE_ID INT,
	@SCHEDULE_TYPE_VALUE_ID INT,
	@MSG Varchar (400), --Optional
	@RTN INT = Null OUTPUT

AS

BEGIN TRY
	BEGIN
		-- MSG is Null for Initialization, however should have informaiton in MSG Initialization fails due to overlap in batch or package errors. 
		IF @MSG IS NULL
			BEGIN
			SELECT @MSG =
				(SELECT CASE @LAST_STATUS_CODE_VALUE_ID
					WHEN -1 THEN 'Batch Error Occured'
					WHEN 2  THEN 'Batch Process Complete'
				 END
				)
			END
	
		-- If '2' is sent, the AM.BATCH_CTRL_MASTER is updated as succesful
		If @LAST_STATUS_CODE_VALUE_ID = 2
			BEGIN
				UPDATE AM.BATCH_CTRL_MASTER
				SET 
				[END_DTE] = GETDATE(),
				[STATUS_CODE_VALUE_ID] = 2,
				[BATCH_MSG] = @MSG,
				[LAST_UPDT_DTE] = GETDATE()
				WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID 

				-- Everytime a status changes a detail record is created
				INSERT INTO AM.BATCH_CTRL_DETAIL
					SELECT 
						 [LOAD_ID]
						,[BATCH_DTE]
						,[START_DTE]
						,[END_DTE]
						,[SCHEDULE_TYPE_VALUE_ID]
						,[STATUS_CODE_VALUE_ID]
						,[BATCH_RETRY_COUNTER]
						,[BATCH_MSG]
						,[CREATED_DTE]
					FROM [AM].[BATCH_CTRL_MASTER]
					WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID 
			END

		--  If a negitive satus is sent then the batch retry count is incremented and hte message is updated. 
		IF @LAST_STATUS_CODE_VALUE_ID = -1
			BEGIN
				UPDATE AM.BATCH_CTRL_MASTER
				SET 
				[STATUS_CODE_VALUE_ID] = -1,
				[BATCH_RETRY_COUNTER] =  [BATCH_RETRY_COUNTER] + 1,
				[BATCH_MSG] = @MSG,
				[LAST_UPDT_DTE] = GETDATE()
				WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID 
				
				-- Everytime a status changes a detail record is created
				INSERT INTO AM.BATCH_CTRL_DETAIL
					SELECT 
						 [LOAD_ID]
						,[BATCH_DTE]
						,[START_DTE]
						,[END_DTE]
						,[SCHEDULE_TYPE_VALUE_ID]
						,[STATUS_CODE_VALUE_ID]
						,[BATCH_RETRY_COUNTER]
						,[BATCH_MSG]
						,[CREATED_DTE]
					FROM [AM].[BATCH_CTRL_MASTER]
					WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID 
			END
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






