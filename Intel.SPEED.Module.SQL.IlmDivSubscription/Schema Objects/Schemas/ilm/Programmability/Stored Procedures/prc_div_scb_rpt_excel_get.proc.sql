SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE [object_id] = object_id(N'[dbo].[prc_div_scb_rpt_excel_get]') AND [type] = 'P')	
	DROP PROCEDURE [dbo].[prc_div_scb_rpt_excel_get]
GO
  
CREATE PROCEDURE [dbo].[prc_div_scb_rpt_excel_get]  
(  
     @evnt_idns  VARCHAR(MAX)  
)    
AS  
/*************************************************************************  
***    File: prc_div_scb_rpt_excel_get  
*** Purpose: Retrieve Data for Excel Rendering for Division Summary Report  
*** History: KFKoh		08/30/10    Created Procedure  
***			 beelengy	02/13/2014	Updated
*** Copyright 2010 Intel Corporation, all rights reserved.  
**************************************************************************/  
BEGIN    
 SET NOCOUNT ON  

 DECLARE @tbl TABLE(evnt_idn INT)  
      
 INSERT INTO @tbl (evnt_idn)  
 SELECT * FROM dbo.fnSplitString (@evnt_idns, ',')  
   
 SELECT  
   i.exc_nme							AS [Issue Number]      -- Issue Number  
  ,mrl.title							AS [Status]            -- Status  
  ,orig.bookname						AS [Originator]        -- Issue Originator  
  ,prob_ownr.bookname					AS [Problem Owner]     -- Problem Owner   
  ,CONVERT(VARCHAR, e.cre_dte,100)		AS [Create Date (PST)] -- Issue Create Date  
  ,ref_iss_src.dsc						AS [Issue Source]      -- Issue Source  
  ,iss.iss_typ_dsc                      AS [Excursion Type]    -- Excursion Type  
  ,ISNULL(ref_lvl.dsc, '')				AS [Level]             -- Level  
  ,ref_symp.dsc							AS [Symptom]           -- Symptom  
  ,div_product.prod_fmly				AS [Product Family]    -- Product Family  
 FROM ilm.division_issue	AS div  
 JOIN ilm.issue				AS i		  ON i.evnt_idn = div.evnt_idn
 JOIN ilm.event				AS e		  ON e.evnt_idn = div.evnt_idn
 JOIN ilm.module_rls_lvl   AS mrl         ON i.lvl_idn = mrl.lvl_idn AND mrl.module_nme = 'DIVISION_ISSUE'  
 JOIN ilm.users            AS orig        ON orig.usr_acct = i.orig_usr  
 JOIN ilm.event_notif_list AS enl         ON div.evnt_idn = enl.evnt_idn AND enl.lkup_psn_rol_idn = 106488    
 JOIN ilm.users            AS prob_ownr   ON enl.usr_acct = prob_ownr.usr_acct    
 JOIN ilm.ref_lookup       AS ref_iss_src ON ref_iss_src.lkup_idn = div.lkup_iss_src_idn AND ref_iss_src.att_idn = 774  
 JOIN ilm.issue_type		AS iss ON iss.iss_typ_idn = i.iss_typ_idn
 LEFT OUTER JOIN ref_lookup AS ref_symp  ON ref_symp.lkup_idn = div.lkup_symp_idn AND ref_symp.att_idn = 775  
 LEFT OUTER JOIN ref_lookup AS ref_lvl   ON ref_lvl.lkup_idn = i.lkup_risk_idn AND ref_lvl.att_idn = 776  
 LEFT OUTER JOIN  
 (  
  SELECT evnt_idn, espeed.dbo.fnConcatFld(prod_fmly) AS prod_fmly  
  FROM espeed.dbo.vw_div_prod_qry  
  WHERE evnt_idn IN (SELECT evnt_idn FROM @tbl)  
  GROUP BY evnt_idn  
 ) AS div_product ON div.evnt_idn = div_product.evnt_idn  
 WHERE div.evnt_idn IN (SELECT evnt_idn FROM @tbl)  
 

 
END  