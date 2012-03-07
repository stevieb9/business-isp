<div align=center>


<br><br>

<table id=accounting border=1 cellspacing=0>

  <tr>
	<th>Pick</th>
	<th>Report Name</th>
	<th>Option1</th>
	<th>Option2</th>
  </tr>
  
  <tr>
	<form action="/cgi-bin/accounting.cgi" method=post>
	<td><input type=submit value=Run></td>
	<input type=hidden name=do value=exec_report>
	<input type=hidden name=report value=income_by_payment_type>
	<td><b>Income By Payment Type</b></td>
	<td>Date: <input type=text name=opt1></td>
	<td>Type: <input type=text name=opt2></td>
	</form>
  </tr>
  
  <tr>
	<form action="/cgi-bin/accounting.cgi" method=post>
	<td><input type=submit value=Run></td>
	<input type=hidden name=do value=exec_report>
	<input type=hidden name=report value=income_by_item>
	<td><b>Income By Item</b></td>
	<td>Date: <input type=text name=opt1></td>
	<td>Item: <input type=text name=opt2></td>
	</form>
  </tr>

  <tr>
	<form action="/cgi-bin/accounting.cgi" method=post>
	<td><input type=submit value=Run></td>
	<input type=hidden name=do value=exec_report>
	<input type=hidden name=report value=unused_service>
	<td><b>Unused Services</b></td>
	<td>Months: <input type=radio name=opt1 value=months></td>
	<td>Hours: <input type=radio name=opt1 value=hours></td>
	</form>
  </tr>

</table>

<br><br>
