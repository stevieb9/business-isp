<br><br>

<div align="center"><center>

<form action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=<TMPL_VAR do> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id="accounting" border=1 cellspacing=0>

	<tr>
    	<th colspan=5>Confirm Payment</th>
  	</tr>

	<tr>
		<td>&nbsp;</td>
	</tr>	

    <tr>
    	<td align="center"><b>Date</b></td>
    	<td><b>Doc# or Comment</b></td>
    	<td><b>Amount Received</b></td>
    	<td><b>Payment Method</b></td>
     </tr>

	<tr>
		<td colspan=4>&nbsp;</td>
	</tr>

	<tr>
		<td><TMPL_VAR date></td>
		<td><TMPL_VAR comment></td>
		<td><TMPL_VAR payment></td>
		<td><TMPL_VAR payment_method></td>
		<input type=hidden name=payment value=<TMPL_VAR payment>>
		<input type=hidden name=comment value=<TMPL_VAR comment>>
	</tr>

</table>

<br><br>

Via <TMPL_VAR payment_method>

<input type=hidden name=payment_method value=<TMPL_VAR payment_method>>

<TMPL_IF cc>

	<TMPL_INCLUDE credit_card_payment.html.tpl>

</TMPL_IF>

</table>

<br><br>
<input type=submit value="Process">

</div>

