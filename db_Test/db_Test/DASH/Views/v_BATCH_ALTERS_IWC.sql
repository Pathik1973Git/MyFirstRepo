



CREATE VIEW [DASH].[v_BATCH_ALTERS_IWC]
AS
SELECT 
	*
  FROM [DASH].[v_ALERTS_OPEN]
  PIVOT
	(
  	  SUM(CNT)
  	  FOR [ALERT_PRIORITY] IN ([Informational],[Warning], [Critical])
	) AS P


