SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ilm].[prc_div_products_slctr]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ilm].[prc_div_products_slctr]
GO
    
CREATE PROCEDURE [ilm].[prc_div_products_slctr]      
(      
   @XmlDoc NVARCHAR(MAX)        
  ,@debug CHAR(1) = 'Y'        
) AS      
/******************************************************************************    
***	Purpose: Division product selector     
***	History: 01/24/14 rsanka1x crated
*** 
***	Copyright 2014 Intel Corporation, all rights reserved.   
*******************************************************************************/      
BEGIN        
	 SET NOCOUNT ON        
	 /** report navigation variables **/      
	 DECLARE @FirstRow INT    /** starting row number in current report page  **/      
	   ,@MaxRows INT    /** maximum number of rows shown on a page   **/      
	   ,@RowQty INT    /** total number of rows found in search   **/       
	   ,@idoc  INT    /** parsed XML document number      **/      
	   ,@sql_stmt  VARCHAR(Max) /** dynamic SQL statement to be executed   **/ 
	   ,@sql_where  VARCHAR(Max) /** dynamic SQL where clause to be executed   **/      
	   /** report filtering variables **/      
	   ,@prdt_nme  VARCHAR(255) /** filter value for product name      **/     
	   ,@lcid  VARCHAR(40)	
	   ,@usr_acct  CHAR(8)          
	   ,@onload CHAR(1) -- indicate first load or onchange	 
		
	 DECLARE @mdul_idn INT = 173 --Division
	 DECLARE @prf_idn INT = 7000 --ilm_prf_organization
	       
	 CREATE TABLE #srch      
	   (row_nbr  INT IDENTITY      
	   ,prdt_nme  CHAR(200)          
	   )      
	      
	 /******************************************************      
	 *** load parameters from common XML document parameter ***/        
	 EXEC sp_xml_preparedocument @idoc OUTPUT, @XmlDoc      
	      
	 /******************************************************      
	 *** authenticate user  ***/      
	EXEC prc_get_idsid_login @idoc = @idoc  
						,@XmlDoc   = @XmlDoc  
						,@usr_acct = @usr_acct OUTPUT  
						,@lcid     = @lcid     OUTPUT      
	      
	 SELECT @prdt_nme = NULLIF(prdt_nme , '') 
		 ,@FirstRow= NULLIF([FirstRow] ,  0)      
		 ,@MaxRows = NULLIF(MaxRows ,  0)  
		 ,@onload  = NULLIF(onload, '')   	
		
	 FROM OPENXML(@idoc, 'ROOT', 2) WITH       
	 ( prdt_nme VARCHAR(255)      
		,wwid  VARCHAR(255)      
		,[FirstRow] INT      
		,MaxRows  INT  
		,onload  CHAR(1)    
		,evnt_idn INT
		,ctrlnme CHAR(1)  
	 )    
	 
	 /******************************************************      
	 *** set dynamic where clause  **/        
	 SET @sql_stmt = ''     
	 SET @sql_where = '' 

	 /** OR filtering **/      
	 IF @prdt_nme IS NOT NULL      
	 BEGIN      
		  SET @prdt_nme = UPPER(@prdt_nme)      
		  SET @prdt_nme = REPLACE(@prdt_nme, '''', '''''')      
		  IF @sql_where <> '' SET @sql_where = @sql_where + ' OR'      
		  SET @sql_where = @sql_where + ' UPPER(pd.prdt_nme) LIKE ''' + @prdt_nme + '''' + CHAR(10)      
	 END    

	 SET @sql_stmt = 'INSERT INTO #srch'    + CHAR(10)      
	   + '    (prdt_nme'        + CHAR(10)   
	   + '    )'    + CHAR(10)      
	   + ' SELECT * FROM '    + CHAR(10)
			 + ' (SELECT DISTINCT mbmr.fmly_dsc AS prdt_nme '    + CHAR(10)
			 + ' FROM exc_pkg_prod '    + CHAR(10)          
			 + ' JOIN mat_material    AS mm   ON exc_pkg_prod.item_cde = mm.mat_id '    + CHAR(10)              
			 + ' JOIN mat_bse_mkt_rup AS mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm '    + CHAR(10)
			 + ' LEFT JOIN uda_item AS uda_die_cde_nm ON mm.mat_id = uda_die_cde_nm.item_cde AND uda_die_cde_nm.att_idn = 10234 '    + CHAR(10)    
			 + ' LEFT JOIN uda_item AS uda_mkt_cde_nm ON mm.mat_id = uda_mkt_cde_nm.item_cde AND uda_mkt_cde_nm.att_idn = 12606 '    + CHAR(10)   
			 + ' LEFT JOIN uda_item AS uda_revision   ON mm.mat_id = uda_revision.item_cde AND uda_revision.att_idn = 10231 '    + CHAR(10)     
			 + ' LEFT JOIN uda_item AS uda_ext_step   ON mm.mat_id = uda_ext_step.item_cde AND uda_ext_step.att_idn = 12347 '    + CHAR(10)     
			 + ' LEFT JOIN uda_item AS uda_pkg_tech ON mm.mat_id = uda_pkg_tech.item_cde AND uda_pkg_tech.att_idn = 12063 '    + CHAR(10)    
			 + ' LEFT JOIN uda_item AS uda_fab_prc ON uda_fab_prc.item_cde=mm.mat_id and uda_fab_prc.att_idn in (11885,12608,12066) '    + CHAR(10) 
		 
			+ ' UNION '    + CHAR(10)
			+ ' SELECT  DISTINCT mbmr.fmly_dsc '    + CHAR(10)
			 + ' FROM cirs_issue_prod '    + CHAR(10)
			 + ' JOIN mat_material    AS mm   ON cirs_issue_prod.item_cde = mm.mat_id '    + CHAR(10)           
			 + ' JOIN mat_bse_mkt_rup AS mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm '    + CHAR(10)  
			 + ' LEFT JOIN uda_item AS uda_die_cde_nm ON mm.mat_id = uda_die_cde_nm.item_cde AND uda_die_cde_nm.att_idn = 10234 '    + CHAR(10)     
			 + ' LEFT JOIN uda_item AS uda_mkt_cde_nm ON mm.mat_id = uda_mkt_cde_nm.item_cde AND uda_mkt_cde_nm.att_idn = 12606 '    + CHAR(10)    
			 + ' LEFT JOIN uda_item AS uda_revision   ON mm.mat_id = uda_revision.item_cde AND uda_revision.att_idn = 10231 '    + CHAR(10)    
			 + ' LEFT JOIN uda_item AS uda_ext_step   ON mm.mat_id = uda_ext_step.item_cde AND uda_ext_step.att_idn = 12347 '    + CHAR(10)    
			 + ' LEFT JOIN uda_item AS uda_pkg_tech ON mm.mat_id = uda_pkg_tech.item_cde AND uda_pkg_tech.att_idn = 12063 '    + CHAR(10)      
			 + ' LEFT JOIN uda_item AS uda_fab_prc ON uda_fab_prc.item_cde=mm.mat_id and uda_fab_prc.att_idn in (11885,12608,12066) '    + CHAR(10)  
		    
			+ ' UNION '    + CHAR(10)
			+ ' SELECT DISTINCT mbmr.fmly_dsc '    + CHAR(10)
			 + ' FROM mat_material AS mm '    + CHAR(10)      
			 + ' JOIN mat_bse_mkt_rup as mbmr ON mm.bse_prd_nm = mbmr.bse_prd_nm '    + CHAR(10)  
			 + ' LEFT JOIN uda_item AS uda_die_cde_nm ON mm.mat_id = uda_die_cde_nm.item_cde AND uda_die_cde_nm.att_idn = 10234 '    + CHAR(10) 
			 + ' LEFT JOIN uda_item AS uda_mkt_cde_nm ON mm.mat_id = uda_mkt_cde_nm.item_cde AND uda_mkt_cde_nm.att_idn = 12606 '    + CHAR(10) 
			 + ' LEFT JOIN uda_item AS uda_revision   ON mm.mat_id = uda_revision.item_cde AND uda_revision.att_idn = 10231 '    + CHAR(10)      
			 + ' LEFT JOIN uda_item AS uda_ext_step   ON mm.mat_id = uda_ext_step.item_cde AND uda_ext_step.att_idn = 12347 '    + CHAR(10)      
			 + ' LEFT JOIN uda_item AS uda_pkg_tech   ON mm.mat_id = uda_pkg_tech.item_cde AND uda_pkg_tech.att_idn = 12063 '    + CHAR(10)     
			 + ' LEFT JOIN uda_item AS uda_fab_prc    ON uda_fab_prc.item_cde=mm.mat_id and uda_fab_prc.att_idn in (11885,12608,12066) '    + CHAR(10) 
			 + ' JOIN ilm.division_product ON mm.mat_id = ilm.division_product.item_cde '    + CHAR(10)

			+ ' UNION '    + CHAR(10)
			+ ' SELECT DISTINCT cosmiq.prod_fmly '    + CHAR(10)
			+ ' FROM cosmiq_platform_product AS cosmiq '    + CHAR(10)    
			+ ' JOIN ilm.division_product ON cosmiq.item_id = ilm.division_product.item_id)pd '    + CHAR(10)
		   + ' WHERE ' + CHAR(10)  
		   +  @sql_where + CHAR(10)  
		   + ' ORDER BY pd.prdt_nme'   
				   
	 /** perform dynamic query **/      
	 IF @debug = 'Y'      
	  PRINT @sql_stmt      
	      
	 EXECUTE(@sql_stmt)      
	 SET @RowQty = @@ROWCOUNT      
	      
	 /** validate first row shown (cursor control) **/        
	 IF @FirstRow >= @RowQty SET @FirstRow = @RowQty - @MaxRows + 1        
	 IF @FirstRow < 1  SET @FirstRow = 1        
	         
      
	 SELECT NULL AS [<TABLENAME>Search_rows</TABLENAME>]      
		,prdt_nme  
	   FROM #srch      
	  WHERE row_nbr >= @FirstRow      
		AND row_nbr <  @FirstRow + @MaxRows      
	  ORDER BY row_nbr      


	 /** return search results report object properties  **/        
	 SELECT NULL  AS [<TABLENAME>Search_nav</TABLENAME>]      
	   ,@RowQty AS [<RowQty>]      
	   ,@MaxRows AS [<MaxRows>]      
	   ,MIN(row_nbr) AS [<FirstRow>]      
	   ,MAX(row_nbr) AS [<LastRow>]      
	   FROM #srch      
	  WHERE row_nbr >= @FirstRow      
		AND row_nbr <  @FirstRow + @MaxRows      
	      
	 DROP TABLE #srch


	 IF @@error != 0 SELECT @@error as error, 'Stored procedure prc_div_products_slctr failure.' AS msg  
		RETURN @@error  

	SET NOCOUNT OFF    
END    

GO


