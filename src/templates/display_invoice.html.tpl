<TMPL_IF print>
	<h1><TMPL_VAR type></h1>
</TMPL_IF>
<br>

<table id=accounting border=1 cellspacing=0 cellpadding=4>

	<tr>
		<th colspan=5><TMPL_VAR type>  #<TMPL_VAR invoice_number></th>
	</tr>
	
	<tr>
		<TMPL_IF print>
			<td colspan=5>&nbsp;</td>
		<TMPL_ELSE>
			<td colspan=5 align=right><b>
				[ <a href="<TMPL_VAR email_invoice>">EMAIL INVOICE</a> ] &nbsp;&nbsp;		
				[ <a href="<TMPL_VAR printable_invoice>">PRINTABLE</a> ]</b>&nbsp;&nbsp;</td>
		
		</TMPL_IF>
	</tr>
	
	<tr>
		<td><b>Username</b></td>
		<td colspan=4><TMPL_VAR username></td>
	</tr>
	<tr>
		<td><b>Payment Method</b></td>
		<td colspan=4><TMPL_VAR payment_method></td>
	</tr>

	<tr>
		<td><b>Date</b></td>
		<td colspan=4><TMPL_VAR date></td>
	</tr>
	<tr>
		<td><b>Document Number</b></td>
		<td colspan=4><TMPL_VAR invoice_number></td>
	</tr>

	<tr>
		<td colspan=5>&nbsp;</td>
	</tr>

	<tr>
		<td><b>Quantity</b></td>
		<td><b>Item</b></td>
		<!-- <td><b>Description</b></td> -->
		<td><b>Unit Price</b></td>
		<td><b>Unit Total</b></td>
		<!-- <TMPL_VAR is_poa> -->
		<TMPL_IF is_poa>
			<td><b>Payment</b></td>
		<TMPL_ELSE>
			<td></td>
		</TMPL_IF>
	</tr>

	<tr>
		<td colspan=5>&nbsp;</td>
	</tr>

	<TMPL_LOOP name="items">
	<tr>
		<td><TMPL_VAR quantity></td>
		<td><TMPL_VAR item_name></td>
		<!-- <td><TMPL_VAR comment></td> -->
		<td><TMPL_VAR amount></td>
		<td><TMPL_VAR total_price></td>
		<TMPL_IF is_poa>	
			<td><TMPL_VAR payment></td>
		<TMPL_ELSE>
			<td></td>
		</TMPL_IF>
	</tr>
	</TMPL_LOOP>
		<tr>
		<td colspan=5>&nbsp;</td>
	</tr>
<tr>
		<td colspan=5>&nbsp;</td>
	</tr>

	<tr>
		<td colspan=4 align=right><font size=3><b>Sub-Total</b></font></td>
		<td><font size=3><b><TMPL_VAR sub_total></b></font></td>
	</tr>
	<tr>
		<td colspan=4 align=right><font size=3><b>Tax</b></font></td>
		<td><b><font size=3><b><TMPL_VAR tax></b></font></td>
	</tr>
	<tr>
		<td colspan=4 align=right><font size=3><b>Total</b></font></td>
		<td><font size=3><b><TMPL_VAR grand_total></b></font></td>
	</tr>	
</table>

<TMPL_IF bank_receipt>

	<br>

	<a href="javascript:hide_show('bank_receipt');">Show/Hide Bank Record</a>

	<div id="bank_receipt" style="display:none;">	
	<br><br>
	<pre><TMPL_VAR bank_receipt></pre>
	<br><br>
	</div>

</TMPL_IF>
