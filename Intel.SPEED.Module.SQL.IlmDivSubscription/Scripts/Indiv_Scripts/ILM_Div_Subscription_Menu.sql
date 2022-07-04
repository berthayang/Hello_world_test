-- SPEED Menu script

USE speed_web
SET NOCOUNT ON
GO

BEGIN TRANSACTION

-- Create key list tables for affected menu data

CREATE TABLE #groups_affected (group_id INT NOT NULL PRIMARY KEY)
CREATE TABLE #page_affected (page_id INT NOT NULL PRIMARY KEY)
CREATE TABLE #menu_detail_affected (menu_seq_id INT NOT NULL PRIMARY KEY)

-- Fill key list tables

-- Populate key list tables for affected menu data

INSERT #menu_detail_affected (menu_seq_id) VALUES(9023)

-- Add any orphan menus belonging to affected group to #menu_detail_affected

INSERT #menu_detail_affected (menu_seq_id) 
SELECT DISTINCT menu_seq_id FROM menu m 
JOIN #groups_affected g ON m.group_id = g.group_id 
WHERE NOT EXISTS (SELECT * FROM #menu_detail_affected x WHERE x.menu_seq_id = m.menu_seq_id)
INSERT #menu_detail_affected (menu_seq_id) 
SELECT DISTINCT relate_seq_id FROM menu m 
JOIN #groups_affected g ON m.group_id = g.group_id 
WHERE NOT EXISTS (SELECT * FROM #menu_detail_affected x WHERE x.menu_seq_id = m.relate_seq_id)
AND m.relate_seq_id IS NOT NULL

-- Delete related menu records from menu

DELETE dbo.menu WHERE relate_seq_id IN (SELECT menu_seq_id FROM #menu_detail_affected)

-- Delete menu records from menu

DELETE dbo.menu WHERE menu_seq_id IN (SELECT menu_seq_id FROM #menu_detail_affected)

-- Delete group_menu_tree records

IF EXISTS (SELECT * FROM speed_web.sys.tables WHERE name = 'group_menu_tree')
DELETE gm FROM dbo.group_menu_tree gm WHERE EXISTS (SELECT * FROM #groups_affected g WHERE gm.group_id = g.group_id) 
OR EXISTS (SELECT * FROM #menu_detail_affected m WHERE gm.menu_seq_id = m.menu_seq_id)

-- Delete page_menu_tree records

IF EXISTS (SELECT * FROM speed_web.sys.tables WHERE name = 'page_menu_tree')
DELETE pm FROM dbo.page_menu_tree pm 
WHERE EXISTS (SELECT * FROM #page_affected p WHERE pm.page_id = p.page_id) 
OR EXISTS (SELECT * FROM #menu_detail_affected m WHERE pm.menu_seq_id = m.menu_seq_id)

-- Delete page_menu records

DELETE pm FROM dbo.page_menu pm 
WHERE EXISTS (SELECT * FROM #page_affected p WHERE pm.page_id = p.page_id) 
OR EXISTS (SELECT * FROM #menu_detail_affected m WHERE pm.menu_seq_id = m.menu_seq_id)

-- Delete page records

DELETE dbo.page WHERE page_id IN (SELECT page_id FROM #page_affected)

-- Delete the menu detail

DELETE dbo.menu_detail WHERE menu_seq_id IN (SELECT menu_seq_id FROM #menu_detail_affected)

-- Delete the groups

DELETE dbo.groups WHERE group_id IN (SELECT group_id FROM #groups_affected)

-- Delete related menu records from url_loc

DELETE dbo.url_loc WHERE url_id NOT IN (SELECT menu_url_id FROM menu_detail)
AND url_id NOT IN (SELECT section_url_id FROM section_details)
AND url_id NOT IN (SELECT url_id FROM news)
AND url_id NOT IN (SELECT url_id FROM cmt)

-- Insert url_loc records

IF EXISTS (SELECT * FROM url_loc WHERE url_id = 8790) 
	UPDATE dbo.url_loc 
SET url_hyperlink ='javascript:SpeedPage.fnGoToMenuItem(''/Intel.SPEED.Module.Web.IlmDivSubscription/pages/ilm_div_subscription.aspx'',''_self'',false);',target=NULL,url_friendly_nm='MODULE:Division Issue, PAGE:ILM Top Navigation, ITEM:Su',event_script=NULL,upd_uid='11417197',upd_dt=GETDATE()
 WHERE url_id = 8790
ELSE 
	INSERT INTO dbo.url_loc (url_id, url_hyperlink, target, url_friendly_nm, event_script, upd_uid, upd_dt) 
VALUES (8790,'javascript:SpeedPage.fnGoToMenuItem(''/Intel.SPEED.Module.Web.IlmDivSubscription/pages/ilm_div_subscription.aspx'',''_self'',false);',NULL,'MODULE:Division Issue, PAGE:ILM Top Navigation, ITEM:Su',NULL,'11417197',GETDATE())


-- Insert menu_detail records

INSERT INTO dbo.menu_detail (menu_seq_id, menu_nm, menu_url_id, menu_dsc, img_id, title, browser_ver, mod_cde, mod_ind, upd_uid, upd_dt) 
VALUES (9023,'Subscription{*7}',8790,'MODULE:Division Issue, PAGE:ILM Top Navigation, ITEM:Subscription{*7}',NULL,'Subscription','5',255,'N','11417197',GETDATE())

-- Insert menu records

INSERT INTO dbo.menu (group_id, menu_lvl, relate_seq_id, menu_seq_id, dsp_ord_nbr, default_flg, act_ind, upd_uid, upd_dt, crud_typ) 
VALUES (508,1,NULL,9023,90,'N','Y','11417197',GETDATE(),'R')

-- Insert page_menu records for secure menu(s) if any

IF EXISTS (SELECT * FROM page WHERE page_id = 1643)
  INSERT INTO dbo.page_menu (page_id, menu_seq_id, dflt_ind, upd_uid, upd_dt) 
  VALUES (1643,9023,'N','11417197',GETDATE())


-- Rebuild menu tree denormalization data

IF EXISTS (SELECT * FROM speed_web.sys.procedures WHERE name = 'prc_menu_build_tree_data')
BEGIN
EXECUTE speed_web.dbo.prc_menu_build_tree_data @menu_seq_id = 9023
END

COMMIT

GO

IF OBJECT_ID('tempdb..#groups_affected') IS NOT NULL
	DROP TABLE #groups_affected
IF OBJECT_ID('tempdb..#page_affected') IS NOT NULL
	DROP TABLE #page_affected
IF OBJECT_ID('tempdb..#menu_detail_affected') IS NOT NULL
	DROP TABLE #menu_detail_affected
GO