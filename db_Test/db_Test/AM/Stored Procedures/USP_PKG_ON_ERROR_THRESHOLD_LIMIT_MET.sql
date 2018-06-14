
CREATE Procedure [AM].[USP_PKG_ON_ERROR_THRESHOLD_LIMIT_MET] 
	@ART_CTRL_MASTER_ID Int, 
	@Error_Limit INT,
	@EXEC_ID as Int = Null,
	@RTN INT = Null OUTPUT

	AS
	
	BEGIN TRY
		DECLARE @LOAD_ID INTEGER
		DECLARE @BATCH_DTE DATE
		DECLARE @ART_GROUP_VALUE_ID tinyint
		DECLARE @SCHEDULE_TYPE_VALUE_ID Int
		DECLARE @ART_NME varchar(100)
		DECLARE @ART_PROCESS_DESC varchar(1000)
		DECLARE @ART_BATCH_RETRY_COUNTER TinyInt
		DECLARE @ART_BATCH_RETRY_THRESHOLD TinyInt
		DECLARE @END_TIME DATETIME = GETDATE()
		DECLARE @START_TIME DATETIME
		DECLARE @LOAD_MESSAGE VARCHAR(100) = 'Fact Error Records Exceed The Threshold'	    

		SELECT @ART_NME = ART_NME, 	@ART_GROUP_VALUE_ID = ART_GROUP_VALUE_ID, @ART_PROCESS_DESC = ART_PROCESS_DESC, @START_TIME = LAST_PROCESS_DTE, @SCHEDULE_TYPE_VALUE_ID = SCHEDULE_TYPE_VALUE_ID, 
			@ART_BATCH_RETRY_COUNTER = ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD = ART_BATCH_RETRY_THRESHOLD,@LOAD_ID = LAST_LOAD_ID, @BATCH_DTE = LAST_BATCH_DTE
		FROM [AM].[ARTIFACT_CTRL_MASTER]
		WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID	
		    
		UPDATE AM.ARTIFACT_CTRL_MASTER
			SET 
			LAST_STATUS_CODE_VALUE_ID = -1,
			ART_BATCH_RETRY_COUNTER = @ART_BATCH_RETRY_THRESHOLD,
			LAST_END_TIME = @END_TIME,
			LAST_MESSAGE = @LOAD_MESSAGE,
			IS_STATUS_VALIDATED = 1
			WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID
		
		IF @EXEC_ID IS NULL
			BEGIN
				SET @EXEC_ID = (Select LAST_EXEC_ID FROM [AM].[ARTIFACT_CTRL_MASTER] WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
			END

	INSERT INTO  AM.ARTIFACT_CTRL_DETAIL
		(
		ART_CTRL_MASTER_ID, ART_NME, EXEC_ID, LOAD_ID, STATUS_CODE_VALUE_ID, ART_GROUP_VALUE_ID,LOAD_MESSAGE,
		ART_PROCESS_DESC, BATCH_DTE, ART_BATCH_RETRY_COUNTER, ART_BATCH_RETRY_THRESHOLD, START_TIME, END_TIME
		,USER_OSUSER, CREATED_DTE)
 
	 Values
		(
		@ART_CTRL_MASTER_ID, @ART_NME, @EXEC_ID, @LOAD_ID, -1, @ART_GROUP_VALUE_ID, @LOAD_MESSAGE,
		@ART_PROCESS_DESC, @BATCH_DTE, @ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD, @Start_Time, @END_Time
		, SYSTEM_USER, GETDATE()			
		)

		--*************************************************************************************************************
		--***************** This  procedure creates  customer alerts based on Fact error thresholds *******************
		--*************************************************************************************************************
		--**************************************** Alerts process *****************************************************
		--*************************************************************************************************************
		
		-- This message is used in alets, this procedure is one of the only procs that has alerts, all of which are custom coded in this proc. 
				DECLARE @MSG VARCHAR (400) = NULL

				-- +1 to the error count because this is reporting pre-retry. 
				SET @ART_BATCH_RETRY_COUNTER = @ART_BATCH_RETRY_THRESHOLD


				-- GETS the batch description based on SCHEDULE_TYPE_VALUE_ID,used to formulate Status and Alert Message Information 
				DECLARE @BATCHDESC VARCHAR (400)= 
					(SELECT CODE_VALUE_DESC
					 FROM AM.ARTIFACT_CODE_VALUE
					 WHERE CODE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
				
				SET @BATCHDESC = CONCAT('(Schedule Type - ', @SCHEDULE_TYPE_VALUE_ID, ' - ', @BATCHDESC, ')')

				--Basic reformating of alert information 
				SET @MSG = CONCAT('This was set to ',  @ART_BATCH_RETRY_THRESHOLD, ' of ', @ART_BATCH_RETRY_THRESHOLD, 
								  ' attempts, although the package may not have executed ', @ART_BATCH_RETRY_THRESHOLD , ' time(s).  The package was forced to fail due to the count of fact error records exceeding the threshold. ', @BATCHDESC, ' is impacted.' )

				--Gets Alert informiton 
				SELECT  @LOAD_ID = (SELECT LOAD_ID FROM AM.BATCH_CTRL_MASTER WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
				DECLARE @SCHEDULE_TYPE_DESC VarChar (50) = (SELECT [CODE_VALUE_DESC] FROM [AM].[ARTIFACT_CODE_VALUE] WHERE [CODE_VALUE_ID] = @SCHEDULE_TYPE_VALUE_ID)
				DECLARE @ALERT_PRIORITY VarChar (20) = 'Critical'
				DECLARE @ALERT_MSG VarChar(5000) = ''
				

				

				-- Formats Informational alert informaiton for the first retry 
				
				-- Formats Critical alert informaiton for the Third retry

				Declare @ALERT_CONTEXT Varchar(200) =  CONCAT('** Final and Only Alert - This package has failed due to violation of the Fact Error Record Threshold. The run count was forced to read ',  @ART_BATCH_RETRY_THRESHOLD , ' of ',   @ART_BATCH_RETRY_THRESHOLD, ' time(s). ', @BATCHDESC, ' is impacted.') 
				SELECT @ALERT_MSG = CONCAT('The package failed due to violation of the Fact Error Record Threshold. Every fact table has an error table where records are written if they cannot commit to the fact table.  There is a limit set in AM.ARTIFACT_PARAMETERS (usually ID P002) that specifies how many error records can be written before the process is forced to error out.  This process has meet its error limit of '
											, @Error_Limit
											,' Records and the process is now forced a Critical Error/ALERT State.  This process will not be re-run, the error records should be cleaned up and this process should be re-run in the process errors only mode.  (usually ID P0001 in the AM.ARTIFACT_PARAMETERS table).  Batch will be held up until this error has been cleared.',
						                    '||',
											@MSG)

				-- Inserts the alert into the ALERTS table
				INSERT INTO AM.ALERTS(LOAD_ID,BATCH_DATE,ART_TYPE_DESC,ALERT_PRIORITY,ALERT_CONTEXT, ART_CTRL_MASTER_ID, ARTIFACT_NAME, 
					RETRY_COUNT, RETRY_THRESHOLD,  ERROR_MSG, MSG_SOURCE, EXECUTION_ID, CREATED_DTE,MSG_UPDATED_DTE)

				VALUES(@LOAD_ID, @BATCH_DTE, 'Package', @ALERT_PRIORITY, @ALERT_CONTEXT, @ART_CTRL_MASTER_ID, @ART_NME, 
						@ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD, @ALERT_MSG,'Custom - Fact Error Threshold Met', @EXEC_ID, GETDATE(), GETDATE())

		--RETURN @RTN  Postive = means the procedure succeeded Negitive means procedure failed.  
		SET @RTN = 1			
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






