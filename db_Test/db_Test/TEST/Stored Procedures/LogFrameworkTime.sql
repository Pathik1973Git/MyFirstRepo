-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [TEST].[LogFrameworkTime]
	-- Add the parameters for the stored procedure here
	@Start_Time varchar(200),--DateTime,
	@End_Time varchar(200)--DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--Insert into [TEST].[FRAMEWORK_TIME] values(CAST(@Start_Time AS varchar(200)), CAST(@End_Time  AS varchar(200)))
	Insert into [TEST].[FRAMEWORK_TIME] values(@Start_Time, @End_Time)
END
