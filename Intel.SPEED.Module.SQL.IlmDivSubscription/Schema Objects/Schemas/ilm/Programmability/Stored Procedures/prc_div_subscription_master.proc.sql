SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_master]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription_master]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_master]
(
 @XmlDoc NVARCHAR(MAX)
) AS
/******************************************************************************
*** Purpose: ILM Division Subscription - Master Stored Procedure
*** History: rsanka1x	01/06/2014	Created
***
*** Copyright 2014 Intel Corporation, all rights reserved.
*******************************************************************************/
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @idoc				INT
			   ,@usr_acct			CHAR(8)
			   ,@bookname			VARCHAR(80)
			   ,@action				VARCHAR(30)
			   ,@mdul_idn			INT
			   ,@scb_idn			INT
			   ,@org_lkup_idn		INT

		CREATE TABLE #mod_cde(
			mod_cde		INT
		   ,mod_dsc		VARCHAR(255)
		   ,edit_ind	CHAR(1) NULL
		   ,view_ind	CHAR(1) NULL
		   ,usr_acct	CHAR(8) NULL
		   ,key1		VARCHAR(40) NULL
		   ,key2		VARCHAR(40) NULL
		   ,key3		VARCHAR(40) NULL
		)

		SET @mdul_idn = 173 -- Module Idn for ILM Division

		EXEC sp_xml_preparedocument @idoc OUTPUT, @XmlDoc
	
		SELECT @action				= NULLIF(action, '')
			  ,@scb_idn				= NULLIF(scb_idn, '')
		FROM OPENXML(@idoc, 'ROOT', 2) 
		WITH (
			action				VARCHAR(30)
		   ,scb_idn				INT
		)

		/**********************************************
		*** USER AUTHENTICATE
		**********************************************/
		EXEC prc_get_idsid_login @idoc = @idoc
								,@XmlDoc = @XmlDoc
								,@usr_acct = @usr_acct OUTPUT
								,@bookname = @bookname OUTPUT

		/**********************************************
		*** SECURITY
		**********************************************/
		EXEC ilm.prc_div_scty @idoc = @idoc
							 ,@usr_acct = @usr_acct
							 ,@cre_tbl_ind = 'N'
							 ,@XmlDoc = @XmlDoc

		/**********************************************
		*** MENU
		**********************************************/
		DECLARE	 @slctd_mnu_id			INT
				,@nw_slctd_mnu_id		INT
				,@old_menu_id			INT
				,@nw_menu_id			INT

		SELECT @slctd_mnu_id	= ISNULL([selected_id], 0),
			   @old_menu_id		= ISNULL([menu_id],1512)		
			FROM OPENXML(@idoc, 'ROOT/SpeedTopNavigation', 2)              
			WITH ([selected_id]			INT,
				  [menu_id]				INT	) 

		/******************************************************
		*** Determine the pageid based on the user organisation
		*******************************************************/
	
		EXEC ilm.prc_procs_stack_execution @XmlDoc = @XmlDoc
		
		IF @action = 'GET_FIELDS'
		BEGIN
			/*** Build subscription fields ***/
			EXEC ilm.prc_div_subscription_field_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn

			/*** Build existing subscription list ***/
			EXEC ilm.prc_div_subscription_list_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn
		END
		ELSE IF @action = 'GET_PORTAL_NOTIF'
		BEGIN
			EXEC ilm.prc_div_portal_subscription_list @usr_acct = @usr_acct, @idoc = @idoc,@XmlDoc = @XmlDoc, @mdul_idn = @mdul_idn
		END
		ELSE IF @action = 'GET_LIST'
		BEGIN
			EXEC ilm.prc_div_subscription_list_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn
		END
		ELSE IF @action = 'GET_EXISTING'
		BEGIN
			EXEC ilm.prc_div_subscription_field_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn, @scb_idn = @scb_idn
		END

		ELSE IF @action = 'SAVE'
		BEGIN
		
			EXEC ilm.prc_div_subscription_save @XmlDoc = @XmlDoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn, @scb_idn = @scb_idn
		
			EXEC ilm.prc_div_subscription_list_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn
		
		END

		ELSE IF @action = 'DELETE'
		BEGIN		
			EXEC ilm.prc_div_subscription_delete @XmlDoc = @XmlDoc, @usr_acct = @usr_acct, @idoc = @idoc

			/*** Build subscription fields ***/
			EXEC ilm.prc_div_subscription_field_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn	

			/*** Build existing subscription list ***/
			EXEC ilm.prc_div_subscription_list_get @idoc = @idoc, @usr_acct = @usr_acct, @mdul_idn = @mdul_idn	
		END

		/**********************************************
		*** RETURN: Mod Codes
		**********************************************/
		SELECT NULL AS [<TABLENAME>MOD CODES</TABLENAME>]
			  ,mod_cde
			  ,mod_dsc
			  ,edit_ind
			  ,view_ind
			  ,usr_acct
			  ,key1
			  ,key2
			  ,key3
		  FROM #mod_cde
	  ORDER BY mod_cde

		/**********************************************
		*** CLEAN-UP
		**********************************************/
		EXEC sp_xml_removedocument @idoc
		DROP TABLE #mod_cde

		SET NOCOUNT OFF
	END TRY

	BEGIN CATCH
		DECLARE @ERROR_MESSAGE VARCHAR(MAX)
		SET @ERROR_MESSAGE = ERROR_MESSAGE()
		SELECT @ERROR_MESSAGE AS error, 'Stored procedure prc_div_subscription_master failure.' AS msg
	END CATCH
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO