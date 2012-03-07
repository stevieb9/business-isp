<br><br>

<form name=edit_plan action="/cgi-bin/accounting.cgi" method=post>
<input type=hidden name=do value=edit_plan>
<!-- <TMPL_VAR username> -->
<!-- <TMPL_VAR classification> -->

<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=6>Edit Plan Information </th>
    </tr>

    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
  	  <td colspan=6><b><TMPL_VAR plan></td>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Login:</b></td>
      <td><input type=text name=login_name class=heading value="<TMPL_VAR login_name>"></td>
      <td><b>Rate:</b></td>
      <td><input type=text name=rate class=heading value="<TMPL_VAR rate>"></td>
      <td><b>Status:</b></td>
      <td class=alert><b><TMPL_VAR plan_status></b></td>
    </tr>
    <tr>
      <td><b>Password:</b></td>
      <td><input type=text name=password class=heading value="<TMPL_VAR password>"></td>
      <td><b>Hours:</b></td>
      <td><TMPL_VAR hours></td>
      <td><b>DOB:</b></td>
      <td><input type=text name=dob class=heading value="<TMPL_VAR dob>"></td>
    </tr>
    <tr>
      <td><b>Email:</b></td>
      <td><a href="mailto:<TMPL_VAR email>"><b><TMPL_VAR email></b></a></td>
      <td><b>Over Rate:</b></td>
      <td><input type=text name=over_rate class=heading value="<TMPL_VAR over_rate>"></td>
      <td><b>Plan Id:</b></td>
	  <input type=hidden id=<TMPL_VAR id>>
      <td><TMPL_VAR id></td>
    </tr>
    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Expiry:</b></td>
      <td><input type=text name=expires class=heading value="<TMPL_VAR expires>"></td>
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
    </tr>    <tr>
      <td colspan=6>&nbsp;</td>
    </tr>
    <tr>
      <td><b>Comment:</b></td>
      <td colspan=5><input type=text size=75 class=heading name=comment value="<TMPL_VAR comment>"></td>
    </tr>
	<tr>
	  <td><b>Desc:</b></td>
	  <td colspan=5>
			<input type=text class=heading size=75 name=description value="<TMPL_VAR description>">
	  </td>
	</tr>
</table>

<br>
<br>

<input type=submit value=Submit>
</form>

<br><br>


<br>

<!--
<TMPL_VAR os>
<TMPL_VAR server>
<TMPL_VAR description>
<TMPL_VAR comment>
-->
