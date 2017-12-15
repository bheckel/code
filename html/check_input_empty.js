<html>
<head>
<script type="text/javascript">
  function notEmpty(){
    var myTextField = document.getElementById('myText');
    if(myTextField.value != "")
      alert("You entered: " + myTextField.value)
    else
      alert("Would you please enter some text?")		
  }
</script>
<input type='text' id='myText' />
<input type='button' onclick='notEmpty()' value='Form Checker' />
</head>
</html>
