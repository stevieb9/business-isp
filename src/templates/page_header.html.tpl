<html>
<head>
 <title>ISP Accounting - Version <TMPL_VAR version></title>
 <link rel="stylesheet" type="text/css" href="/templates/isp_accounting.css">
 <SCRIPT type="text/javascript" src="<TMPL_VAR js_lib>">
 </SCRIPT>
</head>

<body>

<div align=center>

<TMPL_IF is_devel_system>
		<br><br>
		<font size=4 color=red><b>-------------------- Development Platform --------------------</b></font>
		<br><br><br>
</TMPL_IF>

<TMPL_IF master_locked>

	<br>
	<h3><font color=red><TMPL_VAR master_locked></font></h3>
	<br>

<TMPL_ELSE>

	<table>
		<tr>
			<td><img src="/graphics/image.jpeg"></td>
		</tr>
	</table>
	<TMPL_VAR version>

</TMPL_IF>

</div>

<br>
<div align=center>

<a href="<TMPL_VAR go_home_link>"><b>Home</b></a>&nbsp&nbsp<b>|</b>&nbsp&nbsp
<a href="<TMPL_VAR signout_link>"><font color=red><b>Sign Out, <TMPL_VAR operator></b></font></a>&nbsp&nbsp<b>|</b>&nbsp&nbsp

<TMPL_IF config_link>
	<a href="<TMPL_VAR config_link>"><b>Display Config</b></a>&nbsp&nbsp<b>|</b>&nbsp&nbsp
</TMPL_IF>

<TMPL_IF source_repo_link>
	<a href="<TMPL_VAR source_repo_link>" target="_blank"><b>Source Repository</b></a>&nbsp&nbsp<b>|</b>&nbsp&nbsp
</TMPL_IF>

<a href="<TMPL_VAR devdocs_link>" target="_blank"><b>Devel Docs</b></a>&nbsp&nbsp

<br>

<TMPL_IF skipped_tests>
	<br>
	<b>Sanity checks skipped on:</b><br>
	<TMPL_VAR skipped_tests>
	<br>
</TMPL_IF>

<br>
