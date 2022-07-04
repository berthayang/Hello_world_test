/***********************************************************************************
*** Purpose: Code behind to load subscription details in portal
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
    public partial class ilm_div_subscription_notif_list : SpeedPageExt
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.AddXmlParm("action", "GET_PORTAL_NOTIF");
            this.LoadPageDataSet("ilm.prc_div_subscription_master");
            this.Scripts.AddScript("/Intel.SPEED.Module.Web.IlmDivSubscription/scripts/ilm_div_subscription_detail.vbs");
            this.OnClientLoad = "fnSubscriptionLoad";
        }
    }
}