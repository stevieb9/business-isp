<html>
<head>
 <title>ISP Error</title>
 <link rel="stylesheet" type="text/css" href="/templates/isp_accounting.css">
</head>

<body>

<div align=left>

<table>
        <tr>
                <td><img src="/graphics/image.jpeg"></td>
        </tr>
</table>
</div>

<br><br>

<b>The process you were attempting failed. Below are the error messages<br>
regarding why it failed, the invalid data, and the application call stack that<br>
shows the complete process flow.</b><br><br>

<h3>Error messages:</h3>

<TMPL_LOOP NAME=MESSAGES>
  	-- <TMPL_VAR NAME=TEXT><br>
</TMPL_LOOP>

<br>

<h3>Data:</h3>
<TMPL_VAR d3>

<table id=error border=0 cellspacing=0>


<TMPL_LOOP NAME=DATA>
	<TMPL_IF d1><TMPL_VAR d1><br></TMPL_IF>
	<TMPL_IF d2><TMPL_VAR d2><br></TMPL_IF>
	<TMPL_IF d3><TMPL_VAR name=d3><br></TMPL_IF>
	<TMPL_IF d4><TMPL_VAR d4><br></TMPL_IF>
	<TMPL_IF d5><TMPL_VAR d5><br></TMPL_IF>
	<TMPL_IF d6><TMPL_VAR d6><br></TMPL_IF>
	<TMPL_IF d7><TMPL_VAR d7><br></TMPL_IF>
	<TMPL_IF d8><TMPL_VAR d8><br></TMPL_IF>
	<TMPL_IF d9><TMPL_VAR d9><br></TMPL_IF>
	<TMPL_IF d10><TMPL_VAR d10><br></TMPL_IF>
	<TMPL_IF d11><TMPL_VAR d11><br></TMPL_IF>
	<TMPL_IF d12><TMPL_VAR d12><br></TMPL_IF>
	<TMPL_IF d13><TMPL_VAR d13><br></TMPL_IF>
	<TMPL_IF d14><TMPL_VAR d14><br></TMPL_IF>
	<TMPL_IF d15><TMPL_VAR d15><br></TMPL_IF>
	<TMPL_IF d16><TMPL_VAR d16><br></TMPL_IF>
	<TMPL_IF d17><TMPL_VAR d17><br></TMPL_IF>
	<TMPL_IF d18><TMPL_VAR d18><br></TMPL_IF>
	<TMPL_IF d19><TMPL_VAR d19><br></TMPL_IF>
	<TMPL_IF d20><TMPL_VAR d20><br></TMPL_IF>
	<TMPL_IF d21><TMPL_VAR d21><br></TMPL_IF>
	<TMPL_IF d22><TMPL_VAR d22><br></TMPL_IF>
	<TMPL_IF d23><TMPL_VAR d23><br></TMPL_IF>
	<TMPL_IF d24><TMPL_VAR d24><br></TMPL_IF>
	<TMPL_IF d25><TMPL_VAR d25><br></TMPL_IF>
	<TMPL_IF d26><TMPL_VAR d26><br></TMPL_IF>
	<TMPL_IF d27><TMPL_VAR d27><br></TMPL_IF>
	<TMPL_IF d28><TMPL_VAR d28><br></TMPL_IF>
	<TMPL_IF d29><TMPL_VAR d29><br></TMPL_IF>


</TMPL_LOOP>

</table>

<br>

<h3>Stack trace:</h3>

<table id=error border=0 cellspacing=0>
<TMPL_LOOP NAME=STACK>
        <TMPL_IF sub>
        <tr><td>method:</td>  <td>&nbsp;</td> <td><TMPL_VAR NAME=sub></td></tr>
        </TMPL_IF>
        <tr><td>file:</td>    <td>&nbsp;</td> <td><TMPL_VAR NAME=filename></td></tr>        
	<tr><td>line:</td>    <td>&nbsp;</td> <td><TMPL_VAR NAME=line></td></tr>
        <tr><td>class:</td>   <td>&nbsp;</td> <td><TMPL_VAR NAME=package></td></tr>
        <tr><td colspan=3>&nbsp;</td></tr>
</TMPL_LOOP>

</table>
</body>
</html>

