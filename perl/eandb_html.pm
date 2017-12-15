package eandb_html;


$welcome =<< 'EOT';

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
  <TITLE>Identification Required</TITLE>
  <META NAME="Author" CONTENT="Bob Heckel-Static Page">
</HEAD>
<BODY>
  <TABLE>
    <TD VALIGN='bottom'><H2>Identification</H2></TD></TR>
  </TABLE>
<!--        <H1><FONT COLOR="red">THIS SITE IS DOWN FOR MAINTENANCE, PLEASE CHECK BACK LATER. THANKS.</FONT></H1> -->
  <HR SIZE=1>
  <H4>
  blah blah
  <BR>
  <BR>
  Please log in.
  </H4>
  <FORM ACTION="http://47.143.210.230/cgi-bin/bheckel/kids.pl" 
   METHOD="POST">
    <TABLE>
      <TR><TD>Email:</TD><TD><INPUT NAME="emailaddr" TYPE="text" VALUE=""></TD>
      </TR>
    </TABLE>
    <BR>
    <INPUT TYPE="submit" VALUE="Validate Identity">
  </FORM>
  <CENTER>
  <HR SIZE=1><SMALL>
  <I>For problems or to have your email address added to my database:
  <BR>
  <SCRIPT LANGUAGE="javascript">
    document.write('<a href="mailto:the-heck')
    document.write('els@att.wo')
    document.write('rldnet.net">Email me</a>')
  </SCRIPT></I>
  </SMALL>
  </CENTER>
</BODY>
</HTML>

EOT


$mainpage =<<'EOT';

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
  <TITLE> </TITLE>
  <META NAME="author" CONTENT="Robert S. Heckel Jr.">
</HEAD>
<BODY>
foo
<IMG SRC="http://47.143.210.230/~bheckel/cboard.gif" BORDER="0">giflink
<FORM ACTION="http://47.143.210.230/cgi-bin/bheckel/kids.pl" METHOD="POST" NAME="theform">
  <INPUT NAME="archivesubmit" TYPE="submit">
</FORM>
</BODY>
</HTML>

EOT


$archivepage =<<'EOT';

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
<HEAD>
  <TITLE> </TITLE>
  <META NAME="author" CONTENT="Robert S. Heckel Jr.">
</HEAD>
<BODY>
archive apge
</BODY>
</HTML>

EOT


$allowed_users =<< 'EOT';

sbb@one.pbz
sbo@onm.pbz

EOT


1;
