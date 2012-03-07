<div align=center>

<br>
<form name=delete_client action="/cgi-bin/accounting.cgi" method=post>
<input type=hidden name=do value=client_delete_confirm>

<h3>Username to delete:</h3>

<br>

<input type=text name=username size=30 maxlen=45>

<br><br>

<h3>Enter confirmation number:</h3>

<div class=alert><h3><TMPL_VAR captcha></h3></div>
<input type=hidden name=captcha value=<TMPL_VAR captcha>>

<input type=text name=confirm size=8 maxlen=16>

<br><br><br>

<input type=submit value=Submit>

</form>
</div>

