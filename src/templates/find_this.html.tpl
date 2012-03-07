<br><br>
<form name=find_this action=/cgi-bin/accounting.cgi method=post>
<input type=hidden name=do value=<TMPL_VAR do>

<b>Look for:</b>

<br><br>

<select name=find_this>
	<option value=plan_by_id>Plan by ID</option>
	<option selected value=invoice>Invoice</option>
</select>

<br><br><br>

<b>Search text:</b>

<br><br>

<input type=text name=search_data maxlen=45>

<br><br>

<input type=submit value=Submit>

</form>
