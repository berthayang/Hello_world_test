-------------------------------------------------------------------------------
-- One time script to update definition for FSM Subscription in module_property
-- rsanka1x	01/07/2014	Created
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------------------------
USE speed_2max
GO

BEGIN
	SET NOCOUNT ON
	DECLARE @row		INT
		   ,@mdul_idn   INT
		   ,@propty_typ VARCHAR(40)
		   ,@propty_val VARCHAR(255)

	DECLARE @data_change TABLE 
		(row          INT IDENTITY
		,mdul_idn     INT
		,propty_typ   VARCHAR(40)
		,propty_val   VARCHAR(255)
		)

	-- ILM FSM
	INSERT @data_change (mdul_idn, propty_typ, propty_val) SELECT 173, 'SUBSCRIPTION_FIELD_DEFINITION'	, 'ilm.prc_div_subscription_field_def'
	INSERT @data_change (mdul_idn, propty_typ, propty_val) SELECT 173, 'SUBSCRIPTION_DROPDOWN_OPTIONS'	, 'ilm.prc_div_subscription_dd_get'
	INSERT @data_change (mdul_idn, propty_typ, propty_val) SELECT 173, 'SUBSCRIPTION_SECURITY'			, 'ilm.prc_div_scty'
	
	SELECT @row = MIN(row) FROM @data_change
	
	WHILE @row IS NOT NULL
	BEGIN
		SELECT @mdul_idn = mdul_idn, @propty_typ = propty_typ, @propty_val = propty_val
		  FROM @data_change
		 WHERE row = @row 

		PRINT 'Updating propty_val "'      + @propty_val
			+ '" in module ' + CONVERT(VARCHAR, @mdul_idn)
            + '...'

		IF EXISTS (SELECT TOP 1 mdul_idn FROM module_property WHERE mdul_idn = @mdul_idn AND propty_typ = @propty_typ)
		BEGIN
			UPDATE module_property
			   SET propty_val = @propty_val
			 WHERE mdul_idn = @mdul_idn
			   AND propty_typ = @propty_typ
		END 
		ELSE 
		BEGIN
			INSERT module_property (mdul_idn, propty_typ, propty_val) 
			SELECT @mdul_idn, @propty_typ, @propty_val
		END

		SELECT @row = MIN(row) FROM @data_change WHERE row > @row 
	END
END
GO

SELECT * 
FROM module_property 
WHERE propty_typ IN 
	('SUBSCRIPTION_MODULE_DESC'
	,'SUBSCRIPTION_FIELD_DEFINITION'
	,'SUBSCRIPTION_DROPDOWN_OPTIONS'
	,'SUBSCRIPTION_VBS_FILES'       
	,'SUBSCRIPTION_CRUD'            
	,'SUBSCRIPTION_EXISTS_REPORT'
	,'SUBSCRIPTION_SECURITY'
	)
AND mdul_idn = 173
ORDER BY propty_typ, mdul_idn
GO
