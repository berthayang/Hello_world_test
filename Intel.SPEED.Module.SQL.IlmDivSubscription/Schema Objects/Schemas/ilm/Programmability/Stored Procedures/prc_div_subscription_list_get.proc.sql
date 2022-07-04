SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_list_get]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription_list_get]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_list_get]
(
 @idoc		INT
,@usr_acct	CHAR(8)
,@mdul_idn	INT
) AS
/********************************************************************************************************************
*** Purpose: Load existing ILM Division Subscription list for current user
*** History: rsanka1x	01/06/2014	Created
***			 
*** Copyright 2014 Intel Corporation, all rights reserved.
**********************************************************************************************************************/
BEGIN
	SET NOCOUNT ON

	DECLARE @cfg_idoc		INT 
		   ,@cols_config	VARCHAR(MAX)
		   ,@sort_stmt		VARCHAR(MAX)   
		   ,@where_stmt		VARCHAR(MAX)    
		   ,@col_select		VARCHAR(MAX)    
		   ,@sql_stmt		VARCHAR(MAX)
		   ,@col_sql_1		VARCHAR(MAX)
		   ,@col_sql_2		VARCHAR(MAX)
		   ,@RowQty			INT = -1
           ,@FirstRow		INT
           ,@LastRow		INT
           ,@MaxRows		INT
		   ,@lcid			VARCHAR(15)

	DECLARE @cols TABLE (
			nme			VARCHAR(255)	-- ID of ReportColExt
		   ,col_nme		VARCHAR(MAX)	-- column name reference used in the SELECT statement
		   ,title		VARCHAR(255)	-- title of the column
		   ,order_nbr	INT				-- column ordering
		   ,visible		CHAR(1)			-- 'Y' to show, 'N' to hide
		   ,sort_ind	CHAR(4)			-- 'A' to sort ascending, 'D' to sord descending, 'N' for no sorting
		   ,sort_order	INT				-- sort ordering
		   ,group_ind	CHAR(1)			-- 'Y' to do grouping, 'N' for no grouping
		   ,group_order	INT				-- group order
		   ,group_count	INT				-- total row for selected group
		   ,to_load		CHAR(1))		-- 'Y' to load and render the column
    
	DECLARE @cols_tmp TABLE (nme VARCHAR(255), order_nbr INT, sort_ind CHAR(4), sort_order INT, group_ind CHAR(1), group_order INT, to_load CHAR(1))
	CREATE TABLE #rpt (scb_idn INT) 
	
	SET @col_sql_1 = '(SELECT ISNULL(LEFT(list, LEN(list)-1), ''(All)'') FROM (SELECT (SELECT ISNULL(col_val, '''') + '', '' FROM scb_detail sdtl JOIN scb_column scol ON sdtl.col_idn = scol.col_idn AND scol.log_col_nme = '''
	SET @col_sql_2 = ''' JOIN module_column mcol ON scol.col_idn = mcol.col_idn AND mcol.mdul_idn = ' + CONVERT(VARCHAR, @mdul_idn) + ' WHERE sdtl.scb_idn = sdef.scb_idn ORDER BY sdtl.scb_idn FOR XML PATH('''')) AS list) rpt)'

	SELECT @lcid=tag_val FROM user_preference WHERE prf_idn=1008 and usr_acct=@usr_acct

	-- NOTE: col_nme must follow names as per defined in scb_column.log_col_nme
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_start_dte', 'Created Date', 'ISNULL((SELECT ilm.fnGetUserDateOnly('''+ @lcid + ''',dbo.fnTzDte(col_val, ''' + @usr_acct + ''', ''read''))' + ' FROM scb_detail sdtl JOIN scb_column scol ON sdtl.col_idn = scol.col_idn AND scol.log_col_nme = ''div_start_dte'' JOIN module_column mcol ON scol.col_idn = mcol.col_idn AND mcol.mdul_idn = 173 WHERE sdtl.scb_idn = sdef.scb_idn), ''(All)'')', 1, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_orig_usr', 'Originator', @col_sql_1 + 'div_orig_usr' + @col_sql_2, 2, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_iss_src', 'Issue Source', @col_sql_1 + 'div_iss_src' + @col_sql_2, 3, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_exc_typ', 'Event Type', @col_sql_1 + 'div_exc_typ' + @col_sql_2, 4, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_prod_cls', 'Product Class', @col_sql_1 + 'div_prod_cls' + @col_sql_2, 5, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_lvl', 'Level', @col_sql_1 + 'div_lvl' + @col_sql_2, 6, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_symp', 'Symptom', @col_sql_1 + 'div_symp' + @col_sql_2, 7, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_plc_phs', 'PLC', @col_sql_1 + 'div_plc_phs' + @col_sql_2, 8, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_prod_fmly', 'Product Family', @col_sql_1 + 'div_prod_fmly' + @col_sql_2, 9, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_bus_unit', 'Business Unit', @col_sql_1 + 'div_bus_unit' + @col_sql_2, 10, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_risk_scre', 'Overall Risk Score', @col_sql_1 + 'div_risk_scre' + @col_sql_2, 11, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_prim_rc', 'Root Cause Area', @col_sql_1 + 'div_prim_rc' + @col_sql_2, 13, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_sub_rc', 'Root Cause', @col_sql_1 + 'div_sub_rc' + @col_sql_2, 14, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_escp_pnt', 'Escape Point', @col_sql_1 + 'div_escp_pnt' + @col_sql_2, 15, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_svr_type', 'CIRS Severity', @col_sql_1 + 'div_svr_type' + @col_sql_2, 16, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_status', 'Status', @col_sql_1 + 'div_status' + @col_sql_2, 17, 'Y', 'ASC', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_scb_idn', '', 'sdef.scb_idn', 18, 'N', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_pblm_owner', 'Problem Owner', @col_sql_1 + 'div_pblm_owner' + @col_sql_2, 19, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_clsure_aprvr', 'Closure Approver', @col_sql_1 + 'div_clsure_aprvr' + @col_sql_2, 20, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_linked_prt', 'Linked to PRT', @col_sql_1 + 'div_linked_prt' + @col_sql_2, 21, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_linked_cirs', 'Linked to CIRS Issue', @col_sql_1 + 'div_linked_cirs' + @col_sql_2, 22, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_linked_qan', 'Linked to QAN', @col_sql_1 + 'div_linked_qan' + @col_sql_2, 23, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('alrt_typ_idn', 'Notification Type', '(SELECT rl.dsc FROM scb_definition_summary sds JOIN ref_lookup rl ON rl.lkup_idn = sds.lkup_alrt_typ_ind WHERE sds.scb_idn = sdef.scb_idn)', 24, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_Summary', 'Summary Flag', '(SELECT smry_flg FROM scb_definition_summary WHERE scb_idn = sdef.scb_idn)', 25, 'Y', 'NONE', 'N', 'Y')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_RptDuration', 'Report Duration', '(SELECT rpt_duration FROM scb_definition_summary WHERE scb_idn = sdef.scb_idn)', 26, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_RptDay', 'Day of Report', '(SELECT rl.dsc FROM scb_definition_summary sds JOIN ref_lookup rl ON rl.lkup_idn = sds.lkup_rpt_day_idn WHERE sds.scb_idn = sdef.scb_idn)', 27, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_RptFrq', 'Report Frequency', '(SELECT rl.dsc FROM scb_definition_summary sds JOIN ref_lookup rl ON rl.lkup_idn = sds.lkup_rpt_frq_idn WHERE sds.scb_idn = sdef.scb_idn)', 28, 'Y', 'NONE', 'N', 'N')
	INSERT INTO @cols (nme, title, col_nme, order_nbr, visible, sort_ind, group_ind, to_load) VALUES ('div_LastRun', 'Last Run Date', '(SELECT CASE WHEN lst_run_dte IS NULL THEN '''' ELSE ilm.fnGetUserDateOnly(''' + @lcid + ''',dbo.fnTzDte(lst_run_dte, ''' + @usr_acct + ''', ''read'')) END FROM scb_definition_summary WHERE scb_idn = sdef.scb_idn)', 29, 'Y', 'NONE', 'N', 'N')

	SELECT @cols_config = CONVERT(VARCHAR(MAX), COLS)
	  FROM OPENXML(@idoc, 'ROOT/rptSubscriptionList', 2)
	  WITH (COLS XML)

	IF @cols_config IS NULL
		SET @cols_config = '<COLS></COLS>'

	EXEC sp_xml_preparedocument @cfg_idoc OUTPUT, @cols_config
	
    /*** load column details ***/  
	INSERT INTO @cols_tmp(nme, order_nbr, sort_ind, sort_order, group_ind, group_order, to_load)  
		 SELECT nme, order_nbr, sort_ind, sort_order, group_ind, group_order, ISNULL(to_load, 'Y') 
		   FROM OPENXML(@cfg_idoc, 'COLS/COL', 1)
		   WITH (nme VARCHAR(255), order_nbr INT, sort_ind CHAR(4), sort_order INT, group_ind CHAR(1), group_order INT, to_load	CHAR(1))

	EXEC sp_xml_removedocument @cfg_idoc

	IF @@ROWCOUNT > 0
	BEGIN  
		UPDATE c
		   SET order_nbr = ISNULL(tmp.order_nbr, -1)
			  ,to_load = ISNULL(tmp.to_load, 'N')
			  ,sort_ind = CASE WHEN tmp.sort_ind IN ('ASC', 'DESC') THEN tmp.sort_ind ELSE 'NONE' END
			  ,sort_order = tmp.sort_order
			  ,group_ind = CASE WHEN tmp.group_ind = 'Y' THEN 'Y' ELSE 'N' END
			  ,group_order = ISNULL(tmp.group_order, -1)
		  FROM @cols c
	 LEFT JOIN @cols_tmp tmp ON c.nme = tmp.nme
	END
    
	/*** load column select ***/
	SET @col_select = ''
	SELECT @col_select = @col_select + ',' + col_nme + ' AS [' + nme + ']' + CHAR(10)
	  FROM @cols
	 WHERE (to_load = 'Y' OR group_ind = 'Y')
	   AND col_nme IS NOT NULL
     
	/*** prioritize sorting for group column ***/
	SET @sort_stmt = ''
	SELECT @sort_stmt = @sort_stmt + col_nme + ' ' + CASE sort_ind WHEN 'DESC' THEN 'DESC' ELSE 'ASC' END + ','
	  FROM @cols
	 WHERE to_load = 'Y'
	   AND group_ind = 'Y'
  ORDER BY group_order -- order by group order instead of sort order
    
	/*** load sort details ***/
	SELECT @sort_stmt = @sort_stmt + col_nme + ' ' + sort_ind + ','
	  FROM @cols
	 WHERE sort_ind IN ('ASC', 'DESC')
	   AND to_load = 'Y'
	   AND group_ind = 'N'
  ORDER BY sort_order
    
	IF LEN(@sort_stmt) > 0 SET @sort_stmt = 'ORDER BY ' + SUBSTRING(@sort_stmt, 1, LEN(@sort_stmt) - 1)
    
	SET @sql_stmt = 'INSERT INTO #rpt (scb_idn) ' + CHAR(10)
		+ 'SELECT DISTINCT sdef.scb_idn ' + CHAR(10)
		+ 'FROM scb_definition sdef ' + CHAR(10)
		+ 'JOIN scb_detail sdtl ON sdef.scb_idn = sdtl.scb_idn ' + CHAR(10)
		+ 'JOIN scb_column scol ON sdtl.col_idn = scol.col_idn ' + CHAR(10)
		+ 'JOIN module_column mcol ON scol.col_idn = mcol.col_idn AND mcol.mdul_idn = ' + CONVERT(VARCHAR, @mdul_idn) + CHAR(10)
		+ 'WHERE sdef.mdul_idn = ' + CONVERT(VARCHAR, @mdul_idn) + CHAR(10)
		+ ' AND sdef.usr_acct = ''' + @usr_acct + '''' + CHAR(10)
    
	EXECUTE(@sql_stmt)
    
	SELECT NULL AS [<TABLENAME>scb_report</TABLENAME>]
		  ,'rptSubscriptionList' AS [<ID>]
		  ,@FirstRow AS [<FirstRow>]
		  ,@LastRow  AS [<LastRow>]
		  ,@RowQty   AS [<RowQty>]
		  ,@MaxRows  AS [<MaxRows>]
     
	SELECT NULL AS [<TABLENAME>scb_report_cols</TABLENAME>]
		  ,nme			AS [<ID>]
		  ,title		AS [<TITLE>]
		  ,order_nbr	AS [<OrderNbr>]
		  ,sort_ind		AS [<SortMethod>]
		  ,sort_order	AS [<SortOrder>]
		  ,visible		AS [<IsVisible>]
		  ,to_load		AS [<ToLoad>]
		  ,group_ind	AS [<ToGroup>]
		  ,group_order	AS [<GroupOrder>]
	  FROM @cols
  ORDER BY nme
    
	SET @sql_stmt = 'SELECT NULL AS [<TABLENAME>scb_report_rows</TABLENAME>] ' + CHAR(10)
      + @col_select
      + ' FROM scb_definition sdef ' + CHAR(10)
      + ' JOIN #rpt r ON sdef.scb_idn = r.scb_idn ' + CHAR(10)
      + @sort_stmt
	
	EXECUTE(@sql_stmt)
    
	DROP TABLE #rpt

	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_div_subscription_list_get failure.' AS msg
	RETURN @@error	

	SET NOCOUNT OFF
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

