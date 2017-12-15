<html>
  <head>
    <script>
      function ChangeText(txt) {
        var lowest = 1;
        var highest = 5 ;
        var retval = 0;
        var str;

        while ( (retval < lowest) || (retval > highest) ) {
          now = new Date();
          retval = Math.abs(Math.sin(now.getTime())) ;
          retval = parseInt(retval * (highest+1)) ;
        }

        if ( retval == 1 ) {
          str="I am of the nature to be diseased.  I have not gone beyond disease.";
        } else if ( retval == 2 ) {
          str="I am of the nature to die.  I have not gone beyond death.";
        } else if ( retval == 3 ) {
          str="All that is mine, dear and delightful, will change and vanish.";
        } else if ( retval == 4 ) {
          str="I am the owner of my kamma.  I am heir to my kamma.  I am born of my kamma.  i am related to my kamma.  whatever kamma I create, whether good or evil, that I shall inherit.";
        } else if ( retval == 5 ) {
          str="I am of the nature to decay.  I have not gone beyond decay.";
        } else {
          str="error i.e. much dukkha";
        }

      document.getElementById(txt).innerHTML=str;
     }
    </script>
  </head> 
  <body onLoad="ChangeText('mytxt')"> 
    <h1>Rotating random message</h1> 
    <p id='mytxt'>Hello world!</p> 
  </body> 
</html>
