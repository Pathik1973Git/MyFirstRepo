





CREATE PROCEDURE [AM].[USP_INITIALIZE_BATCH] 
	@SCHEDULE_TYPE_VALUE_ID Int NULL, 
	@RTN INT = Null OUTPUT

AS


	SET NOCOUNT ON

	DECLARE @ART_CTRL_MASTER_ID [INT] = 998
	DECLARE @LOAD_ID BIGINT
	DECLARE @FORCE_COMPLETE INT = IsNull((SELECT FORCE_COMPLETE FROM AM.ENVIRONMENT_VAR_BATCH EB WHERE EB.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID),0) 
	
	BEGIN TRY
	   --Check to see of all of the packages executed correctly in the last bach   	   
	   If 2 = ALL(	SELECT [LAST_STATUS_CODE_VALUE_ID] 
					FROM [AM].[ARTIFACT_CTRL_MASTER] AR
						INNER JOIN [AM].[BATCH_CTRL_MASTER] BA 
							ON BA.SCHEDULE_TYPE_VALUE_ID = AR.SCHEDULE_TYPE_VALUE_ID
					WHERE	AR.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID
							and AR.ART_TYPE_VALUE_ID IN(21,23)
							and AR.SCHEDULE_MODE_VALUE_ID IN(51,52)
							and AR.IS_ENABLED_IND = 1) 
							-- Froce complete means the batch is set to force all packages to execute in a good status '2' 
							    -- before it will alow the batch to be intialized again
								-- IF force complete = 0 then package status doesn't appliy and everyting is intizlied for that schedule type
							OR @FORCE_COMPLETE = 1
			
			--IF all of the packages executed correctly in the last batch  OR @FORCE_COMPLETE = 1 	
			Begin
				-- Check the status of the status code for the for the schedule type passed.  If it is not in successful status set it as successful
				If 2 <> (SELECT [STATUS_CODE_VALUE_ID] 
						 FROM [AM].[BATCH_CTRL_MASTER]
						 WHERE [SCHEDULE_TYPE_VALUE_ID] = @SCHEDULE_TYPE_VALUE_ID)
					BEGIN
						--Sets last batch to successful, BATCH_CTRL_MASTER LAST_STATUS_CODE_VALUE_ID = 2 = Successfull, also updates BATCH_CTRL_DETIAL with completed record. 
						--This should have happend prrior to intialze however this is a catch all
						EXEC AM.USP_INITIALIZE_BATCH_UPDATE 2, @SCHEDULE_TYPE_VALUE_ID, NULL  
					END
			
				--Gets the next LOAD_ID so it can be assigned to the next intialized batch. 
				SELECT @LOAD_ID = NEXT VALUE FOR AM.SEQ_LOAD_ID
			 
                -- Deletes the old schedule record and inserts the new. 
				Delete  From AM.BATCH_CTRL_MASTER WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID  
				Insert Into  AM.BATCH_CTRL_MASTER([LOAD_ID], [BATCH_DTE], [START_DTE], [SCHEDULE_TYPE_VALUE_ID], [STATUS_CODE_VALUE_ID], [BATCH_RETRY_COUNTER], [BATCH_MSG],[CREATED_DTE])
					Values(@LOAD_ID, Cast(GETDATE() as Date), GETDATE(),@SCHEDULE_TYPE_VALUE_ID,1,0,'Batch Initialized',GetDate());
			
				--Inserts and intialization record in to AM.BATCH_CTRL_DETAIL (	AM.USP_INITIALIZE_BATCH_UPDATE only does success or failure)	   
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
				
				--GETS the last batch date from BATCH_CTRL_MASTER
				DECLARE @LAST_BATCH_DTE DATE = (SELECT CAST(BATCH_DTE as DATE) as 'DTE' FROM AM.BATCH_CTRL_MASTER WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
				
				DECLARE @NEXT_PROCESS_DATE_TIME DATETIME
				
				
				--Intializes Control Master Records  LAST_STATUS_CODE_VALUE_ID = 0 (Inialized State) -- Only records in Audit or Exec Mode for the specfic schedule passed. 
				UPDATE AM.ARTIFACT_CTRL_MASTER 
				SET 
					LAST_LOAD_ID = Cast(@LOAD_ID AS INT),
					ART_BATCH_RETRY_COUNTER = 0,
					LAST_BATCH_DTE = @LAST_BATCH_DTE,
					LAST_PROCESS_DTE = NEXT_PROCESS_TYPE_VALUE_ID,
					LAST_STATUS_CODE_VALUE_ID = 0,
					IS_STATUS_VALIDATED = 0,
					LAST_START_TIME = NULL,
					LAST_END_TIME = NULL,
					LAST_MESSAGE ='Initialized For Processing',
					NEXT_PROCESS_TYPE_VALUE_ID = 61, 
					NEXT_PROCESS_DATE_TIME = (SELECT AM.UDF_GET_NEXT_PROCESS_TIME(CM.ART_CTRL_MASTER_ID, CM.SCHEDULE_TYPE_VALUE_ID))  
					
				FROM AM.ARTIFACT_CTRL_MASTER  CM
					 Join AM.BATCH_CTRL_MASTER BS On
						CM.SCHEDULE_TYPE_VALUE_ID = BS.SCHEDULE_TYPE_VALUE_ID
				WHERE BS.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID
						and CM.SCHEDULE_MODE_VALUE_ID IN(51,52)
						and CM.ART_TYPE_VALUE_ID IN(21,23)
						and CM.IS_ENABLED_IND = 1

				--RETURN @RTN  Postive = means the procedure succeeded Negitive means procedure failed. (1 and 2 were used for testing purposes)
				Select @RTN = 99
			End
		Else
			BEGIN
				-- This message is used in alets, this procedure is one of the only procs that has alerts, all of which are custome coded in this proc. 
				DECLARE @MSG VARCHAR (400) = NULL

				--Gets a count of Crtical errors (CNT >= Threshohld) and in a -1 Status. 
				DECLARE @ERRCNT as INT =
				(SELECT Count([LAST_STATUS_CODE_VALUE_ID]) 
					 FROM [AM].[ARTIFACT_CTRL_MASTER] AR
						INNER JOIN [AM].[BATCH_CTRL_MASTER] BA 
							ON BA.[LOAD_ID] = AR.LAST_LOAD_ID
					 WHERE AR.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID
							and ART_TYPE_VALUE_ID IN(21,23)
							and SCHEDULE_MODE_VALUE_ID IN(51,52)
							and LAST_STATUS_CODE_VALUE_ID = -1
							and AR.ART_BATCH_RETRY_COUNTER >= ART_BATCH_RETRY_THRESHOLD)

				-- Gets a count of pacakges in this schedule type, both ERRCNT and RUNCT are used to formulate Status and Alert Message Information 
				DECLARE @RUNCNT as INT =
					(SELECT Count([LAST_STATUS_CODE_VALUE_ID]) 
					 FROM [AM].[ARTIFACT_CTRL_MASTER] AR
						INNER JOIN [AM].[BATCH_CTRL_MASTER] BA 
							ON BA.[LOAD_ID] = AR.LAST_LOAD_ID
					 WHERE AR.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID
							and ART_TYPE_VALUE_ID IN(21,23)
							and SCHEDULE_MODE_VALUE_ID IN(51,52)
							and LAST_STATUS_CODE_VALUE_ID in(0,-1)
							and AR.ART_BATCH_RETRY_COUNTER < ART_BATCH_RETRY_THRESHOLD)	

				-- GETS the batch description based on SCHEDULE_TYPE_VALUE_ID,used to formulate Status and Alert Message Information 
				DECLARE @BATCHDESC VARCHAR (400) = 
					(SELECT CODE_VALUE_DESC
					 FROM AM.ARTIFACT_CODE_VALUE
					 WHERE CODE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
				
				--Basic reformating of alert information 
				SET @BATCHDESC = CONCAT('(Schedule Type - ', @SCHEDULE_TYPE_VALUE_ID, ' - ', @BATCHDESC, ')')
				SET @MSG = CONCAT(@BATCHDESC, '  The previous batch has not yet completed.  There are ', @RUNCNT + @ERRCNT, 
								  ' – package(s) still running including ', @ERRCNT, ' package(s) in a critical error State' )

				--Sets last batch to Error State, BATCH_CTRL_MASTER LAST_STATUS_CODE_VALUE_ID = -1 = error state
				EXEC AM.USP_INITIALIZE_BATCH_UPDATE -1, @SCHEDULE_TYPE_VALUE_ID, @MSG
				
				--Gets Alert informiton 
				SELECT  @LOAD_ID = (SELECT LOAD_ID FROM AM.BATCH_CTRL_MASTER WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
				DECLARE @SCHEDULE_TYPE_DESC VarChar (50) = (SELECT [CODE_VALUE_DESC] FROM [AM].[ARTIFACT_CODE_VALUE] WHERE [CODE_VALUE_ID] = @SCHEDULE_TYPE_VALUE_ID)
				DECLARE @ALERT_PRIORITY VarChar (20) = (SELECT [BATCH_RETRY_COUNTER] FROM [AM].[BATCH_CTRL_MASTER] WHERE [SCHEDULE_TYPE_VALUE_ID] = @SCHEDULE_TYPE_VALUE_ID) --implict conversion
				DECLARE @ALERT_CONTEXT VarChar (200) =  @ALERT_PRIORITY
				DECLARE @ALERT_INT INT = TRY_CAST(@ALERT_PRIORITY as INT)
				DECLARE @ALERT_MSG VarChar(5000) = ''
				
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

				-- Formats Informational alert informaiton for the first retry 
				If @ALERT_CONTEXT = '0' or @ALERT_CONTEXT = 1
					BEGIN
						SELECT @ALERT_CONTEXT =  CONCAT('The initialization process has failed to run ', @ALERT_CONTEXT , ' time. ', @BATCHDESC, '  is impacted.') 
						SELECT @ALERT_MSG = CONCAT(@BATCHDESC, '  The initialization process has tried to run however the current batch cycle is in a running or error status. The next batch will not run until the current status is “cleared” by entering a complete status.  This is the first occurrence of this error for this batch ID.  Intraday batch will be delayed from this point forward.',
											'||',
										    @MSG)
					END
				
				-- Formats Warning alert informaiton for the second retry 
				If @ALERT_CONTEXT = '2' 
					BEGIN
						SELECT @ALERT_CONTEXT =  CONCAT('The initialization process has failed to run ', @ALERT_CONTEXT , ' times. ', @BATCHDESC, '  is impacted.') 
						SELECT @ALERT_MSG = CONCAT(@BATCHDESC, '  The initialization process has tried to run however the current batch cycle is in a running or error status. The next batch will not run until the current status is “cleared” by entering a complete status.  There has been multiple occurrences of this error for this batch ID.  The Intraday batch has been significantly delayed.',
						                           '||',
												   @MSG)
					END
				
				-- Formats Critical alert informaiton for the Third retry
				If @ALERT_CONTEXT = '3' 
					BEGIN
						SELECT @ALERT_CONTEXT =  CONCAT('The initialization process has failed to run ', @ALERT_CONTEXT , ' times. ', @BATCHDESC, '  is impacted.') 
						SELECT @ALERT_MSG = CONCAT(@BATCHDESC,  '  The initialization process has tried to run however the current batch cycle is in a running or error status. The next batch will not run until the current status is “cleared” by entering a complete status.  There has been multiple occurrences of this error for this batch ID.  The Intraday batch has been significantly delayed and is in a critical status.',
						                           '||',
												   @MSG)
					END
				-- If this happens more than three times create a critical alert as well. 
				If TRY_CAST(@ALERT_INT as int) > 3 and TRY_CAST(@ALERT_INT as int) IS NOT NULL
					Begin
						SELECT @ALERT_CONTEXT =  CONCAT('**Final Alert! - Further Alerts will be Suppressed** The initialization process has failed to run several times ', @BATCHDESC, '  is impacted.') 
						SELECT @ALERT_MSG = CONCAT(@BATCHDESC, '  The initialization process has tried to run however the current batch cycle is in a running or error status. The next batch will not run until the current status is “cleared” by entering a complete status.  There has been multiple occurrences of this error for this batch ID.  The Intraday batch has been significantly delayed and is in a critical status.',
												   '||',
												   @MSG)			
					End
				
				-- Message suppression only four messages will be sent, otherwise paging will go on for ever. 
				If TRY_CAST(@ALERT_INT as int) < 5 and TRY_CAST(@ALERT_INT as int) IS NOT NULL
					BEGIN
						-- Inserts the alert into the ALERTS table
						INSERT INTO AM.ALERTS(LOAD_ID,BATCH_DATE,ART_TYPE_DESC,ALERT_PRIORITY,ALERT_CONTEXT, ART_CTRL_MASTER_ID, ARTIFACT_NAME, 
							RETRY_COUNT, RETRY_THRESHOLD,  ERROR_MSG, MSG_SOURCE, EXECUTION_ID, CREATED_DTE, MSG_UPDATED_DTE)

						VALUES(@LOAD_ID, GETDATE(), 'Procedure', @ALERT_PRIORITY, @ALERT_CONTEXT, @ART_CTRL_MASTER_ID, 
						   CONCAT('USP_INITIALIZE_BATCH', ' - ', @SCHEDULE_TYPE_DESC), 0, -1, @ALERT_MSG, NULL, NULL, GETDATE(), GETDATE())
					END
						--RETURN @RTN  Postive = means the procedure succeeded Negitive means procedure failed.  
						SET @RTN = -99
						
			END
			RETURN @RTN
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

		 
		 
		
		INSERT INTO AM.ALERTS(BATCH_DATE,ART_TYPE_DESC,ALERT_PRIORITY,ALERT_CONTEXT, ART_CTRL_MASTER_ID, ARTIFACT_NAME, 
			RETRY_COUNT, RETRY_THRESHOLD, MSG_SOURCE, EXECUTION_ID, CREATED_DTE, ERROR_MSG)

			VALUES(	    GETDATE(), 0,  'Critical' , 'A failure has occurred within USP_INITIALIZE_BATCH.', 
						@ART_CTRL_MASTER_ID, 'USP_INITIALIZE_BATCH',0, -1, NULL, NULL, GETDATE(),
						'The procedure USP_INITIALIZE_BATCH has failed for reasons unknown.  This is a critical error due to the basic utility this procedure provides directly impacts all batch capability.  This error needs attention immediately.')
	
		--RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
		EXECUTE @RTN =  AM.USP_ERR_LOG @ProcName, @ER_PLAT, @ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR
		RETURN @RTN
	END CATCH;










