﻿
	CREATE Procedure [AM].[USP_PKG_ON_COMPLETE] 
	@ART_CTRL_MASTER_ID Int, 
	@EXEC_ID as Int,
	@SOURCE_NME as VarChar (100) = NULL,
	@SOURCE_TOTAL_RECORDS decimal(10,0) = null,
	@SOURCE_NEW_RECORDS  decimal(10,0) = null,
	@SOURCE_CHANGE_RECORDS  decimal(10,0) = null,
	@SOURCE_DELETE_RECORDS  decimal(10,0) = null,
	@TARGET_TOTAL_RECORDS_BEFORE decimal(10,0) = null,
	@TARGET_NEW_RECORDS decimal(10,0) = null,
	@TARGET_CHANGE_RECORDS decimal(10,0) = null,
	@TARGET_DELETE_RECORDS decimal(10,0) = null,
	@TARGET_UNCHANGED_RECORDS decimal(10,0) = null,
	@TARGET_FAILED_RECORDS decimal(10,0) = null,
	@TARGET_TOTAL_RECORDS_AFTER decimal(10,0) = null,
	@TARGET_NME as Varchar(100) = NULL,
	@START_TIME as varchar(200), -- load start time
	@END_TIME as varchar(200), -- load end time
	@IS_INCREMENTAL bit,
	@RTN INT = Null OUTPUT

	AS
		
	BEGIN TRY
		DECLARE @LOAD_ID INTEGER
		DECLARE @SCHEDULE_TYPE_VALUE_ID INTEGER
		DECLARE @BATCH_DTE DATE
		DECLARE @ART_GROUP_VALUE_ID tinyint
		DECLARE @ART_NME varchar(100)
		DECLARE @ART_PROCESS_DESC varchar(1000)
		DECLARE @ART_BATCH_RETRY_COUNTER TinyInt
		DECLARE @ART_BATCH_RETRY_THRESHOLD TinyInt
		DECLARE @PKG_START_TIME DATETIME
		DECLARE @PKG_END_TIME DATETIME = GETDATE()
		DECLARE @LOAD_MESSAGE VarChar (200) = 'Package Execution Completed - EXEC MODE '

	
		SELECT @ART_NME = ART_NME, 	@ART_GROUP_VALUE_ID = ART_GROUP_VALUE_ID, @ART_PROCESS_DESC = ART_PROCESS_DESC, @PKG_START_TIME = LAST_PROCESS_DTE, @SCHEDULE_TYPE_VALUE_ID = SCHEDULE_TYPE_VALUE_ID,
			@ART_BATCH_RETRY_COUNTER = ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD = ART_BATCH_RETRY_THRESHOLD, @LOAD_ID = LAST_LOAD_ID, @BATCH_DTE = LAST_BATCH_DTE
		FROM [AM].[ARTIFACT_CTRL_MASTER]
		WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID	

		IF @SOURCE_NME IS NULL
		BEGIN
			SET @SOURCE_NME = (SELECT CM.LAST_SOURCE_NME FROM AM.ARTIFACT_CTRL_MASTER CM WHERE CM.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
		END

		IF @TARGET_NME IS NULL
		BEGIN
			SET @TARGET_NME = (SELECT CM.LOAD_TARGET_NME FROM AM.ARTIFACT_CTRL_MASTER CM WHERE CM.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
		END

		UPDATE AM.ARTIFACT_CTRL_MASTER
			SET 
			LAST_EXEC_ID = @EXEC_ID,
			LAST_STATUS_CODE_VALUE_ID = 2, 
			LAST_END_TIME = @PKG_END_TIME, 
			LAST_MESSAGE = @LOAD_MESSAGE,
			LAST_SOURCE_NME = @SOURCE_NME,
			LOAD_TARGET_NME = @TARGET_NME,
			IS_STATUS_VALIDATED = 0,
			LOAD_START_VALUE = @START_TIME,
			LOAD_END_VALUE	 = @END_TIME,
			IS_INCREMENTAL_LOAD = @IS_INCREMENTAL
		WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID

	INSERT INTO  AM.ARTIFACT_CTRL_DETAIL
		(
		ART_CTRL_MASTER_ID, ART_NME, EXEC_ID, LOAD_ID, STATUS_CODE_VALUE_ID, ART_GROUP_VALUE_ID, 
		ART_PROCESS_DESC, BATCH_DTE, ART_BATCH_RETRY_COUNTER, ART_BATCH_RETRY_THRESHOLD, START_TIME, END_TIME
		,SOURCE_NME,SOURCE_TOTAL_RECORDS,SOURCE_NEW_RECORDS,SOURCE_CHANGE_RECORDS,SOURCE_DELETE_RECORDS
		,TARGET_NME,TARGET_TOTAL_RECORDS_BEFORE,TARGET_NEW_RECORDS,TARGET_CHANGE_RECORDS,TARGET_DELETE_RECORDS
		,TARGET_UNCHANGED_RECORDS,TARGET_FAILED_RECORDS,TARGET_TOTAL_RECORDS_AFTER
		,LOAD_MESSAGE,USER_OSUSER ,CREATED_DTE, IS_INCREMENTAL_LOAD, LOAD_START_VALUE,LOAD_END_VALUE
		)
 
	 Values
		(
		@ART_CTRL_MASTER_ID, @ART_NME, @EXEC_ID, @LOAD_ID, 2, @ART_GROUP_VALUE_ID, 
		@ART_PROCESS_DESC, @BATCH_DTE, @ART_BATCH_RETRY_COUNTER, @ART_BATCH_RETRY_THRESHOLD, @PKG_START_TIME, @PKG_END_TIME
		,@SOURCE_NME,@SOURCE_TOTAL_RECORDS,@SOURCE_NEW_RECORDS,@SOURCE_CHANGE_RECORDS,@SOURCE_DELETE_RECORDS
		,@TARGET_NME,@TARGET_TOTAL_RECORDS_BEFORE,@TARGET_NEW_RECORDS,@TARGET_CHANGE_RECORDS,@TARGET_DELETE_RECORDS
		,@TARGET_UNCHANGED_RECORDS,@TARGET_FAILED_RECORDS,@TARGET_TOTAL_RECORDS_AFTER
		,@LOAD_MESSAGE, SYSTEM_USER, GETDATE(),@IS_INCREMENTAL, @START_TIME, @END_TIME	
		)

		Select @RTN = 1
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
			 --RETURN @RTN --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
		END
	
		RETURN @RTN

	END CATCH;


