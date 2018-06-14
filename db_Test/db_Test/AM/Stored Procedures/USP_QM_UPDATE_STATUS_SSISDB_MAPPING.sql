﻿

CREATE PROCEDURE [AM].[USP_QM_UPDATE_STATUS_SSISDB_MAPPING]
						@RTN INT = Null OUTPUT
AS
BEGIN TRY
	-- Synchronizes the ACM LAST_STATUS_CODE_VALUE with the SSIDB package status.  This is based on a maping table - AM.SSISDB_STATUS_MAPPING
	-- In rare cases the framework and SSISDB can fall out of synch on status.  
	-- This is usually do to event handler tasks not firing correctly or on other anomolies that may happen along the way. 
	-- The mapping table (AM.SSISDB_STATUS_MAPPING) contains the logic that drives this process.
	SET NOCOUNT ON

	IF OBJECT_ID(N'tempdb..#SSISDB_UPDATE', N'U') IS NOT NULL 
	BEGIN  
		DROP TABLE #SSISDB_UPDATE; 
	END;
	
	WITH CTE AS
		(
		SELECT ACM.ART_CTRL_MASTER_ID, ACM.LAST_EXEC_ID, ACM.LAST_STATUS_CODE_VALUE_ID, O.status, M.CHG_FRAMEWORK_TO
			,CHG_MSG = CONCAT('LAST STATUS CHANGED TO: ', M.CHG_FRAMEWORK_STATUS_DESC, ' | FW SATSUS WAS: ', M.FRAMEWORK_STATUS_DESC, ' | SSISDB STATUS WAS: ', M.SSISDB_STATUS_DESC)
			,IIF(m.CHG_FRAMEWORK_TO IS NOT NULL, 1, 0) as 'NEEDS_UPDATE'
		FROM SSISDB.internal.executions (NOLOCK) E 
			INNER JOIN AM.ARTIFACT_CTRL_MASTER ACM 
				ON E.execution_id = ACM.LAST_EXEC_ID
			INNER JOIN SSISDB.internal.operations O
				ON E.execution_id= O.operation_id
			JOIN AM.ENVIRONMENT_VAR_SSISDB_MAPPING M
				ON CONCAT(ACM.LAST_STATUS_CODE_VALUE_ID, O.status) = M.ID
			Where   
				LAST_START_TIME Is NOT NULL
				--and ACM.IS_STATUS_VALIDATED = 0
		) 
	
	SELECT *  INTO #SSISDB_UPDATE FROM CTE;

	-- Update Records That Requrie Changes Based on SSISDB Mismatch
	UPDATE ACM
	SET
		ACM.LAST_EXEC_STATUS_VALUE_ID = T.[Status],
		ACM.LAST_STATUS_CODE_VALUE_ID = T.CHG_FRAMEWORK_TO,
		ACM.IS_STATUS_VALIDATED = 1,
		ACM.LAST_MESSAGE = T.CHG_MSG
	FROM #SSISDB_UPDATE T
		JOIN AM.ARTIFACT_CTRL_MASTER ACM 
			ON T.LAST_EXEC_ID = ACM.LAST_EXEC_ID
	WHERE NEEDS_UPDATE = 1
	
	-- Update Records that match with SSISDB LAST_EXEC_STATUS_VALUE_ID 
	--UPDATE ACM
	--SET
	--	ACM.IS_STATUS_VALIDATED = 1,
	--	ACM.LAST_EXEC_STATUS_VALUE_ID = T.[Status]
	--FROM #SSISDB_UPDATE T
	--	JOIN AM.ARTIFACT_CTRL_MASTER ACM 
	--		ON T.LAST_EXEC_ID = ACM.LAST_EXEC_ID
	--WHERE T.NEEDS_UPDATE = 0 

	---- Update auidt mode records.
	--UPDATE AM.ARTIFACT_CTRL_MASTER
	--SET
	--	IS_STATUS_VALIDATED = 1,
	--	LAST_EXEC_STATUS_VALUE_ID = 7
	--WHERE SCHEDULE_MODE_VALUE_ID = 51 
	--	AND LAST_END_TIME iS NOT NULL
	--	AND LAST_STATUS_CODE_VALUE_ID = 2

	 
		
	-- This is technically a status change so we add a record to AM.ARTIFACT_CTRL_DETAIL
	INSERT INTO  AM.ARTIFACT_CTRL_DETAIL
	([ART_CTRL_MASTER_ID]
           ,[ART_NME]
           ,[EXEC_ID]
           ,[LOAD_ID]
           ,[STATUS_CODE_VALUE_ID]
           ,[EXEC_STATUS_VALUE_ID]
           ,[ART_GROUP_VALUE_ID]
           ,[ART_PROCESS_DESC]
           ,[BATCH_DTE]
           ,[ART_BATCH_RETRY_COUNTER]
           ,[ART_BATCH_RETRY_THRESHOLD]
           ,[START_TIME]
           ,[END_TIME]
           ,[SOURCE_NME]
           ,[SOURCE_TOTAL_RECORDS]
           ,[SOURCE_NEW_RECORDS]
           ,[SOURCE_CHANGE_RECORDS]
           ,[SOURCE_DELETE_RECORDS]
           ,[TARGET_NME]
           ,[TARGET_TOTAL_RECORDS_BEFORE]
           ,[TARGET_NEW_RECORDS]
           ,[TARGET_CHANGE_RECORDS]
           ,[TARGET_DELETE_RECORDS]
           ,[TARGET_UNCHANGED_RECORDS]
           ,[TARGET_FAILED_RECORDS]
           ,[TARGET_TOTAL_RECORDS_AFTER]
           ,[LOAD_MESSAGE]
           ,[USER_OSUSER]
           ,[CREATED_DTE])
	SELECT ACM.ART_CTRL_MASTER_ID, ART_NME, EXEC_ID = ACM.LAST_EXEC_ID, LOAD_ID = LAST_LOAD_ID, STATUS_CODE_VALUE_ID = ACM.LAST_STATUS_CODE_VALUE_ID,EXEC_STATUS_VALUE_ID = LAST_EXEC_STATUS_VALUE_ID, ART_GROUP_VALUE_ID, 
	ART_PROCESS_DESC, BATCH_DTE = LAST_BATCH_DTE, ART_BATCH_RETRY_COUNTER, ART_BATCH_RETRY_THRESHOLD, START_TIME = LAST_START_TIME, END_TIME = LAST_END_TIME
	,SOURCE_NME = NULL,SOURCE_TOTAL_RECORDS = NULL,SOURCE_NEW_RECORDS = NULL,SOURCE_CHANGE_RECORDS = NULL,SOURCE_DELETE_RECORDS = NULL
	,TARGET_NME = NULL,TARGET_TOTAL_RECORDS_BEFORE = NULL,TARGET_NEW_RECORDS = NULL,TARGET_CHANGE_RECORDS = NULL, TARGET_DELETE_RECORDS = NULL
	,TARGET_UNCHANGED_RECORDS = NULL ,TARGET_FAILED_RECORDS = NULL,TARGET_TOTAL_RECORDS_AFTER = NULL
	,LOAD_MESSAGE = T.CHG_MSG ,USER_OSUSER = SYSTEM_USER , CREATED_DTE = GETDATE()
	FROM AM.ARTIFACT_CTRL_MASTER ACM
	JOIN #SSISDB_UPDATE T ON 
		ACM.LAST_EXEC_ID = T.LAST_EXEC_ID 
	WHERE T.NEEDS_UPDATE = 1
	
	-- INVOKE ALERTS WHERE REQRUIED
	EXECUTE [AM].[USP_ALERTS_MANAGER]

	--DROP TEMP TABLE
	IF OBJECT_ID(N'tempdb..#SSISDB_UPDATE', N'U') IS NOT NULL 
	BEGIN  
		DROP TABLE #SSISDB_UPDATE; 
	END;

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
			 
		END

		--RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
		RETURN @RTN
END CATCH





