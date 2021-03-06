﻿CREATE PROCEDURE [AM].[USP_UI_ADD_ARTIFACT_DEPLOYMENT]
	@ART_CTRL_MASTER_ID INTEGER,
	@ART_DEPLOYMENT_PATH VARCHAR(400) = NULL,
	@ART_FOLDER_VALUE_ID INT = NULL,
	@ART_PROJECT_VALUE_ID INT = NULL,
	@DEPLOYMENT_COMMENTS VARCHAR(1000) = NULL,
	@ART_VALIDATED BIT = NULL,
	@RTN INT = Null OUTPUT

AS

	SET NOCOUNT ON

	DECLARE @IS_ENABLED_IND BIT = 'True'
	DECLARE @CREATED_DTE DATETIME = GETDATE()
	DECLARE @CREATED_BY VARCHAR(50) = SYSTEM_USER
	DECLARE @X AS INTEGER
	DECLARE @Y AS INTEGER

	BEGIN TRY
	
		IF @ART_CTRL_MASTER_ID IS NOT NULL
			BEGIN
				SET @X = (SELECT COUNT(ART_CTRL_MASTER_ID) FROM AM.ARTIFACT_CTRL_MASTER WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
				IF @X <> 1
					BEGIN  
						RAISERROR ('The Master Package does not exist, change cancled' ,16, 1)
					END
				SET @x = 0
			END

		INSERT INTO AM.ARTIFACT_DEPLOYMENT(ART_CTRL_MASTER_ID, ART_DEPLOYMENT_PATH, ART_VALIDATED,
											ART_FOLDER_VALUE_ID,ART_PROJECT_VALUE_ID, 
											DEPLOYMENT_COMMENTS, IS_ENABLED_IND, CREATED_DTE, CREATED_BY) 
					VALUES(@ART_CTRL_MASTER_ID, @ART_DEPLOYMENT_PATH, @ART_VALIDATED,
									@ART_FOLDER_VALUE_ID, @ART_PROJECT_VALUE_ID,  
									@DEPLOYMENT_COMMENTS, @IS_ENABLED_IND, @CREATED_DTE, @CREATED_BY)

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
		 Rollback
	END CATCH;




