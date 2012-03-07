<br><br>

<div align=center>

<table id="accounting" border=0 cellspacing=1 cellpadding=1>

	<th colspan=2>Configuration File: <TMPL_VAR config_location></th>

	<tr> 
		<td colspan=2>&nbsp;</tr>
	</tr>

	<tr>
		<td><b>Directive</b></td>
		<td><b>Current Value</b></td>
	<tr>

	<tr> 
		<td colspan=2>&nbsp;</tr>
	</tr>

	<TMPL_LOOP NAME="config">
	
	<TMPL_IF heading>
		<tr>
			<td colspan=2>&nbsp;</td>
		</tr>
		<tr>
			<td class=heading><div class=quickview><TMPL_VAR directive></div></td>
			<td><TMPL_VAR value></td>
		</tr>
		<tr>
			<td colspan=2>&nbsp;</td>
		</tr>
	<TMPL_ELSE>

		<tr>
			<td><TMPL_VAR directive></td>
			<td><TMPL_VAR value></td>
		</tr>

	</TMPL_IF>

	</TMPL_LOOP>
</table>

</div>	
	
