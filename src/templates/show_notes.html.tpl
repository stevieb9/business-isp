<br><br>


<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=4>Client Notes</th>
    </tr>
</table>

<br><br>

<TMPL_IF notes_loop>

	<TMPL_LOOP notes_loop>

		<!-- <TMPL_VAR username> -->
		<table id=accounting border=1>
		<tr>
			<td><b><TMPL_VAR date></b></td>
			<td><b>Tag:</b> <TMPL_VAR tag></td>
			<td><b>ID:</b> <TMPL_VAR id> </td>
			<td><b>By:</b> <TMPL_VAR operator></td>
		</tr>
		</tr>
			<td colspan=4><pre><TMPL_VAR note></pre></td>
		</tr>
	</table>
	<br><br>
	</TMPL_LOOP>

	</table>

<TMPL_ELSE>

	<b>This client doesn't have any notes to display.</b>
	<br>

</TMPL_IF>
