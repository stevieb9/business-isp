
<TMPL_IF no_user_found>
<br><br>
<b><TMPL_VAR no_user_found></b>

<TMPL_ELSE>

<!-- PRINT THE PLANS TABLE -->

<TMPL_IF plan1>

<table id="accounting" border=1 cellspacing=0>

  <tr>
    <th colspan=7>Account Plans</th>
  </tr>
  <tr>

    <td class=plan align=center><a href="<TMPL_VAR plan1_link>"><TMPL_VAR plan1></a></td>

    <TMPL_IF plan2>
        <td class=plan align=center><a href="<TMPL_VAR plan2_link>"><TMPL_VAR plan2></a></td>
    <TMPL_ELSE>
        <td class=plan align=center></td>
    </TMPL_IF>

    <TMPL_IF plan3>
        <td class=plan align=center><a href="<TMPL_VAR plan3_link>"><TMPL_VAR plan3></a></td>
    <TMPL_ELSE>
        <td class=plan align=center></td>
    </TMPL_IF>

    <TMPL_IF plan4>    
        <td class=plan align=center><a href="<TMPL_VAR plan4_link>"><TMPL_VAR plan4></a></td>
    <TMPL_ELSE>
        <td class=plan align=center></td>
    </TMPL_IF>

    <TMPL_IF plan5>
        <td class=plan align=center><a href="<TMPL_VAR plan5_link>"><TMPL_VAR plan5></a></td>
    <TMPL_ELSE>
        <td class=plan align=center></td>
    </TMPL_IF>

    <td class=plan colspan=2></td>

  </tr>

</table>

<br><br>
</TMPL_IF>

<table id="accounting" border=1 cellspacing=0>

  <tr>
    <th colspan=7>Account Operations</th>
  </tr>

  <tr class=function>

    <td><a href="<TMPL_VAR renewal_link>">Renewal</a></td>
    <td><a href="<TMPL_VAR payment_link>">Payment</a></td>
    <td><a href="<TMPL_VAR purchase_link>">Purchase</a></td>
    <td><a href="<TMPL_VAR uledger_link>">Ledger</a></td>
    <td><a href="<TMPL_VAR add_plan_link>">Add Plan</a></td>
    <td><a href="<TMPL_VAR show_notes_link>">See Notes</a></td>
    <td><a href="<TMPL_VAR add_notes_link>">Add Notes</a></td>

  </tr>
  <tr>
    <td colspan=7>&nbsp;</td>
  </tr>
  <tr>
    <td class=quickview colspan=2>User: <b><a href="<TMPL_VAR client_home_link>"><TMPL_VAR user></a></b></td>
    <td colspan=3>  </td>
    <td class=quickview>Balance:</td>
    <td class=quickview><b><TMPL_VAR balance></b></td>
  </tr>
</table>

</TMPL_IF>
