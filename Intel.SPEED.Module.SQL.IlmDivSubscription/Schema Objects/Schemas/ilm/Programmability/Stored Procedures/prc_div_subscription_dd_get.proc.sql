SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_dd_get]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription_dd_get]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_dd_get] (
 @scb_idn	INT = NULL
,@mdul_idn	INT
,@debug		CHAR(1) = 'N'
) AS
/******************************************************************************
*** Purpose: Get drop-down options for ILM Division Subscription
*** History: rsanka1x	01/06/2014	Created
***			 
*** Copyright 2014 Intel Corporation, all rights reserved.
*******************************************************************************/
BEGIN
	SET NOCOUNT ON
    
	DECLARE @row	INT
		,@col_idn	VARCHAR(  40)
		,@obj_type	VARCHAR(  40)
		,@sql		VARCHAR(2000)
		,@sql_join	VARCHAR(2000)
		,@sql_where	VARCHAR(2000)
		,@sp_nme	VARCHAR( 255)
		,@obj_id	VARCHAR( 100)
	
	CREATE TABLE #dd
		(row		INT IDENTITY
		,srt_ord	INT NULL
		,col_id		VARCHAR(255)	NULL
		,col_val	VARCHAR(255)	NULL
		,cstm_int	INT				NULL
		,cstm_chr	VARCHAR(255)	NULL
		)
	
	/*** Load option list value ***/
	/*** Split/Delete 'tmext' ***/
	SELECT @row = MIN(row) FROM #scb_field_def WHERE obj_type IN ('dropdown','multislct','tmext','slctr-user')	
	WHILE @row IS NOT NULL
	BEGIN
		SELECT @sql     = LTRIM(RTRIM(ISNULL(sql     , ''))) 
			,@obj_type	= LOWER(RTRIM(ISNULL(obj_type, ''))) 
			,@col_idn	= col_idn
		FROM #scb_field_def 
		WHERE row = @row
			
		IF (@obj_type = 'dropdown' OR @obj_type = 'multislct') AND @sql != ''
		BEGIN
			SET @sp_nme = RTRIM(SUBSTRING(@sql, 1, 255))
			IF CHARINDEX(' ', @sp_nme) > 0
			BEGIN
				SET @sp_nme = RTRIM(SUBSTRING(@sql, 1, CHARINDEX(' ', @sp_nme)))
			END

			IF NOT EXISTS
				(SELECT * 
				FROM dbo.sysobjects 
				WHERE id = object_id(@sp_nme) 
				AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
			BEGIN
				SET @sql = 'espeed..' + @sql
			END

			IF @debug = 'Y' SELECT @sql AS [DD Options Get]
			
			TRUNCATE TABLE #dd

			INSERT #dd (col_id, col_val) EXEC (@sql)
			
			UPDATE #dd SET srt_ord = row
			
			-- add a blank selection for only dropdown, doesn't work well for multi-selector
			IF (@obj_type = 'dropdown')
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 row FROM #dd WHERE NULLIF(RTRIM(col_val), '') IS NULL) AND @col_idn > 0
					INSERT #dd (col_id) SELECT NULL

				IF NOT EXISTS (SELECT TOP 1 row FROM #dd WHERE NULLIF(RTRIM(col_val), '') IS NULL) AND @col_idn in(-4,-5)
					INSERT #dd (col_id) SELECT NULL
			END
			IF (@obj_type <> 'tmext')
			BEGIN
			SET @sql = 'SELECT row AS [<TABLENAME>DdOptions' + @col_idn + '</TABLENAME>]' + CHAR(10)
				+ ' ,''Opt'' + CONVERT(VARCHAR, row) AS [<ID />]' + CHAR(10)
				+ ' ,col_id AS [<VALUE />]' + CHAR(10)
				+ ' ,col_val AS [<InnerHTML />]' + CHAR(10)
				+ ' FROM #dd ORDER BY srt_ord'

			IF @debug = 'Y' SELECT @sql AS [DD Options Return]
			EXEC (@sql)
			END

			/*** Load selected value for existing subscription if scb_idn exist ***/
			SET @sql = ''
			IF @scb_idn IS NOT NULL
			BEGIN
				IF EXISTS (SELECT scb_idn FROM scb_detail WHERE scb_idn = @scb_idn AND col_idn = @col_idn)
				BEGIN
					SET @sql_join = ' JOIN scb_column scol ON sdtl.col_idn = scol.col_idn' + CHAR(10)
							+ ' JOIN module_column mcol ON scol.col_idn = mcol.col_idn AND mcol.mdul_idn = ' + CONVERT(VARCHAR, @mdul_idn) + CHAR(10)
					SET @sql_where = ' WHERE scb_idn = ' + CONVERT(VARCHAR, @scb_idn) + CHAR(10) 
							+ ' AND sdtl.col_idn = ' + @col_idn + CHAR(10)

					IF @obj_type = 'dropdown'
					BEGIN
						IF (@row % 2) = 1 SET @obj_id = 'FL_' + CONVERT(VARCHAR, @col_idn)
						ELSE SET @obj_id = 'FR_' + CONVERT(VARCHAR, @col_idn)

						SET @sql = 'SELECT NULL AS [<TABLENAME>DdSelected' + @col_idn + '</TABLENAME>]' + CHAR(10)
							+ ' ,col_id AS [' + @obj_id + ']' + CHAR(10)
							+ ' ,col_val' + CHAR(10)
							+ ' FROM scb_detail sdtl' + CHAR(10)
							+ @sql_join
							+ @sql_where
							+ ' ORDER BY col_val'
					END
					ELSE IF @obj_type = 'multislct'
					BEGIN
						SET @sql = 'SELECT NULL AS [<TABLENAME>DdSelected' + @col_idn + '</TABLENAME>]' + CHAR(10)
							+ ' ,''Opt'' +  CONVERT(VARCHAR, seq_nbr) AS [<ID />]' + CHAR(10)
							+ ' ,col_id AS [<VALUE />]' + CHAR(10)
							+ ' ,col_val AS [<InnerHTML />]' + CHAR(10)
							+ ' FROM scb_detail sdtl' + CHAR(10)
							+ @sql_join
							+ @sql_where
							+ ' ORDER BY col_val'
					END

					IF LEN(@sql) > 0
					BEGIN
						IF @debug='Y' SELECT @sql AS [DD Selected Return]
						EXEC (@sql)
					END
				END
			END
		END

		IF(@obj_type = 'tmext')
		IF @scb_idn IS NOT NULL
			BEGIN
				SET @sql_where = ' WHERE scb_idn = ' + CONVERT(VARCHAR, @scb_idn) + CHAR(10) 
							+ ' AND sdtl.col_idn = ' + @col_idn + CHAR(10)

				SET @sql = 'SELECT NULL AS [<TABLENAME>DdSelected' + @col_idn + '</TABLENAME>]' + CHAR(10)
					+ ' ,''Opt'' + col_id AS [<ID />]' + CHAR(10)
					+ ' ,col_id AS [<VALUE />]' + CHAR(10)
					+ ' ,col_val AS [<InnerHTML />]' + CHAR(10)
					+ ' FROM scb_detail sdtl' + CHAR(10)
					--+ @sql_join
					+ @sql_where
					+ ' ORDER BY col_val'

				IF @debug='Y' SELECT @sql AS [tmext Selected Return]
				EXEC (@sql)
			END

			IF( @obj_type = 'slctr-user' OR @obj_type = 'slctr-prdt')
			IF @scb_idn IS NOT NULL
			BEGIN
				SET @sql_where = ' WHERE scb_idn = ' + CONVERT(VARCHAR, @scb_idn) + CHAR(10) 
							+ ' AND sdtl.col_idn = ' + @col_idn + CHAR(10)

				SET @sql = 'SELECT NULL AS [<TABLENAME>DdSelected' + @col_idn + '</TABLENAME>]' + CHAR(10)
					+ ' ,''Opt'' + col_id AS [<ID />]' + CHAR(10)
					+ ' ,col_id AS [<VALUE />]' + CHAR(10)
					+ ' ,col_val AS [<InnerHTML />]' + CHAR(10)
					+ ' FROM scb_detail sdtl' + CHAR(10)
					+ @sql_where
					+ ' ORDER BY col_val'

				IF @debug='Y' SELECT @sql AS [tmext Selected Return]
				EXEC (@sql)
			END
		
		SELECT @row = MIN(row) FROM #scb_field_def WHERE obj_type IN ('dropdown','multislct', 'tmext','slctr-user','slctr-prdt') AND row > @row
	END

	--ddSubscriptionType
	IF(EXISTS (SELECT scb_idn FROM scb_definition_summary WHERE scb_idn = @scb_idn AND lkup_alrt_typ_ind > 0))
		SELECT NULL AS '[<TABLENAME>DdSelected-2</TABLENAME>]', lkup_alrt_typ_ind AS 'ddSubscriptionType', rl.dsc AS 'col_val' FROM scb_definition_summary sds
		JOIN ref_lookup rl ON sds.lkup_alrt_typ_ind = rl.lkup_idn
		WHERE scb_idn = @scb_idn

	--Subscription Summary
	IF(EXISTS (SELECT scb_idn FROM scb_definition_summary WHERE scb_idn = @scb_idn))
		SELECT NULL AS '[<TABLENAME>SubscriptionSummary</TABLENAME>]', smry_flg AS 'chkSummary',rpt_duration AS 'txtDuration', lst_run_dte AS 'calLastRun' FROM scb_definition_summary
		WHERE scb_idn = @scb_idn

	IF(EXISTS (SELECT scb_idn FROM scb_definition_summary WHERE scb_idn = @scb_idn AND lkup_rpt_day_idn > 0))
		SELECT NULL AS '[<TABLENAME>DdSelected-4</TABLENAME>]', lkup_rpt_day_idn AS 'ddRptDay', rl.dsc AS 'col_val' FROM scb_definition_summary sds
		JOIN ref_lookup rl ON sds.lkup_rpt_day_idn = rl.lkup_idn
		WHERE scb_idn = @scb_idn

	IF(EXISTS (SELECT scb_idn FROM scb_definition_summary WHERE scb_idn = @scb_idn AND lkup_rpt_frq_idn > 0))
		SELECT NULL AS '[<TABLENAME>DdSelected-5</TABLENAME>]', lkup_rpt_frq_idn AS 'ddRptFrq', rl.dsc AS 'col_val' FROM scb_definition_summary sds
		JOIN ref_lookup rl ON sds.lkup_rpt_frq_idn = rl.lkup_idn
		WHERE scb_idn = @scb_idn


	/*************************************************************
	*** cleanup  ***/
	DROP TABLE #dd

	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_div_subscription_dd_get failure.' AS msg
	RETURN @@error	

	SET NOCOUNT OFF
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
