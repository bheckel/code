<SCRIPT>
  function ClearRadios(oRad) {
    if ( typeof oRad.length != 'undefined' ) {
      for ( var i=0; i<oRad.length; i++ ) {
        oRad[i].checked = false;
      }
    } else {
      oRad.checked = false;
    }
  } 
</SCRIPT>

<FORM onsubmit="ClearRadios(form1);return false;">
  <INPUT TYPE="submit" VALUE="Clear">
</FORM>
