<br><br>

<form name=edit_client_info action="/cgi-bin/accounting.cgi" method=post>
<input type=hidden name=do value=edit_client_info>
<!-- <TMPL_VAR id> -->

<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=4>Edit Client Info</th>
    </tr>
</table>

<table id=accounting border=1 cellpadding=0 cellspacing=0>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=2><b>Billing Info</b></td>
		<td colspan=2><b>Shipping Info</b></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=3>Apply Billing Info to Shipping?: <input type=checkbox name=billeqship value=billeqship checked></td>
		<td>Client ID: <TMPL_VAR id></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Name: First</b></td>
		<td><input type=text class=heading name=billing_first_name maxlen=25 size=10 value="<TMPL_VAR billing_first_name>"> 
			  <b>Last</b> <input type=text class=heading name=billing_last_name maxlen=35 size=20 value="<TMPL_VAR billing_last_name>"></td>
		<td><b>Name: First</b></td>
		<td><input type=text class=heading name=shipping_first_name maxlen=25 size=10 value="<TMPL_VAR shipping_first_name>"> 
			  <b>Last</b> <input type=text class=heading name=shipping_last_name maxlen=35 size=20 value="<TMPL_VAR shipping_last_name>"></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Company</b></td>
		<td><input type=text class=heading name=billing_company_name maxlen=45 size=40 value="<TMPL_VAR billing_company_name>"></td>
		<td><b>Company</b></td>
		<td><input type=text class=heading name=shipping_company_name maxlen=45 size=40 value="<TMPL_VAR shipping_company_name>"></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Address 1</b></td>
		<td><b><input type=text class=heading name=billing_address1 maxlen=45 size=35 value="<TMPL_VAR billing_address1>"></b></td>
		<td><b>Address 1</b></td>
		<td><b><input type=text class=heading name=shipping_address1 maxlen=45 size=35 value="<TMPL_VAR shipping_address1>"></b></td>
	</tr>
	<tr>
		<td><b>Address 2</b></td>
		<td><b><input type=text class=heading name=billing_address2 maxlen=45 size=35 value="<TMPL_VAR billing_address2>"></b></td>
		<td><b>Address 2</b></td>
		<td><b><input type=text class=heading name=shipping_address2 maxlen=45 size=35 value="<TMPL_VAR shipping_address2>"></b></td>
	</tr>

	<tr>
		<td><b>City</b></td>
		<td><input type=text class=heading name=billing_town maxlen=25 value="<TMPL_VAR billing_town>"> 
			  <b>Prov</b> <input type=text class=heading name=billing_province maxlen=25 size=10 value="<TMPL_VAR billing_province>"></td>
		<td><b>City</b></td>
		<td><input type=text class=heading name=shipping_town maxlen=25 value="<TMPL_VAR shipping_town>"> 
			  <b>Prov</b> <input type=text class=heading name=shipping_province maxlen=25 size=10 value="<TMPL_VAR shipping_province>"></td>
	</tr>

	<tr>
		<td><b>Postal Code</b></td>
		<td><input type=text  class=heading name=billing_postal_code maxlen=7 size=7 value="<TMPL_VAR billing_postal_code>"></td>
		<td><b>Postal Code</b></td>
		<td><input type=text  class=heading name=shipping_postal_code maxlen=7 size=7 value="<TMPL_VAR shipping_postal_code>"></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Bill Email</b></td>
		<td><input type=text  class=heading name=billing_email_address maxlen=45 size=35 value="<TMPL_VAR billing_email_address>"></td>
		<td><b>Ship Email</b></td>
		<td><input type=text  class=heading name=shipping_email_address maxlen=45 size=35 value="<TMPL_VAR shipping_email_address>"></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>
	
	<tr>
		<td colspan=4><b>Contact Information</b></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>
	<tr>
		<td><b><font color=red>Username</font></b></td>
		<td><input type=text  class=heading name=username maxlen=44 value="<TMPL_VAR username>"></td>
		<td><b>Fax</b></td>
		<td><input type=text  class=heading maxlen=20 name=fax_phone value="<TMPL_VAR fax_phone>"></td>
	</tr>

	<tr>
		<td><b>Home Phone</b></td>
		<td><input type=text maxlen=20  class=heading name=home_phone value="<TMPL_VAR home_phone>"></td>
		<td><b>Work Phone</b></td>
		<td><input type=text maxlen=20  class=heading name=work_phone value="<TMPL_VAR work_phone>"></td>
	</tr>
	
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Tax Exempt</b></td>
		<td>
			<select name=tax_exempt>
				<TMPL_IF tax_exempt>
					<option value="Yes" selected>Yes</option>
					<option value="No">No</option>
				<TMPL_ELSE>
					<option value="Yes">Yes</option>
					<option value="No" selected>No</option>
				</TMPL_IF>			
			</select>
		</td>
		<td><b>Last Update</b></td>
		<td><TMPL_VAR last_update></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Comment</b></td>
		<td colspan=3><input type=text  class=heading name=comment maxlen=80 size=90 value="<TMPL_VAR comment>"></td>
	</tr>
</table>

<br><br>

<input type=submit value="Edit Client">
</form>

