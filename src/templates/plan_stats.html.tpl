<table id=accounting border=1 cellpadding=0 cellspacing=0>

	<th colspan=4>Plan Statistics</th>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Month</b></td>
		<td><b>Hours</b></td>
		<td><b>Upload (MB)</b></td>
		<td><b>Download (MB)</b></td>
	</tr>
	
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>
	<TMPL_LOOP plan_stats>

		<tr>
			<td><TMPL_VAR date></td>
			<td><TMPL_VAR duration></td>
			<td><TMPL_VAR upload></td>
			<td><TMPL_VAR download></td>
		</tr>
	</TMPL_LOOP>
</table>

<br><br>
	
