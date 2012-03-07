<br><br>

<div align="center"><center>

<form action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=<TMPL_VAR do> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id="accounting" border=1 cellspacing=0>

	<tr>
    	<th colspan=5>Confirm Account Renewal</th>
  	</tr>

	<tr>
		<td colspan=5>&nbsp;</td>
	</tr>	

	<tr>
		<td><b>Plan</b></td>
		<td><b>Qty</b></td>
		<td><b>Id</b></td>
	</tr>

	<tr>
		<td colspan=5>&nbsp;</td>
	</tr>	
	
	<TMPL_IF plan1>
  		<tr>    
			<td><TMPL_VAR plan1name></td>
			<td><TMPL_VAR plan1qty></td>
			<td><TMPL_VAR plan1id></td>
			<input type=hidden name=plan1name value=<TMPL_VAR plan1name>>
			<input type=hidden name=plan1qty value=<TMPL_VAR plan1qty>>
			<input type=hidden name=plan1id value=<TMPL_VAR plan1id>>
			<input type=hidden name=plan1rate value=<TMPL_VAR plan1rate>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF plan2>
  		<tr>    
			<td><TMPL_VAR plan2name></td>
			<td><TMPL_VAR plan2qty></td>
			<td><TMPL_VAR plan2id></td>
			<input type=hidden name=plan2name value=<TMPL_VAR plan2name>>
			<input type=hidden name=plan2qty value=<TMPL_VAR plan2qty>>
			<input type=hidden name=plan2id value=<TMPL_VAR plan2id>>
			<input type=hidden name=plan2rate value=<TMPL_VAR plan2rate>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF plan3>
  		<tr>    
			<td><TMPL_VAR plan3name></td>
			<td><TMPL_VAR plan3qty></td>
			<td><TMPL_VAR plan3id></td>
			<input type=hidden name=plan3name value=<TMPL_VAR plan3name>>
			<input type=hidden name=plan3qty value=<TMPL_VAR plan3qty>>
			<input type=hidden name=plan3id value=<TMPL_VAR plan3id>>
			<input type=hidden name=plan3rate value=<TMPL_VAR plan3rate>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF plan4>
  		<tr>    
			<td><TMPL_VAR plan4name></td>
			<td><TMPL_VAR plan4qty></td>
			<td><TMPL_VAR plan4id></td>
			<input type=hidden name=plan4name value=<TMPL_VAR plan4name>>
			<input type=hidden name=plan4qty value=<TMPL_VAR plan4qty>>
			<input type=hidden name=plan4id value=<TMPL_VAR plan4id>>
			<input type=hidden name=plan4rate value=<TMPL_VAR plan4rate>>
	  	</tr>
	</TMPL_IF>

	<TMPL_IF plan5>
  		<tr>    
			<td><TMPL_VAR plan5name></td>
			<td><TMPL_VAR plan5qty></td>
			<td><TMPL_VAR plan5id></td>
			<input type=hidden name=plan5name value=<TMPL_VAR plan5name>>
			<input type=hidden name=plan5qty value=<TMPL_VAR plan5qty>>
			<input type=hidden name=plan5id value=<TMPL_VAR plan5id>>
			<input type=hidden name=plan5rate value=<TMPL_VAR plan5rate>>
	  	</tr>
	</TMPL_IF>

	<tr>
		<td colspan=5>&nbsp;</td>
	</tr>	

	<tr>
		<td><b><font size=3px>Tax</font></b></td>
		<td colspan=2><b><font size=3px><TMPL_VAR tax></font></b></td>
		<input type=hidden name=tax value=<TMPL_VAR tax>>
	</tr>

	<tr>
		<td><b><font size=4px>Total</font></b></td>
		<td colspan=2><b><font size=4px><TMPL_VAR total_amount></font></b></td>
		<input type=hidden name=total_amount value=<TMPL_VAR total_amount>>
	</tr>

</table>

<br><br>

Via <TMPL_VAR payment_method>

<input type=hidden name=payment_method value=<TMPL_VAR payment_method>

<TMPL_IF cc>

	<TMPL_INCLUDE credit_card_payment.html.tpl>

</TMPL_IF>

</table>

<br><br>
<input type=submit value="Process">

</div>

