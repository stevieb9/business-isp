/*
   Display additional purchase items
*/

function purchase_display_row( str ){        
    var row = document.getElementById( str );        
    if ( row.style.display == '' ){ 
        row.style.display = 'none';        
    }
    else row.style.display = '';
}


/*
   Display a div elem
*/

function hide_show( str ){
    var item = document.getElementById( str );
    if ( item.style.display == '' ){
        item.style.display = 'none';
    }
    else item.style.display = '';
}


/*
   Test function
*/

function test_alert() {
    alert( "JS is working fine" );
}
