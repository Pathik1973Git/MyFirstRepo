--********************************************************************************************************************************
--****** UDF_GET_RETRY_DELAY ** CREATED: 11/27/2016 ******************************************************************************
--********************************************************************************************************************************
--** This funciton sets the delay for retries by incrimenting NEXT_PROCESS_DATE_TIME in minutes									**
--**    based on the setting in AM.ENVIRONMENT_VAR_BATCH for that SCHEDULE_TYPE_VALUE_ID.										**
--**	Retries happen if a package errors for some reason, see the ACM for ART_BATCH_RETRY_COUNTER								**
--** Next schedule times can be have an optional re-run delay by schedule type.													**
--**   This allows some time in case of issues such as time outs occur, so the package doesn't get executed immeadeatly again   **
--********************************************************************************************************************************

CREATE FUNCTION [AM].[UDF_GET_RETRY_DELAY]
	(@SCHEDULE_TYPE_VALUE_ID INT)
	RETURNS DATETIME
	
	AS
	
	BEGIN

		DECLARE @NEXT_PROCESS_DATE_TIME DATETIME = NULL
		DECLARE @DELAY_IN_MINUTES INT = NULL
		
		-- GET THE DELAY FROM AM.ENVIRONMENT_VAR_BATCH, This the standard delay in minutes for any package execution retry for that SCHEDULE_TYPE_VALUE_ID 
		SET @DELAY_IN_MINUTES = (SELECT VB.RETRY_DELAY_MINUTES FROM AM.ENVIRONMENT_VAR_BATCH VB WHERE SCHEDULE_TYPE_VALUE_ID = @SCHEDULE_TYPE_VALUE_ID)
		

		IF @DELAY_IN_MINUTES IS NULL
			BEGIN
				-- If null the schedule wasn't set up in the enviornment variable, defualt to current DateTime
				SET @NEXT_PROCESS_DATE_TIME = GETDATE()
			END
		ELSE
			BEGIN
				-- Add the delay to the current datetime so the package will not execute right away. 
				SET @NEXT_PROCESS_DATE_TIME = DATEADD(MINUTE, @DELAY_IN_MINUTES, GETDATE())
			END

		RETURN @NEXT_PROCESS_DATE_TIME
	END
