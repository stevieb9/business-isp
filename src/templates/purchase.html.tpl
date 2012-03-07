<br><br>

<div align=center>

<form action="/cgi-bin/accounting.cgi" method=post>

<input type=hidden name=do value=<TMPL_VAR do> >
<input type=hidden name=username value=<TMPL_VAR username> >

<table id=accounting border=1 cellspacing=0>

  <tr>
    <th colspan=6>Purchase</th>
  </tr>

  <tr>
    <td colspan=6>&nbsp;</td>
  </tr>

  <tr>
    <td><b>Quantity</b></td>
    <td><b>Item</b></td>
    <td><b>Comment</b></td>
    <td><b>Amount</b></td>
    <td><b>Tax</b></td>
	<td></td>
  </tr>

  <tr>
    <td><input type=text name=quantity1 value=1 size=5></td>
    <td><TMPL_VAR plan1></td>
    <td><input type=text name=comment1></td>
    <td><input type=text name=amount1 size=7></td>
    <td><TMPL_VAR tax_select1></td>
	<td><button onclick="purchase_display_row('item2'); return false;">+</button></td>
  </tr>

  <tr id=item2 style="display:none">
    <td><input type=text name=quantity2 value=1 size=5></td>
    <td><TMPL_VAR plan2></td>
    <td><input type=text name=comment2></td>
    <td><input type=text name=amount2 size=7></td>
    <td><TMPL_VAR tax_select2></td>
	<td><button onclick="purchase_display_row('item3'); return false;">+</button></td>
  </tr>

  <tr id=item3 style="display:none">
    <td><input type=text name=quantity3 value=1 size=5></td>
    <td><TMPL_VAR plan3></td>
    <td><input type=text name=comment3></td>
    <td><input type=text name=amount3 size=7></td>
    <td><TMPL_VAR tax_select3></td>
	<td><button onclick="purchase_display_row('item4'); return false;">+</button></td>
  </tr>

  <tr id=item4 style="display:none">
    <td><input type=text name=quantity4 value=1 size=5></td>
    <td><TMPL_VAR plan4></td>
    <td><input type=text name=comment4></td>
    <td><input type=text name=amount4 size=7></td>
    <td><TMPL_VAR tax_select4></td>
	<td><button onclick="purchase_display_row('item5'); return false;">+</button></td>
  </tr>

  <tr id=item5 style="display:none">
    <td><input type=text name=quantity5 value=1 size=5></td>
    <td><TMPL_VAR plan5></td>
    <td><input type=text name=comment5></td>
    <td><input type=text name=amount5 size=7></td>
    <td><TMPL_VAR tax_select5></td>
	<td><button onclick="purchase_display_row('item5'); return false;">-</button></td>
  </tr>

</table>

<br><br>

<TMPL_VAR payment_method>

<br><br>

<input type=submit value="Process Purchase">
</div>


