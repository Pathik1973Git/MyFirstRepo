﻿
CREATE VIEW [AM].[v_ARTIFACT_DEPLOYMENT]

AS

SELECT  A.ART_DEPLOYMENT_ID, A.ART_CTRL_MASTER_ID, A.ART_DEPLOYMENT_PATH,
		A.ART_FOLDER_VALUE_ID, C.CODE_VALUE_DESC AS 'FOLDER',
		A.ART_PROJECT_VALUE_ID, D.CODE_VALUE_DESC AS 'PROJECT',
		A.ART_VALIDATED, A.DEPLOYMENT_COMMENTS, A.IS_ENABLED_IND, A.CREATED_DTE, A.CREATED_BY, A.LAST_UPDT_DTE, A.LAST_UPDT_BY
	FROM AM.ARTIFACT_DEPLOYMENT AS A
		LEFT OUTER JOIN AM.ARTIFACT_CODE_VALUE AS C
			ON A.ART_FOLDER_VALUE_ID = C.CODE_VALUE_ID
		LEFT OUTER JOIN AM.ARTIFACT_CODE_VALUE AS D
			ON A.ART_PROJECT_VALUE_ID = D.CODE_VALUE_ID
		


