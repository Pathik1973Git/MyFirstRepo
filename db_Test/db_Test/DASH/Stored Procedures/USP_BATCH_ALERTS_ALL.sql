﻿CREATE PROCEDURE [DASH].[USP_BATCH_ALERTS_ALL]
AS

SET NOCOUNT ON

BEGIN
	SELECT ISNULL(TotalAlerts,0) TotalAlerts
	FROM [DASH].[v_BATCH_ALERTS_ALL]
END
