﻿CREATE PROCEDURE [DASH].[USP_BATCH_SCHD_AVGS]
AS

SET NOCOUNT ON
BEGIN
	SELECT [SCHEDULE_TYPE_VALUE_ID], [CODE_VALUE_DESC], [AVG], [CUR], [ElapsedTime]
	FROM [DASH].[v_BATCH_SCHD_AVGS]
	ORDER BY [SCHEDULE_TYPE_VALUE_ID]
END 

