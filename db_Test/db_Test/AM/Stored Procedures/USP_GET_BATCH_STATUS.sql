-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE AM.USP_GET_BATCH_STATUS 
	-- Add the parameters for the stored procedure here
	@batch_Id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select
		LAST_STATUS_CODE_VALUE_ID
		,count(1)
	from 
		AM.ARTIFACT_CTRL_MASTER
	where SCHEDULE_TYPE_VALUE_ID = @batch_Id
	group by LAST_STATUS_CODE_VALUE_ID
END
