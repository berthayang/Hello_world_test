<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ilm_div_subscription_list.ascx.cs" Inherits="Intel.SPEED.Module.Web.IlmDivSubscription.controls.ilm_div_subscription_list" %>

<!------------------------------------------------------------
-- Purpose: ILM Division Subscription control page for report
-- History: rsanka1x     01/03/2014  Created
--          
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------->
<div>
    <table class="wp100" cellpadding="0" cellspacing="5">
        <tr>
            <td class="tar">
                 <SPEEDX:ButtonExt2 ID="btnScbListEditCol" VALUE="Edit Columns" ONCLICK="fnScbListEditCol()" runat="server" />                
            </td>
        </tr>
    </table>
    <div id="divSubscriptionReport">
        <SPEEDX:ReportExt ID="rptSubscriptionList" ColReorder="false" EnableSort="false" EnableGrouping="false" ReloadFn="fnScbListReload"
            TableName="scb_report" ColTableName="scb_report_cols" ReportTableName="scb_report_rows" onRowSelect="fnScbList_OnRowSelect"
            IsSelectable="true" WIDTH="1000px" SaveType="ROW" runat="server">
            <SPEEDX:ReportColExt ID="div_start_dte" runat="server" IsColRemovable="false">
                <ItemTemplate>
                    <SPEED:Element ID="eleStartDte" TagName="span" DataBindID="div_start_dte" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_orig_usr" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleOrigUsr" DataBindID="div_orig_usr" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_iss_src" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleIssSrc" DataBindID="div_iss_src" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
                    <SPEEDX:ReportColExt ID="div_exc_typ" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleExcTyp" DataBindID="div_exc_typ" runat="server" />
                </ItemTemplate>
                </SPEEDX:ReportColExt>
              <SPEEDX:ReportColExt ID="div_prod_cls" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="dleProdCls" DataBindID="div_prod_cls" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_lvl" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleLvl" DataBindID="div_lvl" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_symp" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleSymp" DataBindID="div_symp" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
                        <SPEEDX:ReportColExt ID="div_plc_phs" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="elePlcPhs" DataBindID="div_plc_phs" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
                        <SPEEDX:ReportColExt ID="div_prod_fmly" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleProdFmly" DataBindID="div_prod_fmly" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
                        <SPEEDX:ReportColExt ID="div_bus_unit" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleBusUnit" DataBindID="div_bus_unit" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
                        <SPEEDX:ReportColExt ID="div_risk_scre" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleRiskScre" DataBindID="div_risk_scre" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_prim_rc" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="elePrimRc" DataBindID="div_prim_rc" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_sub_rc" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleSubRc" DataBindID="div_sub_rc" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_escp_pnt" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleEscpPnt" DataBindID="div_escp_pnt" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_svr_type" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleSvrType" DataBindID="div_svr_type" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_status" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleStatus" DataBindID="div_status" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_pblm_owner" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="elePblmOwner" DataBindID="div_pblm_owner" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_clsure_aprvr" runat="server" >
                <ItemTemplate>
                    <SPEED:Element ID="eleClsureAprvr" DataBindID="div_clsure_aprvr" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_linked_prt" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleLinkedPrt" DataBindID="div_linked_prt" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_linked_cirs" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="eleLinkedCirs" DataBindID="div_linked_cirs" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_linked_qan" runat="server">
                <ItemTemplate>
                    <SPEED:Element ID="delLinkedQan" DataBindID="div_linked_qan" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="alrt_typ_idn" runat="server" IsColRemovable="false">
                <ItemTemplate>
                    <SPEED:Element ID="eleAlrtTyp" DataBindID="alrt_typ_idn" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
            <SPEEDX:ReportColExt ID="div_scb_idn" IsVisible="false" runat="server">
                <ItemTemplate>
                    <SPEEDX:HiddenExt2 ID="hdnScbIdn" DataBindID="div_scb_idn" runat="server" />
                </ItemTemplate>
            </SPEEDX:ReportColExt>
        </SPEEDX:ReportExt>
    </div>
</div>
