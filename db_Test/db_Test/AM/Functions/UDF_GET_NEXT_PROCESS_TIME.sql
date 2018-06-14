
--****************************************************************************************************************************************
--****** UDF_GET_NEXT_PROCESS_TIME ** CREATED: 11/27/2016 ********************************************************************************
--****************************************************************************************************************************************
--** This function gets calclates the next process date time during inizlization.           									    	**
--** Uses informaiton provided as  well as AM.ENVIRONMENT_VAR_BATCH varibles  to dertermine if the next batch date is today or tomorrow **
--****************************************************************************************************************************************

CREATE FUNCTION [AM].[UDF_GET_NEXT_PROCESS_TIME] (@ART_CTRL_MASTER_ID INT, @SCHEDULE_TYPE_VALUE_ID Int)
	
	RETURNS DATETIME
	
	AS

BEGIN
	--TEST DATES
	 --SELECT BCM.START_DTE  FROM AM.BATCH_CTRL_MASTER BCM WHERE BCM.SCHEDULE_TYPE_VALUE_ID = 31
	 --SELECT CAST(CONCAT(DATEPART(hh,BCM.START_DTE), ':', DATEPART(mi,BCM.START_DTE), ':', DATEPART(ss,BCM.START_DTE)) As TIme(0)) AS 'START_TIME' FROM AM.BATCH_CTRL_MASTER BCM WHERE BCM.SCHEDULE_TYPE_VALUE_ID = 31
	 --SELECT ACM.LAST_BATCH_DTE FROM AM.ARTIFACT_CTRL_MASTER ACM WHERE ACM.ART_CTRL_MASTER_ID = 1001		
	 --SELECT ACM.SCHEDULE_RUN_TIME FROM AM.ARTIFACT_CTRL_MASTER ACM WHERE ACM.ART_CTRL_MASTER_ID = 1001
	 --SELECT VB.SLA_TIME FROM AM.ENVIRONMENT_VAR_BATCH VB WHERE VB.SCHEDULE_TYPE_VALUE_ID = 32
	
	DECLARE @NEXT_PROCESS_DATE_TIME DATETIME = NULL
	DECLARE @BATCH_START_TIME TIME(0) = (SELECT CAST(CONCAT(DATEPART(hh,BCM.START_DTE), ':', DATEPART(mi,BCM.START_DTE), ':', DATEPART(ss,BCM.START_DTE)) As TIme(0)) AS 'START_TIME' FROM AM.BATCH_CTRL_MASTER BCM WHERE BCM.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
	DECLARE @BATCH_SLA_TIME  TIME(0) = (SELECT VB.SLA_TIME FROM AM.ENVIRONMENT_VAR_BATCH VB WHERE VB.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
	DECLARE @SCHEDULE_RUN_TIME TIME(0) = (SELECT ACM.SCHEDULE_RUN_TIME FROM AM.ARTIFACT_CTRL_MASTER ACM WHERE ACM.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
	DECLARE @BATCH_DATE Date =	(SELECT ACM.LAST_BATCH_DTE FROM AM.ARTIFACT_CTRL_MASTER ACM WHERE ACM.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
	DECLARE @HAS_MULTIPLE_BATCHES BIT = (SELECT VB.HAS_MULTIPLE_BATCHES FROM AM.ENVIRONMENT_VAR_BATCH VB WHERE VB.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)

	IF @SCHEDULE_TYPE_VALUE_ID IS NULL
		BEGIN
			SET @SCHEDULE_TYPE_VALUE_ID = (SELECT ACM.SCHEDULE_TYPE_VALUE_ID FROM AM.ARTIFACT_CTRL_MASTER ACM WHERE ACM.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
		END


	IF @SCHEDULE_RUN_TIME IS NULL OR @BATCH_DATE IS NULL OR @BATCH_START_TIME IS NULL
		BEGIN
			-- Defualt the next runtime to current date time
			SET @NEXT_PROCESS_DATE_TIME = GETDATE()
		END
	ELSE
		-- Defualt all batch end dates (less 31) to and SLA of 10 AM
		SET @BATCH_SLA_TIME = (SELECT VB.SLA_TIME FROM AM.ENVIRONMENT_VAR_BATCH VB WHERE VB.SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
		BEGIN 
			SELECT @NEXT_PROCESS_DATE_TIME = 
			CASE
				-- Next runtime = NULL because runtimes can't be set for multiple batches - this has be handled by the job that inizalizes batch not to inialize before the epxected times
				WHEN @HAS_MULTIPLE_BATCHES = 1
					THEN  GETDATE()
					
				-- Next runtime is the same day as  batch date at the specified time
				WHEN @SCHEDULE_RUN_TIME >= @BATCH_START_TIME AND @SCHEDULE_RUN_TIME < '23:59:59.0000000' 
					THEN CAST(CONCAT(dateadd(dd,0,@BATCH_DATE), ' ',  @SCHEDULE_RUN_TIME) as DATETIME)
				
				-- Next runtime is the day after batch date at the specified time
				WHEN @SCHEDULE_RUN_TIME >= '12 AM' AND @SCHEDULE_RUN_TIME <= @BATCH_SLA_TIME 
					THEN  CAST(CONCAT(dateadd(dd,1,@BATCH_DATE), ' ',@SCHEDULE_RUN_TIME) as DATETIME)
				
				-- Defualt the next runtime to current date time - this shouldn't happen. 
				ELSE  GETDATE()
			END -- Case
		END -- Else
	
	-- Send Return
	RETURN @NEXT_PROCESS_DATE_TIME

END

