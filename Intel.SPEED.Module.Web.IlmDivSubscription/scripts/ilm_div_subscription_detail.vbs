'******************************************************************************
'*** Purpose: Custom client-side scripts for ILM Division Subscription page
'*** History: rsanka1x   01/03/2014  Created.
'***
'*** Copyright 2014 Intel Corporation, all rights reserved.
'******************************************************************************

'------------------------------------------------------------------------------
'--- This function is used to check if any field is modified
'------------------------------------------------------------------------------
Function fnChkIsDirty(divName)
    Set oDocAll = Document.All
    Set oDiv = oDocAll(divName)
    strDirty = "N"
    blnIsDirty = fnPageIsDirty(oDiv)
	If blnIsDirty And blnAllowNavigate = False Then
        msgDirty = Msgbox("Are you sure you want to navigate away from this page?" & vbCr & vbCr _
                    & "Values on this page have changed. If you continue, the changes will be lost!" & Chr(10) _
                    & "Are you sure you want to continue?" & vbCr & vbCr _
                    & "Press OK to continue, or Cancel to stay on the current page.", 1+48)
        If msgDirty = 2 Then
            strDirty = "Y"
            blnAllowNavigate = False
        Else
            blnAllowNavigate = True
		End If
	End If
    strSaveRecInd = "N"
	fnChkIsDirty = strDirty
End Function

'------------------------------------------------------------------------------
'-- This function is used to load on subscription
'------------------------------------------------------------------------------
Sub fnDivSubscriptionLoad()
    fnSummaryFlagClick()
End Sub

'------------------------------------------------------------------------------
'-- This function is used to clears mandatory selection
'------------------------------------------------------------------------------
Sub fnClearMandatory()
    document.getElementById("ddRptFrq").set_isRequiredCond(false)
    document.getElementById("ddRptDay").set_isRequiredCond(false)
    document.getElementById("txtDuration").set_isRequiredCond(false)
    document.getElementById("calLastRun").IsRequired = "false"
    document.getElementById("calLastRun").set_isRequiredCond(false)
    document.getElementById("spLstReq").style.visibility="hidden"
    document.getElementById("spDayReq").style.visibility="hidden"
End Sub

'------------------------------------------------------------------------------
'-- This function is used to shows mandatory selection
'------------------------------------------------------------------------------
Sub fnValidateMandatory()
    fnClearMandatory()
    Call fnDivLocateSummaryFields(chkSummary, txtDuration, ddRptDay, ddRptFrq, calLastRun)
    If chkSummary.checked="True" Then
        document.getElementById("txtDuration").set_isRequiredCond(true)
	    Select Case ddRptFrq.fnGetValue()
		    '-- Weekly Report frequency, 
		    '--   enable Day of Report dropdown
		    '--   disable Last Run Date field
		    Case strWEEK
                document.getElementById("spDayReq").style.visibility="visible"
                document.getElementById("ddRptDay").set_isRequiredCond(true)
                calLastRun.children(0).style.backgroundColor = "#F2F2F2" 
			    calLastRun.fnClear()
                calLastRun.fnDisable()
			    Call ddRptDay.fnEnable()
		    '-- Monthly or Quarterly Report frequency, 
		    '--   disable Day of Report dropdown
		    '--   enable Last Run Date field
		    Case strMONTH, strQTR
                document.getElementById("spLstReq").style.visibility="visible"
                document.getElementById("calLastRun").IsRequired = "true"
                document.getElementById("calLastRun").set_isRequiredCond(true)
			    Call calLastRun.fnEnable()
			    Call ddRptDay.fnClear()
			    Call ddRptDay.fnDisable()
		    '-- No Report frequency, 
		    '--   enable Day of Report dropdown
		    '--   enable Last Run Date field
		    Case Else
			    Call calLastRun.fnEnable()
			    Call ddRptDay.fnEnable()
	    End Select
    End If
End Sub

'------------------------------------------------------------------------------
'-- This function is used to hide/visible the fummary fields
'------------------------------------------------------------------------------
intDIV_START_ROW = 1
Sub fnSummaryFlagClick()
	strIsSummary = "N"
    fnValidateMandatory()
	Set oRptFields = document.all.rptSubscriptionFields_table
	For intRowIdx = intDIV_START_ROW To (oRptFields.Rows.Length - 1) 
		Set rwFields = oRptFields.Rows(intRowIdx)

		strLeftColIdn = rwFields.all.ele_col_idn_left.value
        strRightColIdn = rwFields.all.ele_col_idn_right.value

		If Not IsNumeric(strLeftColIdn) Then strLeftColIdn = "0"
        If Not IsNumeric(strRightColIdn) Then strRightColIdn = "0"
		intLeftColIdn = CDbl(strLeftColIdn)
		intRightColIdn = CDbl(strRightColIdn)

		If intLeftColIdn = -1 Then 
			strIsSummary =rwFields.all("chkSummary").checked
            if(IsNull(rwFields.all("txtDuration"))= False) Then
                If strIsSummary = "True" Then
				    rwFields.all.ele_obj_right.style.visibility="visible"
                    rwFields.all.ele_label_right.style.visibility="visible"
			    Else
				    rwFields.all.ele_obj_right.style.visibility="hidden"
                    rwFields.all.ele_label_right.style.visibility="hidden"
			    End If
            End If
		End If
        If intRightColIdn = -1 Then 
            strIsSummary =rwFields.all("chkSummary").checked
        End If
		
		If intLeftColIdn < -2 Or intRightColIdn < -2 Then
			If strIsSummary = "True" Then
                If intLeftColIdn <> -1 Then 
				    rwFields.all.ele_obj_left.style.visibility="visible"
                    rwFields.all.ele_label_left.style.visibility="visible"
                End If
                    rwFields.all.ele_obj_right.style.visibility="visible"
                    rwFields.all.ele_label_right.style.visibility="visible"
			Else
                If intLeftColIdn <> -1 Then 
				    rwFields.all.ele_obj_left.style.visibility="hidden"
                    rwFields.all.ele_label_left.style.visibility="hidden"
                End If
                rwFields.all.ele_obj_right.style.visibility="hidden"
                rwFields.all.ele_label_right.style.visibility="hidden"
			End If
		End If
	Next

    If strIsSummary = "True" Then
        document.getElementById("ddRptFrq").set_isRequiredCond(true)
    End If

	Set rwFields   = Nothing
	Set oRptFields = Nothing

End Sub

'------------------------------------------------------------------------------
'-- This function is used to load Edit Column pop up
'------------------------------------------------------------------------------
Sub fnScbListEditCol()
    Set oRpt = document.all("rptSubscriptionList").control
    Set coords = SpeedPage.getPageCoordinates(window.event)
    Call oRpt.displayColumnPicker(coords.pageX - 122, coords.pageY - 168)
End Sub

'------------------------------------------------------------------------------
'-- This function is used to reload the subscription report
'------------------------------------------------------------------------------
Sub fnScbListReload(sender)
    Set oDocAll = document.all
    Set oXml = New XmlSave

    Call oXml.fnSetRootLevelValue("action", "GET_LIST")
    strErrMsg = oXml.HarvestValuesWithDomPrn(oDocAll.rptSubscriptionList, strXmlDoc)
    Set oXml = Nothing
    If Not strErrMsg = "" Then Exit Sub
    
    Set oWebSvc = WebSvcAccessExt.CreateInstance()
    Call oWebSvc.set_webSvc("/Intel.SPEED.Module.Web.IlmDivSubscription/services/ilm_div_subscription_websvc.asmx/GetSubscriptionList")
    Call oWebSvc.SetParam("XmlDoc", strXmlDoc, "varchar")
    
    oWebSvc.fnCallWebSvc(GetRef("fnScbListReload_Callback"))
    Set oWebSvc = Nothing
End Sub

Sub fnScbListReload_Callback(oWebSvc)        
    Set oDocAll = document.all
    strErrMsg = oWebSvc.GetErr()

    If strErrMsg = "" Then        
        Call SpeedPage.updateContent(oDocAll.divSubscriptionList, oWebSvc.GetReturnHTML("SubscriptionList"))
    End If
    fnSummaryFlagClick()
End Sub

'------------------------------------------------------------------------------
'-- This function is used to load existing subcription on detail page
'------------------------------------------------------------------------------
Sub fnScbList_OnRowSelect(sender)
    Set oDocAll = document.all
    
    Set element = sender.get_element()
    Set oSrc = window.event.srcElement : Set oTr = oSrc.parentElement
    While (UCase(oTr.tagName) <> "TR") : Set oTr = oTr.parentElement : Wend

    If (oTr.All("hdnScbIdn") Is Nothing) Then Exit Sub
    scbIdn = oTr.All("hdnScbIdn").value
    document.getElementById("hdnSubscriptionId").value = scbIdn
    document.getElementById("pnlSubscriptionFields").control.fnExpand()
    Set oXml = New XmlSave
    oXml.ValidateElements = False
    oXml.SkipEmptyValues = True
    oXml.SkipCleanValues = False
    
    strErrMsg = oXml.fnSetRootLevelValue("action", "GET_EXISTING")
    strErrMsg = oXml.fnSetRootLevelValue("scb_idn", scbIdn)
    strErrMsg = oXml.HarvestValuesWithDomPrn(oDocAll.rptSubscriptionFields, strXmlDoc)

    Set oXml = Nothing
    If Not strErrMsg = "" Then Exit Sub
    
    Set oWebSvc = WebSvcAccessExt.CreateInstance()
    Call oWebSvc.set_webSvc("/Intel.SPEED.Module.Web.IlmDivSubscription/services/ilm_div_subscription_websvc.asmx/GetExistingSubscription")
    Call oWebSvc.SetParam("XmlDoc", strXmlDoc, "varchar")
    oWebSvc.fnCallWebSvc(GetRef("fnScbList_OnRowSelect_Callback"))

    oDocAll.hdnSubscriptionId.value = scbIdn
    oDocAll.hdnHierarchyEnforced.value = hierEnf

    document.getElementById("btnDelete").disabled = false
    document.getElementById("btnDeleteBottom").disabled = false
    document.getElementById("btnCreateNew").disabled = false           
    document.getElementById("btnCreateNewBottom").disabled = false
    
    Set oWebSvc = Nothing
End Sub

Sub fnScbList_OnRowSelect_Callback(oWebSvc)
    Set oDocAll = document.all
    strErrMsg = oWebSvc.GetErr()
    
    If strErrMsg = "" Then
        Call SpeedPage.updateContent(oDocAll.divSubscriptionFields, oWebSvc.GetReturnHTML("SubscriptionFields"))
    End If
    fnSummaryFlagClick()
End Sub

'*********************************************************************************************************
'*** This function use for set the info message after save successfull
'*********************************************************************************************************
Sub fnInfoMsg(msg)
    Set oDocAll = document.all
    oDocAll.divMsgTop.style.display = "block"
    oDocAll.divMsgTop_Text.innerHtml = msg

    '*** Clear Message After 3 seconds
    setTimeout "fnClearInfoMsg()", 3000
End Sub

'*******************************************************************************************
'*** The following functions use for clear the validation message
'*******************************************************************************************
Sub fnClearInfoMsg()
    Set oDocAll = document.all
    oDocAll.divMsgTop.style.display = "none"
    oDocAll.divMsgTop_Text.innerHtml=""
End Sub

'*******************************************************************************************
'*** The following functions use for Saving the Subscription records
'*******************************************************************************************
Sub fnSave()
    Set oXml = New XmlSave
    Set oDocAll = document.all

    scbIdn = oDocAll.hdnSubscriptionId.value
    
    oXml.SkipEmptyValues = false
    oXml.ValidateElements = True
    oXml.SkipCleanValues = False
    Call oXml.fnSetRootLevelValue("action", "SAVE")
    Call oXml.fnSetRootLevelValue("scb_idn", scbIdn)
    
    strErrMsg = oXml.HarvestValuesWithDomPrn(oDocAll.divAllFields, strXmlDoc)
	blnIsValid = oXml.IsValid
    blnIsDirty = oXml.IsDirty 
    strXmlDoc = oXml.xml    
	Set oXml = Nothing
    
    If (Not blnIsValid) Or (Not strErrMsg = "") Then Exit Sub
    
    strCustomValidationStatus = fnCustomValidate()
    If strCustomValidationStatus = False Then
        Exit Sub
    End If

    If (ddSubscriptionType.IsDirty Or chkSummary.IsDirty Or txtDuration.IsDirty Or ddRptDay.IsDirty Or ddRptFrq.IsDirty Or calLastRun.IsDirty)  And scbIdn = "0" Then
        If(Not fnCheckIsDirty(oDocAll.divSubscriptionFields) ) Then
            fnInfoMsg("No changes were made, save action unnecessary.") 'dirty field info
            Exit Sub
        End If
    End If
	
    If(Not fnPageIsDirty(oDocAll.divAllFields)) Then
        fnInfoMsg("No changes were made, save action unnecessary.") 'dirty field info
        Exit Sub
    End If
    
    Set objWebSvc = New WebSvcAccess
	objWebSvc.WebSvc = "/Intel.SPEED.Module.Web.IlmDivSubscription/services/ilm_div_subscription_websvc.asmx/SaveSubscription"
    Call objWebSvc.AddParam ("XmlDoc", strXmlDoc, "varchar")
    strErrMsg = objWebSvc.fnCallWebSvc()
    
    If strErrMsg = "" Then       
        fnInfoMsg("Save action is successful.")
        Call SpeedPage.updateContent(oDocAll.divSubscriptionList, objWebSvc.GetReturnHTML("SubscriptionList"))
        document.getElementById("hdnSubscriptionId").value =  objWebSvc.GetReturnHTML("Scbidn")
      
        document.getElementById("btnDelete").disabled = false
        document.getElementById("btnCreateNew").disabled = false
        document.getElementById("btnDeleteBottom").disabled = false
        document.getElementById("btnCreateNewBottom").disabled = false
    End If
    
    Set objWebSvc = Nothing 
    SpeedPage.afterSaved(oDocAll.divAllFields) 
    fnResetDirtyFlag()
End Sub


''*******************************************************************************************
'*** The following functions use for clear dirty fields
'*******************************************************************************************
Sub fnResetDirtyFlag() 
    Call fnDivLocateSummaryFields(chkSummary, txtDuration, ddRptDay, ddRptFrq, calLastRun)
    ddSubscriptionType.IsDirty = false
    chkSummary.IsDirty = false
    txtDuration.IsDirty = false
    ddRptDay.IsDirty = false
    ddRptFrq.IsDirty = false
    calLastRun.IsDirty = false
End Sub

''*******************************************************************************************
'*** The following functions use for check dirty controlwise
'*******************************************************************************************
Function fnCheckIsDirty(objDomParent)
    fnCheckIsDirty=False
   If (objDomParent Is Nothing) Then Set objDomParent = document.body
	For Each objDomChild In objDomParent.children
		If UCase(objDomChild.getAttribute("SaveType")) = "ELEMENT" Or _
		   UCase(objDomChild.getAttribute("SaveType")) = "SAVE"    Then
			If CBool(objDomChild.IsDirty) Then
                If (objDomChild.id<>"ddSubscriptionType" And objDomChild.id<>"chkSummary" And objDomChild.id<>"txtDuration" And objDomChild.id<>"ddRptDay" And objDomChild.id<>"ddRptFrq" And objDomChild.name<>"date_calLastRun") Then
				    fnCheckIsDirty = True
				    Exit Function
                End If
            End If
		End If

		fnCheckIsDirty = fnCheckIsDirty(objDomChild)
		If fnCheckIsDirty Then Exit Function
	Next

End Function

'*******************************************************************************************
'*** The following functions use for clear all the controls
'*******************************************************************************************
Sub fnCreateNew()
    Set oDocAll = document.all

    Set oXml = New XmlSave
    oXml.ValidateElements = False
    oXml.SkipEmptyValues = True
    oXml.SkipCleanValues = False


    strErrMsg = oXml.fnSetRootLevelValue("action", "GET_EXISTING")
    strErrMsg = oXml.fnSetRootLevelValue("scb_idn", NULL)
    strErrMsg = oXml.HarvestValuesWithDomPrn(oDocAll.rptSubscriptionFields, strXmlDoc)


    Set oXml = Nothing
    If Not strErrMsg = "" Then Exit Sub

	Set oWebSvc = WebSvcAccessExt.CreateInstance()
    Call oWebSvc.set_webSvc("/Intel.SPEED.Module.Web.IlmDivSubscription/services/ilm_div_subscription_websvc.asmx/GetExistingSubscription")
    Call oWebSvc.SetParam("XmlDoc", strXmlDoc, "varchar")
    oWebSvc.fnCallWebSvc(GetRef("fnCreateNew_Callback"))

    oDocAll.hdnSubscriptionId.value = 0
    oDocAll.hdnHierarchyEnforced.value = "Y"

    document.getElementById("btnDelete").disabled = true
    document.getElementById("btnDeleteBottom").disabled = true
    document.getElementById("btnCreateNew").disabled = true
    document.getElementById("btnCreateNewBottom").disabled = true

    Set oWebSvc = Nothing
End Sub

Sub fnCreateNew_Callback(oWebSvc)
    Set oDocAll = document.all
    strErrMsg = oWebSvc.GetErr()
    
    If strErrMsg = "" Then
        Call SpeedPage.updateContent(oDocAll.divSubscriptionFields, oWebSvc.GetReturnHTML("SubscriptionFields"))
    End If
    fnSummaryFlagClick()
End Sub

'*******************************************************************************************
'*** The following functions use for Delete the selected record
'*******************************************************************************************
Sub fnDelete()
    If MsgBox("Do you want to delete this Subscription?", 52, "Confirm Delete") = VbYes Then
        Set oDocAll = document.all
        Set oXml = New XmlSave
        scbIdn = oDocAll.hdnSubscriptionId.value
       
        Call oXml.fnSetRootLevelValue("action", "DELETE")  
        Call oXml.fnSetRootLevelValue("scb_idn", scbIdn)
        strErrMsg = oXml.HarvestValuesWithDomPrn(oDocAll.divSubscription, strXmlDoc)
        strXmlDoc = oXml.xml
        Set oXml = Nothing
        If Not strErrMsg = "" Then Exit Sub
        
        Set oWebSvc = WebSvcAccessExt.CreateInstance()
        Call oWebSvc.set_webSvc("/Intel.SPEED.Module.Web.IlmDivSubscription/services/ilm_div_subscription_websvc.asmx/DeleteSubscription")
        Call oWebSvc.SetParam("XmlDoc", strXmlDoc, "varchar")
        oWebSvc.fnCallWebSvc(GetRef("fnDelete_Callback"))

        oDocAll.hdnSubscriptionId.value = 0
        oDocAll.hdnHierarchyEnforced.value = "Y"

        document.getElementById("btnDelete").disabled = true
        document.getElementById("btnDeleteBottom").disabled = true
        document.getElementById("btnCreateNew").disabled = true
        document.getElementById("btnCreateNewBottom").disabled = true

        Set oWebSvc = Nothing
    Else
        Exit Sub
    End If
End Sub

Sub fnDelete_Callback(oWebSvc)
    Set oDocAll = document.all
    strErrMsg = oWebSvc.GetErr()
    
    If strErrMsg = "" Then
        fnInfoMsg("Delete action is successful.")
        Call SpeedPage.updateContent(oDocAll.divSubscriptionFields, oWebSvc.GetReturnHTML("SubscriptionFields"))
        Call SpeedPage.updateContent(oDocAll.divSubscriptionList, oWebSvc.GetReturnHTML("SubscriptionList"))
    End If
    fnSummaryFlagClick()
End Sub

'*******************************************************************************************
'*** The following functions for load subscription notification widget
'*******************************************************************************************

Sub fnReportSubscriptionLoad(sender)
   fnSubscriptionLoad()
End Sub

Sub fnSubscriptionLoad()
    Set oXml = New XmlSave 
    Call oXml.fnSetRootLevelValue("action", "GET_PORTAL_NOTIF")
    strErrMsg = oXml.HarvestValuesWithDomPrn(document.getElementById("rptSubscription"), strXmlDoc)    
    Set oWebSvc = WebSvcAccessExt.CreateInstance()
    Call oWebSvc.set_webSvc("/Intel.SPEED.Module.Web.IlmDivSubscription/services/ilm_div_subscription_websvc.asmx/GetPotalNotif")
    Call oWebSvc.SetParam("XmlDoc", strXmlDoc, "varchar")
    Call oWebSvc.fnAsyncContentUpdate(document.getElementById("divSubscriptionData"), "SubscriptionNotif",GetRef("fnSubscriptionLoad_Callback"))
    Set oWebSvc = Nothing
End Sub

Sub fnSubscriptionLoad_Callback(oWebSvc)
    Set oDocAll = document.all  
    strErrMsg = oWebSvc.GetErr()
    If Not strErrMsg="" Then
        Msgbox strErrMsg , 48, "Subscription Notification Error"  
    Else
        Call SpeedPage.updateContent(oDocAll.divSubscriptionData, oWebSvc.GetReturnHTML("SubscriptionNotif"))
        Call fnSetElementWidth(document.getElementById("divSubscriptionData"),"DIV")
    End If
End Sub

'*********************************************************************************************************
'*** This function use to reset the report extension control as 100%
'*********************************************************************************************************
Sub fnSetElementWidth(element,tagName) 
    eleArr = element.getElementsByTagName(tagName) 
    eleCount = eleArr.all.length - 1     
    For x = 0 To eleCount 
        If eleArr.all(x).tagName = "TABLE" Then
            eleArr.all(x).style.width = "100%" 
        ElseIf eleArr.all(x).style.width = "349px" Then
            eleArr.all(x).style.width = "70%"
        ElseIf eleArr.all(x).style.width = "153px" or eleArr.all(x).style.width = "149px" Then
            eleArr.all(x).style.width = "30%"
        End If
    Next 
End Sub

Sub fnRptNotif_onRowSelect(NotifIdn)
    Call window.showModalDialog("/speed/module/inbox/notif_detail_slct.asp" &_
												"?notify_idn="	& NotifIdn, _
												window,_
					                            "dialogHeight:550px;" &_
												"dialogWidth:800px;" &_
												"help:no;" &_
												"status:no;" &_
												"center:yes;" &_
												"resizable:no;" &_
												"scroll:yes;")	 
End Sub 


'-----------------------------------------------------------------------
'-- Validate custom controls
'-----------------------------------------------------------------------
strWEEK	= "100962"
strMONTH= "100963"
strQTR	= "100964"

Function fnCustomValidate()
    Call fnDivLocateSummaryFields(chkSummary, txtDuration, ddRptDay, ddRptFrq, calLastRun)
    fnValidateMandatory()
    If chkSummary.checked = "True" Then
		'-- Report Frequency
			If ddRptFrq.fnGetValue() = "" Then
                document.getElementById("ddRptFrq").set_isRequiredCond(true)
				fnInfoMsg("Report Frequency value required when Summary Flag is checked.")
				fnCustomValidate = False
                Exit Function
			End If

			strValue = txtDuration.fnGetValue()

			If strValue = ""  Or Not IsNumeric(strValue) Then
				fnInfoMsg("Duration value must be a valid integer between 1 and 90 (inclusive) " &_
					"when the Summary Flag is checked.")
				fnCustomValidate = False
                Exit Function
			Else
				intValue = CDbl(strValue)
				If intValue < 1  Or intValue > 90 Then
					fnInfoMsg("Duration value must be between 1 and 90 (inclusive).")
					fnCustomValidate = False
                    Exit Function
				End If
			End If
		
			If ddRptFrq.fnGetValue() = strWEEK And ddRptDay.fnGetValue() = "" Then
				fnInfoMsg ("Day of Report value required when Summary Flag is checked and " &_
					"Report Frequency is ""Weekly"".")
				fnCustomValidate = False
                Exit Function
			End If
		
		'-- Last Run Date
			If ddRptFrq.fnGetValue() <> strWEEK And calLastRun.fnGetValue() = "" Then
				fnInfoMsg("Last Run Date value required when Summary Flag is checked and " &_
					"Report Frequency is ""Monthly"" or ""Quarterly"".")
				fnCustomValidate = False
                Exit Function
			End If
	End If
    fnCustomValidate = True
End Function

'-----------------------------------------------------------------------
'-- locate all Summary fields
'-----------------------------------------------------------------------
Function fnDivLocateSummaryFields(ByRef chkSummary, ByRef txtDuration, ByRef ddRptDay, ByRef ddRptFrq, ByRef calLastRun) 
	Set oRptFields	= document.all.rptSubscriptionFields_table
	Set chkSummary  = oRptFields.all("chkSummary")
    Set txtDuration  = oRptFields.all("txtDuration")
    Set ddRptDay  = oRptFields.all("ddRptDay")
    Set ddRptFrq  = oRptFields.all("ddRptFrq")
    Set calLastRun  = oRptFields.all("calLastRun")
End Function

'-----------------------------------------------------------------------
'-- Handle Report Frequency onChange event
'-- Disable/Enable Division Issue Summary Subscription fields
'-----------------------------------------------------------------------
Sub fnDivRptFreqChange(sender)
    fnValidateMandatory()
End Sub
