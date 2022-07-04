USE espeed
GO
IF EXISTS (SELECT *
           FROM   notif_msg
           WHERE  msg_name = 'DIV_ISS_CLOSED')
     BEGIN
          DELETE module_notif
          WHERE  msg_idn IN (SELECT msg_idn
                             FROM   notif_msg
                             WHERE  msg_name = 'DIV_ISS_CLOSED')

          DELETE notif_msg
          WHERE  msg_name = 'DIV_ISS_CLOSED'
     END
GO

INSERT INTO notif_msg(
            msg_name,
            msg_dsc,
            msg_subject,
            msg_priority,
            msg_txt,
            msg_src,
            scb_txt,
            scb_src,
            msg_rcp_src,
            scb_rcp_src,
            scb_flg,
            att_fl,
            alw_non_spd_usr_ind,
            ovrd_flg, 
            scrty_sp,
            excpt_evnt_nme,
            batch_ind
)
VALUES      ('DIV_ISS_CLOSED',
             'Division Issue Closure (CLOSE or CLOSE W/PSA)',
             'Division Issue {*issue_number*} {*close_action*} on {*close_date*}',
             'N',
             '<html>
<head>
<style>
    body {
        font-family: Calibri, Arial, Helvetica, sans-serif;
        font-size: 14px;
        text-align: left;
        width: 600px;
    }
    .content {
        background: white;
        border: 1px solid #CACACA;
        padding: 5px;
    }
    .contentHeader {
        color: blue; 
        height: 22px;
        font-style: italic;
    }
    .mainTable {
        width: 100%;
        border: 1px solid #D8DEE2;
    }
    .mainTable td {
        height: 22px;
        font-family: Calibri, Arial, Helvetica, sans-serif;
        font-size: 12px;
    }
    .reportitem td {
        background:#D8DEE2;
        padding-left: 5px;
        height: 22px;
        border-top: 1px solid #FFFFFF;
        font-family: Calibri, Arial, Helvetica, sans-serif;
        font-size: 12px;
    }
    .section {   
        /*border: 1px solid #D8DEE2;*/
    }
    .section-dynamic {
        /*border: 1px solid #D8DEE2;*/
        background: White;
    }
    .sectionHeader td {
        background: #3772B2;
        height: 30px;
        font-size: 12px;
        text-align: left;
        padding-left: 5px;
        color: #ccffcc;
        font-weight:bold;
    }
    .reportheader {
        background: #5785B6;
        font-size: 12px;
        padding: 0px;
        margin: 0px;
        text-align: center;   
    }    
    .reportheader td {
        padding-left: 5px;
        height: 22px;
        font-family: Calibri, Arial, Helvetica, sans-serif;
        font-size: 12px;
        color: White;
        font-weight:bold;
    }
    .mt10 {
        /*margin-top: 10px;*/
    }
    .label {
        text-align: right;
        font-weight: bold;
        padding-right: 5px;
        width: 150px;
        height: 22px;
    }
</style>
</head>
<body>
    <div class="contentHeader">This is a system activated notification, please do not reply.</div>
    <br />
    <div>
Division Issue {*issue_number*} was {*close_action*} on {*close_date*}.</div>
    <br />
    <div>
        <table cellpadding="0" cellspacing="0" class="mainTable">
            <tr>
                <td class="label" width="50px">Issue Number:</td>
                <td>{*url*}</td>
            </tr>

             <tr>
                <td class="label">Issue Created Date:</td>
                <td>{*create_date*}</td>
            </tr>

             <tr>
                <td class="label">Problem Owner:</td>
                <td>{*problem_owner*}</td>
            </tr>

            <tr>
                <td class="label">Issue Title:</td>
                <td>{*issue_title*}</td>
            </tr>
              <tr>
                <td class="label">Problem Description:</td>
                <td>{*problem_dsc*}</td>
            </tr>
            <tr>
                <td class="label">Root Cause:</td>
                <td>{*root_cause*}</td>
            </tr>
            <tr>
                <td class="label">Root Cause Description:</td>
                <td>{*root_cause_dsc*}</td>
            </tr>
            <tr>
                <td class="label">Root Cause Fix Summary:</td>
                <td>{*root_cause_fix_sum*}</td>
            </tr>
            <tr>
                <td class="label">Close Date:</td>
                <td>{*close_date*}</td>
            </tr>
        </table>
    </div>
    <br />    
</body>
</html>',
             'speed.ilm.prc_div_issue_closed_msg_txt',
             '',
             NULL,
             'speed.ilm.prc_div_issue_closed_msg_rcpt',
             'speed.ilm.prc_div_subscription',
             'Y',
             'Y',
             'Y',
             'N',
             NULL,
             NULL,
             'N'
)

DECLARE @msg_idn AS INT

SET @msg_idn = @@IDENTITY

IF EXISTS (SELECT *
           FROM   module_notif
           WHERE  msg_idn = @msg_idn)
     DELETE module_notif
     WHERE  msg_idn = @msg_idn

INSERT INTO module_notif(
            mdul_idn,
            msg_idn,
            cre_usr,
            cre_dte,
            lst_upd_usr,
            lst_upd_dte
)
VALUES      (173,
            @msg_idn,
            '11314786',
            '5/5/2009 10:50:04 PM',
            '11417197',
            '1/14/2014 6:58:56 PM'
)
GO

PRINT('**************************************** CREATED NOTIFICATION TEMPLATE FOR DIV_ISS_CLOSED       ****************************************')
GO