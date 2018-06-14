﻿

CREATE VIEW [DASH].[v_BATCH_SCHD_COUNTS] 
AS
  SELECT B.SCHEDULE_TYPE_VALUE_ID, CNT, isnull(Complete,0) As Complete
  FROM AM.BATCH_CTRL_MASTER B
	LEFT JOIN 
		(
		SELECT SCHEDULE_TYPE_VALUE_ID, COUNT(1) as CNT
		FROM AM.ARTIFACT_CTRL_MASTER
		GROUP BY SCHEDULE_TYPE_VALUE_ID
		) X ON X.SCHEDULE_TYPE_VALUE_ID = B.SCHEDULE_TYPE_VALUE_ID 
	LEFT JOIN 
		(
		SELECT SCHEDULE_TYPE_VALUE_ID, COUNT(1) as Complete
		FROM AM.ARTIFACT_CTRL_MASTER
        WHERE LAST_STATUS_CODE_VALUE_ID = 2
		GROUP BY SCHEDULE_TYPE_VALUE_ID
		) Y ON Y.SCHEDULE_TYPE_VALUE_ID = B.SCHEDULE_TYPE_VALUE_ID 
  WHERE START_DTE >= DATEADD(dd,- 7,GetDate())
    


