SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_field_def]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription_field_def]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_field_def] AS
/******************************************************************************
*** Purpose: Get field definition for ILM Division Subscription
*** History: rsanka1x	05/11/2014	Created
***			 
*** Copyright 2014 Intel Corporation, all rights reserved.
*******************************************************************************/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @scb_field_save TABLE
		(row		INT IDENTITY
		,col_idn	INT
		,id_tbl		VARCHAR(  50) NULL
		,id_nme		VARCHAR(  50) NULL
		,id_type	VARCHAR(  50) NULL
		,label		VARCHAR(  80) NULL
		,obj_type	VARCHAR(  50) NULL
		,sql		VARCHAR(2000) NULL
		,slct_idn	INT           NULL
		,tag_attr	VARCHAR(1000) NULL
		,val_nme	VARCHAR(  50) NULL
		,val_len	VARCHAR(  80) NULL
		,join_def	VARCHAR(1000) NULL
		)
	
	/** start with standard fields **/
	INSERT @scb_field_save(col_idn, label, obj_type, id_tbl, id_nme, id_type, sql, slct_idn, val_nme, val_len, join_def)
	SELECT module_column.col_idn
			,module_column.screen_label		AS label
			,LOWER(module_column.col_typ)	AS obj_type
			,scb_column.phy_tbl_nme			AS id_tbl
			,scb_column.phys_col_nme		AS id_nme
			,scb_column.data_type			AS id_type
			,scb_column.sp_nme				AS sql
			,scb_column.slct_idn			AS slct_idn
			,scb_column.log_col_nme			AS val_nme
			,REPLACE(scb_column.dsc, 'value length: ', '') AS val_len
			,scb_column.join_definition		AS join_def
		FROM #scb
		JOIN module_column ON module_column.mdul_idn = #scb.mdul_idn
		JOIN scb_column ON scb_column.col_idn = module_column.col_idn AND scb_column.curr_actv_ind = 'Y'
	ORDER BY scb_column.srt_ord, scb_column.col_idn

	/** add custom fields **/
	INSERT @scb_field_save (col_idn, id_nme, val_nme, label, obj_type,sql) 
		SELECT -2, 'ddSubscriptionType', 'ddSubscriptionType', '<label>Notification Type</label>', 'dropdown'
			,'ilm.prc_get_options @att_idn = 1110, @active_ind = NULL'

	INSERT @scb_field_save (col_idn, id_nme, val_nme, label, obj_type,sql) 
		SELECT -1, 'chkSummary', 'chkSummary', '<label>Summary Flag</label>', 'checkbox',NULL

	INSERT @scb_field_save (col_idn, id_nme, val_nme, label, obj_type,sql) 
		SELECT -3, 'txtDuration', 'txtDuration', '<label><span id=spDurReq>*&nbsp;</span>Report Duration</label>', 'text',NULL

	INSERT @scb_field_save (col_idn, id_nme, val_nme, label, obj_type,sql) 
		SELECT -4, 'ddRptDay', 'ddRptDay', '<label><span  id=spDayReq>*&nbsp;</span>Day of Report</label>', 'dropdown'
			,'ilm.prc_get_options @att_idn = 262, @active_ind = NULL'

	INSERT @scb_field_save (col_idn, id_nme, val_nme, label, obj_type,sql) 
		SELECT -5, 'ddRptFrq', 'ddRptFrq', '<label><span>*&nbsp;</span>Report Frequency</label>', 'dropdown'
			,'ilm.prc_get_options @att_idn = 263, @active_ind = NULL'

	INSERT @scb_field_save (col_idn, id_nme, val_nme, label, obj_type,sql) 
		SELECT -6, 'calLastRun', 'calLastRun', '<label><span id=spLstReq>*&nbsp;</span>Last Run Date</label>', 'date',NULL

	/** place fields into master table **/
	INSERT #scb_field_def(col_idn, label, obj_type, id_tbl, id_nme, id_type, sql, slct_idn, val_nme, val_len, join_def, tag_attr)
	SELECT col_idn
		  ,label
		  ,obj_type
		  ,id_tbl
		  ,id_nme
		  ,id_type
		  ,sql
		  ,slct_idn
		  ,val_nme
		  ,val_len
		  ,join_def
		  ,tag_attr
	  FROM @scb_field_save 
  ORDER BY row

	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_div_subscription_field_def failure.' AS msg
	RETURN @@error	

	SET NOCOUNT OFF
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO