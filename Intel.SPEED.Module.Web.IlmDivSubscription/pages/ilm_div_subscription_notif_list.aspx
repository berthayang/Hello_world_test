<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ilm_div_subscription_notif_list.aspx.cs" Inherits="Intel.SPEED.Module.Web.IlmDivSubscription.pages.ilm_div_subscription_notif_list" %>

<!--[if IE]><!DOCTYPE html>
<!------------------------------------------------------------
-- File   : ilm_div_subscription_notif_list.aspx
-- Purpose: ILM Division Subscription notification in Portal
-- History: rsanka1x     01/03/2014  Created.
--			
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------->
<!-- <![endif]-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register TagPrefix="CONTROLS" TagName="Subscription_Notif" Src="~/controls/ilm_div_subscription_notif_list.ascx" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Portal Division Subscription</title>
</head>
<body>
    <div id="divSubscriptionData" >
        <table style="width:98%;">
                <tr>
                    <td>
                        <CONTROLS:Subscription_Notif  runat="server" />
                    </td>
                 </tr>
       </table>
    </div>
</body>
</html>

