SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = OBJECT_ID(N'[ilm].[prc_div_subscription_save]') AND [type] = 'P')
	DROP PROCEDURE [ilm].[prc_div_subscription_save]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_save]
(
 @XmlDoc	NVARCHAR(MAX)
,@usr_acct	CHAR(8)
,@mdul_idn	INT
,@scb_idn	INT
) AS
/***************************************************************
***	Purpose	: To save data of SPEED-Division Subscription Page     
***	History	: rsanka1x	01/06/2014	Created Procedure
***
***	Copyright 2014 Intel Corporation, all rights reserved.
***************************************************************/
BEGIN
    SET NOCOUNT ON 
	
	DECLARE	@idoc		INT
		   ,@row		INT
		   ,@alrt_typ_idn	VARCHAR(200)
		   ,@div_summary		VARCHAR(1)
		   ,@div_duration	VARCHAR(20)
		   ,@div_rpt_day		VARCHAR(20)
		   ,@div_rpt_frq		VARCHAR(20)
		   ,@div_lst_run		Varchar(200)
		   ,@col_val		VARCHAR(2000)
		   ,@sql			NVARCHAR(2000) = ''

	DECLARE @scb_dtl TABLE (row_idn INT IDENTITY, col_idn INT, col_val VARCHAR(2000), col_id VARCHAR(2000))
	DECLARE @col_dtl TABLE (row_idn INT, col_val VARCHAR(2000), col_id VARCHAR(2000))

	EXEC sp_xml_preparedocument @idoc OUTPUT, @XmlDoc
	SELECT * INTO #full_xml FROM OPENXML (@idoc, '', 2)
	EXEC sp_xml_removedocument @idoc
	
	-- retrieve values for controls on the left side of table
	INSERT INTO @scb_dtl (col_idn, col_id)
	SELECT REPLACE(data1.localname, 'FL_', ''), data2.text 
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname LIKE 'FL_%'

	-- retrieve values for controls on the right side of table
	INSERT INTO @scb_dtl (col_idn, col_id)
	SELECT REPLACE(data1.localname, 'FR_', ''), data2.text 
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname LIKE 'FR_%'

	-- retrieve value for alert type
	SELECT @alrt_typ_idn = data2.text
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname =  'ddSubscriptionType'

	-- retrieve custom field values
	SELECT @div_summary = data2.text
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname =  'chkSummary'

	 SELECT @div_duration = data2.text
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname =  'txtDuration'

	 SELECT @div_rpt_day = data2.text
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname =  'ddRptDay'

	SELECT @div_rpt_frq = data2.text
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname =  'ddRptFrq'

	 SELECT @div_lst_run = data2.text
	  FROM #full_xml data1
	  JOIN #full_xml data2 ON data1.id = data2.parentid AND data2.localname = '#text'
	 WHERE data1.localname =  'calLastRun'

	SELECT @row = MIN(row_idn) FROM @scb_dtl
		
	WHILE @row IS NOT NULL
	BEGIN
		SELECT @sql = CASE sc.data_type 
						WHEN 'int'		THEN sp_nme + ', @curr_idn = ' + sd.col_id
						WHEN 'smallint' THEN sp_nme + ', @curr_idn = ' + sd.col_id
						WHEN 'char'		THEN sp_nme + ', @curr_idn = ''' + sd.col_id + ''''
						WHEN 'prdt'		THEN 'SELECT ''' + sd.col_id + ''','''+ sd.col_id + ''''
						WHEN 'user'		THEN 'SELECT TOP 1 usr_acct, bookname FROM users WHERE usr_acct='''+  sd.col_id + ''''
						ELSE ''
					  END
		  FROM @scb_dtl sd
		  JOIN scb_column sc ON sd.col_idn = sc.col_idn
		 WHERE sd.row_idn = @row

		IF @sql <> '' AND @sql IS NOT NULL
		BEGIN
			INSERT @col_dtl (col_id, col_val) EXEC sp_executesql @sql
			UPDATE @col_dtl SET row_idn = @row WHERE row_idn IS NULL
		END

		SELECT @row = MIN(row_idn) FROM @scb_dtl WHERE row_idn > @row
	END
	 
	UPDATE sd
	   SET sd.col_val = cd.col_val
	  FROM @scb_dtl sd
	  JOIN @col_dtl cd ON sd.row_idn = cd.row_idn AND sd.col_id = cd.col_id

	-- remove values with CheckBox unchecked
	DELETE sd
	  FROM @scb_dtl sd
	  JOIN module_column mc ON sd.col_idn = mc.col_idn AND mc.col_typ = 'checkbox' AND mc.mdul_idn = @mdul_idn
	 WHERE sd.col_id <> 'Y'

	-- update col_val to Yes for CheckBox checked
	UPDATE sd
	   SET col_val = 'Yes'
	  FROM @scb_dtl sd
	  JOIN module_column mc ON sd.col_idn = mc.col_idn AND mc.col_typ = 'checkbox' AND mc.mdul_idn = @mdul_idn
	 WHERE sd.col_id = 'Y'

	UPDATE sd
	   SET col_val = sd.col_id
	  FROM @scb_dtl sd
	  JOIN module_column mc ON sd.col_idn = mc.col_idn  AND mc.mdul_idn = @mdul_idn
	 WHERE mc.col_typ = 'tmext'	 

	UPDATE sd
	   SET col_val = sd.col_id
	  FROM @scb_dtl sd
	  JOIN module_column mc ON sd.col_idn = mc.col_idn AND mc.col_typ = 'date' AND mc.mdul_idn = @mdul_idn

	BEGIN TRY
		BEGIN TRANSACTION

		-- if new subscription record
		IF NOT EXISTS (SELECT scb_idn FROM scb_definition WHERE scb_idn = @scb_idn)
		BEGIN
			-- Create new subscription record if not found for this scb_idn
			INSERT INTO scb_definition (mdul_idn, usr_acct)
				 VALUES (@mdul_idn, @usr_acct)

			-- get auto-generated scb_idn
			SET @scb_idn = @@identity
		END
		ELSE
		BEGIN
			DELETE FROM scb_detail
				  WHERE scb_idn = @scb_idn
		END		
		INSERT INTO scb_detail (scb_idn, col_idn, seq_nbr, col_val, col_id)
			 SELECT @scb_idn
				   ,col_idn
				   ,ROW_NUMBER() OVER (PARTITION BY col_idn ORDER BY col_idn) AS seq_nbr
				   ,col_val
				   ,col_id 
			   FROM @scb_dtl
		   ORDER BY col_idn, col_val

		If @div_summary <> 'Y'
		BEGIN
			SET @div_duration=NULL
			SET @div_lst_run = NULL
			SET @div_rpt_frq = NULL
			SET @div_rpt_day = NULL
		END

		IF NOT EXISTS (SELECT scb_idn FROM scb_definition_summary WHERE scb_idn = @scb_idn)
			INSERT INTO scb_definition_summary (scb_idn, smry_flg, rpt_duration, lkup_alrt_typ_ind,lst_run_dte,lkup_rpt_day_idn,lkup_rpt_frq_idn) 
			VALUES (@scb_idn, @div_summary, ISNULL(@div_duration,1),ISNULL(@alrt_typ_idn,0),@div_lst_run,@div_rpt_day,@div_rpt_frq)
		ELSE
		BEGIN
			UPDATE scb_definition_summary 
			SET smry_flg = @div_summary,lkup_alrt_typ_ind = ISNULL(@alrt_typ_idn,0), rpt_duration=ISNULL(@div_duration,1),lst_run_dte=@div_lst_run,lkup_rpt_day_idn=@div_rpt_day,lkup_rpt_frq_idn=@div_rpt_frq
			WHERE scb_idn = @scb_idn
		END

		SELECT NULL AS [<TABLENAME>scbidn</TABLENAME>]
			  ,@scb_idn			AS [<scb_idn>]
			  

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		SELECT @@ERROR AS error, ISNULL(ERROR_PROCEDURE(), 'prc_div_subscription_save') + ' failed: ' + ERROR_MESSAGE() AS msg
		RETURN @@ERROR
	END CATCH

	DROP TABLE #full_xml
    SET NOCOUNT OFF
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO