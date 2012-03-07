<html>
<head>
 <title>ISP Accounting - Version <TMPL_VAR version></title>
 <link rel="stylesheet" type="text/css" href="/templates/isp_accounting.css">
</head>

<body>

<div align=center>

<TMPL_IF is_devel_system>
		<br><br>
		<font size=4 color=red><b>-------------------- Development Platform --------------------</b></font>
		<br><br><br>
</TMPL_IF>

<table>
    <tr>
        <td><img src="/graphics/image.jpeg"></td>

    </tr>
</table>
<TMPL_VAR version>

<TMPL_IF message>
	<br>
	<br>
	<div class=alert><b><TMPL_VAR message></b></div>
	<br>
<TMPL_ELSE>
	<br><br><br>
</TMPL_IF>

<form name=login action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=login>

<b>Operator Name:</b>

<br><br>

<input name=operator type=text size=15 maxlength=10>

<br><br>

<b>Password:</b>

<br><br>

<input name=password type=password size=15 maxlength=10></td>

<br><br>

<input type=submit value=Login>

</form>

</div>

