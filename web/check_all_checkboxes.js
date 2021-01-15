 /* For code injection */

function cbx() {
  var allInputs = document.getElementsByTagName("input");
  for (var i=0, max=allInputs.length; i<max; i++){
    if (allInputs[i].type === 'checkbox')
      // Toggle
      if (allInputs[i].checked == false) {
        allInputs[i].checked = true;
      } else {
        allInputs[i].checked = false;
      }
  }
}
cbx()
