<br><br>

<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=4>Detailed Client Info</th>
    </tr>
</table>

<table id=accounting border=1 cellpadding=0 cellspacing=0>
	<tr>
		<td colspan=4 align=right>Client ID: <TMPL_VAR id></td>
	</tr>

	<tr>
		<td colspan=2><b>Billing Info</b></td>
		<td colspan=2><b>Shipping Info</b></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=2><b><TMPL_VAR billing_first_name> <TMPL_VAR billing_last_name></b></td>
		<td colspan=2><b><TMPL_VAR shipping_first_name> <TMPL_VAR shipping_last_name></b></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=2><b><TMPL_VAR billing_company_name></b></td>
		<td colspan=2><b><TMPL_VAR shipping_company_name></b></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=2><b><TMPL_VAR billing_address1></b></td>
		<td colspan=2><b><TMPL_VAR shipping_address1></b></td>
	</tr>
	
	<TMPL_IF billing_address2>
		<tr>
			<td colspan=2><b><TMPL_VAR billing_address2></b></td>
			<td colspan=2><b><TMPL_VAR shipping_address2></b></td>
		</tr>
	</TMPL_IF>

	<tr>
		<td colspan=2><b><TMPL_VAR billing_town>, <TMPL_VAR billing_province></b></td>
		<td colspan=2><b><TMPL_VAR shipping_town>, <TMPL_VAR shipping_province></b></td>
	</tr>

	<tr>
		<td colspan=2><b><TMPL_VAR billing_postal_code></b></td>
		<td colspan=2><b><TMPL_VAR shipping_postal_code></b></td>
	</tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=2><b><TMPL_VAR billing_email_address></b></td>
		<td colspan=2><b><TMPL_VAR shipping_email_address></b></td>
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
		<td><TMPL_VAR username></td>
		<td><b>Fax</b></td>
		<td><TMPL_VAR fax_phone></td>
	</tr>

	<tr>
		<td><b>Home Phone</b></td>
		<td><TMPL_VAR home_phone></td>
		<td><b>Work Phone</b></td>
		<td><TMPL_VAR work_phone></td>
	</tr>
	
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Tax Exempt</b></td>
		<td><TMPL_VAR tax_exempt></td>
		<td><b>Last Update</b></td>
		<td><TMPL_VAR last_update></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Comment</b></td>
		<td colspan=3><TMPL_VAR comment></td>
	</tr>
</table>

<br><br>

