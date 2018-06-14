
CREATE Procedure [AM].[USP_PKG_ON_ERROR_IBC] 
	@ART_CTRL_MASTER_ID Int, 
	@EXEC_ID as Int = Null,
	@RTN INT = Null OUTPUT

	AS
	
	BEGIN TRY
		DECLARE @LOAD_ID INTEGER
		DECLARE @BATCH_DTE DATE
		DECLARE @ART_GROUP_VALUE_ID INT
		DECLARE @SCHEDULE_TYPE_VALUE_ID Int
		DECLARE @ART_NME varchar(100)
		DECLARE @ART_PROCESS_DESC varchar(1000)
		DECLARE @ART_BATCH_RETRY_COUNTER INT
		DECLARE @ART_BATCH_RETRY_THRESHOLD INT
		DECLARE @END_TIME DATETIME = GETDATE()
		DECLARE @START_TIME DATETIME
		DECLARE @LOAD_MESSAGE VARCHAR(100) = 'IBC/Record Count Error (See Alerts)'	    
		DECLARE @NEXT_PROCESS_DATE_TIME DateTime

		SELECT @ART_NME = ART_NME, 	@ART_GROUP_VALUE_ID = ART_GROUP_VALUE_ID, @ART_PROCESS_DESC = ART_PROCESS_DESC, @START_TIME = LAST_PROCESS_DTE, @SCHEDULE_TYPE_VALUE_ID = SCHEDULE_TYPE_VALUE_ID, 
			@ART_BATCH_RETRY_COUNTER = ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD = ART_BATCH_RETRY_THRESHOLD,@LOAD_ID = LAST_LOAD_ID, @BATCH_DTE = LAST_BATCH_DTE
		FROM [AM].[ARTIFACT_CTRL_MASTER]
		WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID	

		EXEC @NEXT_PROCESS_DATE_TIME = AM.UDF_GET_RETRY_DELAY @SCHEDULE_TYPE_VALUE_ID 

		UPDATE AM.ARTIFACT_CTRL_MASTER
			SET 
			LAST_STATUS_CODE_VALUE_ID = -1, 
			LAST_END_TIME = @END_TIME,
			LAST_MESSAGE = @LOAD_MESSAGE,
			IS_STATUS_VALIDATED = 1,
			NEXT_PROCESS_DATE_TIME = @NEXT_PROCESS_DATE_TIME
			WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID
    
	SET @EXEC_ID = ISNULL(@EXEC_ID, (Select LAST_EXEC_ID FROM [AM].[ARTIFACT_CTRL_MASTER] WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID))
		
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
		--***************** This  procedure creates  customer alerts based on IBC (Record Cout Errors) ****************
		--******************************** IBC - Internal Balance and Controls ****************************************
		--**************************************** Alerts process *****************************************************
		--*************************************************************************************************************
		
		-- This message is used in alets, this procedure is one of the only procs that has alerts, all of which are custom coded in this proc. 
		DECLARE @MSG VARCHAR (400) = NULL

		-- +1 to the error count because this is reporting pre-retry. 
		SET @ART_BATCH_RETRY_COUNTER = @ART_BATCH_RETRY_COUNTER + 1

		--Gets a count of Crtical errors (CNT >= Threshohld) and in a -1 Status. 
		DECLARE @ERRCNT as INT =
		(SELECT Count([LAST_STATUS_CODE_VALUE_ID]) 
				FROM [AM].[ARTIFACT_CTRL_MASTER] AR
				INNER JOIN [AM].[BATCH_CTRL_MASTER] BA 
					ON BA.[LOAD_ID] = AR.LAST_LOAD_ID
				WHERE BA.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID
					and ART_TYPE_VALUE_ID IN(21,23)
					and SCHEDULE_MODE_VALUE_ID IN(51,52)
					and LAST_STATUS_CODE_VALUE_ID = -1
					and BATCH_RETRY_COUNTER >= ART_BATCH_RETRY_THRESHOLD) + 1

		-- Gets a count of pacakges in this schedule type, both ERRCNT and RUNCT are used to formulate Status and Alert Message Information 
		DECLARE @RUNCNT as INT =
			(SELECT Count([LAST_STATUS_CODE_VALUE_ID]) 
				FROM [AM].[ARTIFACT_CTRL_MASTER] AR
				INNER JOIN [AM].[BATCH_CTRL_MASTER] BA 
					ON BA.[LOAD_ID] = AR.LAST_LOAD_ID
				WHERE BA.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID
					and ART_TYPE_VALUE_ID IN(21,23)
					and SCHEDULE_MODE_VALUE_ID IN(51,52)
					and LAST_STATUS_CODE_VALUE_ID = 0)	

		-- GETS the batch description based on SCHEDULE_TYPE_VALUE_ID,used to formulate Status and Alert Message Information 
		DECLARE @BATCHDESC VARCHAR (400)= 
			(SELECT CODE_VALUE_DESC
				FROM AM.ARTIFACT_CODE_VALUE
				WHERE CODE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
				
		SET @BATCHDESC = CONCAT('(Schedule Type - ', @SCHEDULE_TYPE_VALUE_ID, ' - ', @BATCHDESC, ')')

		--Basic reformating of alert information 
		SET @MSG = CONCAT('This package failed ', @ART_BATCH_RETRY_COUNTER, ' of ', @ART_BATCH_RETRY_THRESHOLD, 
							' attempts, the last attempt was due to IBC controls that reconcile record counts. ', @BATCHDESC, ' is impacted.' )

		--Gets Alert informiton 
		SELECT  @LOAD_ID = (SELECT LOAD_ID FROM AM.BATCH_CTRL_MASTER WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
		DECLARE @SCHEDULE_TYPE_DESC VarChar (50) = (SELECT [CODE_VALUE_DESC] FROM [AM].[ARTIFACT_CODE_VALUE] WHERE [CODE_VALUE_ID] = @SCHEDULE_TYPE_VALUE_ID)
		DECLARE @ALERT_PRIORITY VarChar (20) = Cast(((SELECT [ART_BATCH_RETRY_COUNTER] FROM [AM].[ARTIFACT_CTRL_MASTER] WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)) as VARCHAR)
		DECLARE @ALERT_CONTEXT VarChar (200) =  @ALERT_PRIORITY 
		DECLARE @ALERT_MSG VarChar(5000) = ''
		DECLARE @ALERT_REMAINGING_TRIES Integer
				
		--Formats alert priority 
		SELECT @ALERT_PRIORITY =
		(SELECT CASE @ALERT_PRIORITY
			WHEN '0' THEN 'Informational'
			WHEN '1' THEN 'Informational'  
			WHEN '2' THEN 'Warning'
			WHEN '3' THEN 'Critical'
			Else 'Critical'
			END
		)

		SET @ALERT_REMAINGING_TRIES = @ART_BATCH_RETRY_THRESHOLD - @ART_BATCH_RETRY_COUNTER

		-- Formats Informational alert informaiton for the first retry 
		If @ALERT_REMAINGING_TRIES >= 2 
			BEGIN
				SELECT @ALERT_CONTEXT =  CONCAT('The package failed based on IBC (Count Errors) ', @ALERT_CONTEXT , ' time(s). ', @BATCHDESC, ' is impacted.') 
				SELECT @ALERT_MSG = CONCAT('The package failed due to Internal Balance and Controls (IBC) issues. This happen when the source record count and the expected target can’t be mathematically reconciled.  This error will impact batch and further dependent items until this status is cleared ether by automated retries or manual intervention.',
									'||',
									@MSG)
			END
				
		-- Formats Warning alert informaiton for the second retry 
		If @ALERT_REMAINGING_TRIES = 1  
			BEGIN
				SELECT @ALERT_CONTEXT =  CONCAT('The package failed based on IBC (Count Errors) ', @ALERT_CONTEXT , ' time(s). ', @BATCHDESC, ' is impacted.') 
				SELECT @ALERT_MSG = CONCAT('The package failed due to Internal Balance and Controls (IBC) issues. This happen when the source record count and the expected target can’t be mathematically reconciled.  This error will impact batch and further dependent items until this status is cleared ether by automated retries or manual intervention.',
						                    '||',
											@MSG)
			END
				
		-- Formats Critical alert informaiton for the Third retry
		If @ALERT_REMAINGING_TRIES <= 0
			BEGIN
				SELECT @ALERT_CONTEXT =  CONCAT('**Final Alert! The package failed based on IBC (Count Errors) ', @ALERT_CONTEXT , ' time(s). ', @BATCHDESC, ' is impacted.') 
				SELECT @ALERT_MSG = CONCAT('The package failed due to Internal Balance and Controls (IBC) issues. This happen when the source record count and the expected target can’t be mathematically reconciled.  This error will impact batch and further dependent items until this status is cleared ether by automated retries or manual intervention.',
						                    '||',
											@MSG)
			END

		-- Inserts the alert into the ALERTS table
		INSERT INTO AM.ALERTS(LOAD_ID, EXECUTION_ID, BATCH_DATE, ART_TYPE_DESC, ALERT_PRIORITY, ALERT_CONTEXT, ART_CTRL_MASTER_ID, ARTIFACT_NAME, 
			RETRY_COUNT, RETRY_THRESHOLD,  ERROR_MSG, MSG_SOURCE, CREATED_DTE, MSG_UPDATED_DTE )

		VALUES(@LOAD_ID, @EXEC_ID, GETDATE(), 'Package', @ALERT_PRIORITY, @ALERT_CONTEXT, @ART_CTRL_MASTER_ID, @ART_NME, 
				@ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD, @ALERT_MSG, 'Custom - IBC Error', GETDATE(),GETDATE())
						
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





