SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[prc_div_scb_process]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[prc_div_scb_process]
GO

  
CREATE PROCEDURE [dbo].[prc_div_scb_process]    
(      
     @scb_idn    INT    
    ,@rpt_dur    INT    
    ,@today      DATETIME    
    ,@notify_idn INT          OUTPUT    
    ,@evnt_idns  VARCHAR(MAX) OUTPUT    
)      
AS    
/*************************************************************************    
***    File: prc_div_scb_process    
*** Purpose: Process single Division Summary Report Subscription      
*** History: KFKoh   08/30/10    Created Procedure    
*** rsanka1x	02/13/2014	Issue fix single column with multiple values
***
*** Copyright 2010 - 2014 Intel Corporation, all rights reserved.    
**************************************************************************/    
BEGIN      
 SET NOCOUNT ON    
    
 DECLARE      
   @batch_id        INT    
  ,@row_nbr         INT    
  ,@sql_query       VARCHAR(MAX)    
  ,@where_clause    VARCHAR(MAX)    
  ,@join_definition VARCHAR(MAX)    
  ,@error_msg       VARCHAR(MAX)    
  ,@parm_list       VARCHAR(MAX)    
  ,@col_idn         INT    
  ,@status_msg      VARCHAR(MAX)    
  ,@row_count       INT      
      
    /** Status Variable to report the current Subscription Process Status **/    
    SET @status_msg = ''      
 SET @batch_id = 0    
     
 /**************************************************    
 ** Temporary table to hold matching Division Issue    
 ***************************************************/    
    CREATE TABLE #temp_ids    
    (    
   batch_id INT    
  ,evnt_idn INT    
    )    
    
    /*****************************************************    
     ** Temporary table to hold criteria entered by user    
     *****************************************************/    
    CREATE TABLE #temp_criteria    
    (    
   row_nbr  INT IDENTITY(1, 1)    
  ,col_idn  INT    
  ,criteria VARCHAR(1000)    
  ,join_def VARCHAR(7000)    
    )        
      
    /** Get Division Issues in which Report Day fall in user entered duration based on Create Date **/      
 INSERT INTO #temp_ids(batch_id, evnt_idn)      
 SELECT @batch_id, di.evnt_idn    
 FROM ilm.event e  
 JOIN ilm.division_issue di ON e.evnt_idn=di.evnt_idn    
 WHERE DATEDIFF(dd, e.cre_dte, @today ) <= @rpt_dur        
      
    /** Retrieve all criteria entered by user for the current subscription **/      
    INSERT INTO #temp_criteria(criteria, join_def, col_idn)      
 SELECT    
  CASE UPPER(data_type)      
   WHEN 'INT' THEN phy_tbl_nme + '.' + phys_col_nme + '=' + col_id      
   WHEN 'SMALLINT' THEN phy_tbl_nme + '.' + phys_col_nme + '=' + col_id      
   ELSE phy_tbl_nme + '.' + phys_col_nme + '=''' + col_id + ''''      
  END AS criteria    
  ,join_definition    
  ,col.col_idn      
 FROM scb_detail     AS dtl       
 JOIN scb_definition AS def ON dtl.scb_idn = def.scb_idn      
 JOIN scb_column     AS col ON dtl.col_idn = col.col_idn      
 WHERE def.scb_idn = @scb_idn  
 ORDER BY col_idn   
  
    /** Filter out Division Issue based on user selected criteria in one-by-one basis **/      
 SELECT @row_nbr = COUNT(col_idn) FROM #temp_criteria    
    
 WHILE @row_nbr > 0 AND EXISTS (SELECT TOP 1 evnt_idn FROM #temp_ids)    
    BEGIN      
  /** Get Criteria & Join **/    
  SELECT    
    @where_clause    = criteria    
   ,@join_definition = join_def    
   ,@col_idn         = col_idn      
  FROM #temp_criteria       
  WHERE row_nbr = @row_nbr    
  
  /** Build evaluation SQL Query **/      
  SET @sql_query = 'SELECT division_issue.evnt_idn, ' + CAST((@batch_id + 1)AS VARCHAR(10)) + CHAR(10)      
               + ' FROM ilm.division_issue ' + ISNULL(@join_definition, '')     + CHAR(10)      
               + ' WHERE division_issue.evnt_idn IN ('                      + CHAR(10)      
               + '       SELECT evnt_idn FROM #temp_ids '                    + CHAR(10)      
               + '       WHERE batch_id = ' + CAST(@batch_id AS VARCHAR(10)) + CHAR(10)    
               + ')  AND ' + @where_clause      
 
        /** Insert matching Division Issue **/      
  INSERT INTO #temp_ids(evnt_idn, batch_id)      
  EXEC(@sql_query)      
        
  IF @@error != 0      
  BEGIN      
   /** Dynamic Query Error**/      
   SET @status_msg = 'Dynamic Query Error. Col ID : ' + CAST(@col_idn AS VARCHAR(3))      
    + ' Query : ''' + @sql_query + ''''      
   GOTO err_routine      
  END   
  
  /** Delete Temp ID by batch **/     
  IF(NOT EXISTS (SELECT * FROM #temp_criteria WHERE row_nbr < @row_nbr AND col_idn = @col_idn))
  BEGIN
	DELETE FROM #temp_ids WHERE batch_id = @batch_id      
	SET @batch_id = @batch_id + 1 
  END
  SET @row_nbr = @row_nbr - 1      
           
END      
      
    /** Get number of matching Division Issue **/      
    SELECT @row_count = COUNT(DISTINCT evnt_idn) FROM #temp_ids    
      
    /** Send summary report notification **/      
    IF @row_count > 0     
    BEGIN    
        /** Clear Parameter list **/      
        SET @parm_list = ''    
        SET @evnt_idns = ''    
       
        SELECT @evnt_idns = @evnt_idns + CAST(evnt_idn AS VARCHAR(20)) + ',' FROM #temp_ids    
        ORDER BY evnt_idn DESC    
      
        /** Build the full parameter string for the notification **/      
  SET @parm_list = '@scb_idn=' + CAST(@scb_idn AS VARCHAR(20))    
      
        /** Invoke notification **/      
  EXEC [dbo].[prc_notify_com]    
    @event_nme   = 'DIV_SUMMARY_REPORT'    
   ,@cur_usr_idn = 'SYSTEM'    
   ,@parm_list   = @parm_list    
   ,@cca_flg     = 'Y'    
   ,@req_sts     = 'P'    
   ,@notify_idn  = @notify_idn OUTPUT    
   ,@error_msg   = @error_msg  OUTPUT    
         
  IF @error_msg != ''      
  BEGIN      
   /** Notification SP Error **/      
   SET @status_msg = 'Notification Error: ' + @error_msg      
   GOTO err_routine      
  END    
   
  UPDATE notification_request    
  SET request_status = 'C'    
  WHERE notify_idn = @notify_idn      
    END      
      
    PRINT 'Number of Division Issue found : ' + CAST(@row_count AS VARCHAR(10))      
    DROP TABLE #temp_criteria      
    DROP TABLE #temp_ids      
    RETURN 0      
      
err_routine:      
    PRINT 'Error: Subscription ' + CAST(@scb_idn AS VARCHAR(10)) + '. Desc: ' + @status_msg      
    DROP TABLE #temp_criteria      
    DROP TABLE #temp_ids      
    RETURN -1      
      
END 
GO


