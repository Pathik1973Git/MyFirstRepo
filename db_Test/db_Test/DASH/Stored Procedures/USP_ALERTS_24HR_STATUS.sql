﻿CREATE PROCEDURE [DASH].[USP_ALERTS_24HR_STATUS]
AS

SET NOCOUNT ON

BEGIN
	Select [ALERT_PRIORITY],[CREATED_DTE],[ARTIFACT_NAME], [ART_TYPE_DESC],[RETRY_COUNT],[RETRY_THRESHOLD] 
	FROM [DASH].[v_ALERTS_OPEN_FULL]
	ORDER BY ALERT_PRIORITY ASC
END

