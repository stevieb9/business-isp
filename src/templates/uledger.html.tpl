<br><br>

<table id=accounting border=1 cellspacing=0>
<th colspan=4>Account activity</th>
<tr><td colspan=4>&nbsp;</td></tr>

<tr>
	<td><b>Date</b></td>
	<td><b>Inv Num</b></td>
    <td><b>Amount</b></td>
	<td><b>Payment</b></td>
</tr>
  
<TMPL_LOOP NAME=ULEDGER_ENTRIES>
    <tr>
      <td><TMPL_VAR date></td>
      <td><a href="<TMPL_VAR invoice_link>"><TMPL_VAR invoice_number></a></td>
      <td><TMPL_VAR amount></td>
      <td><TMPL_VAR payment></td>
      
	<!--

      /* 
          this commented piece allows us to accept a parameter that we don't
          want to display, and continue die()ing on nonexistent params

             <td><TMPL_VAR username></td>
			 <td><TMPL_VAR id></td>
      */

      -->

    </tr>

    <tr>
      <td colspan=4><TMPL_VAR comment></td>
	  <tr><td colspan=4>&nbsp;</td></tr>
    </tr>

</TMPL_LOOP>

</table>

<br>
