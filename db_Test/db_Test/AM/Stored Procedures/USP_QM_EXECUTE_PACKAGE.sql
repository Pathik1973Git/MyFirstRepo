
CREATE PROCEDURE [AM].[USP_QM_EXECUTE_PACKAGE]

@ART_CTRL_MASTER_ID integer,
@OUTPUT_EXECUTION_ID BIGINT = Null OUTPUT

AS

BEGIN
 
 DECLARE @referenceid tinyint
 DECLARE @FOLDER_NAME VARCHAR(max)
 DECLARE @PROJECT_NAME VARCHAR(max)
 DECLARE @PACKAGE_NAME VARCHAR(max)

 BEGIN TRY

		set @referenceid = 
		(
			SELECT top 1 reference_id
			  FROM  SSISDB.[catalog].environment_references er
				JOIN SSISDB.[catalog].projects p 
					ON p.project_id = er.project_id
				join am.ARTIFACT_CODE_VALUE acv 
					on ltrim(rtrim(p.name)) = ltrim(rtrim(acv.CODE_VALUE_DESC))
				join AM.ARTIFACT_DEPLOYMENT a 
					on a.ART_PROJECT_VALUE_ID = acv.CODE_VALUE_ID
			 WHERE
			a.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID  
	   )

		set @FOLDER_NAME = (select ltrim(rtrim(acv.CODE_VALUE_DESC)) from am.ARTIFACT_CODE_VALUE acv 
				join am.ARTIFACT_DEPLOYMENT ad on ad.ART_FOLDER_VALUE_ID = acv.CODE_VALUE_ID
				where ad.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)

		set @PROJECT_NAME = (select ltrim(rtrim(acv.CODE_VALUE_DESC)) from am.ARTIFACT_CODE_VALUE acv 
				join am.ARTIFACT_DEPLOYMENT a on a.ART_PROJECT_VALUE_ID = acv.CODE_VALUE_ID
				where a.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)

		set @PACKAGE_NAME = (select ltrim(rtrim(ACM.ART_NME)) from am.ARTIFACT_CTRL_MASTER ACM where ACM.ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID) + '.dtsx'

		EXEC [SSISDB].[catalog].[create_execution] @package_name=@PACKAGE_NAME, @execution_id=@OUTPUT_EXECUTION_ID OUTPUT, @folder_name=@FOLDER_NAME, @project_name=@PROJECT_NAME, @use32bitruntime=False, @reference_id = @referenceid

		DECLARE @var0 smallint = 3

		EXEC [SSISDB].[catalog].[set_execution_parameter_value] @OUTPUT_EXECUTION_ID,  @object_type=50, @parameter_name=N'LOGGING_LEVEL', @parameter_value=@var0


		if exists(select * from SSISDB.catalog.executions where execution_id = @OUTPUT_EXECUTION_ID)	
			begin
				EXEC [SSISDB].[catalog].[start_execution] @OUTPUT_EXECUTION_ID
			end				



		IF @OUTPUT_EXECUTION_ID is null 
			BEGIN
				SET @OUTPUT_EXECUTION_ID = 1 
			END

		return @OUTPUT_EXECUTION_ID

END TRY

	BEGIN CATCH
		 DECLARE @RTN as INTEGER = 0
		 DECLARE @ProcName AS NVARCHAR(128) = ISNULL(ERROR_PROCEDURE(), 'UNKNOWN');
		 DECLARE @ER_NBR AS INTEGER = ISNULL(ERROR_NUMBER(),0)
		 DECLARE @ER_LINE AS INTEGER = ISNULL(ERROR_LINE(),0)
		 DECLARE @ER_SEV AS INTEGER = ISNULL(ERROR_SEVERITY(),0)
		 DECLARE @ER_ST AS INTEGER = ISNULL(ERROR_STATE(),0)
		 DECLARE @ER_MSG AS NVARCHAR(4000) = ISNULL(ERROR_MESSAGE(), 'A MESSAGE WAS NOT PROVIDED');
		 DECLARE @ER_USR AS VARCHAR(255) = ISNULL(CURRENT_USER, 'UNKONWN')

		 --SELECT 'ERROR'
		 
		 -- Send and alert on the execution of package failure
		 EXECUTE @RTN = AM.USP_PKG_ON_ERROR_EXEC_ENGINE @ART_CTRL_MASTER_ID
		 
		 -- Return the EXEC ID of the SSIS Package
		 EXECUTE @OUTPUT_EXECUTION_ID =  AM.USP_ERR_LOG @ProcName,'',@ER_NBR, @ER_LINE, @ER_SEV, @ER_ST,@ER_MSG, @ER_USR	
		 RETURN @OUTPUT_EXECUTION_ID --Returns LOG_ID From [AM].[PROCEDURE_ERROR_LOG]  as a negitive integer
		 ROLLBACK
	END CATCH;

END




