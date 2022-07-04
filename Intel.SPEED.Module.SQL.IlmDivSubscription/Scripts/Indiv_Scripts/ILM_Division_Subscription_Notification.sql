--  rsanka1x 01/06/2014 ILM Division Item - Subscription Reporting in Portal

USE speed_2max
GO

IF NOT EXISTS (SELECT * FROM dbo.ref_lookup_attribute WHERE att_idn = 1110)
	INSERT INTO dbo.ref_lookup_attribute(att_idn, dsc, alw_upd_ind, dflt_ctrl_ctry_accs_ind, case_sensitive_ind)
	VALUES(1110,'Subscription Type in ILM Division', 'N','Y', 'N')

IF NOT EXISTS (SELECT * FROM dbo.ref_lookup_module WHERE att_idn = 1110 AND mdul_idn =173)
	INSERT INTO dbo.ref_lookup_module(att_idn, mdul_idn, alw_upd_ind)
	VALUES(1110, 173 , 'N')

PRINT 'Create Reference Lookup: Email'
IF NOT EXISTS (SELECT * FROM ref_lookup WHERE lkup_idn =171092)
   INSERT INTO ref_lookup (lkup_idn, att_idn, dsc, 
			srt_ord, curr_actv_ind, ctrl_ctry_accs_ind, cre_dte, lst_upd_dte, 
			upd_usr_acct, alw_upd_ind, display_ind, usr_def_attr)
      SELECT 171092,1110,'Email',
			1,'Y','Y',GETDATE(),GETDATE(),
			'SYSTEM','N','N',NULL
			
PRINT 'Create Reference Lookup: Portal'
IF NOT EXISTS (SELECT * FROM ref_lookup WHERE lkup_idn = 171090)
   INSERT INTO ref_lookup (lkup_idn, att_idn, dsc, 
			srt_ord, curr_actv_ind, ctrl_ctry_accs_ind, cre_dte, lst_upd_dte, 
			upd_usr_acct, alw_upd_ind, display_ind, usr_def_attr)
      SELECT 171090,1110,'Portal',
			2,'Y','Y',GETDATE(),GETDATE(),
			'SYSTEM','N','N',NULL
			
PRINT 'Create Reference Lookup: Both Email and Portal'
IF NOT EXISTS (SELECT * FROM ref_lookup WHERE lkup_idn = 171091)
   INSERT INTO ref_lookup (lkup_idn, att_idn, dsc, 
			srt_ord, curr_actv_ind, ctrl_ctry_accs_ind, cre_dte, lst_upd_dte, 
			upd_usr_acct, alw_upd_ind, display_ind, usr_def_attr)
      SELECT 171091,1110,'Both Email and Portal',
			3,'Y','Y',GETDATE(),GETDATE(),
			'SYSTEM','N','N',NULL

PRINT 'Create Reference Lookup: ilm.prc_div_products_slctr'
IF NOT EXISTS (SELECT * FROM ref_lookup WHERE lkup_idn =171097)
   INSERT INTO ref_lookup (lkup_idn, att_idn, dsc, 
			srt_ord, curr_actv_ind, ctrl_ctry_accs_ind, cre_dte, lst_upd_dte, 
			upd_usr_acct, alw_upd_ind, display_ind, usr_def_attr)
      SELECT 171097,1036,'ilm.prc_div_products_slctr',
			NULL,'Y','N',GETDATE(),GETDATE(),
			'SYSTEM','N','N',NULL