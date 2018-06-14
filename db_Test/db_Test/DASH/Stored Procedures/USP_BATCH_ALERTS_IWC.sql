

CREATE PROCEDURE [DASH].[USP_BATCH_ALERTS_IWC]
as

SET NOCOUNT ON

BEGIN
	SELECT ISNULL(Informational,0) Informational, ISNULL(Warning,0) Warning,  isnull(Critical, 0) Critical
	FROM [DASH].[v_BATCH_ALTERS_IWC]
END
 



