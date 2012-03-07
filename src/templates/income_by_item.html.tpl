<div align=center>

<br><br>

<table id=accounting>

  <tr>
	<th>Item</th>
	<th>Revenue</th>

  <tr>
	<td colspan=2>&nbsp;</td>
  </tr>

  <TMPL_LOOP report_data>
  
  <tr>
	<td><b><TMPL_VAR name></b></td>
	<td><b>$<TMPL_VAR amount></b></td>
  </tr>

  </TMPL_LOOP>

</table>

<br><br>
