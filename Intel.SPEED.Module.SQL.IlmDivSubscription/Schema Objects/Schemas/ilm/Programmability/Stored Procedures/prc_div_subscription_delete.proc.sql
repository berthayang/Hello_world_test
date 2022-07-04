SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[ilm].[prc_div_subscription_delete]') AND [type] = 'P')	
	DROP PROCEDURE [ilm].[prc_div_subscription_delete]
GO

CREATE PROCEDURE [ilm].[prc_div_subscription_delete]
(
 @idoc		INT = NULL
,@XmlDoc	NVARCHAR(MAX) = NULL
,@usr_acct	CHAR(8)
) AS
/****************************************************************************************************************
*** Purpose: To delete the ILM Division subscription
*** History: 01/06/2014 - rsanka1x - Created Procedure
***
*** Copyright 2014 Intel Corporation, all rights reserved.
******************************************************************************************************************/
BEGIN 
	SET NOCOUNT ON	 
	DECLARE @scb_idn INT
   	
	BEGIN TRY
		SELECT	@scb_idn = ISNULL(scb_idn, 0)			
		FROM OPENXML(@idoc, N'ROOT', 2)	WITH (scb_idn INT)
			  
		BEGIN TRANSACTION

			Delete from scb_detail where scb_idn=@scb_idn
			Delete from scb_definition_summary where scb_idn=@scb_idn
			Delete from scb_definition where scb_idn=@scb_idn	
				
		COMMIT TRANSACTION
	END TRY
		BEGIN CATCH  
			SELECT 'error'
			IF @@TRANCOUNT > 0 ROLLBACK
		END CATCH
END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON
GO