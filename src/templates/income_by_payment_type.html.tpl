<div align=center>

<br><br>

<TMPL_LOOP report_data>

<table id=accounting>

  <tr>
    <td colspan=6><font size=4><TMPL_VAR payment_method></font></td>
  </tr>

  <tr>
	<td colspan=6>&nbsp;</td>
  </tr>

  <tr>
	<th>Contact Name</th>
	<th>Login Name</th>
	<th>Document</th>
	<th>Account</th>
	<th>Comment</th>
	<th>Total</th>
  </tr>

  <TMPL_LOOP entries>
	<!-- <TMPL_VAR payment_method> -->
  <tr>
	<td><TMPL_VAR fullname></td>
	<td><TMPL_VAR username></td>
	<td><a href="<TMPL_VAR invoice_link>"><TMPL_VAR invoice_number></a></td>
	<td><TMPL_VAR item_name></td>
	<td><TMPL_VAR comment></td>
	<td>$<TMPL_VAR total_price></td>
  </tr>

  </TMPL_LOOP>

  <tr>
	<td colspan=6>&nbsp;</td>
  </tr>

  <tr>
	<td colspan=5 align=right><font size=4><TMPL_VAR payment_method> total:&nbsp;&nbsp;&nbsp</font></td>
	<td colspan=1 align=left><font size=4>$<TMPL_VAR account_total></font></td>
  </tr>

</table>

<br><br>

</TMPL_LOOP>
