<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ilm_div_subscription_fields.ascx.cs" Inherits="Intel.SPEED.Module.Web.IlmDivSubscription.controls.ilm_div_subscription_fields" %>
<!------------------------------------------------------------
-- File   : ilm_div_subscription_fields.ascx
-- Purpose: ILM Division Subscription control page for fields
-- History: rsanka1x     01/03/2014  Created.
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------->
<div id="divSubscriptionContent">
    <SPEEDX:ReportExt ID="rptSubscriptionFields" HideHeader="true" OVERFLOW="auto" ReportTableName="scb_field_items" STYLE="border:0px" runat="server">
        <SPEEDX:ReportColExt ID="td_label_left" STYLE="border:0px;vertical-align:top" runat="server">
            <ItemTemplate>
                <SPEED:Element ID="ele_label_left" ALIGN="right" TagName="div" runat="server" />
                <SPEED:Element ID="ele_col_idn_left" TagName="input" CustomAttributes="type=hidden" HasInnerHTML="false" runat="server" />
                <SPEED:Element ID="ele_col_nme_left" TagName="input" CustomAttributes="type=hidden" HasInnerHTML="false" runat="server" />
            </ItemTemplate>
        </SPEEDX:ReportColExt>
        <SPEEDX:ReportColExt ID="td_field_left" ALIGN="left" STYLE="border:0px;vertical-align:top" runat="server">
            <ItemTemplate>                            
                <SPEEDX:ControlContainer ID="ele_obj_left" TagName="DIV" runat="server" />
            </ItemTemplate>
        </SPEEDX:ReportColExt>
        <SPEEDX:ReportColExt ID="td_space" STYLE="border:0px;vertical-align:top" runat="server">
            <ItemTemplate>&nbsp;</ItemTemplate>
        </SPEEDX:ReportColExt>
        <SPEEDX:ReportColExt ID="td_label_right" STYLE="border:0px;vertical-align:top" runat="server">
            <ItemTemplate>                            
                <SPEED:Element ID="ele_label_right" ALIGN="right" TagName="div" runat="server" />
                <SPEED:Element ID="ele_col_idn_right" TagName="input" CustomAttributes="type=hidden" HasInnerHTML="false" runat="server" />
                <SPEED:Element ID="ele_col_nme_right" TagName="input" CustomAttributes="type=hidden" HasInnerHTML="false" runat="server" />
            </ItemTemplate>
        </SPEEDX:ReportColExt>
        <SPEEDX:ReportColExt ID="td_field_right" ALIGN="left" STYLE="border:0px;vertical-align:top" runat="server">
            <ItemTemplate>                            
                <SPEEDX:ControlContainer ID="ele_obj_right" TagName="DIV" runat="server" />
            </ItemTemplate>
        </SPEEDX:ReportColExt>
    </SPEEDX:ReportExt>
</div>
