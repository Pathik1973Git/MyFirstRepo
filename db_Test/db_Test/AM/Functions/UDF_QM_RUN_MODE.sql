﻿
CREATE FUNCTION [AM].[UDF_QM_RUN_MODE] (@ART_CTRL_MASTER_ID INT, @MSTR_MODE INT = NULL)
	RETURNS INT

	AS

	BEGIN
		--51 = AUDIT MODE
		--52 = EXEC MODE

		DECLARE @RUN_MODE INT
		DECLARE @PKG_MODE INT

		IF @MSTR_MODE IS NULL
			BEGIN
				SET @MSTR_MODE = (SELECT SCHEDULE_MODE_VALUE_ID FROM AM.ARTIFACT_CTRL_MASTER WHERE ART_CTRL_MASTER_ID = 999)
			END
		
		SET @PKG_MODE = (SELECT SCHEDULE_MODE_VALUE_ID FROM AM.ARTIFACT_CTRL_MASTER WHERE ART_CTRL_MASTER_ID = @ART_CTRL_MASTER_ID)
		
		IF @PKG_MODE IN(51, 52) and @MSTR_MODE IN(51, 52)
			BEGIN
				IF @MSTR_MODE = 51
					BEGIN
						SET @RUN_MODE = 51
					END
				ELSE
					BEGIN
						IF @PKG_MODE = 51
							BEGIN
								SET @RUN_MODE = 51
							END
						ELSE
							BEGIN
								SET @RUN_MODE = 52
							END
					END
			END
		ELSE
			BEGIN
				SET @RUN_MODE = 51
			END
		
		RETURN @RUN_MODE
	END	

