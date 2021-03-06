﻿
CREATE PROCEDURE [AM].[USP_UI_CHANGE_ARTIFACT_DEPENDENCY]
	@ART_CTRL_MASTER_ID INTEGER,			--<=Requried
	@REFERENCED_CTRL_MASTER_ID INTEGER,		--<=Requried
	@DEPENDENCY_TYPE_VALUE_ID INTEGER,		--<=Requried
	@DEPENDENCY_SEQUENCE INTEGER = NULL,			--<=Requried
	@RTN AS INTEGER = NULL OUTPUT			--<=Optional - No need to send defaults to 0 and then returns message based on success
	
AS
	
	SET NOCOUNT ON
	
	BEGIN TRY
		DECLARE @LAST_UPDT_DTE DATETIME = GETDATE()
		DECLARE @LAST_UPDT_BY VarChar (100) = SYSTEM_USER
		DECLARE @SQL_STR NVARCHAR(4000)
		DECLARE @PARMDEF NVARCHAR(1000)

		IF @DEPENDENCY_SEQUENCE IS NULL
			BEGIN
				SET @DEPENDENCY_SEQUENCE = 1	
			END 
		
		DECLARE @x INTEGER
			


		SET @X = (SELECT COUNT(ART_CTRL_MASTER_ID) FROM AM.ARTIFACT_DEPENDENCY WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID AND REFERENCED_CTRL_MASTER_ID = @REFERENCED_CTRL_MASTER_ID)	
		IF @X <> 1
			BEGIN 
				RAISERROR ('No matching records found with this ART_CTRL_MASTER_ID and REFERENCED_CTRL_MASTER_ID' ,16, 1)
			END	
      
		SET @x = 0
		SET @SQL_STR = N'UPDATE AM.ARTIFACT_DEPENDENCY SET '

		IF @DEPENDENCY_TYPE_VALUE_ID IS NOT NULL 
			BEGIN
				SET @SQL_STR = @SQL_STR + N'DEPENDENCY_TYPE_VALUE_ID = @DEPENDENCY_TYPE_VALUE_ID, ' 
				SET @X = @X + 1  
			END 

		IF @DEPENDENCY_SEQUENCE IS NOT NULL 
			BEGIN 
				SET @SQL_STR = @SQL_STR + N'DEPENDENCY_SEQUENCE = @DEPENDENCY_SEQUENCE, ' 
				
				SET @X = @X + 1 
			END

		If @X = 0
			BEGIN 
				--Raise Error
				RAISERROR ('You must update at least one field',16,1)
			END

		SET @SQL_STR = @SQL_STR + N'LAST_UPDT_DTE = @LAST_UPDT_DTE, '
		SET @SQL_STR = @SQL_STR + N'LAST_UPDT_BY = @LAST_UPDT_BY '
		SET @SQL_STR = @SQL_STR + N'WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID '
		SET @SQL_STR = @SQL_STR + N'AND REFERENCED_CTRL_MASTER_ID = @REFERENCED_CTRL_MASTER_ID'


		SET @PARMDEF = N'@DEPENDENCY_TYPE_VALUE_ID INTEGER, @DEPENDENCY_SEQUENCE INTEGER, @LAST_UPDT_DTE DATETIME, 
						@LAST_UPDT_BY VARCHAR(50), @ART_CTRL_MASTER_ID INTEGER, @REFERENCED_CTRL_MASTER_ID INTEGER'

		--Execute  sp_executesql @SQL_STR, @PARMDEF, @PARMVAL
		Execute  sp_executesql @SQL_STR, @PARMDEF, 
				@ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID,
				@REFERENCED_CTRL_MASTER_ID = @REFERENCED_CTRL_MASTER_ID,
				@DEPENDENCY_TYPE_VALUE_ID = @DEPENDENCY_TYPE_VALUE_ID,
				@DEPENDENCY_SEQUENCE = @DEPENDENCY_SEQUENCE,
				@LAST_UPDT_DTE = @LAST_UPDT_DTE,
				@LAST_UPDT_BY = @LAST_UPDT_BY

		SET @RTN = 1
		RETURN @RTN --Positive Return
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

		 EXECUTE @RTN =  AM.USP_ERR_LOG @ProcName, @ER_PLAT, @ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR	
		 RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
	END CATCH;





