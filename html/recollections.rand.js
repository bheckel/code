<HTML>
<HEAD>
<SCRIPT language="JavaScript">
	lowest=1
	highest=5 
  retval = 0

  while ((retval < lowest) || (retval > highest)) {
    now = new Date()
    retval = Math.abs(Math.sin(now.getTime())) 
    retval = parseInt(retval * (highest+1)) 
  }

	if ( retval == 1 ) {
		str="I AM OF THE NATURE TO BE DISEASED.  I HAVE NOT GONE BEYOND DISEASE."
	} else if ( retval == 2 ) {
		str="I AM OF THE NATURE TO DIE.  I HAVE NOT GONE BEYOND DEATH."
	} else if ( retval == 3 ) {
		str="ALL THAT IS MINE, DEAR AND DELIGHTFUL, WILL CHANGE AND VANISH."
	} else if ( retval == 4 ) {
		str="I AM THE OWNER OF MY KAMMA.  I AM HEIR TO MY KAMMA.  I AM BORN OF MY KAMMA.  I AM RELATED TO MY KAMMA.  WHATEVER KAMMA I CREATE, WHETHER GOOD OR EVIL, THAT I SHALL INHERIT."
	} else if ( retval == 5 ) {
		str="I AM OF THE NATURE TO DECAY.  I HAVE NOT GONE BEYOND DECAY."
	} else {
		str="error"
	}

  document.write(str)
</SCRIPT>
</HEAD>
<BODY>
</BODY>
</HTML> 
