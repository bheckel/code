#!/usr/bin/perl -w

# age-calculator.cgi - give age in months after accepting date e.g. 2000-05

use CGI qw(:standard);

$birthdate = param("birthdate");

($year, $month) = ($birthdate =~ /^(\d\d\d\d)-(\d\d)\s*$/)
                    or die "The birthdate was not in the YYYY-MM format.\n";

($this_year, $this_month) = (localtime)[5,4];
# localtime() returns year minus 1900, e.g. 100 for year 2000.
$this_year  += 1900;	
$year_diff  = $this_year - $year;
$month_diff = $this_month - $month;
$difference = $year_diff * 12 + $month_diff;
print header(), "<HTML><HEAD><TITLE>Age in Months</TITLE></HEAD>",
                "<BODY><H3>Age in Months</H3>",
                "You are $difference months old.",
                "</BODY></HTML>\n";


__END__

To see it work:
Open this stub in browser:
  C:\cygwin\home\bheckel\html\cgi-bin\age-calc.html
Then click Submit Query to run the code above 
  C:\cygwin\home\bheckel\html\cgi-bin\age-calc.cgi
  (http://localhost/cgi-bin/age-calc.cgi)

Create this file and name it age-calc.html:

<HTML>
<HEAD>
  <TITLE>This stub runs code http://localhost/cgi-bin/age-calc.cgi</TITLE>
</HEAD>

<BODY>
  <FORM ACTION="http://localhost/cgi-bin/age-calc.cgi" METHOD="POST">
    <INPUT NAME="birthdate" TYPE="text" VALUE="1998-05">
    <INPUT NAME="thesubmit" TYPE="submit">
  </FORM>
</BODY>
</HTML>


Or use telnet localhost 80  and type this:
POST /cgi-bin/age-calc.cgi HTTP/1.0
Content-length: 17

birthdate=1998-05

Apache will then spit out this:
HTTP/1.1 200 OK
Date: Mon, 14 May 2001 17:36:09 GMT
Server: Apache/1.3.6 (Cygwin)
Connection: close
Content-Type: text/html; charset=ISO-8859-1
<HTML><HEAD><TITLE>Age in Months</TITLE></HEAD><BODY><H3>Age in Months</H3>You are 35 months old.</BODY></HTML>


Or get same output with
GET /cgi-bin/age-calc.cgi?birthdate=1998-05 HTTP/1.0


