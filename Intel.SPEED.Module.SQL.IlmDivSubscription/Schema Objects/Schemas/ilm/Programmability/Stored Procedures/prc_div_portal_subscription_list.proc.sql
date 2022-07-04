SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_portal_subscription_list]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_portal_subscription_list]
GO

CREATE PROCEDURE [ilm].[prc_div_portal_subscription_list]
(
 @XmlDoc		NVARCHAR(MAX) = NULL  
 ,@idoc			INT = NULL 
 ,@usr_acct		CHAR(8)
 ,@mdul_idn		INT
) AS
/********************************************************************************************************************
*** Purpose: Portal subscription to load notification 
*** History: rsanka1x	07/03/2014	Created
***	
*** Copyright 2014 Intel Corporation, all rights reserved.
**********************************************************************************************************************/
BEGIN
	BEGIN TRY   
		DECLARE  @row_qty INT
				,@first_row INT
				,@max_rows INT
				,@last_row INT
				,@lcid	VARCHAR(15)
				
		DECLARE @col_table AS TABLE(id INT, col_nme VARCHAR(500),col_idn VARCHAR(500))
		
		CREATE TABLE #temp(row_no int identity(1,1), subject VARCHAR(MAX), processed_dte VARCHAR(100))
		SELECT @lcid=tag_val FROM user_preference WHERE prf_idn=1008 and usr_acct=@usr_acct
		/******************************************************      
		*** parse parameters XML document  ***/  
		EXEC sp_xml_preparedocument @idoc OUTPUT, @XmlDoc   
		
		/*******************************************************
		*** load paging variables from common xml_document  ***/
		SELECT @first_row = ISNULL([FirstRow], 1), @max_rows = ISNULL(MaxRows, 50)
		FROM OPENXML(@idoc, '/ROOT/rptSubscription', 2) WITH ([FirstRow] INT, MaxRows INT)

		EXEC sp_xml_removedocument @idoc  	
		
		INSERT INTO #temp(subject,processed_dte)
		SELECT top 100 '<a href="#" onclick="fnRptNotif_onRowSelect('+ CONVERT(VARCHAR,nr.notify_idn) +')" >' + mm.subject + '</a>' AS subject
			, CASE WHEN nr.processed_dte IS NULL THEN '&nbsp;' ELSE  CONVERT(VARCHAR(100)
			,ilm.fnGetUserDateOnly(@lcid,dbo.fnTzDte(nr.processed_dte, @usr_acct, 'read'))) END
		FROM     notification_request nr
		JOIN     mail_message mm
				 ON mm.notify_idn = nr.notify_idn 
		JOIN     mail_recipient mr
				 ON mr.notify_idn = nr.notify_idn 
		JOIN     notif_msg nm
				 ON nm.msg_name = nr.event_nme
		JOIN     module_notif mn
				 ON nm.msg_idn = mn.msg_idn
		JOIN     module m
				 ON mn.mdul_idn = m.mdul_idn
		WHERE    nr.request_status IN ('D', 'P')
				 AND mn.mdul_idn = CONVERT(VARCHAR,@mdul_idn)
				 AND mr.usr_idn = @usr_acct
				 AND mr.reason = 'Portal view only.'
		ORDER BY nr.notify_idn DESC	
			
		/*** Paging Control ***/		
		SELECT @row_qty = @@ROWCOUNT
		IF @max_rows  IS NULL SET @max_rows = 10
		IF @first_row IS NULL SET @first_row = 1
		
		IF @first_row > @row_qty SET @first_row = @row_qty - @max_rows + 1
		IF @first_row < 1 SET @first_row = 1		
		
		/*** return report object properties ***/
		SELECT @last_row = MAX(row_no) FROM #temp WHERE row_no < @first_row + @max_rows   
		IF @last_row IS NULL SET @last_row = 0		

		SELECT NULL AS [<TABLENAME>Rpt_Subscription</TABLENAME>],  * FROM #temp
		WHERE row_no >= @first_row 
			AND row_no <= @last_row
		ORDER BY row_no			
		
		/**********************************************
		*** Return report navigation 
		**********************************************/
		SELECT NULL AS [<TABLENAME>Rpt_Subscription_Nav</TABLENAME>]
			  ,'rptSubscription' AS [<ID>]
			  ,@row_qty	AS [<RowQty>]
			  ,@first_row AS [<FirstRow>]
			  ,@max_rows AS [<MaxRows>]
			  ,@last_row AS [<LastRow>]
	DROP TABLE #temp
	END TRY  
	BEGIN CATCH  
		SELECT ERROR_MESSAGE() AS error, 'Stored procedure [prc_div_portal_subscription_list] failure.' AS msg  
	END CATCH  
	SET NOCOUNT OFF 
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
