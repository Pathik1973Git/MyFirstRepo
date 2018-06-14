﻿
-- =============================================
-- Author:		Shreyas Bhagat
-- Create date: 09/21/2015
-- Description:	This Stored Procedure identifies long running packages and inserts the alert records in AM.ALERTS table with appropriate ALERT_LEVELS.
-- =============================================
CREATE PROCEDURE [AM].[USP_ARTIFACT_LONG_RUN_ALERT] 
	
	@RTN INT = Null OUTPUT									--<=Optional - No need to send defaults to 0 and then returns message based on success

AS
BEGIN TRY

	SET NOCOUNT ON;
	
	-- Get Artifacts who are still running and have crossed threshold(Informational/Critical) and for whom alerts arent raised yet.
    SELECT EXE.execution_id,AT.ART_CTRL_MASTER_ID,AT.ART_NME, DATEDIFF(MILLISECOND,CAST(EXE.START_TIME AS DATETIME),GETDATE())/ 1000 RUN_TIME
	, LR.INFO_LVL*60 INFO_LVL,LR.WARN_LVL*60 WARN_LVL,LR.CRIT_LVL*60 CRIT_LVL,LR.INFO_SENT,LR.WARN_SENT,LR.CRIT_SENT 
	,CASE WHEN (DATEDIFF(MILLISECOND,CAST(EXE.START_TIME AS DATETIME),GETDATE())/ 1000>LR.CRIT_LVL*60) AND LR.CRIT_SENT =0 AND LR.[OVERRIDE_ALERT]=0 THEN 'Critical'
	WHEN (DATEDIFF(MILLISECOND,CAST(EXE.START_TIME AS DATETIME),GETDATE())/ 1000 BETWEEN LR.INFO_LVL*60 AND LR.CRIT_LVL*60) AND LR.INFO_SENT=0 AND LR.[OVERRIDE_ALERT]=0 THEN 'Informational' 
	WHEN (DATEDIFF(MILLISECOND,CAST(EXE.START_TIME AS DATETIME),GETDATE())/ 1000>LR.[OVERRIDE_LVL]*60) AND LR.CRIT_SENT =0 AND LR.[OVERRIDE_ALERT]=1 THEN  'Critical'
	ELSE NULL END ALERT_PRIORITY,LR.BATCH_DTE, ACL.CODE_VALUE_DESC ART_LAYER, ACG.CODE_VALUE_DESC ART_GROUP,
	ACP.CODE_VALUE_DESC ART_PROJECT--, ACE.CODE_VALUE_DESC EXEC_TYPE	
	INTO #Temp_Run  
	FROM   SSISDB.[CATALOG].[EXECUTIONS] (NOLOCK) AS EXE
	JOIN AM.ARTIFACT_CTRL_MASTER (NOLOCK) AS AT ON EXE.PACKAGE_NAME=AT.ART_NME + '.DTSX' 
	JOIN [AM].[ARTIFACT_LONG_RUN_ALERT] (NOLOCK) LR ON AT.ART_CTRL_MASTER_ID=LR.ART_CTRL_MASTER_ID
	JOIN AM.ARTIFACT_CODE_VALUE (NOLOCK) AS ACL on AT.ART_LAYER_VALUE_ID=ACL.CODE_VALUE_ID
	JOIN AM.ARTIFACT_CODE_VALUE (NOLOCK) ACG ON AT.ART_GROUP_VALUE_ID=ACG.CODE_VALUE_ID
	JOIN AM.ARTIFACT_DEPLOYMENT (NOLOCK) AD ON AT.ART_CTRL_MASTER_ID=AD.ART_CTRL_MASTER_ID
	JOIN AM.ARTIFACT_CODE_VALUE (NOLOCK) ACP ON AD.ART_PROJECT_VALUE_ID=ACP.CODE_VALUE_ID
	JOIN AM.ARTIFACT_CTRL_MASTER (NOLOCK) ACM ON AT.ART_CTRL_MASTER_ID=ACM.ART_CTRL_MASTER_ID
	--*JOIN AM.ARTIFACT_CODE_VALUE (NOLOCK) ACE ON ACM.PROCESS_TYPE_VALUE_ID=ACE.CODE_VALUE_ID
	WHERE STATUS=2--Consider only running state packages in SSISDB
	and CAST(EXE.START_TIME AS DATETIME)>GETDATE()-1-- Last 24 hours packages considered
	AND (LR.INFO_SENT=0 OR LR.CRIT_SENT=0)-- And only artifacts whose Critical/Informational alerts arent raised for current batch yet.
	
	
	
	INSERT INTO [AM].[ALERTS]
           (--[LOAD_ID]
           --,
		   [EXECUTION_ID]
           ,[BATCH_DATE]
           ,[ART_TYPE_DESC]
           ,[ALERT_PRIORITY]
           ,[ALERT_CONTEXT]
           ,[ART_CTRL_MASTER_ID]
           ,[ARTIFACT_NAME]
           ,[RETRY_COUNT]
           ,[RETRY_THRESHOLD]
           ,[ERROR_MSG]
           ,[MSG_SOURCE]
           ,[CREATED_DTE]
           ,[MSG_UPDATED_DTE])
     SELECT EXECUTION_ID
           ,BATCH_DTE
           ,'Package' [ART_TYPE_DESC]
           ,ALERT_PRIORITY
           ,'Artifact execution exceeding than normal expected time and is still running. Run Time is: ' + CAST(CONVERT(TIME(0), DATEADD(SS,RUN_TIME,0),108) AS VARCHAR(100)) ALERT_CONTEXT
          ,ART_CTRL_MASTER_ID
           ,ART_NME
           ,NULL
           ,NULL           
           ,'Artifact execution exceeding than normal expected time and is still running. Run Time is: ' + CAST(CONVERT(TIME(0), DATEADD(SS,RUN_TIME,0),108) AS VARCHAR(100)) ERROR_MSG
           ,'AM.USP_ARTIFACT_LONG_RUN_ALERT' MSG_SOURCE
           ,GETDATE()
           ,NULL
		   FROM #Temp_Run WHERE ALERT_PRIORITY IS NOT NULL


		   --Mark the alerted records as sent in  [ARTIFACT_LONG_RUN_ALERT] table.
			UPDATE LR
			SET LR.CRIT_SENT=(CASE WHEN TR.ALERT_PRIORITY='Critical' THEN 1 ELSE LR.CRIT_SENT END)
			, LR.INFO_SENT= (CASE WHEN TR.ALERT_PRIORITY='Critical' AND LR.INFO_SENT=0 THEN 1 
							WHEN TR.ALERT_PRIORITY='Informational' THEN 1  ELSE LR.INFO_SENT END)
			,LST_UPD_DTE=GETDATE()
			FROM [AM].[ARTIFACT_LONG_RUN_ALERT] (NOLOCK) LR JOIN #Temp_Run TR ON LR.ART_CTRL_MASTER_ID=TR.ART_CTRL_MASTER_ID
			WHERE TR.ALERT_PRIORITY IS NOT NULL
END TRY	
BEGIN CATCH
		DECLARE @ProcName AS NVARCHAR(128) = ISNULL(ERROR_PROCEDURE(), 'UNKNOWN');
		DECLARE @ER_NBR AS INTEGER = ISNULL(ERROR_NUMBER(),0)
		DECLARE @ER_LINE AS INTEGER = ISNULL(ERROR_LINE(),0)
		DECLARE @ER_SEV AS INTEGER = ISNULL(ERROR_SEVERITY(),0)
		DECLARE @ER_ST AS INTEGER = ISNULL(ERROR_STATE(),0)
		DECLARE @ER_MSG AS NVARCHAR(4000) = ISNULL(ERROR_MESSAGE(), 'A MESSAGE WAS NOT PROVIDED');
		DECLARE @ER_USR AS VARCHAR(255) = ISNULL(CURRENT_USER, 'UNKONWN')

		 
		--EXECUTE @RTN =  AM.ERR_LOG @ProcName,'',@ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR	
		RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
		
END CATCH;

