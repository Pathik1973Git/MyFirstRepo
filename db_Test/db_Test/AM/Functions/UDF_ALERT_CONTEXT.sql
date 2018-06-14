



CREATE FUNCTION [AM].[UDF_ALERT_CONTEXT]
	(
	@RETRY_COUNT INTEGER,
	@RETRY_THRESHOLD INTEGER,
	@RUN_MODE INTEGER
	)
	RETURNS VARCHAR(400)
	
	AS 
	
	BEGIN
		DECLARE @ALERT_TYPE VARCHAR(100)
		DECLARE @ALERT_CONTEXT VARCHAR(300)
		DECLARE @RTN as VARCHAR(400)
		DECLARE @ALERT_REMAINGING_TRIES INTEGER

		SET @ALERT_REMAINGING_TRIES = @RETRY_THRESHOLD - @RETRY_COUNT


				
				
				--Sets the Alert Type and Context (Explanation of the Alert)
				--If the second or Multiple executions fails and the records is in an error state
				IF @ALERT_REMAINGING_TRIES >= 2
					BEGIN
						SET @ALERT_TYPE = 'Informational' 
						SET @ALERT_CONTEXT = CONCAT('Multiple Execution Attempts Have Failed - (', @RETRY_COUNT, ' Attempts of ', @RETRY_THRESHOLD,' Attempt(s) Have Failed)')
					END

				--Sets the Alert Type and Context (Explanation of the Alert)
				--If the first execution fails and the records is in an error state
				IF @ALERT_REMAINGING_TRIES >= 2 and @RETRY_COUNT = 1 
					BEGIN
						SET @ALERT_TYPE = 'Informational' 
						SET @ALERT_CONTEXT = CONCAT('First Execution Attempt Failed - (', @RETRY_COUNT, ' Attempt of ', @RETRY_THRESHOLD, ' Attempts Have Failed)')
					END
			
				

				--Sets the Alert Type and Context (Explanation of the Alert)
				--IF only one attempt is remaining, this will override the priror two attempts to set varibles. (will override mutliple attempts message)
				IF @ALERT_REMAINGING_TRIES = 1
					BEGIN
						SET @ALERT_TYPE = 'Warning' 
						SET @ALERT_CONTEXT = CONCAT('One Attempt Remaining - (', @RETRY_COUNT, ' Attempts of ', @RETRY_THRESHOLD, ' Attempts Have Failed)')
					END

				--Sets the Alert Type and Context (Explanation of the Alert)
				--IF run manually this will catch the error  
				IF  @RETRY_COUNT <= 0 and @RUN_MODE = 51
					BEGIN
						SET @ALERT_TYPE = 'Informational'  
						SET @ALERT_CONTEXT = CONCAT('A Manual Attempt Failed - (', @RETRY_COUNT, ' Attempts of ', @RETRY_THRESHOLD, ' Attempt(s) Have Failed)')
		 			END;
	
				--Sets the Alert Type and Context (Explanation of the Alert)
				--IF only one attempt is remaining, this will override the first two attempts to set varibles.  
				IF @ALERT_REMAINGING_TRIES <=0
					BEGIN
						SET @ALERT_TYPE = 'Critical' 
						SET @ALERT_CONTEXT = CONCAT('**Final Alert! The Last Attempt Failed - (', @RETRY_COUNT, ' Attempts of ', @RETRY_THRESHOLD, ' Attempt(s) Have Failed)')
		 			END;
				

		SET @RTN = CONCAT(@ALERT_TYPE,'|', @ALERT_CONTEXT)
		RETURN @RTN
	END

