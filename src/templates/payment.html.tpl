<br><br>

<div align="center"><center>

<form action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=<TMPL_VAR do> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id="accounting" border=1 cellspacing=0>

  <tr>
    <th colspan="4">Enter User Payment</th>
  </tr>

  <tr>
    <td colspan=4>&nbsp;</td>
  </tr>

  <tr>
    <td align="center"><b>Date</b></td>
    <td><b>Doc# or Comment</b></td>
    <td><b>Amount Received</b></td>
    <td><b>Payment Method</b></td>
 </tr>

 <tr>
    <td><TMPL_VAR date></td>
    <td><input type=text name=comment></td>
    <td><input type=text name=payment></td>
    <td><b><TMPL_VAR payment_method></b></td>
	<input type=hidden name=date value=<TMPL_VAR date>>
 </tr>

</table>

<br><br>

<input type=submit value="Process Payment">

</div>

