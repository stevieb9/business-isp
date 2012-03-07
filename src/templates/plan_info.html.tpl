<br><br>
<!-- <TMPL_VAR classification> -->

<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=6>Plan Information </th>
    </tr>
    <tr>
      <td colspan=6 align=right><b>[ <a href="<TMPL_VAR display_edit_plan_link>">EDIT</a> ]&nbsp&nbsp</b><td>
    </tr>
    <tr>
	  <TMPL_IF is_plana>
  	  <td colspan=6><b><TMPL_VAR plan> &nbsp&nbsp <font color=green><TMPL_VAR hours_balance></font>
			<TMPL_IF this_month_hours> &nbsp&nbsp minus <TMPL_VAR this_month_hours> used this month.</TMPL_IF></b></td>
	  <TMPL_ELSE>
	  <td colspan=6><b><TMPL_VAR plan> &nbsp&nbsp <TMPL_VAR dsl_number></b></td>
	  </TMPL_IF>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Login:</b></td>
      <td><TMPL_VAR login_name></td>
      <td><b>Rate:</b></td>
      <td><TMPL_VAR rate></td>
      <td><b>Status:</b></td>
      <td class=alert><b><a href="<TMPL_VAR plan_status_link>"><TMPL_VAR plan_status></a></b></td>
    </tr>
    <tr>
      <td><b>Password:</b></td>
      <td><TMPL_VAR password></td>
      <td><b>Hours:</b></td>
      <td><TMPL_VAR hours></td>
      <td><b>DOB:</b></td>
      <td><TMPL_VAR dob></td>
    </tr>
    <tr>
      <td><b>Email:</b></td>
      <td><a href="mailto:<TMPL_VAR email>"><b><TMPL_VAR email></b></a></td>
      <td><b>Over Rate:</b></td>
      <td><TMPL_VAR over_rate></td>
      <td><b>Plan Id:</b></td>
      <td><TMPL_VAR id></td>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Expiry:</b></td>
      <td><TMPL_VAR expires></td>
      <td><b>Started:</b></td>
      <td><TMPL_VAR started></td>
      <td><b>Billing Method:</b></td>
      <td><TMPL_VAR billing_method></td>
    </tr>
    <tr>
      <td><b>PAP Method:</b></td>
      <td><TMPL_VAR pap_method></td>
      <td><b>PAP Date:</b></td>
      <td><TMPL_VAR pap_date></td>
      <td><b>Last Update:</b></td>
      <td><TMPL_VAR last_update></td>
    </tr>
    <tr>
      <td><b>Billing Period:</b></td>
      <td><TMPL_VAR billing_period></td>
      <td><b>Next Bill Date:</b></td>
      <td><TMPL_VAR next_billing_date></td>
      <td colspan=2></td>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>    
	<tr>
	  <td><b><font color=red>RADIUS password:</font></b></td>
	  <td>&nbsp;&nbsp;<TMPL_VAR radius_password></td>
	  <td><b><font color=red>Email Password:</font></b></td>
	  <td></td>
	  <td colspan=2></td>
	</tr>
	<tr>
	  <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Comment:</b></td>
      <td colspan=5><TMPL_VAR comment></td>
    </tr>
	<tr>
	  <td><b>Desc:</b></td>
	  <td colspan=5><TMPL_VAR description></td>
	</tr>
</table>

<br><br>

<form name=delete_plan action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=delete_plan>
<input type=hidden name=id value=<TMPL_VAR id> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id=accounting border=1 colspan=0>
	<tr>
		<th colspan=3>Delete Plan</th>
	</tr>
	<tr>
		<td colspan=3>&nbsp;</td>
	</tr>
	<tr>
		<input type=hidden name=captcha value=<TMPL_VAR captcha>>
		<td>Enter the following number to confirm: <b><TMPL_VAR captcha></b></td>
		<td><input type=text name=confirm size=5></td>
		<td><input type=submit value=Delete></td>
	</tr>
</table>
</form>
&nbsp&nbsp&nbsp

<br>

<!--
<TMPL_VAR os>
<TMPL_VAR server>
<TMPL_VAR comment>
-->
