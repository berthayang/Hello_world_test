-------------------------------------------------------------------------------
-- One time Migration script for Division Subscription
-- rsanka1x	01/08/2014	Created
-- 
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------------------------

USE speed
GO


-- variables declaration

DECLARE @exc_fields TABLE
		(row					INT IDENTITY
		,div_log_col_nme		VARCHAR(50)		NULL
		,ilm_div_log_col_nme	VARCHAR(50)		NULL)
		
DECLARE @row					INT
		,@div_log_col_nme		VARCHAR(50)
		,@ilm_div_log_col_nme	VARCHAR(50)
		,@div_col_idn				INT
		,@ilm_div_col_idn				INT


INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'cre_dte','div_start_dte'
	
INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'iss_orig_usr','div_orig_usr'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'iss_scr','div_iss_src'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'div_exc_typ','div_exc_typ'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'div_prod_cls','prod_cls'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'risk_lvl','div_lvl'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'symp','div_symp'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'plc_phs','div_plc_phs'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'prod_fmly','div_prod_fmly'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'bus_unit','div_bus_unit'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'overall_risk_score','div_risk_scre'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'div_root_cause','div_prim_rc'
	
INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'sub_rc','div_sub_rc'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'div_escp_pnt','div_escp_pnt'
	
INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'cirs_svrty','div_svr_type'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'div_status','div_status'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'prob_ownr_usr_acct','div_pblm_owner'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'cls_apprv_usr_acct','div_clsure_aprvr'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'linked_to_prt','div_linked_prt'
	
INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'linked_to_cirs_issue','div_linked_cirs'

INSERT @exc_fields (div_log_col_nme, ilm_div_log_col_nme) 
	SELECT 'div_linked_qan','div_linked_qan'
	
SELECT @row = MIN(row) FROM @exc_fields

WHILE @row IS NOT NULL
BEGIN

	SELECT @div_log_col_nme = div_log_col_nme, @ilm_div_log_col_nme= ilm_div_log_col_nme 
	FROM @exc_fields 
	WHERE row = @row
	
	IF(@div_log_col_nme != @ilm_div_log_col_nme)
	BEGIN
	
		SELECT @div_col_idn = col_idn 
		FROM scb_column
		WHERE log_col_nme = @div_log_col_nme
				
		SELECT @ilm_div_col_idn = col_idn 
		FROM scb_column
		WHERE log_col_nme = @ilm_div_log_col_nme
				
		UPDATE scb_detail SET col_idn = @ilm_div_col_idn
		WHERE col_idn = @div_col_idn
	END
	
	SELECT @row = MIN(row) FROM @exc_fields where row > @row
END

--issue type data migration

  UPDATE scb_detail SET col_id = (SELECT iss_typ_idn FROM ilm.issue_type WHERE mdul_idn=173 and iss_typ_dsc='MRB')
	FROM scb_detail  sd  
  JOIN scb_column sc  ON sc.col_idn=sd.col_idn where log_col_nme='div_exc_typ' AND col_val ='MRB'
  
    UPDATE scb_detail SET col_id = (SELECT iss_typ_idn FROM ilm.issue_type WHERE mdul_idn=173 and iss_typ_dsc='DRB')
	FROM scb_detail  sd  
  JOIN scb_column sc  ON sc.col_idn=sd.col_idn where log_col_nme='div_exc_typ' AND col_val ='DRB'

GO