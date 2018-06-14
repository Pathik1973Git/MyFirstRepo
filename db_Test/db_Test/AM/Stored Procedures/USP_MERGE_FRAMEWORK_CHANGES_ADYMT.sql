﻿
CREATE PROCEDURE [AM].[USP_MERGE_FRAMEWORK_CHANGES_ADYMT]
@CHANGE_ID INT,
@CHANGE_LOAD_ID INT
AS

BEGIN 

SET IDENTITY_INSERT AM.ARTIFACT_DEPLOYMENT ON 

MERGE INTO AM.ARTIFACT_DEPLOYMENT AS target
USING
(SELECT * 
 FROM AM.STAGE_ARTIFACT_DEPLOYMENT
 WHERE ART_CTRL_MASTER_ID IN
 (SELECT ART_CTRL_MASTER_ID FROM CHG.STAGE_CHANGE_CONTROL_ARTIFACT 
  WHERE CHG_ID = @CHANGE_ID AND IS_ACTIVE_IND = 1 AND LAST_CHG_LOAD_ID =  @CHANGE_LOAD_ID ) ) AS source
 ON (target.ART_CTRL_MASTER_ID = source.ART_CTRL_MASTER_ID)

 WHEN MATCHED THEN
 UPDATE SET
--target.ART_DEPLOYMENT_ID = source.ART_DEPLOYMENT_ID,
target.ART_CTRL_MASTER_ID = source.ART_CTRL_MASTER_ID,
target.ART_DEPLOYMENT_PATH = source.ART_DEPLOYMENT_PATH,
target.ART_FOLDER_VALUE_ID = source.ART_FOLDER_VALUE_ID,
target.ART_PROJECT_VALUE_ID = source.ART_PROJECT_VALUE_ID,
target.DEPLOYMENT_COMMENTS = source.DEPLOYMENT_COMMENTS,
target.ART_VALIDATED = source.ART_VALIDATED,
target.IS_ENABLED_IND = source.IS_ENABLED_IND,
target.LOAD_ID = source.LOAD_ID,
target.CREATED_DTE = source.CREATED_DTE,
target.CREATED_BY = source.CREATED_BY,
target.LAST_UPDT_DTE = getdate(),	 --current date
target.LAST_UPDT_BY = CURRENT_USER , -- current user
target.LAST_CHG_LOAD_ID = @CHANGE_LOAD_ID 

WHEN NOT MATCHED BY TARGET THEN        
INSERT(ART_DEPLOYMENT_ID,ART_CTRL_MASTER_ID,ART_DEPLOYMENT_PATH,ART_FOLDER_VALUE_ID,ART_PROJECT_VALUE_ID,DEPLOYMENT_COMMENTS,ART_VALIDATED,IS_ENABLED_IND,LOAD_ID,CREATED_DTE,CREATED_BY,LAST_UPDT_DTE,LAST_UPDT_BY,LAST_CHG_LOAD_ID)
VALUES(ART_DEPLOYMENT_ID,ART_CTRL_MASTER_ID,ART_DEPLOYMENT_PATH,ART_FOLDER_VALUE_ID,ART_PROJECT_VALUE_ID,DEPLOYMENT_COMMENTS,ART_VALIDATED,IS_ENABLED_IND,LOAD_ID,GETDATE(),CURRENT_USER,NULL,NULL,@CHANGE_LOAD_ID)

;
SET IDENTITY_INSERT AM.ARTIFACT_DEPLOYMENT OFF

END

