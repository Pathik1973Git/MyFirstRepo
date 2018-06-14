﻿CREATE PROCEDURE [AM].[USP_MERGE_FRAMEWORK_CHANGES_AP]
@CHANGE_ID INT,
@CHANGE_LOAD_ID INT
AS

BEGIN 

MERGE INTO AM.ARTIFACT_PARAMETER AS target
USING
(SELECT * 
FROM  [AM].[STAGE_ARTIFACT_PARAMETER]
 WHERE ART_CTRL_MASTER_ID IN
 (SELECT ART_CTRL_MASTER_ID FROM CHG.STAGE_CHANGE_CONTROL_ARTIFACT 
  WHERE CHG_ID = @CHANGE_ID AND IS_ACTIVE_IND = 1 AND LAST_CHG_LOAD_ID =  @CHANGE_LOAD_ID ) ) AS source
  ON (target.ART_CTRL_MASTER_ID = source.ART_CTRL_MASTER_ID AND target.PARM_ID  = source.PARM_ID)

  WHEN MATCHED THEN
 UPDATE SET
-- target.ART_CTRL_MASTER_ID = source.ART_CTRL_MASTER_ID,
-- target.PARM_ID  = source.PARM_ID ,
target.LOAD_ID  = source.LOAD_ID ,
target.PARM_NME = source.PARM_NME,
target.PARM_VALUE_DATA_TYPE_CODE  = source.PARM_VALUE_DATA_TYPE_CODE ,
target.PARM_CHAR_VALUE = source.PARM_CHAR_VALUE,
target.PARM_INT_VALUE = source.PARM_INT_VALUE,
target.PARM_DTE_VALUE = source.PARM_DTE_VALUE,
target.PARM_DESC  = source.PARM_DESC ,
target.IS_ENABLED_IND  = source.IS_ENABLED_IND ,
target.CREATED_DTE  = source.CREATED_DTE ,
target.CREATED_BY  = source.CREATED_BY ,
target.LAST_UPDT_DTE = getdate(), --current date
target.LAST_UPDT_BY = CURRENT_USER, -- current user
target.LAST_CHG_LOAD_ID = @CHANGE_LOAD_ID 


WHEN NOT MATCHED BY TARGET THEN        
INSERT(ART_CTRL_MASTER_ID,PARM_ID ,LOAD_ID ,PARM_NME,PARM_VALUE_DATA_TYPE_CODE ,PARM_CHAR_VALUE,PARM_INT_VALUE,PARM_DTE_VALUE,PARM_DESC ,IS_ENABLED_IND ,CREATED_DTE ,CREATED_BY ,LAST_UPDT_DTE,LAST_UPDT_BY,LAST_CHG_LOAD_ID)
VALUES(ART_CTRL_MASTER_ID,PARM_ID ,LOAD_ID ,PARM_NME,PARM_VALUE_DATA_TYPE_CODE ,PARM_CHAR_VALUE,PARM_INT_VALUE,PARM_DTE_VALUE,PARM_DESC ,IS_ENABLED_IND ,GETDATE() ,CURRENT_USER ,NULL,NULL,@CHANGE_LOAD_ID)

;

END