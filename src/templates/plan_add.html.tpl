<br><br>


<form name=add_plan action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=<TMPL_VAR do> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=6>Plan Information</th>
    </tr>
 <TMPL_IF date>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td colspan=6><b><TMPL_VAR plan> &nbsp&nbsp <TMPL_VAR dsl_number></b></td>
    </tr>
  </TMPL_IF>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Login:</b></td>
      <td><input type=text class=heading name=login_name></td>
      <td><b>Rate:</b></td>
      <td><input type=text class=heading name=rate></td>
      <td><b>Status:</b></td>
      <td><TMPL_VAR plan_status></td>
    </tr>
    <tr>
      <td><b>Password:</b></td>
      <td><input type=text class=heading name=password></td>
      <td><b>Hours:</b></td>
      <td><input type=text class=heading name=hours></td>
      <td><b>DOB:</b></td>
      <td><input type=text class=heading name=dob></td>
    </tr>
    <tr>
      <td><b>Email:</b></td>
      <td><input type=text class=heading name=email></b></a></td>
      <td><b>Over Rate:</b></td>
      <td><input type=text class=heading name=over_rate value=1.00></td>
      <td><b>Plan Id:</b></td>
      <td>N/A</td>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Expiry:</b></td>
      <td><input type=text class=heading name=expires></td>
      <td><b>Started:</b></td>
      <td><TMPL_VAR date></td>
      <td><b>Billing Method:</b></td>
      <td><TMPL_VAR name=billing_method></td>
    </tr>
    <tr>
      <td><b>PAP Method:</b></td>
      <td><TMPL_VAR pap_method></td>
      <td><b>PAP Date:</b></td>
      <td><TMPL_VAR pap_date></td>
      <td><b>Last Update:</b></td>
      <td><TMPL_VAR name=date></td>
    </tr>
    <tr>
      <td><b>Billing Period:</b></td>
      <td>N/A</td>
      <td><b>Next Bill Date:</b></td>
      <td>N/A</td>
      <td colspan=2></td>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Plan:</b></td>
      <td colspan=5><TMPL_VAR plan></td>
    </tr>
    <tr>
      <td><b>DSL Num:</b></td>
      <td colspan=5><input type=text class=heading size=15 name=dsl_number></td>
    </tr>
    <tr>
      <td><b>Comment:</b></td>
      <td colspan=5><input type=text class=heading size=75 name=comment></td>
    </tr>
	<tr>
	  <td><b>Desc:</b></td>
	  <td colspan=5><input type=text class=heading size=75 name=description></td>
	</tr>
</table>

&nbsp&nbsp&nbsp

<br><br>

<input type=submit value="Process">
</form>

<!--
<TMPL_VAR os>
<TMPL_VAR server>
<TMPL_VAR description>
<TMPL_VAR comment>
-->
