



CREATE PROCEDURE [AM].[USP_QM_EXECUTE_QUEUE_MSTR] 
	@RTN INT = Null OUTPUT

AS
	BEGIN TRY
		SET NOCOUNT ON
		--*****************************************************************************************************************************************************
		--**************** Processing Variables ***************************************************************************************************************
		--*****************************************************************************************************************************************************

		DECLARE @EXEC_ID INT					-- Execution ID From SSIS DB used only in execution mode otherwise -1 is sent to CTRL MSTR
		DECLARE @ART_SCALE_VALUE INT = 0		-- Currnet Package Scale Value
		DECLARE @SCALE_TO_THRESH INT = 0		-- Calcuated environment scale left to execute Environment Scale - Sum of Running Scale
		DECLARE @MSTR_MODE INT = NULL			-- SCHEDULE_MODE_VALUE_ID of the this procedure USP_EXEC_QUEUE_MSTR (The mode is it executing in)
		DECLARE @PKG_MODE as  INT				-- SCHEDULE_MODE_VALUE_ID of the package being executed
		DECLARE @RUN_MODE VarChar(10) = NULL	-- Calulated in UDF_RUN_MODE (Both MSTR and PKG need to be in EXEC to run in EXEC MODE, Otherwise AUDIT MODE)
		DECLARE @MIN_SCALE INT					-- Minimum SCALE IN QUEUE used for look ahead to set values for while loop
		DECLARE @EXEC_MSTR INT = 1				-- Integer that returns the status of this procedure, also used in some calculations. 
		DECLARE @ART_CTRL_MASTER_ID INT = NULL	-- ART_CTRL_MASTER_ID of the package executing (From ARTIFACT_CTRL_MASTER)
		DECLARE @ART_PATH VarChar(100) = NULL	-- ART_DEPLOYMENT_PATH of the package executing (From ARTIFACT_CTRL_MASTER)
		DECLARE @STATUS_CODE INT = NULL			-- LAST_STATUS_CODE_VALUE_ID of the package executing (From ARTIFACT_CTRL_MASTER)
		DECLARE @SKIP_THRESH INT = 0			-- NUMBER OF RECORDS THAT USP_QM_EXEC_QUEUE_MSTR CAN SKIP WHILE TRYING TO FIND A PACKAGE THAT WILL FIT INTO THE REMAINING THRESHOLD
		
		--*****************************************************************************************************************************************************
		--**************** Logging Variables ******************************************************************************************************************
		--*****************************************************************************************************************************************************
		DECLARE @EXEC_COUNT INT = 0				-- Dual Purpose - First Represents # of Packages to be run,  Second # of Executions in this run
		DECLARE @EXEC_SCALE INT = 0				-- The sum of artifact scale executed
		DECLARE @AUDIT_COUNT INT = 0			-- # of AUDIT MODE Executions in this run
		DECLARE @AUDIT_SCALE INT = 0			-- The sum of artifact AUDIT MODE scale executed
		DECLARE @SKIP_COUNT INT = 0				-- # of Packages skipped because threshold not met however the scale of the artifact was too large to execute
		DECLARE @SKIP_SCALE INT = 0				-- Sum of artifact scale skipped because it couldn't be executed withing the current threshold. 
		DECLARE @PROC_START DateTime			-- Time Procedure started
		DECLARE @PROC_END DateTime				-- Time PRocedure Ended 
		DECLARE @START_RUN_SCALE INT = 0		-- Sum of the starting scale running at the start of procedure
		DECLARE @START_RUN_COUNT INT = 0		-- Count of packages running at the start of procedure
		DECLARE @END_RUN_SCALE INT = 0			-- Sum of the ending scale running at the end of procedure
		DECLARE @END_RUN_COUNT INT = 0			-- Count of packages Running at the end of the procedure
		DECLARE @REMAIN_Q_COUNT INT = 0			-- Count of Remaing Queue 
		DECLARE @REMAIN_Q_SCALE INT = 0			-- Sum of Remaing Queue Scale
		DECLARE @THRESH INT = 0					-- Current environment scale threshold
		DECLARE @LOG_MSG VarChar(200)			-- MSG Returned to the AM.QUEUE_EXEC_LOG generated from @EXEC_MSTR value
		DECLARE @ROW_NBR INT = NULL				-- Row number in the EXEC_TEMP actively being processed
		--*****************************************************************************************************************************************************
		--*****MAINTENANCE*************************************************************************************************************************************
		--*****************************************************************************************************************************************************
		
		-- This is a maintenance item if the framework falls out of synch with the SSSIS DB, Updates CTRL Master LAST_STATUS_VALUE_ID
	    --EXEC AM.USP_QM_UPDATE_STATUS_SSISDB_MAPPING
		
		-- Sets alerts if reqruied 
		EXEC AM.USP_ALERTS_MANAGER
		
		-- REMOVE TEMP TABLE IF EXISTS
		IF OBJECT_ID(N'tempdb..#EXEC_QUEUE', N'U') IS NOT NULL 
			BEGIN  
				DROP TABLE #QUEUE_SKIP; 
			END

		-- REMOVE TEMP TABLE IF EXISTS
		IF OBJECT_ID(N'tempdb..#QUEUE_SKIP', N'U') IS NOT NULL 
			BEGIN  
				DROP TABLE #EXEC_QUEUE; 
			END
		
		-- CREATE TEMP TABLE FOR REMOVING SKIPPED ITEMS FROM RUN LIST
	    CREATE TABLE #QUEUE_SKIP
	        (ART_CTRL_MASTER_ID int)
		
		--print('Before set variable')
		--*****************************************************************************************************************************************************
		--*****SET VARIABLES***********************************************************************************************************************************
		--*****************************************************************************************************************************************************
		SET  @PROC_START = GETUTCDATE()
		SET  @START_RUN_COUNT = ISNULL((SELECT COUNT(1) CNT FROM AM.ARTIFACT_CTRL_MASTER WHERE LAST_STATUS_CODE_VALUE_ID = 1), 0)
		SET  @START_RUN_SCALE = ISNULL((SELECT SUM(ART_SCALE_VALUE) as 'SUM' FROM AM.ARTIFACT_CTRL_MASTER WHERE LAST_STATUS_CODE_VALUE_ID = 1), 0)
		SET  @SKIP_THRESH = ISNULL((SELECT KeyValueInt CNT FROM AM.ENVIRONMENT_VAR_MASTER WHERE ID = 2),0) 		 
		SET  @EXEC_COUNT = ISNULL((SELECT COUNT(1) CNT FROM AM.v_MASTER_QUEUE), 0)
		SET @THRESH = ISNULL((SELECT KeyValueInt CNT FROM AM.ENVIRONMENT_VAR_MASTER WHERE ID = 1),0) 
		--*****************************************************************************************************************************************************
		--***** PRE-WORK **************************************************************************************************************************************
		--*****************************************************************************************************************************************************
		
		
		--Get the curent Scale of the envionrment running vs the threshold for the environment (How much scale we can still execute now)
		EXEC @SCALE_TO_THRESH = AM.UDF_QM_THRESH_TO_SCALE
		SET  @MSTR_MODE = ISNULL((SELECT SCHEDULE_MODE_VALUE_ID FROM AM.ARTIFACT_CTRL_MASTER WHERE ART_CTRL_MASTER_ID = 999), 51) -- Defaults to audit mode if not found
		
		SET  @EXEC_MSTR = IIF (@EXEC_COUNT < 1, -1, @EXEC_COUNT)      -- -1 = Nothing in queue to execute
		SET  @EXEC_MSTR = IIF (@SCALE_TO_THRESH < 1, -2, @EXEC_MSTR)  -- -2 = Threshold was too high to execute anything
		--print('Log_1')
		IF @EXEC_MSTR > 0
			BEGIN
				
				--RESET @EXEC_MSTR 0 = 'Threshold was met' which is the defualt message. Other STATUS will be set if requried in the code below 
				SET @EXEC_MSTR = 0
				
				--Counters for packages run and skipped
				SET @EXEC_COUNT = 0
				SET @SKIP_COUNT = 0
				
				-- GET Execution Queue from v_MASTER_QUEUE	
				SELECT ROW_NUMBER() OVER(PARTITION BY IS_ENABLED_IND ORDER BY [MODE_PRIORITY] ASC, [LAYER_PRIORITY] ASC, [SCHEDULE_PRIORITY] ASC, [GROUP_PRIORITY] ASC) as 'ROW_NBR'
							 ,V.ART_CTRL_MASTER_ID, [LAST_LOAD_ID], [SCHEDULE_MODE_VALUE_ID], [ART_DEPLOYMENT_PATH], [ART_GROUP_VALUE_ID], [ART_SCALE_VALUE], [ART_LAYER_VALUE_ID], [LAST_STATUS_CODE_VALUE_ID], [NEXT_PROCESS_TYPE_VALUE_ID], [NEXT_PROCESS_DATE_TIME], [MODE_PRIORITY], [LAYER_PRIORITY], [SCHEDULE_PRIORITY], [GROUP_PRIORITY]
				INTO #EXEC_QUEUE
				FROM [AM].[v_MASTER_QUEUE] V
				LEFT JOIN #QUEUE_SKIP S --Exclude Skipped ART_CTRL_MASTER_ID's
					ON V.ART_CTRL_MASTER_ID = S.ART_CTRL_MASTER_ID
					WHERE S.ART_CTRL_MASTER_ID IS NULL	
				
		--*****************************************************************************************************************************************************
		--***** MAIN LOOP**************************************************************************************************************************************
		--*****************************************************************************************************************************************************		
				WHILE @SCALE_TO_THRESH > 0  
					BEGIN
						--GET THE NEXT PACKAGE TO EXECUTE
						SELECT TOP 1  @ROW_NBR =  ROW_NBR, @ART_CTRL_MASTER_ID = ART_CTRL_MASTER_ID, @ART_PATH = ART_DEPLOYMENT_PATH, @PKG_MODE = SCHEDULE_MODE_VALUE_ID, @ART_SCALE_VALUE = ART_SCALE_VALUE
						FROM #EXEC_QUEUE
						ORDER BY ROW_NBR
						
						--Refresh Scale and Threshold Informaiton
						EXEC @SCALE_TO_THRESH = AM.UDF_QM_THRESH_TO_SCALE
				
						--NEXT GET MODES AUDIT EXEC PKG AND MSTR SCHEDULE
						EXEC @RUN_MODE = AM.UDF_QM_RUN_MODE @ART_CTRL_MASTER_ID, @MSTR_MODE
						--print('Log-2')
						IF (@SCALE_TO_THRESH) - @ART_SCALE_VALUE >= 0 OR  @ROW_NBR IS NOT NULL
							BEGIN
								IF @RUN_MODE = 51
									BEGIN
										--print('Log-3')
										-- Set the pacakge in a running state on ACM and create a detail reocrd
										EXEC [AM].[USP_QM_INITIALIZE_EXECUTION] @RUN_MODE, @ART_CTRL_MASTER_ID
										
										-- Incriment AUDIT MODE Run Counter
										SET @AUDIT_COUNT = @AUDIT_COUNT + 1 

										-- Incriment Sum of SAUDIT MODE cale Executed
										SET @AUDIT_SCALE = @AUDIT_SCALE + @ART_SCALE_VALUE

										-- Incriment @SCALE_TO_THRESH TO ACCOUNT FOR THE EXECUTED @ART_SCALE_VALUE
										SET @SCALE_TO_THRESH = @SCALE_TO_THRESH - @ART_SCALE_VALUE
										
										-- Close the package in a complete state on ACM and create a detail record.
										EXEC AM.USP_QM_COMPLETE_AUDIT_MODE @ART_CTRL_MASTER_ID
										--print('Log-3 end')

									END
								ELSE
									BEGIN
										--print('Log-4')
										-- Set the pacakge in a running state on ACM and create a detail reocrd	
										EXEC [AM].[USP_QM_INITIALIZE_EXECUTION] @RUN_MODE, @ART_CTRL_MASTER_ID
										
										-- Execcute Artifact
										EXEC @EXEC_ID = [AM].[USP_QM_EXECUTE_PACKAGE] @ART_CTRL_MASTER_ID

										-- This is just a precautionary step, sometimes on errors pre-execute wil lnot fire. 
										UPDATE AM.ARTIFACT_CTRL_MASTER
										SET LAST_EXEC_ID = @EXEC_ID, IS_STATUS_VALIDATED = 0
										WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID
										
										IF @EXEC_ID = 1
											BEGIN
												EXEC AM.USP_PKG_ON_ERROR_EXEC_ENGINE @ART_CTRL_MASTER_ID
											END
																				
										-- Incriment Run Counter
										SET @EXEC_COUNT = @EXEC_COUNT + 1 

										-- Incriment Sum of Scale Executed
										SET @EXEC_SCALE = @EXEC_SCALE + @ART_SCALE_VALUE
										
										-- Incriment @SCALE_TO_THRESH TO ACCOUNT FOR THE EXECUTED @ART_SCALE_VALUE
										SET @SCALE_TO_THRESH = @SCALE_TO_THRESH - @ART_SCALE_VALUE
										--print('Log-4 end')
									END

								--DELETE RECORD FROM EXEC_QUEUE
								DELETE FROM #EXEC_QUEUE WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID
								
								-- Let Everything Settle and Commit  
								WAITFOR DELAY '00:00:01'

							END
						ELSE
							BEGIN
							--print('Log-5')
								IF @SKIP_COUNT >= @SKIP_THRESH
									BEGIN
										IF @SKIP_THRESH <> 0 
											BEGIN
												SET @SCALE_TO_THRESH = 0
												SET @EXEC_MSTR = - 5  -- Skip Threshold Met 
											END
										ELSE
											BEGIN
												SET @SCALE_TO_THRESH = 0
												SET @EXEC_MSTR = - 4  -- Threshold met, however not maxed 
											END
									END
								ELSE
									BEGIN
										IF @SKIP_THRESH <> 0
											BEGIN
												-- SKIP THIS PACKAGE - Adding it to the temp table will remove it from execution list
												INSERT INTO #QUEUE_SKIP (ART_CTRL_MASTER_ID) VALUES (@ART_CTRL_MASTER_ID)
								
												UPDATE AM.ARTIFACT_CTRL_MASTER 
												SET LAST_MESSAGE = 'SKIPED IN QUEUE - TO LARGE FOR CURRENT THRESHHOLD'
												WHERE ART_CTRL_MASTER_ID = 	@ART_CTRL_MASTER_ID
																					
												-- Incriment Skip Counter
												SET @SKIP_COUNT = @SKIP_COUNT + 1

												-- Incriment Sum of Scale Skipped
												SET @SKIP_SCALE = @SKIP_SCALE + @ART_SCALE_VALUE
											END
									END		
								--print('Log-5 end')				
								END
						
						IF ISNULL((SELECT COUNT(1) CNT FROM #EXEC_QUEUE), 0) = 0 
							BEGIN
								--print('Log-6');
								--REFRESH THE EXEC TABLE MORE ITEMS MAY HAVE COME INTO QUEUE DURING PROCESSING 
								WITH CTE AS 
									(SELECT ROW_NUMBER() OVER(PARTITION BY IS_ENABLED_IND ORDER BY [MODE_PRIORITY] ASC, [LAYER_PRIORITY] ASC, [SCHEDULE_PRIORITY] ASC, [GROUP_PRIORITY] ASC) ROW_NBR
											,v.ART_CTRL_MASTER_ID, LAST_LOAD_ID, SCHEDULE_MODE_VALUE_ID, ART_DEPLOYMENT_PATH, ART_GROUP_VALUE_ID, ART_SCALE_VALUE, ART_LAYER_VALUE_ID, LAST_STATUS_CODE_VALUE_ID, NEXT_PROCESS_TYPE_VALUE_ID, NEXT_PROCESS_DATE_TIME, MODE_PRIORITY, LAYER_PRIORITY, SCHEDULE_PRIORITY, GROUP_PRIORITY
									 FROM [AM].[v_MASTER_QUEUE] V
									 LEFT JOIN #QUEUE_SKIP S --Exclude Skipped ART_CTRL_MASTER_ID's
										ON V.ART_CTRL_MASTER_ID = S.ART_CTRL_MASTER_ID
									 WHERE S.ART_CTRL_MASTER_ID IS NULL)
									 	
								INSERT INTO #EXEC_QUEUE 
									 SELECT ROW_NBR, ART_CTRL_MASTER_ID, LAST_LOAD_ID, SCHEDULE_MODE_VALUE_ID, ART_DEPLOYMENT_PATH, ART_GROUP_VALUE_ID
									 ,ART_SCALE_VALUE, ART_LAYER_VALUE_ID, LAST_STATUS_CODE_VALUE_ID, NEXT_PROCESS_TYPE_VALUE_ID, NEXT_PROCESS_DATE_TIME
									 ,MODE_PRIORITY, LAYER_PRIORITY, SCHEDULE_PRIORITY, GROUP_PRIORITY
								FROM CTE; 
									
								-- Make Sure Next Recrod Exists if not @ROW_NBR is null and exit loop
								SET @ROW_NBR = ISNULL((SELECT TOP 1 ROW_NBR FROM #EXEC_QUEUE ORDER BY ROW_NBR),0)
								
								-- Reset the ScaleToThresh and set message value 
								IF @ROW_NBR = 0
									BEGIN 
										SET @SCALE_TO_THRESH = 0
										SET @EXEC_MSTR = - 3  -- Queue is now empty 
									END
								--print('Log-6 end')
							END
						ELSE
							BEGIN
								SET @MIN_SCALE = ISNULL((SELECT MIN(ART_SCALE_VALUE) CNT FROM AM.v_MASTER_QUEUE), 0)
								SET @MIN_SCALE = IIF(@MIN_SCALE < 1, 1, @MIN_SCALE)

								IF @SCALE_TO_THRESH > 0
									BEGIN
										IF @MIN_SCALE > @SCALE_TO_THRESH
											BEGIN
												SET @SCALE_TO_THRESH = 0
												SET @EXEC_MSTR = - 4  -- Threshold met, however not maxed 
											END
									END
							END

						
				END -- END While
		END-- END IF @EXEC_MSTR > 0 
		--*****************************************************************************************************************************************************
		--***** RECORD EVENTS *********************************************************************************************************************************
		--*****************************************************************************************************************************************************		
		-- Create Log Message Text
		SELECT @LOG_MSG =
				(SELECT CASE @EXEC_MSTR
					WHEN  0 THEN 'Threshold was met'
					WHEN -1 THEN 'Queue was empty, nothing to execute'
					WHEN -2 THEN 'Environment Threshold met prior to execution'  
					WHEN -3 THEN 'Queue was emptied - nothing more to execute'
					WHEN -4 THEN 'Max scale executed however below max threshold'
					WHEN -5 THEN CONCAT('Skip Threshold  of ', @SKIP_THRESH , ' has been reached')
					Else 'Unknown procedure limit or error occurred'
				 END
				)
		--print('Log-7')
		-- SET closing variables
		SET @END_RUN_COUNT = ISNULL((SELECT COUNT(1) CNT FROM AM.ARTIFACT_CTRL_MASTER WHERE LAST_STATUS_CODE_VALUE_ID = 1), 0)
		SET @END_RUN_SCALE = ISNULL((SELECT SUM(ART_SCALE_VALUE) as 'SUM' FROM AM.ARTIFACT_CTRL_MASTER WHERE LAST_STATUS_CODE_VALUE_ID = 1), 0)
		SET @REMAIN_Q_COUNT = ISNULL((SELECT COUNT(1) CNT FROM AM.v_MASTER_QUEUE), 0)
		SET @REMAIN_Q_SCALE = ISNULL((SELECT SUM(ART_SCALE_VALUE) as 'SUM' FROM AM.v_MASTER_QUEUE), 0)
		SET @PROC_END = GETUTCDATE()
		
		-- UPDATE AM.QUEUE_EXEC_LOG
		INSERT INTO AM.QUEUE_EXECUTION_LOG
		(
		 PROC_START_TIME, PROC_END_TIME, EXECUTION_COUNT, EXECUTION_SCALE, AUDIT_COUNT, AUDIT_SCALE, SKIP_COUNT, SKIP_SCALE, 
		 STARTING_RUN_COUNT, STARTING_RUN_SCALE, ENDING_RUN_COUNT, ENDING_RUN_SCALE,
		 REMAINING_QUEUE_COUNT, REMAINING_QUEUE_SCALE, LOG_MSG_VALUE, LOG_MSG_DESC, ENV_SCALE_THRESHOLD, SKIP_THRESHOLD
		 ) 
		 VALUES
		 (
		 @PROC_START, @PROC_END, @EXEC_COUNT, @EXEC_SCALE, @AUDIT_COUNT, @AUDIT_SCALE, @SKIP_COUNT, @SKIP_SCALE,
		 @START_RUN_COUNT, @START_RUN_SCALE, @END_RUN_COUNT, @END_RUN_SCALE, 
		 @REMAIN_Q_COUNT, @REMAIN_Q_SCALE, ABS(@EXEC_MSTR), @LOG_MSG, @THRESH, @SKIP_THRESH
		 )
		 --print('Log-8')
		--*****************************************************************************************************************************************************
		--***** CLEAN UP **************************************************************************************************************************************
		--*****************************************************************************************************************************************************		
		-- Drop Temp Table #QUEUE_SKIP if exists
		IF OBJECT_ID(N'tempdb..#QUEUE_SKIP', N'U') IS NOT NULL 
			BEGIN  
				DROP TABLE #QUEUE_SKIP; 
			END

		-- Drop Temp Table #EXEC_QUEUE if exists
		IF OBJECT_ID(N'tempdb..#EXEC_QUEUE', N'U') IS NOT NULL 
			BEGIN  
				DROP TABLE #EXEC_QUEUE; 
			END


		-- This is a maintenance item if the framework falls out of synch with the SSSIS DB, Updates CTRL Master LAST_STATUS_VALUE_ID
	    --EXEC AM.USP_QM_UPDATE_STATUS_SSISDB_MAPPING
		-- Closes Out Batches If Completed
		EXEC AM.USP_INITIALIZE_BATCH_CLOSE
		-- Sets alerts if reqruied 
		EXEC AM.USP_ALERTS_MANAGER

		--print('Log-9')
		
		Select @RTN = 1
		RETURN @RTN
	END  TRY
	--*****************************************************************************************************************************************************
	--***** ERROR HANDLING ********************************************************************************************************************************
	--*****************************************************************************************************************************************************		
	BEGIN CATCH

	Begin
		--print('Log-10')
		 DECLARE @ProcName AS NVARCHAR(128) = ISNULL(ERROR_PROCEDURE(), 'UNKNOWN');
		 DECLARE @ER_PLAT as VARCHAR(128) = 'MSSQL DB ENGINE'
		 DECLARE @ER_NBR AS INTEGER = ISNULL(ERROR_NUMBER(),0)
		 DECLARE @ER_LINE AS INTEGER = ISNULL(ERROR_LINE(),0)
		 DECLARE @ER_SEV AS INTEGER = ISNULL(ERROR_SEVERITY(),0)
		 DECLARE @ER_ST AS INTEGER = ISNULL(ERROR_STATE(),0)
		 DECLARE @ER_MSG AS NVARCHAR(4000) = ISNULL(ERROR_MESSAGE(), 'A MESSAGE WAS NOT PROVIDED');
		 DECLARE @ER_USR AS VARCHAR(255) = ISNULL(CURRENT_USER, 'UNKONWN')

		 EXECUTE @RTN =  AM.USP_ERR_LOG @ProcName, @ER_PLAT, @ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR	
		 --print('Log-11')
	END

	--RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
	RETURN @RTN

END CATCH;






