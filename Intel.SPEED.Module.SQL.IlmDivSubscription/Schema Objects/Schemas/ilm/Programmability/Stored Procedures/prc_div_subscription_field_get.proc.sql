SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_field_get]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription_field_get]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_field_get] 
(
 @idoc		INT
,@usr_acct	CHAR(8)
,@mdul_idn	INT
,@scb_idn	INT = NULL
,@debug		CHAR(1) = 'N'
) AS
/******************************************************************************
*** Purpose: Get create/edit field list for ILM Division Subscription maintenance page.
*** History: rsanka1x	01/06/2014	Created
***
*** Copyright 2014 Intel Corporation, all rights reserved.
*******************************************************************************/
BEGIN
	SET NOCOUNT ON
    DECLARE @row		INT
		   ,@sp_nme		VARCHAR(255)
		   ,@label		VARCHAR( 80)
		   ,@lbl_style	VARCHAR(500)
		   ,@obj_type	VARCHAR( 40)
		   ,@col_idn	VARCHAR( 40)
		   ,@col_nme	VARCHAR( 50)
		   ,@slct_idn	INT
		   ,@tag_attr	VARCHAR(2000)
		   ,@tst_attr	VARCHAR(2000)
		   ,@dd_sp_nme	VARCHAR( 255)
		   ,@col_qty	INT
		   ,@space_pos	INT
	
	DECLARE @scb_field_html TABLE
		(col_idn	INT
		,col_nme	VARCHAR(  50)
		,fld_html	VARCHAR(5000) NULL
		,lbl_style	VARCHAR( 500)
		,lbl_html	VARCHAR( 255) NULL
		)

	CREATE TABLE #scb(
		usr_acct CHAR(8)
	   ,mdul_idn INT
	   ,scb_idn  INT
	   ,is_dirty VARCHAR(7)
	)

	CREATE TABLE #scb_field_def(
		 row		INT IDENTITY
		,col_idn	INT
		,id_tbl		VARCHAR(50) NULL
		,id_nme		VARCHAR(50) NULL
		,id_type	VARCHAR(50) NULL
		,label		VARCHAR(80) NULL
		,lbl_style	VARCHAR(500) DEFAULT '<!-- NO CHANGE -->'
		,obj_type	VARCHAR(50) NULL
		,sql		VARCHAR(2000) NULL
		,slct_idn	INT NULL
		,tag_attr	VARCHAR(1000) NULL
		,val_nme	VARCHAR(50) NULL
		,val_len	VARCHAR(80) NULL
		,join_def	VARCHAR(1000) NULL
	)

	CREATE TABLE #rpt(
		 row			INT IDENTITY
		,col_idn_left	VARCHAR(255)
		,col_idn_right	VARCHAR(255)
	)

	INSERT #scb (mdul_idn, usr_acct, scb_idn, is_dirty)
	SELECT @mdul_idn
		  ,@usr_acct
		  ,@scb_idn
		  ,NULLIF(is_dirty, '')
	FROM OPENXML(@idoc, 'ROOT', 2) WITH (
		is_dirty	VARCHAR(7)
		)

	/**********************************************
	*** Load field list definitions, latest proc is "ilm.prc_div_subscription_field_def"
	**********************************************/
	SET @sp_nme = NULL
		
	SELECT @sp_nme = module_property.propty_val 
	  FROM #scb
	  JOIN module_property ON module_property.mdul_idn = #scb.mdul_idn
	   AND module_property.propty_typ = 'SUBSCRIPTION_FIELD_DEFINITION'

	IF @sp_nme IS NOT NULL EXEC (@sp_nme)

	SELECT row AS [<TABLENAME>FieldDefinitions</TABLENAME>]
		  ,col_idn, label, id_nme, id_type, lbl_style, obj_type
		  ,sql, slct_idn, tag_attr, val_nme, val_len, join_def
	  FROM #scb_field_def 
  ORDER BY row

    /*********************************************************
    *** build SPEED-tags  ***/
	SELECT @row = MIN(row) FROM #scb_field_def
	WHILE @row IS NOT NULL
	BEGIN
		SET @tst_attr = ''
		SELECT @label	= RTRIM(label)
			,@lbl_style = lbl_style
			,@obj_type	= LOWER(obj_type)
			,@col_idn	= col_idn
			,@col_nme	= val_nme
			,@slct_idn	= slct_idn
			,@tag_attr  = ISNULL(tag_attr, '')
			,@tst_attr  = ' ' + LOWER(ISNULL(tag_attr, ''))
		FROM #scb_field_def 
		WHERE row = @row
		
			
		/** remove delimiters from test attributes **/
		SET @tst_attr = REPLACE(@tst_attr, '	', ' ')
		SET @tst_attr = REPLACE(@tst_attr, ' ='  , '=')
		SET @tst_attr = REPLACE(@tst_attr, ' :'  , ':')
		
		/** add leading space to tag attributes **/
		IF @tag_attr != '' SET @tag_attr = ' ' + @tag_attr
		
		/** insert tag width **/
		IF  CHARINDEX(' width=', @tst_attr) = 0 
		AND CHARINDEX(' width:', @tst_attr) = 0 
		BEGIN
			SET @tag_attr = CASE(@obj_type)
				WHEN 'element'		THEN ' STYLE="width:235px;"' + @tag_attr
				WHEN 'hidden'		THEN @tag_attr
				WHEN 'checkbox'		THEN @tag_attr
				WHEN 'dropdown'		THEN ' WIDTH=230' + @tag_attr
				WHEN 'multislct'	THEN ' WIDTH=230 HEIGHT=150' + @tag_attr
				WHEN 'slctr-user'	THEN ' WIDTH=230 HEIGHT=150' + @tag_attr
				WHEN 'slctr-prdt'	THEN ' WIDTH=230 HEIGHT=150' + @tag_attr
				WHEN 'text'			THEN ' CLASS=textbox STYLE="width:220px"' + @tag_attr
				WHEN 'selector'		THEN ' STYLE="width:216px;"' + @tag_attr
				WHEN 'date'			THEN ' IsDateOnly="true" WIDTH=216px' + @tag_attr
				WHEN 'tmext'			THEN ' WIDTH=230 HEIGHT=150' + @tag_attr
				ELSE ' WIDTH=235px' +  @tag_attr 
				END
		END

		/** condition label, insert name & title **/
		SET @label = NULLIF(@label, '')
		SET @label = NULLIF(@label, '&nbsp;')
		SET @label = @label + ':'

		IF @obj_type = 'dropdown' -- insert drop-down options source table name
		BEGIN
			SET @tag_attr = ' TableName="DdSelected' + CONVERT(VARCHAR, @col_idn) + '" OptionTableName="DdOptions' + CONVERT(VARCHAR, @col_idn) + '"' + @tag_attr
		END
		ELSE IF @obj_type = 'multislct'   -- insert multi-selector options source table name
		BEGIN
			SET @tag_attr = ' SelectionTableName="DdSelected' + CONVERT(VARCHAR, @col_idn) + '" OptionTableName="DdOptions' + CONVERT(VARCHAR, @col_idn) + '"' + @tag_attr
		END
		ELSE IF @obj_type = 'slctr-user' OR  @obj_type = 'slctr-prdt'   -- insert multi-selector options for  selector crud
		BEGIN
			SET @tag_attr = ' runat=server SelectionTableName="DdSelected' + CONVERT(VARCHAR, @col_idn) + '" OptionTableName="DdOptions' + CONVERT(VARCHAR, @col_idn) + '"' + @tag_attr
		END
		ELSE IF  @obj_type = 'tmext'  -- insert multi-selector options source table name
		BEGIN
			SET @tag_attr = ' OptionTableName="DdSelected' + CONVERT(VARCHAR, @col_idn) + '" ' + @tag_attr
		END
		ELSE IF  @obj_type = 'date'  -- insert multi-selector options source table name
		BEGIN
		if(EXISTS(SELECT TOP 1 col_id FROM scb_detail WHERE scb_idn = @scb_idn AND col_idn = @col_idn))
			SET @tag_attr = ' VALUE=''' + (SELECT TOP 1 ISNULL(col_id,'') FROM scb_detail WHERE scb_idn = @scb_idn AND col_idn = @col_idn)   + '''' + @tag_attr
		END
		ELSE IF @obj_type = 'checkbox'
		BEGIN
			IF EXISTS (SELECT scb_idn FROM scb_detail WHERE scb_idn = @scb_idn AND col_idn = @col_idn AND col_id = 'Y')
			BEGIN
				SET @tag_attr = ' VALUE="Y" CHECKED' + @tag_attr
			END
			ELSE 
			BEGIN
				SET @tag_attr = ' VALUE="N"' + @tag_attr
			END
		END
		ELSE IF @obj_type='tmext'
		BEGIN
			SET @tag_attr=@tag_attr
		END
		ELSE IF @obj_type = 'text'
		BEGIN
			SELECT @tag_attr = ' VALUE="' + col_val + '"' + @tag_attr FROM scb_detail WHERE scb_idn = @scb_idn AND col_idn = @col_idn
		END

		/** insert ID and parse fields into left and right columns **/
		IF (@row % 2) = 1
		BEGIN			
			IF @col_idn = -2 SET @tag_attr = ' ID=ddSubscriptionType' + @tag_attr
			ELSE IF @col_idn = -1 SET @tag_attr = ' ID=chkSummary TABLENAME=SubscriptionSummary  onclick=fnSummaryFlagClick()' + @tag_attr
			ELSE IF @col_idn = -3 SET @tag_attr = ' ID=txtDuration TABLENAME=SubscriptionSummary IsNumber=true' + @tag_attr
			ELSE IF @col_idn = -4 SET @tag_attr = ' ID=ddRptDay' + @tag_attr
			ELSE IF @col_idn = -5 SET @tag_attr = ' ID=ddRptFrq ONCHANGE="fnDivRptFreqChange" ' + @tag_attr
			ELSE IF @col_idn = -6 SET @tag_attr = ' ID=calLastRun TABLENAME=SubscriptionSummary' + @tag_attr
			ELSE SET @tag_attr = ' ID=FL_' + CONVERT(VARCHAR, @col_idn) + @tag_attr

			INSERT #rpt(col_idn_left) SELECT @col_idn
		END 
		ELSE 
		BEGIN
			IF @col_idn = -2 SET @tag_attr = ' ID=ddSubscriptionType' + @tag_attr
			ELSE IF @col_idn = -1 SET @tag_attr = ' ID=chkSummary TABLENAME=SubscriptionSummary onclick=fnSummaryFlagClick()' + @tag_attr
			ELSE IF @col_idn = -3 SET @tag_attr = ' ID=txtDuration TABLENAME=SubscriptionSummary IsNumber=true' + @tag_attr
			ELSE IF @col_idn = -4 SET @tag_attr = ' ID=ddRptDay' + @tag_attr
			ELSE IF @col_idn = -5 SET @tag_attr = ' ID=ddRptFrq ONCHANGE="fnDivRptFreqChange" ' + @tag_attr
			ELSE IF @col_idn = -6 SET @tag_attr = ' ID=calLastRun TABLENAME=SubscriptionSummary' + @tag_attr
			ELSE SET @tag_attr = ' ID=FR_' + CONVERT(VARCHAR, @col_idn) + @tag_attr

			UPDATE #rpt SET col_idn_right = @col_idn WHERE row = @row/2
		END


		/** insert SPEED-tag class **/
		SET @tag_attr = CASE(@obj_type)
			WHEN 'span'			THEN '<SPEED:Element'			+ @tag_attr
			WHEN 'hidden'		THEN '<SPEEDX:HiddenExt2'		+ @tag_attr
			WHEN 'text'			THEN '<SPEEDX:TextboxExt2'			+ @tag_attr
			WHEN 'date'			THEN '<SPEEDX:DateExt2'				+ @tag_attr
			WHEN 'checkbox'		THEN '<SPEED:InputCheckbox'		+ @tag_attr
			WHEN 'dropdown'		THEN '<SPEEDX:RadComboBox'		+ @tag_attr
			WHEN 'multislct'	THEN '<SPEEDX:SelectorMultiExt' + @tag_attr
			WHEN 'slctr-user'	THEN '<SPEEDX:SelectorMultiExt' + @tag_attr
			WHEN 'slctr-prdt'	THEN '<SPEEDX:SelectorMultiExt' + @tag_attr
			WHEN 'selector'		THEN '<SPEED:Selector'			+ @tag_attr
			WHEN 'tmext'		THEN '<SPEEDX:TextboxMultiExt savetype=SAVE '			+ @tag_attr
			ELSE '<SPEED:Element' 
				+ ' InnerHTML=''(prc_scb_field: undefined type "' + ISNULL(@obj_type, '(null)') + '")'''
				+ ' TagName=span STYLE="color:red;"' +  @tag_attr
			END

		/** build SPEED-tag **/
		
		IF(@obj_type = 'slctr-user')
		BEGIN
			INSERT @scb_field_html(col_idn, col_nme, fld_html, lbl_html, lbl_style)
			SELECT @col_idn
				  ,@col_nme
				  ,@tag_attr + '> 
								<SelectorExt ID="slctOtherContacts' + @col_idn + '" ProcIdn= "' + CONVERT(VARCHAR,@slct_idn) + '" ParamTableName="TeamSearchParams"' + ' TableName="DdSelected' + CONVERT(VARCHAR, @col_idn) + '"' +
								   ' ShowDropdownHeader="true" DropdownWidth="280px" runat="server" >
									<SearchCols>
										<SPEEDX:SearchCol Name="usr_acct" Visible="false" Type="IDN" />
										<SPEEDX:SearchCol Name="bookname_display" Header="Name" Visible="true" Searchable="false" />
										<SPEEDX:SearchCol Name="bookname" Visible="false" Searchable="true" Type="DISPLAY" />
										<SPEEDX:SearchCol Name="wwid" Header="WWID" Visible="true" Searchable="true" />
										<SPEEDX:SearchCol Name="user_data" Visible="false" Type="DATA" Searchable="false" />
									</SearchCols>
									<SearchParams>
										<SPEEDX:SearchParam Name="onload" Value="Y" />
										<SPEEDX:SearchParam Name="ctrlnme" Value="T" />
										<SPEEDX:SearchParam Name="evnt_idn" />
									</SearchParams>
								</SelectorExt>
							</SPEEDX:SelectorMultiExt>'
				  ,@label
				  ,@lbl_style
		END
		ELSE
		IF(@obj_type = 'slctr-prdt')
		BEGIN
			INSERT @scb_field_html(col_idn, col_nme, fld_html, lbl_html, lbl_style)
			SELECT @col_idn
				  ,@col_nme
				  ,@tag_attr + '> 
								<SelectorExt ID="slctProducts' + @col_idn + '" ProcIdn= "' + CONVERT(VARCHAR,@slct_idn) + '" TableName="DdSelected' + CONVERT(VARCHAR, @col_idn) + '"' +
								   ' ShowDropdownHeader="true" DropdownWidth="220px" runat="server" >
									<SearchCols>
										<SPEEDX:SearchCol Name="prdt_nme" Header="Product Family" Visible="true" Searchable="true" />
									</SearchCols>
									<SearchParams>
										<SPEEDX:SearchParam Name="onload" Value="Y" />
									</SearchParams>
								</SelectorExt>
							</SPEEDX:SelectorMultiExt>'
				  ,@label
				  ,@lbl_style
		END
		ELSE
		BEGIN
			INSERT @scb_field_html(col_idn, col_nme, fld_html, lbl_html, lbl_style)
			SELECT @col_idn
			  ,@col_nme
			  ,@tag_attr + ' Runat=server />'
			  ,@label
			  ,@lbl_style
		END

		SELECT @row = MIN(row) FROM #scb_field_def WHERE row > @row
	END

    /*********************************************************
    *** return field list report  ***/
	SELECT NULL AS [<TABLENAME>scb_field_items</TABLENAME>] 
		  ,html_left.lbl_html						AS [ele_label_left]
		  ,ISNULL(#rpt.col_idn_left, '(none)')		AS [ele_col_idn_left<VALUE />]
		  ,html_left.col_nme						AS [ele_col_nme_left<VALUE />]
		  ,ISNULL(html_left.fld_html, '&nbsp;')		AS [ele_obj_left]
		  ,html_right.lbl_html						AS [ele_label_right]
		  ,ISNULL(#rpt.col_idn_right, '(none)')		AS [ele_col_idn_right<VALUE />]
		  ,html_right.col_nme						AS [ele_col_nme_right<VALUE />]
		  ,ISNULL(html_right.fld_html, '&nbsp;')	AS [ele_obj_right]
	  FROM #rpt
 LEFT JOIN @scb_field_html AS html_left ON html_left.col_idn = #rpt.col_idn_left
 LEFT JOIN @scb_field_html AS html_right ON html_right.col_idn = #rpt.col_idn_right
  ORDER BY #rpt.row
	
    /*********************************************************
    *** return drop-down options ***/
	SET @dd_sp_nme = NULL
	
	SELECT @dd_sp_nme = module_property.propty_val 
	  FROM #scb
	  JOIN module_property ON module_property.mdul_idn = #scb.mdul_idn 
	   AND module_property.propty_typ = 'SUBSCRIPTION_DROPDOWN_OPTIONS'
	
	IF @dd_sp_nme IS NOT NULL
	BEGIN
		SET @dd_sp_nme = @dd_sp_nme + ' @mdul_idn = ' + CONVERT(VARCHAR, @mdul_idn)
		IF @scb_idn IS NOT NULL SET @dd_sp_nme = @dd_sp_nme + ', @scb_idn = ' + CONVERT(VARCHAR, @scb_idn)
		SELECT 	 @dd_sp_nme	,@mdul_idn,	 @scb_idn
		IF @debug='Y' SELECT @dd_sp_nme AS [Gather drop-down options command]
		EXEC (@dd_sp_nme)
	END

	/*************************************************************
	*** cleanup  ***/
	select * from 	  @scb_field_html
	DROP TABLE #scb, #rpt, #scb_field_def

	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_div_subscription_field_get failure.' AS msg
	RETURN @@error	

	SET NOCOUNT OFF
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
