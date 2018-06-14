﻿


CREATE VIEW [DASH].[v_ALERTS_OPEN]
AS
SELECT 
       A.ALERT_PRIORITY,CNT = 1
  FROM AM.ALERTS A
  Join (Select ART_CTRL_MASTER_ID, LAST_LOAD_ID From AM.ARTIFACT_CTRL_MASTER WHERE LAST_STATUS_CODE_VALUE_ID = -1) ACM
  ON ACM.ART_CTRL_MASTER_ID = A.ART_CTRL_MASTER_ID and ACM.LAST_LOAD_ID = A.LOAD_ID 
  WHERE ACM.ART_CTRL_MASTER_ID <> 998
 

 UNION ALL

 SELECT 
       A.ALERT_PRIORITY,CNT = 1
  FROM AM.ALERTS A
  Join (Select LOAD_ID From AM.BATCH_CTRL_MASTER WHERE STATUS_CODE_VALUE_ID = -1) BM
  ON BM.LOAD_ID = A.LOAD_ID 
  WHERE A.ART_CTRL_MASTER_ID = 998
 




