﻿CREATE FUNCTION [AM].[UDF_UI_ARTIFACT_PARAMETER_NEXT_PARM_ID]
	(@ART_CTRL_MASTER_ID INTEGER)
	RETURNS CHAR(4) 
AS 
BEGIN
	
	DECLARE @LAST_VAL CHAR(4)
	DECLARE @i INTEGER
	SET @LAST_VAL = (SELECT MAX(PARM_ID) FROM AM.ARTIFACT_PARAMETER WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID) 
		IF @LAST_VAL IS NULL SET @LAST_VAL = 'P000' 
		SET @i = RIGHT(@LAST_VAL,3) + 1 
		RETURN 'P' +RIGHT('00' + CONVERT(VARCHAR(10),@i),3) 
END


