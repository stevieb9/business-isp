<br><br>

<table id="accounting" border="1" cellpadding="0" cellspacing="0">
    <tr>
      <th colspan=4>Add Client Notes</th>
    </tr>
</table>

<form name=process_notes action="/cgi-bin/accounting.cgi" method=post>

<!-- example of why we need Session...-->
<!-- rev 943/944 of ISP -->
<input type=hidden name=do value=<TMPL_VAR do>>
<table>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>
	<tr>

		<td colspan=2><b>Classification:</b>&nbsp&nbsp&nbsp&nbsp<TMPL_VAR classification></td>
		<td><b>Operator:</b></td>
		<td><TMPL_VAR operator></td>
	</tr>
	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>
	<tr>
		<td colspan=4><textarea name=note cols=90 rows=12 wrap=hard></textarea></td>
	</tr>
</table>

<br><br>

<input type=submit value="Add Note">
</form>

