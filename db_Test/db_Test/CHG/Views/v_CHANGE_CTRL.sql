﻿
CREATE VIEW [CHG].[v_CHANGE_CTRL]

AS

SELECT A.CHG_ID, A.ART_CTRL_MASTER_ID, B.ART_NME, A.IS_ACTIVE_IND, A.CREATED_DTE, A.CREATED_BY, A.LAST_UPDT_DTE, A.LAST_UPDT_BY
		FROM CHG.CHANGE_CONTROL_ARTIFACT AS A
			LEFT OUTER JOIN  AM.ARTIFACT_CTRL_MASTER AS B
				ON A.ART_CTRL_MASTER_ID = B.ART_CTRL_MASTER_ID


