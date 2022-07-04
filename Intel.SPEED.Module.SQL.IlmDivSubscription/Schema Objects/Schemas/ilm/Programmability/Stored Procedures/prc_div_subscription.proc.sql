SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription]
GO
	
CREATE PROCEDURE [ilm].[prc_div_subscription] (
 @notify_idn	INT
,@evnt_idn		INT
,@notify_click	CHAR(1) = NULL -- used in TEAM
) AS
/******************************************************************************
*** Purpose: Master stored procedure for Division subscription (tied with notification event)
*** History: rsanka1x	01/06/2014	Created
***			 
*** Copyright 2014 Intel Corporation, all rights reserved.
*******************************************************************************/ 

BEGIN
	SET NOCOUNT ON
  
	DECLARE @mdul_idn		INT
		   ,@event_nme		VARCHAR(50)
		   ,@where_clause	VARCHAR(200)

	-- Temp table to hold recipients whose subscription criteria match the data for current event
	CREATE TABLE #recipient_list (
		usr_acct		VARCHAR(8)
	   ,sts_ind			CHAR(1)
	   ,reason			VARCHAR(80)
	)

	SET @mdul_idn = 173
  
	/******************************************************
	*** Get the current event information
	******************************************************/       
	SELECT @event_nme = event_nme
	  FROM notification_request
	 WHERE notify_idn = @notify_idn
  
	SET @where_clause = 'WHERE ilm.division_issue.evnt_idn = ' + CONVERT(VARCHAR, @evnt_idn)
    
	/*********************************************************
	*** Populate all subscribed users that matches the event data, and stored in #recipient_list
	*********************************************************/
	EXEC ilm.prc_div_subscription_rcpt_get @mdul_idn = @mdul_idn, @where_clause = @where_clause, @base_table = 'ilm.division_issue', @evnt_nme = @event_nme


	/*********************************************************
	*** Insert the information in to the mail_recepient table
	*********************************************************/	
	INSERT INTO mail_recipient (notify_idn, usr_idn, usr_nme, address_cde, sts_ind, reason)
	SELECT DISTINCT @notify_idn
				   ,rcpt.usr_acct
				   ,u.bookname
				   ,'T'
				   ,rcpt.sts_ind
				   ,rcpt.reason
			   FROM #recipient_list rcpt
			   JOIN users u ON rcpt.usr_acct = u.usr_acct
			  WHERE rcpt.usr_acct NOT IN (SELECT usr_idn FROM mail_recipient WHERE notify_idn = @notify_idn)
		   ORDER BY u.bookname
       
	DROP TABLE #recipient_list
  
	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_div_subscription failure.' AS msg
	RETURN @@error	

	SET NOCOUNT OFF
END
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON 
GO