<div align="center">

<form name=search action=<TMPL_VAR action> method=post>

<input type=hidden name=do value=<TMPL_VAR do> >

<TMPL_IF message>
	<br>
	<h3><div class=alert><TMPL_VAR message></div></h3>
</TMPL_IF>

<br><br>

<h3>Enter Username: </h3>

<input class=searchbox type=text name=search_for size=30>

<br><br>

<input type=submit value="Submit">

</form>

<a href="<TMPL_VAR client_add_link>">Add Client</a><br>
<a href="<TMPL_VAR client_delete_link>">Delete Client</a><br>
<a href="<TMPL_VAR find_link>">Find Something</a><br>
<a href="<TMPL_VAR reports_link>">Reports</a><br>

<script type="text/javascript">
<!--
  document.search.search_for.focus();
//-->
</script>

</div>

