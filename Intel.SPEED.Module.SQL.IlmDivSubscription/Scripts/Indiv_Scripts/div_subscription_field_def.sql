-------------------------------------------------------------------------------
-- One time script to create field definition for Division Subscription
-- rsanka1x	01/08/2014	Created
-- 
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------------------------
USE speed_2max
GO

BEGIN
	SET NOCOUNT ON
	DECLARE @row		INT
		,@col_idn		INT
		,@mdul_idn		INT
		,@log_col_nme	VARCHAR(50)

	DECLARE @exc_fields TABLE
		(row INT IDENTITY
		,mdul_idn			INT
		,col_idn			INT
		,screen_label		VARCHAR(80)		NULL
		,phys_col_nme		VARCHAR(50)		NULL
		,log_col_nme		VARCHAR(50)		NULL
		,dsc				VARCHAR(80)		NULL
		,data_type			VARCHAR(50)		NULL
		,sp_nme				VARCHAR(1000)	NULL
		,join_definition	VARCHAR(5000)	NULL
		,slct_idn			INT				NULL
		,col_typ			VARCHAR(10)		NULL
		,phy_tbl_nme		VARCHAR(50)		NULL
		,srt_ord			INT				NULL
		)
			

	-------------------------------------------------------------------------------
	--- ILM Division
	-------------------------------------------------------------------------------
	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Created Date</label>', 'date', 'incdnt_strt_dte', NULL, NULL, 'datetime', 'div_start_dte', 'Created Date', 'LEFT JOIN ilm.issue ON ilm.division_issue.evnt_idn = ilm.issue.evnt_idn', 'ilm.issue', 1

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Originator</label>', 'slctr-user', 'orig_usr', '169790', NULL, 'user', 'div_orig_usr', 'Originator', 'LEFT JOIN ilm.issue ON ilm.division_issue.evnt_idn = ilm.issue.evnt_idn', 'ilm.issue', 2

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Issue Source</label>', 'multislct', 'lkup_iss_src_idn', NULL, 'ilm.prc_get_options @att_idn = 774, @active_ind = NULL', 'int', 'div_iss_src', 'Issue Source', '', 'ilm.division_issue', 3

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Event Type</label>', 'multislct', 'iss_typ_idn', NULL, 'ilm.prc_get_issue_types @mdul_idn = 173, @active_ind = NULL', 'smallint', 'div_exc_typ', 'Event Type', 'LEFT JOIN ilm.issue ON ilm.division_issue.evnt_idn = ilm.issue.evnt_idn', 'ilm.issue', 4

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Product Class</label>', 'multislct', 'lkup_prod_cls_idn', NULL, 'ilm.prc_get_options @att_idn = 783, @active_ind = NULL', 'int', 'div_prod_cls', 'Product Class', '', 'ilm.division_issue', 5

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Level</label>', 'multislct', 'lkup_risk_idn', NULL, 'ilm.prc_get_options @att_idn = 776, @active_ind = NULL', 'int', 'div_lvl', 'Level', 'LEFT JOIN ilm.issue ON ilm.division_issue.evnt_idn = ilm.issue.evnt_idn', 'ilm.issue', 6

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Symptom</label>', 'multislct', 'lkup_symp_idn', NULL, 'ilm.prc_get_options @att_idn = 775, @active_ind = NULL', 'int', 'div_symp', 'Symptom', '', 'ilm.division_issue', 7

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>PLC</label>', 'multislct', 'lkup_plc_phs_idn', NULL, 'ilm.prc_get_options @att_idn = 823, @active_ind = NULL', 'int', 'div_plc_phs', 'PLC', 'LEFT JOIN ilm.issue ON ilm.division_issue.evnt_idn = ilm.issue.evnt_idn', 'ilm.issue', 8

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Product Family</label>', 'slctr-prdt', 'prdt_nme', '171097', NULL, 'prdt', 'div_prod_fmly', 'Product Family', 'LEFT JOIN (SELECT evnt_idn, CASE WHEN (fmly_dsc IS NULL) THEN cosmiq.prod_fmly ELSE mbmr.fmly_dsc END AS prdt_nme FROM ilm.division_product prod  LEFT JOIN ilm.mat_material mm ON prod.item_cde = mm.mat_id LEFT JOIN ilm.cosmiq_platform_product cosmiq ON prod.item_id = cosmiq.item_id LEFT JOIN ilm.mat_bse_mkt_rup mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm) prdt_fmly ON ilm.division_issue.evnt_idn =prdt_fmly.evnt_idn', 'prdt_fmly', 9

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Business Unit</label>', 'multislct', 'bus_unit', NULL, 'ilm.prc_get_business_unit @active_ind = NULL', 'char', 'div_bus_unit', 'Business Unit', 'LEFT JOIN (SELECT evnt_idn, CASE WHEN (prd_div_dsc IS NULL) THEN cosmiq.bus_unit ELSE mbmr.prd_div_dsc END AS bus_unit FROM ilm.division_product prod  LEFT JOIN ilm.mat_material mm ON prod.item_cde = mm.mat_id LEFT JOIN ilm.cosmiq_platform_product cosmiq ON prod.item_id = cosmiq.item_id LEFT JOIN ilm.mat_bse_mkt_rup mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm) bus_unit ON ilm.division_issue.evnt_idn =bus_unit.evnt_idn', 'bus_unit', 10

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Overall Risk Score</label>', 'multislct', 'lkup_risk_scor_idn', NULL, 'ilm.prc_get_options @att_idn = 777, @active_ind = NULL', 'int', 'div_risk_scre', 'Overall Risk Score', '', 'ilm.division_issue', 11

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Root Cause Area</label>', 'multislct', 'lkup_prim_rc_idn', NULL, 'ilm.prc_get_options @att_idn = 841, @active_ind = NULL', 'int', 'div_prim_rc', 'Root Cause Area', '', 'ilm.division_issue', 12
		
	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Root Cause</label>', 'multislct', 'lkup_sub_rc_idn', NULL, 'ilm.prc_get_options @att_idn = 842, @active_ind = NULL', 'int', 'div_sub_rc', 'Root Cause', '', 'ilm.division_issue', 13

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Escape Point</label>', 'multislct', 'lkup_escp_pnt_idn', NULL, 'ilm.prc_get_options @att_idn = 1061, @active_ind = NULL', 'int', 'div_escp_pnt', 'Escape Point', '' , 'ilm.division_issue', 14

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>CIRS Severity</label>', 'multislct', 'lkup_severity_idn', NULL, 'ilm.prc_get_options @att_idn = 82 , @active_ind = NULL', 'int', 'div_svr_type', 'CIRS Severity', 'LEFT JOIN (SELECT er.evnt_idn,st.lkup_severity_idn  FROM espeed.dbo.fnSevereTbl() st LEFT JOIN dbo.cirs_issue ci ON st.evnt_idn = ci.evnt_idn LEFT JOIN ilm.event_relations er ON ci.evnt_idn = er.rltd_idn) fst ON fst.evnt_idn=ilm.division_issue.evnt_idn', 'fst', 15

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Status</label>', 'multislct', 'lvl_idn', NULL, 'ilm.prc_generic_get_status @module_nme=''DIVISION_ISSUE'', @active_ind = NULL', 'char', 'div_status', 'Status', 'LEFT JOIN ilm.issue ON ilm.division_issue.evnt_idn = ilm.issue.evnt_idn', 'ilm.issue', 16

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Problem Owner</label>', 'slctr-user', 'usr_acct', '169790', NULL, 'user', 'div_pblm_owner', 'Problem Owner', 'LEFT JOIN ilm.event_notif_list ON ilm.event_notif_list.evnt_idn = ilm.division_issue.evnt_idn  AND lkup_psn_rol_idn = 106488', 'ilm.event_notif_list', 17

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Closure Approver</label>', 'slctr-user', 'usr_acct', '169790', NULL, 'user', 'div_clsure_aprvr', 'Closure Approver', 'LEFT JOIN ilm.event_notif_list ON ilm.event_notif_list.evnt_idn = ilm.division_issue.evnt_idn  AND lkup_psn_rol_idn = 166799', 'ilm.event_notif_list', 18

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Linked to PRT</label>', 'checkbox', 'is_linked_to_prt', NULL, NULL, 'char', 'div_linked_prt', 'Linked to PRT', 'LEFT JOIN ilm.div_related_event_indicator ON div_related_event_indicator.evnt_idn = ilm.division_issue.evnt_idn', '[ilm].[div_related_event_indicator]', 19

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Linked to CIRS Issue</label>', 'checkbox', 'is_linked_to_cirs', NULL, NULL, 'char', 'div_linked_cirs', 'Linked to CIRS Issue', 'LEFT JOIN ilm.div_related_event_indicator ON div_related_event_indicator.evnt_idn = ilm.division_issue.evnt_idn', '[ilm].[div_related_event_indicator]', 20

	INSERT @exc_fields (mdul_idn, screen_label, col_typ, phys_col_nme, slct_idn, sp_nme, data_type, log_col_nme, dsc, join_definition, phy_tbl_nme, srt_ord) 
		SELECT 173, '<label>Linked to QAN</label>', 'checkbox', 'is_linked_to_qan', NULL, NULL, 'char', 'div_linked_qan', 'Linked to QAN', 'LEFT JOIN ilm.div_related_event_indicator ON div_related_event_indicator.evnt_idn = ilm.division_issue.evnt_idn', '[ilm].[div_related_event_indicator]', 21



	-------------------------------------------------------------------------------
	--- insertion loop
	-------------------------------------------------------------------------------
	UPDATE scb_column SET curr_actv_ind = 'N' WHERE col_idn IN 
		(SELECT col_idn FROM module_column WHERE mdul_idn = 173)

	SELECT @row = MIN(row) FROM @exc_fields
	
	WHILE @row IS NOT NULL
	BEGIN
		SELECT @col_idn		= NULL
		      ,@mdul_idn	= mdul_idn
			  ,@log_col_nme	= log_col_nme
		FROM @exc_fields
		WHERE row = @row

		SELECT @col_idn = col_idn FROM scb_column WHERE log_col_nme = @log_col_nme
		
		IF @col_idn IS NULL
		BEGIN
			INSERT scb_column (log_col_nme, phys_col_nme, data_type, curr_actv_ind) 
				SELECT @log_col_nme, '', '', 'N'
			SET @col_idn = @@IDENTITY
		END
		
		UPDATE @exc_fields SET col_idn = @col_idn WHERE row = @row

		UPDATE scb_column
		   SET phys_col_nme		= def.phys_col_nme
		      ,dsc				= def.dsc
		      ,data_type		= def.data_type
		      ,sp_nme			= def.sp_nme
		      ,join_definition	= def.join_definition
		      ,curr_actv_ind	= 'Y'
		      ,slct_idn			= def.slct_idn
			  ,phy_tbl_nme		= def.phy_tbl_nme
			  ,srt_ord			= def.srt_ord
			FROM scb_column
			JOIN @exc_fields AS def
			  ON def.col_idn = scb_column.col_idn
			 AND def.row = @row

		IF NOT EXISTS
			(SELECT TOP 1 mdul_idn 
			FROM module_column 
			WHERE mdul_idn = @mdul_idn
			  AND col_idn  = @col_idn)
		BEGIN
			INSERT module_column (mdul_idn, col_idn) SELECT @mdul_idn, @col_idn
		END

		UPDATE module_column
		   SET col_typ		= def.col_typ
		      ,screen_label	= def.screen_label
			FROM module_column
			JOIN @exc_fields AS def
			  ON def.mdul_idn = module_column.mdul_idn
			 AND def.col_idn  = module_column.col_idn
			 AND def.row = @row

		SELECT @row = MIN(row) FROM @exc_fields where row > @row
	END

END

GO
