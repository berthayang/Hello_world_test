-------------------------------------------------------------------------------
-- View created for cheking the linked status in subscription module
-- rsanka1x	01/09/2014	Created
-- 
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------------------------

USE [speed]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[ilm].[div_related_event_indicator]'))
DROP VIEW [ilm].[div_related_event_indicator]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [ilm].[div_related_event_indicator]
AS 
  SELECT  
  evnt_idn  
  ,(CASE  
   WHEN EXISTS   
   (  
    SELECT TOP 1 evnt_idn  
    FROM ilm.event_relations
    WHERE rltd_mdul_idn = 56  
    AND evnt_idn = div.evnt_idn  
   ) THEN 'Y'  
   ELSE 'N'  
  END) AS is_linked_to_cirs  
  ,(CASE  
   WHEN EXISTS   
   (  
    SELECT TOP 1 evnt_idn  
    FROM ilm.event_relations
    WHERE rltd_mdul_idn = 142  
    AND evnt_idn = div.evnt_idn  
   ) THEN 'Y'  
   ELSE 'N'  
  END) AS is_linked_to_prt  
  ,(CASE  
   WHEN EXISTS   
   (  
    SELECT TOP 1 evnt_idn  
    FROM ilm.event_qan_relations
    WHERE  evnt_idn = div.evnt_idn  
   ) THEN 'Y'  
   ELSE 'N'  
  END) AS is_linked_to_qan 
 FROM ilm.division_issue AS div  
GO


