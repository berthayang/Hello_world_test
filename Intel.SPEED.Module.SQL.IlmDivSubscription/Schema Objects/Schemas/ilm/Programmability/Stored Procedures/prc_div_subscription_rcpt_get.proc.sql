SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_rcpt_get]') AND [type] = 'P')
	DROP PROCEDURE [ilm].[prc_div_subscription_rcpt_get]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_rcpt_get] (
 @mdul_idn		INT
,@where_clause  VARCHAR(255)
,@base_table	VARCHAR(50)
,@evnt_nme		VARCHAR(50)
) AS
/******************************************************************************
*** Purpose: Generate list of subscribed users based on event data
*** History: rsanka1x	01/06/2014	Created
***          slee44     01/29/2016  START 8627841 Slowness in ILM Subscriptions
***			  
*** Copyright 2014-2016 Intel Corporation, all rights reserved.
*******************************************************************************/
BEGIN
	SET NOCOUNT ON    
	
	DECLARE  @sql				VARCHAR(8000)
			,@col_idn			INT
			,@phys_tbl_col		VARCHAR(100)
			,@phys_col_nme		VARCHAR(50)
			,@phys_tbl_nme		VARCHAR(50)
			,@join_definition	VARCHAR(5000)
	
	CREATE TABLE #scb_data (scb_idn INT, col_idn INT, col_idn2 INT)

	IF RTRIM(ISNULL(@where_clause, '')) = ''
	BEGIN
		RAISERROR ('Missing where clause', 16, 1)
		RETURN
	END

	IF RTRIM(ISNULL(@base_table, '')) = ''
	BEGIN
		RAISERROR ('Missing base table', 16, 1)
		RETURN
	END

	/********************************************************************
	*** Temp table to hold column id and data for the current event
	********************************************************************/
	CREATE TABLE #evnt_data (col_idn INT, data VARCHAR(2000))
    
	/********************************************************************
	*** Temp table to hold subscription column information for the current module
	********************************************************************/
	CREATE TABLE #scb_col (col_idn INT, phys_col_nme VARCHAR(50), phys_tbl_nme VARCHAR(50), join_definition VARCHAR(5000))
 
	-- All the columns that can be subscribed in the current module
	INSERT INTO #scb_col (col_idn, phys_col_nme, phys_tbl_nme, join_definition)
		 SELECT sc.col_idn, sc.phys_col_nme, sc.phy_tbl_nme, sc.join_definition
		   FROM scb_column sc
		   JOIN module_column mc ON sc.col_idn = mc.col_idn AND mc.mdul_idn = @mdul_idn 
		  WHERE sc.curr_actv_ind IN ('Y') -- Y = active
    
	/********************************************************************
	*** Data values for the subscribed columns on the current event_idn
	********************************************************************/
	WHILE (SELECT COUNT(*) FROM #scb_col) <>  0     
	BEGIN    
		SELECT TOP 1 @col_idn = col_idn, @phys_col_nme = ISNULL(phys_col_nme, ''), @phys_tbl_nme = ISNULL(phys_tbl_nme, ''), @join_definition = ISNULL(join_definition, '') 
			  FROM #scb_col
    
		SET @phys_tbl_col = @phys_tbl_nme  + '.' + @phys_col_nme     
       
		SET @sql = 'INSERT INTO #evnt_data (col_idn, data) ' + CHAR(10)
				+ 'SELECT DISTINCT ' 
				+ CONVERT(VARCHAR, @col_idn) 
				+ ',' + @phys_tbl_col		+ CHAR(10)
				+ ' FROM ' + @base_table	+ CHAR(10)
				+ @join_definition			+ CHAR(10)
				+ @where_clause				+ CHAR(10)
       
		EXEC(@sql)
		
		DELETE #evnt_data WHERE data IS NULL
		DELETE #scb_col WHERE col_idn = @col_idn
	END
  
	/********************************************************************
	*** Join subscription with event data. LEFT JOIN to #evnt_data so that we know which col_idn does not match (col_idn=NULL)
	********************************************************************/
	INSERT INTO #scb_data (scb_idn, col_idn, col_idn2)
		 SELECT DISTINCT dtl.scb_idn, dtl.col_idn, evnt.col_idn
		   FROM scb_definition def
		   JOIN scb_detail dtl ON def.scb_idn = dtl.scb_idn
	  LEFT JOIN #evnt_data evnt ON dtl.col_idn = evnt.col_idn AND RTRIM(dtl.col_id) = RTRIM(evnt.data)
		  WHERE def.mdul_idn = @mdul_idn

	-- Cleanup: keep only matching records between event and subscription data
	DELETE FROM #scb_data WHERE scb_idn IN (
		SELECT DISTINCT scb_idn 
		  FROM (
			SELECT DISTINCT scb_idn, col_idn 
			  FROM #scb_data -- full set of data
			EXCEPT
			SELECT DISTINCT scb_idn, col_idn 
			  FROM #scb_data 
			 WHERE col_idn2 IS NOT NULL -- valid data
				) AS scb_final
	)

	/********************************************************************
	*** Subscribed users for this event
	********************************************************************/
		INSERT INTO #recipient_list (usr_acct, sts_ind, reason)
		 SELECT DISTINCT def.usr_acct
			   ,CASE summ.lkup_alrt_typ_ind
					WHEN 171090 THEN 'I'
					ELSE NULL
				END
			   ,CASE summ.lkup_alrt_typ_ind
					WHEN 171090 THEN 'Portal view only.'	--Portal
					WHEN 171091 THEN 'Portal view only.'	--Both
					ELSE NULL
				END
		   FROM scb_definition def
		   JOIN #scb_data scb ON def.scb_idn = scb.scb_idn
		   LEFT JOIN scb_definition_summary summ ON def.scb_idn = summ.scb_idn AND smry_flg = 'N'

	DROP TABLE #evnt_data
    DROP TABLE #scb_col
	DROP TABLE #scb_data

	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_div_subscription_rcpt_get failure.' AS msg
	RETURN @@error	
	   
	SET NOCOUNT OFF    
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 