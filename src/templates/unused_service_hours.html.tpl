<br>

<h3><TMPL_VAR report_name></h3>

<br>

<table id=accounting>

  <tr>
	<th>Username</th>
	<th>Contact</th>
	<th>Email</th>
	<th>Hours</th>
	<th>Rate</th>
	<th>Unused Hours</th>
	<th>Outstanding</th>
  </tr>

<TMPL_LOOP service_data>

  <tr>
	<td><TMPL_VAR username></td>
	<td><TMPL_VAR fullname></td>
	<td><TMPL_VAR email></td>
	<td><TMPL_VAR hours></td>
	<td><TMPL_VAR rate></td>
	<td><TMPL_VAR unused></td>
	<td>$<TMPL_VAR outstanding></td>

  </tr>

</TMPL_LOOP>

<TMPL_LOOP service_totals>

  <tr>
	<td colspan=7>&nbsp;</td>
  </tr>

  <tr>
	<th colspan=7>Totals</th>
  </tr>

  <tr>
	<td colspan=6 align=right><b>Users:</b></td>
	<td align=right><font size=3><b><TMPL_VAR users></b></font></td>
  </tr>
  <tr>
	<td colspan=6 align=right><b>Outstanding hours:</b></td>
	<td align=right><font size=3><b><TMPL_VAR hours></b></font></td>
  </tr>
  <tr>
	<td colspan=6 align=right><b>Outstanding value:</b></td>
	<td align=right><font size=3><b>$<TMPL_VAR outstanding></b></font></td>
  </tr>

</TMPL_LOOP>

</table>
