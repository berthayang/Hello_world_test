<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ilm_div_subscription_notif_list.ascx.cs" Inherits="Intel.SPEED.Module.Web.IlmDivSubscription.controls.ilm_div_subscription_notif_list" %>
<!------------------------------------------------------------
-- Purpose: Div Subscription notification widget
-- History: rsanka1x     01/14/2014  Created
-- 
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------->
<div id="divSubscription">
    <SPEEDX:ReportExt ID="rptSubscription" EnableGrouping="false" AllowMultiGroup="false" ColReorder="false"
                        EnableSort="false" SaveType="ROW"  runat="server" TableName="Rpt_Subscription_Nav"
                        ReportTableName="Rpt_Subscription"  ReloadFn="fnReportSubscriptionLoad">  
            <SPEEDX:ReportColExt WIDTH="350" ALIGN="left" ID="subject" runat="server" TITLE="Notification Subject">
                <ItemTemplate>
                    <SPEED:Element ID="eleSubject" DataBindID="subject" runat="server"/>
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt WIDTH="150" ID="processed_dte" runat="server" TITLE="Processed Date">
                <ItemTemplate>
                    <SPEED:Element ID="eleProcessDate" DataBindID="processed_dte" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
        </SPEEDX:ReportExt>
</div>
