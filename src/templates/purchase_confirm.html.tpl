<br><br>

<div align="center"><center>

<form action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=<TMPL_VAR do> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id="accounting" border=1 cellspacing=0>

	<tr>
    	<th colspan=3>Confirm Purchase</th>
  	</tr>

	<tr>
		<td colspan=3>&nbsp;</td>
	</tr>	

	<tr>
		<td><b>Item</b></td>
		<td><b>Qty</b></td>
		<td><b>Sub-total</b></td>
	</tr>

	<tr>
		<td colspan=3>&nbsp;</td>
	</tr>	
	
	<TMPL_IF item1>
  		<tr>    
			<td><TMPL_VAR item1name></td>
			<td><TMPL_VAR item1qty></td>
			<td><TMPL_VAR item1amount></td>
			<input type=hidden name=item1tax value=<TMPL_VAR item1tax>>
	  		<input type=hidden name=item1name value=<TMPL_VAR item1name>>
			<input type=hidden name=item1qty value=<TMPL_VAR item1qty>>
			<input type=hidden name=item1amount value=<TMPL_VAR item1amount>>
		</tr>
	</TMPL_IF>

	<TMPL_IF item2>
  		<tr>    
			<td><TMPL_VAR item2name></td>
			<td><TMPL_VAR item2qty></td>
			<td><TMPL_VAR item2amount></td>
	  		<input type=hidden name=item2name value=<TMPL_VAR item2name>>
			<input type=hidden name=item2tax value=<TMPL_VAR item2tax>>
			<input type=hidden name=item2qty value=<TMPL_VAR item2qty>>
			<input type=hidden name=item2amount value=<TMPL_VAR item2amount>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF item3>
  		<tr>    
			<td><TMPL_VAR item3name></td>
			<td><TMPL_VAR item3qty></td>
			<td><TMPL_VAR item3amount></td>
	  		<input type=hidden name=item3name value=<TMPL_VAR item3name>>
			<input type=hidden name=item3tax value=<TMPL_VAR item3tax>>
			<input type=hidden name=item3qty value=<TMPL_VAR item3qty>>
			<input type=hidden name=item3amount value=<TMPL_VAR item3amount>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF item4>
  		<tr>    
			<td><TMPL_VAR item4name></td>
			<td><TMPL_VAR item4qty></td>
			<td><TMPL_VAR item4amount></td>
	  		<input type=hidden name=item4name value=<TMPL_VAR item4name>>
			<input type=hidden name=item4tax value=<TMPL_VAR item4tax>>
			<input type=hidden name=item4qty value=<TMPL_VAR item4qty>>
			<input type=hidden name=item4amount value=<TMPL_VAR item4amount>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF item5>
  		<tr>    
			<td><TMPL_VAR item5name></td>
			<td><TMPL_VAR item5qty></td>
			<td><TMPL_VAR item5amount></td>
	  		<input type=hidden name=item5name value=<TMPL_VAR item5name>>
			<input type=hidden name=item5tax value=<TMPL_VAR item5tax>>
			<input type=hidden name=item5qty value=<TMPL_VAR item5qty>>
			<input type=hidden name=item5amount value=<TMPL_VAR item5amount>>
	  	</tr>
	</TMPL_IF>
</table>

<br><br>


<table  border=0 cellspacing=0>
	<tr>
		<td colspan=3>&nbsp;</td>
	</tr>	
	
	<tr>
		<td>Tax:</td>
		<td><TMPL_VAR tax_total></td>
	</tr>
	<tr>
		<td>Sub total:</td>
		<td><TMPL_VAR subtotal></td>
	</tr>
	<tr>
		<td colspan=2>&nbsp;</td>
	</tr>
	<tr>
		<td><b> Total:</b></td>
		<td><b><TMPL_VAR total></b></td>
</table>

<br><br>

Via <TMPL_VAR payment_method>

<input type=hidden name=payment_method value=<TMPL_VAR payment_method>>
<input type=hidden name=total value=<TMPL_VAR total>>

<TMPL_IF cc>

	<TMPL_INCLUDE credit_card_payment.html.tpl>

</TMPL_IF>

</table>

<br><br>
<input type=submit value="Process">

</div>

