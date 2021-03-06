﻿



CREATE VIEW [DASH].[v_ALERTS_24HR_STATUS]
AS
SELECT 
      A.ALERT_ID
	  , IIf(ACM.LAST_STATUS_CODE_VALUE_ID = -1, 'OPEN', 'CLOSED') as 'ALERT_STATUS'
      ,A.LOAD_ID
      ,A.EXECUTION_ID
      ,A.BATCH_DATE
      ,A.ART_TYPE_DESC
      ,A.ALERT_PRIORITY
      ,A.ALERT_CONTEXT
      ,A.ART_CTRL_MASTER_ID
      ,A.ARTIFACT_NAME
      ,A.RETRY_COUNT
      ,A.RETRY_THRESHOLD
      ,A.ERROR_MSG
      ,A.MSG_SOURCE
      ,A.CREATED_DTE
      ,A.MSG_UPDATED_DTE
  FROM AM.ALERTS A
  Left Join (Select ART_CTRL_MASTER_ID, LAST_STATUS_CODE_VALUE_ID  From AM.ARTIFACT_CTRL_MASTER) ACM
  ON ACM.ART_CTRL_MASTER_ID = A.ART_CTRL_MASTER_ID 
  WHERE A.CREATED_DTE >= DATEADD(dd,-1,GetDate())
	AND ACM.ART_CTRL_MASTER_ID <> 998
 

 UNION ALL

 SELECT 
       A.ALERT_ID
	  ,IIf(BM.STATUS_CODE_VALUE_ID = -1, 'OPEN', 'CLOSED') as 'ALERT_STATUS'
	  ,A.LOAD_ID
      ,A.EXECUTION_ID
      ,A.BATCH_DATE
      ,'BATCH' as ART_TYPE_DESC
      ,A.ALERT_PRIORITY
      ,A.ALERT_CONTEXT
      ,A.ART_CTRL_MASTER_ID
      ,A.ARTIFACT_NAME
      ,A.RETRY_COUNT
      ,A.RETRY_THRESHOLD
      ,A.ERROR_MSG
      ,A.MSG_SOURCE
      ,A.CREATED_DTE
      ,A.MSG_UPDATED_DTE
  FROM AM.ALERTS A
  Left Join (Select LOAD_ID, STATUS_CODE_VALUE_ID From AM.BATCH_CTRL_MASTER) BM
  ON BM.LOAD_ID = A.LOAD_ID 
  WHERE A.CREATED_DTE >= DATEADD(dd,-1,GetDate())
	AND A.ART_CTRL_MASTER_ID = 998




