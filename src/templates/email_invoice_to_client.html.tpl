<br><br>

<TMPL_IF success>

	<b>Document number <TMPL_VAR invoice_number> was emailed to <TMPL_VAR username>.</b>

<TMPL_ELSE>

	<b>Document number <TMPL_VAR invoice_number> could not be sent to <TMPL_VAR username>.</b>

</TMPL_IF>
