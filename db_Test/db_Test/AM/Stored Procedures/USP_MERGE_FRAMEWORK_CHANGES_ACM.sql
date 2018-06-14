﻿CREATE PROCEDURE [AM].[USP_MERGE_FRAMEWORK_CHANGES_ACM]
@CHANGE_ID INT,
@CHANGE_LOAD_ID INT
AS

BEGIN 

SET IDENTITY_INSERT AM.ARTIFACT_CTRL_MASTER ON 

MERGE INTO AM.ARTIFACT_CTRL_MASTER AS target
USING
(SELECT * 
 FROM AM.STAGE_ARTIFACT_CTRL_MASTER
 WHERE ART_CTRL_MASTER_ID IN
 (SELECT ART_CTRL_MASTER_ID FROM CHG.STAGE_CHANGE_CONTROL_ARTIFACT 
  WHERE CHG_ID = @CHANGE_ID AND IS_ACTIVE_IND = 1 AND LAST_CHG_LOAD_ID =  @CHANGE_LOAD_ID ) ) AS source
 ON (target.ART_CTRL_MASTER_ID = source.ART_CTRL_MASTER_ID)

 WHEN MATCHED THEN
 UPDATE SET
 target.ART_NME = source.ART_NME,
 target.ART_PROCESS_DESC = source.ART_PROCESS_DESC,
 target.ART_TYPE_VALUE_ID = source.ART_TYPE_VALUE_ID,
 target.ART_SCALE_VALUE = source.ART_SCALE_VALUE,
 target.ART_GROUP_VALUE_ID = source.ART_GROUP_VALUE_ID,
 target.ART_LAYER_VALUE_ID = source.ART_LAYER_VALUE_ID,
 target.SOURCE_SYSTEM_VALUE_ID = source.SOURCE_SYSTEM_VALUE_ID,
 target.SCHEDULE_TYPE_VALUE_ID = source.SCHEDULE_TYPE_VALUE_ID,
target.SCHEDULE_MODE_VALUE_ID = source.SCHEDULE_MODE_VALUE_ID,
target.SCHEDULE_RUN_TIME = source.SCHEDULE_RUN_TIME,
target.ART_BATCH_RETRY_THRESHOLD = source.ART_BATCH_RETRY_THRESHOLD,
target.ART_BATCH_RETRY_COUNTER = source.ART_BATCH_RETRY_COUNTER,
target.NEXT_PROCESS_TYPE_VALUE_ID = source.NEXT_PROCESS_TYPE_VALUE_ID,
target.NEXT_PROCESS_DATE_TIME = source.NEXT_PROCESS_DATE_TIME,
target.LOAD_TARGET_NME = source.LOAD_TARGET_NME,
target.LAST_LOAD_ID = source.LAST_LOAD_ID,
target.LAST_EXEC_ID = source.LAST_EXEC_ID,
target.LAST_EXEC_STATUS_VALUE_ID  = source.LAST_EXEC_STATUS_VALUE_ID ,
target.LAST_BATCH_DTE  = source.LAST_BATCH_DTE ,
target.LAST_PROCESS_DTE  = source.LAST_PROCESS_DTE ,
target.LAST_STATUS_CODE_VALUE_ID = source.LAST_STATUS_CODE_VALUE_ID,
target.IS_STATUS_VALIDATED  = source.IS_STATUS_VALIDATED ,
target.LAST_START_TIME  = source.LAST_START_TIME ,
target.LAST_END_TIME  = source.LAST_END_TIME ,
target.LAST_SOURCE_NME  = source.LAST_SOURCE_NME ,
target.LAST_MESSAGE = source.LAST_MESSAGE,
target.IS_ENABLED_IND  = source.IS_ENABLED_IND ,
target.CREATED_DTE = source.CREATED_DTE,
target.CREATED_BY = source.CREATED_BY,
target.LAST_UPDT_DTE = getdate(),	 --current date
target.LAST_UPDT_BY  = CURRENT_USER , -- current user
target.LAST_CHG_LOAD_ID = @CHANGE_LOAD_ID 

WHEN NOT MATCHED BY TARGET THEN        
INSERT(ART_CTRL_MASTER_ID,ART_NME  ,ART_PROCESS_DESC,ART_TYPE_VALUE_ID   ,ART_SCALE_VALUE , ART_GROUP_VALUE_ID,ART_LAYER_VALUE_ID,SOURCE_SYSTEM_VALUE_ID,SCHEDULE_TYPE_VALUE_ID, SCHEDULE_MODE_VALUE_ID,SCHEDULE_RUN_TIME,ART_BATCH_RETRY_THRESHOLD,ART_BATCH_RETRY_COUNTER,NEXT_PROCESS_TYPE_VALUE_ID,NEXT_PROCESS_DATE_TIME,LOAD_TARGET_NME,LAST_LOAD_ID,LAST_EXEC_ID,LAST_EXEC_STATUS_VALUE_ID ,LAST_BATCH_DTE ,LAST_PROCESS_DTE ,LAST_STATUS_CODE_VALUE_ID,IS_STATUS_VALIDATED ,LAST_START_TIME ,LAST_END_TIME ,LAST_SOURCE_NME ,LAST_MESSAGE,IS_ENABLED_IND ,CREATED_DTE,CREATED_BY,LAST_UPDT_DTE,LAST_UPDT_BY ,LAST_CHG_LOAD_ID)
VALUES(ART_CTRL_MASTER_ID,ART_NME  ,ART_PROCESS_DESC,ART_TYPE_VALUE_ID   ,ART_SCALE_VALUE        ,ART_GROUP_VALUE_ID,ART_LAYER_VALUE_ID,SOURCE_SYSTEM_VALUE_ID,SCHEDULE_TYPE_VALUE_ID, SCHEDULE_MODE_VALUE_ID,SCHEDULE_RUN_TIME,ART_BATCH_RETRY_THRESHOLD,ART_BATCH_RETRY_COUNTER,NEXT_PROCESS_TYPE_VALUE_ID,NEXT_PROCESS_DATE_TIME,LOAD_TARGET_NME,LAST_LOAD_ID,LAST_EXEC_ID,LAST_EXEC_STATUS_VALUE_ID ,LAST_BATCH_DTE ,LAST_PROCESS_DTE ,LAST_STATUS_CODE_VALUE_ID,IS_STATUS_VALIDATED ,LAST_START_TIME ,LAST_END_TIME ,LAST_SOURCE_NME ,LAST_MESSAGE,IS_ENABLED_IND , getdate(),CURRENT_USER,NULL,NULL ,@CHANGE_LOAD_ID)

;
SET IDENTITY_INSERT AM.ARTIFACT_CTRL_MASTER OFF

END
