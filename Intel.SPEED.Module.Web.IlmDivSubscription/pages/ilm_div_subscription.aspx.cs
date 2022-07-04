/***********************************************************************************
*** Purpose: Code behind to load subscription details 
*** History: rsanka1x    01/03/2014  Created
***
*** Copyright 2014 Intel Corporation, all rights reserved.
************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Intel.SPEED.Core.Web.Control.Extension;

namespace Intel.SPEED.Module.Web.IlmDivSubscription.pages
{
    public partial class ilm_div_subscription : SpeedPageExt
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Expires = 0;
            this.AddXmlParm("action", "GET_FIELDS");
            this.LoadPageDataSet("ilm.prc_div_subscription_master");

            // If user not yet setup Preferences before will redirect to Preferences
            ValidatePageAccess(96, "/Intel.SPEED.Module.Web.IlmPreferences/pages/ilm_preferences.aspx");

            this.Scripts.AddScript("/Intel.SPEED.Module.Web.IlmDivSubscription/scripts/ilm_div_subscription_detail.vbs");

            //*** IsDirty checking ***
            this.OnClientMenuClickValidate = "fnDirtyCheck";
            this.OnClientLoad = "fnDivSubscriptionLoad";
        }
    }
}