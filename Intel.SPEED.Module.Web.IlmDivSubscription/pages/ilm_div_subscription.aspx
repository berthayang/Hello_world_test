<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ilm_div_subscription.aspx.cs" Inherits="Intel.SPEED.Module.Web.IlmDivSubscription.pages.ilm_div_subscription" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--[if IE]><!DOCTYPE html>
<!------------------------------------------------------------
-- File   : ilm_div_subscription.aspx
-- Purpose: ILM Division Subscription main page
-- History: rsanka1x     01/03/2014  Created.
--			
-- Copyright 2014 Intel Corporation, all rights reserved.
-------------------------------------------------------------->
<!-- <![endif]-->
<%@ Register TagPrefix="CONTROLS" TagName="SubscriptionFields" Src="~/controls/ilm_div_subscription_fields.ascx" %>
<%@ Register TagPrefix="CONTROLS" TagName="SubscriptionList" Src="~/controls/ilm_div_subscription_list.ascx" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Subscription</title>
</head>
<script language="vbscript" type="text/vbscript">
Function fnDirtyCheck()
    strDirty = fnChkIsDirty("SpeedContent")
    If strDirty = "Y" Then
        fnDirtyCheck = true
    Else
        fnDirtyCheck = false
    End If
End Function
</script>
<body>
    <!-- hidden field to keep subscription idn -->
    <SPEEDX:HiddenExt2 ID="hdnSubscriptionId" VALUE="0" runat="server" />
    <!-- hidden field to keep hierarchy enforced flag -->
    <SPEEDX:HiddenExt2 ID="hdnHierarchyEnforced" VALUE="Y" runat="server" />
    <SPEEDX:HiddenExt2 ID="hdnCcUserFlag" TableName="citi_info" runat="server" /> 
    <SPEEDX:HiddenExt2 ID="hdnCcUserEnv" TableName="citi_info" runat="server" /> 
    <SPEEDX:SpeedFrame ID="speedFrameSubscription" ShowTitleBar="false" TopNavigationID="1643"
        TopNavigationSelectedID="9023" runat="server">
        <TitleBarTemplate>
        </TitleBarTemplate>
        <ContentTemplate>
        <div id="divSubscription">
            <SPEEDX:Panel ID="pnlSubscriptionFields" CLASS="mt05" HideHelp="true"
                TITLE="Division Subscription" HideRequiredRemaining="true" runat="server">
                <HeaderTemplate>
                    <div id="divMsgTop" class="messageBar" style="float: left; display: none">
                        <div id="divMsgTop_Text">
                        </div>
                    </div>
                    &nbsp;
                    <SPEEDX:ButtonExt2 ID="btnCreateNew" VALUE="Create New" IsEnabled="false" ONCLICK="fnCreateNew()" runat="server" />
                    <SPEEDX:ButtonExt2 ID="btnSave" VALUE="Save Changes" ONCLICK="fnSave()" runat="server" />
                    <SPEEDX:ButtonExt2 ID="btnDelete" VALUE="Delete" ONCLICK="fnDelete()" IsEnabled="false" runat="server" />
                </HeaderTemplate>
                <BodyTemplate>                
                    <table width="100%">
                        <tr>
                            <td>
                                <div id="divAllFields">
                                    <div id="divSubscriptionFields" style="width: 99%">
                                        <CONTROLS:SubscriptionFields ID="ctrlFields" runat="server" />
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                               <SPEEDX:ButtonExt2 ID="btnCreateNewBottom" VALUE="Create New" IsEnabled="false" ONCLICK="fnCreateNew()" runat="server" />
                               <SPEEDX:ButtonExt2 ID="btnSaveBottom" VALUE="Save Changes" ONCLICK="fnSave()" runat="server" />
                               <SPEEDX:ButtonExt2 ID="btnDeleteBottom" VALUE="Delete" ONCLICK="fnDelete()" IsEnabled="false" runat="server" />
                            </td>
                        </tr>
                    </table>
                </BodyTemplate>
            </SPEEDX:Panel>
            <SPEEDX:Panel ID="pnlSubscriptionList" HeaderControlsWidth="725" HideHelp="true"
                CLASS="mt05" TITLE="Current Subscription" HideRequiredRemaining="true" runat="server">
                <HeaderTemplate></HeaderTemplate>
                <BodyTemplate>
                    <div id="divSubscriptionList">
                        <CONTROLS:SubscriptionList ID="ctrlSubscriptionList" runat="server" />
                    </div>
                </BodyTemplate>
            </SPEEDX:Panel>
        </div>
        </ContentTemplate>
        <BottomBarTemplate>
        </BottomBarTemplate>
    </SPEEDX:SpeedFrame>
</body>
</html>

