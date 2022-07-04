/***********************************************************************************
*** Purpose: WebMethod to build subscription page
*** History: rsanka1x    01/03/2014  Created.
***          
*** Copyright 2014 Intel Corporation, all rights reserved.
************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using Intel.SPEED.Core.Web.Control.Extension;

namespace Intel.SPEED.Module.Web.IlmDivSubscription.services
{
    /// <summary>
    /// Summary description for ilm_div_subscription_websvc
    /// </summary>
    [WebService(Namespace = "http://speed.intel.com/speed/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    public class ilm_div_subscription_websvc : SpeedWebServiceExt
    {
        [WebMethod]
        public string[] GetSubscriptionList(string[] parmNames, string[] parmValues, string[] parmTypes)
        {
            try
            {
                this.LoadCallParms(parmNames, parmValues, parmTypes);
                this.LoadDataSet("ilm.prc_div_subscription_master");
                this.LoadControl(@"~\controls\ilm_div_subscription_list.ascx");
                this.AddReturnHTML("SubscriptionList", this.RenderedPage);
            }
            catch (Exception e)
            {
                this.ErrorMessage = e.Message;
            }
            return this.WebServiceReturn;
        }

        [WebMethod]
        public string[] GetExistingSubscription(string[] parmNames, string[] parmValues, string[] parmTypes)
        {
            try
            {
                this.LoadCallParms(parmNames, parmValues, parmTypes);
                this.LoadDataSet("ilm.prc_div_subscription_master");

                this.LoadControl(@"~\controls\ilm_div_subscription_fields.ascx");
                this.AddReturnHTML("SubscriptionFields", this.RenderedPage);
            }
            catch (Exception e)
            {
                this.ErrorMessage = e.Message;
            }
            return this.WebServiceReturn;
        }

        [WebMethod]
        public string[] SaveSubscription(string[] parmNames, string[] parmValues, string[] parmTypes)
        {
            try
            {
                this.LoadCallParms(parmNames, parmValues, parmTypes);
                this.LoadDataSet("ilm.prc_div_subscription_master");

                string scbidn = this.Page.PageDataSet.Tables["scbidn"].Rows[0][1].ToString();

                if (this.Page.PageDataSet.Tables["scb_report_rows"] != null)
                {
                    this.LoadControl(@"~\controls\ilm_div_subscription_list.ascx");
                    this.AddReturnHTML("Scbidn", scbidn);
                    this.AddReturnHTML("SubscriptionList", this.RenderedPage);
                }

            }
            catch (Exception e)
            {
                this.ErrorMessage = e.Message;
            }
            return this.WebServiceReturn;
        }

        [WebMethod]
        public string[] DeleteSubscription(string[] parmNames, string[] parmValues, string[] parmTypes)
        {
            try
            {
                this.LoadCallParms(parmNames, parmValues, parmTypes);
                this.LoadDataSet("ilm.prc_div_subscription_master");

                this.LoadControl(@"~\controls\ilm_div_subscription_list.ascx");
                this.AddReturnHTML("SubscriptionList", this.RenderedPage);
                this.LoadControl(@"~\controls\ilm_div_subscription_fields.ascx");
                this.AddReturnHTML("SubscriptionFields", this.RenderedPage);
            }
            catch (Exception e)
            {
                this.ErrorMessage = e.Message;
            }
            return this.WebServiceReturn;
        }

        [WebMethod]
        public string[] GetPotalNotif(string[] parmNames, string[] parmValues, string[] parmTypes)
        {
            try
            {
                this.LoadCallParms(parmNames, parmValues, parmTypes);
                this.LoadDataSet("ilm.prc_div_subscription_master");

                this.LoadControl(@"~\controls\ilm_div_subscription_notif_list.ascx");
                this.AddReturnHTML("SubscriptionNotif", this.RenderedPage);
            }
            catch (Exception e)
            {
                this.ErrorMessage = e.Message;
            }
            return this.WebServiceReturn;
        }

    }
}
