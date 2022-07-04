SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ilm].[prc_get_business_unit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ilm].[prc_get_business_unit]
GO

CREATE  PROCEDURE [ilm].[prc_get_business_unit]
(  
	@active_ind CHAR(1) = 'A'  
	,@curr_idn  VARCHAR(200) = ''  
) AS  
/******************************************************************************
*** Purpose: To get all the business units
*** History: rsanka1x	01/22/2014	Created
***
*** Copyright 2014 Intel Corporation, all rights reserved.
*******************************************************************************/
BEGIN
	DECLARE @query NVARCHAR(4000) = ''

	SET @query = 'SELECT * FROM(
		SELECT DISTINCT mbmr.prd_div_dsc AS lkup_val, mbmr.prd_div_dsc as dsc          
		 FROM exc_pkg_prod          
		 JOIN mat_material    AS mm   ON exc_pkg_prod.item_cde = mm.mat_id              
		 JOIN mat_bse_mkt_rup AS mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm
		 LEFT JOIN uda_item AS uda_die_cde_nm ON mm.mat_id = uda_die_cde_nm.item_cde AND uda_die_cde_nm.att_idn = 10234    
		 LEFT JOIN uda_item AS uda_mkt_cde_nm ON mm.mat_id = uda_mkt_cde_nm.item_cde AND uda_mkt_cde_nm.att_idn = 12606   
		 LEFT JOIN uda_item AS uda_revision   ON mm.mat_id = uda_revision.item_cde AND uda_revision.att_idn = 10231     
		 LEFT JOIN uda_item AS uda_ext_step   ON mm.mat_id = uda_ext_step.item_cde AND uda_ext_step.att_idn = 12347     
		 LEFT JOIN uda_item AS uda_pkg_tech ON mm.mat_id = uda_pkg_tech.item_cde AND uda_pkg_tech.att_idn = 12063    
		 LEFT JOIN uda_item AS uda_fab_prc ON uda_fab_prc.item_cde=mm.mat_id and uda_fab_prc.att_idn in (11885,12608,12066) 
	 
		UNION
		SELECT  DISTINCT mbmr.prd_div_dsc, mbmr.prd_div_dsc          
		 FROM cirs_issue_prod       
		 JOIN mat_material    AS mm   ON cirs_issue_prod.item_cde = mm.mat_id           
		 JOIN mat_bse_mkt_rup AS mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm  
		 LEFT JOIN uda_item AS uda_die_cde_nm ON mm.mat_id = uda_die_cde_nm.item_cde AND uda_die_cde_nm.att_idn = 10234     
		 LEFT JOIN uda_item AS uda_mkt_cde_nm ON mm.mat_id = uda_mkt_cde_nm.item_cde AND uda_mkt_cde_nm.att_idn = 12606    
		 LEFT JOIN uda_item AS uda_revision   ON mm.mat_id = uda_revision.item_cde AND uda_revision.att_idn = 10231    
		 LEFT JOIN uda_item AS uda_ext_step   ON mm.mat_id = uda_ext_step.item_cde AND uda_ext_step.att_idn = 12347    
		 LEFT JOIN uda_item AS uda_pkg_tech ON mm.mat_id = uda_pkg_tech.item_cde AND uda_pkg_tech.att_idn = 12063      
		 LEFT JOIN uda_item AS uda_fab_prc ON uda_fab_prc.item_cde=mm.mat_id and uda_fab_prc.att_idn in (11885,12608,12066)  
	    
		UNION
		SELECT DISTINCT mbmr.prd_div_dsc, mbmr.prd_div_dsc  
		 FROM mat_material AS mm      
		 JOIN mat_bse_mkt_rup as mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm  
		  LEFT JOIN uda_item AS uda_die_cde_nm ON mm.mat_id = uda_die_cde_nm.item_cde AND uda_die_cde_nm.att_idn = 10234 
		 LEFT JOIN uda_item AS uda_mkt_cde_nm ON mm.mat_id = uda_mkt_cde_nm.item_cde AND uda_mkt_cde_nm.att_idn = 12606 
		 LEFT JOIN uda_item AS uda_revision   ON mm.mat_id = uda_revision.item_cde AND uda_revision.att_idn = 10231      
		 LEFT JOIN uda_item AS uda_ext_step   ON mm.mat_id = uda_ext_step.item_cde AND uda_ext_step.att_idn = 12347      
		 LEFT JOIN uda_item AS uda_pkg_tech   ON mm.mat_id = uda_pkg_tech.item_cde AND uda_pkg_tech.att_idn = 12063     
		 LEFT JOIN uda_item AS uda_fab_prc    ON uda_fab_prc.item_cde=mm.mat_id and uda_fab_prc.att_idn in (11885,12608,12066) 
		 JOIN ilm.division_product ON mm.mat_id = ilm.division_product.item_cde

		UNION
		SELECT DISTINCT cosmiq.bus_unit,cosmiq.bus_unit
		FROM cosmiq_platform_product AS cosmiq    
		JOIN ilm.division_product ON cosmiq.item_id = ilm.division_product.item_id)tmp
	WHERE tmp.dsc !='''''

	If @curr_idn !=''
	BEGIN
		SET @query = @query + ' AND tmp.lkup_val = '''+ @curr_idn + ''''
	END

	EXEC sp_executesql @query

	IF @@error != 0 SELECT @@error AS error, 'Stored procedure prc_get_business_unit failure.' AS msg
	RETURN @@error	

	SET NOCOUNT OFF
END  

GO


