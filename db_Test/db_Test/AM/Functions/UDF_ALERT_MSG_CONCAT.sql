
CREATE FUNCTION [AM].[UDF_ALERT_MSG_CONCAT]
	(@EXEC_ID INTEGER
	
	)
	RETURNS VARCHAR(5000)
AS 
BEGIN
	
	DECLARE @ALERT_MSG AS VARCHAR(5000);
					
				--Pulls a message from the the execution for the control flow
								WITH CTE_CTL_FLOW AS
					(
					SELECT TOP 1 CONCAT('CONTROL FLOW MESSAGE - ', EM.message) AS CONCAT_MESSAGE, EM.message_source_name    
					FROM SSISDB.catalog.event_messages EM (NOLOCK)
					WHERE EM.operation_id = @EXEC_ID
						AND EM.message_source_type = 60
						AND EM.event_name = 'OnError'
					)

				--Pulls a message from the the execution for the data flow
				,CTE_DATA_FLOW AS
					(

					SELECT TOP 1 CONCAT('||','DATA FLOW MESSAGE - ', EM.message) AS CONCAT_MESSAGE, EM.message_source_name   
					FROM SSISDB.catalog.event_messages EM (NOLOCK)
					WHERE EM.operation_id = @EXEC_ID
						AND EM.message_source_type = 40
						AND EM.event_name = 'OnError'
					)

				--Pulls a message from the the execution for the PACKAGE-LEVEL-OBJECTS
				,CTE_OBJECT_LEVEL AS				
					(
					SELECT TOP 1 CONCAT('||', 'PACKAGE-LEVEL-OBJECTS MESSAGE - ',EM.message) AS CONCAT_MESSAGE, EM.message_source_name    
					FROM SSISDB.catalog.event_messages EM (NOLOCK)
					WHERE EM.operation_id = @EXEC_ID
						AND EM.message_source_type = 30
						AND EM.event_name = 'OnError'
					)

				-- CONCATS the messages if a message exists for each level into a single column and row entry
				-- Takes the first non null message_source_name (Usually these are all the same for each OnError record in the SSIS DB Message Catalog

				,CTE_ALL_MSG AS
					(
					SELECT CONCAT((SELECT CONCAT_MESSAGE FROM CTE_CTL_FLOW),(SELECT CONCAT_MESSAGE FROM CTE_DATA_FLOW),(SELECT CONCAT_MESSAGE FROM CTE_OBJECT_LEVEL)) AS FULL_MSG, 
					COALESCE((SELECT message_source_name FROM CTE_CTL_FLOW),(SELECT message_source_name FROM CTE_DATA_FLOW),(SELECT message_source_name FROM CTE_OBJECT_LEVEL))  AS 'MESSAGE_SOURCE'
					)	
					
					--Sets the alert and message soruce varibles
					SELECT @ALERT_MSG = LTRIM(LEFT(FULL_MSG,5000)) FROM  CTE_ALL_MSG

	RETURN @ALERT_MSG
END


