#!/usr/bin/perl

##############################################################################
#    Name: optical.cgi
# Summary: Accept Org and Dept info from user, produce link to relevant 
#          spreadsheet.
# Created: Thu, 10 Feb 2000 15:36:17 (Bob Heckel)
##############################################################################

use CGI;
use CGI::Carp qw(fatalsToBrowser);

$query = new CGI;

print $query->header;
print $query->start_html('Optical');

# Recycle current window.
print "<CENTER><H1>Monthly Variance and Trend Reports By Department</H1>\n";
print '<LINK REL=stylesheet TYPE="text/css" HREF="http://triweb/CustSvcFin/finance.css">';

print $query->startform(-target=>'indexmainrightpane');
  print "<P>Select TOTRHBB Organization:<P>",
  $query->scrolling_list(-name=>'orgs',
                         -values=>['All Hedrick', 'PRIDGEN','BBCSADM',
                                   'CGJONES/ECOMM_UTIL', 'HEIKKLA/DIS_SPA', 
                                   'HEIKKLA/ENS', 'HEIKKLA/CNS', 'LORENZ', 
                                   'STRATGY/HUNTER', 'STRATGY/KAUFMAN']);
  print "<P>";
  print $query->submit(-name=>'action1',
                       -value=>'Display Departments');
print $query->endform;

$orgselected = $query->param('orgs');

# Capture button clicked from Org section.
$action = $query->param('action1');

# Start new subform.
print $query->startform;
  # If they're clicked the first button.
  if ( $action =~ /Display Departments/ ) {
    print "<HR>";
    if ( $orgselected =~ /All Hedrick/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['TOTRHBB']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /PRIDGEN/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['5490269', '5490820', '5490821',
                                          '5490823', '5492470', '549T110',
                                          '549T111', '5402446', 'PRIDGEN']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /BBCSADM/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['5492473', '549T049', '5490969',
                                          '5492477', '5490976', '5986702',
                                          '549T036', 'BBCSADM']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /CGJONES\/ECOMM_UTIL/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['5490953', '145C353', '145X061',
                                          '5490951', 'CGJONES_ECOMM_UTIL']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /HEIKKLA\/DIS_SPA/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['145X911', '5490964',
                                          'HEIKKLA_DIS_SPA']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /HEIKKLA\/ENS/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['145C415', '5490814', '145X071',
                                          'HEIKKLA_ENS']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /HEIKKLA\/CNS/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['5490268', '5492420',
                                          'HEIKKLA_CNS']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /LORENZ/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['145X062', '145X070', '5490961',
                                          '5490965', 'LORENZ']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /STRATGY\/HUNTER/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['710476D', '7296039',
                                          'STRATGY_HUNTER']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } elsif ( $orgselected =~ /STRATGY\/KAUFMAN/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['145X065', '5490973', '145X072',
                                          'STRATGY_KAUFMAN']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Download');
    } else {
    print "Error--see Bob Heckel";
    }
  }
print $query->endform;

# Capture button clicked.
$action2 = $query->param('action2');

# Capture radio button selected.
$deptselected = $query->param('deptgroup');

# DEBUG
###print $query->dump;

if ( $action2 =~ /Display Available Download/ ) {
  print "<HR>";
  $fullspdsht = $deptselected . '.xls';
  # Has spreadsheet been uploaded?
  if ( -e $fullspdsht ) {
    print qq{<BR><FONT SIZE="+2"><A HREF="http://triweb/CustSvcFin/usa/rtp/optical/download/$fullspdsht">Spreadsheet available: $deptselected.xls</A></FONT><BR><BR>};
  } else {
    print "<P>Sorry, file either does not exist or has not been uploaded yet.<P>Please use Contacts button on the left for assistance.<P>";
  }
}
  
print '</CENTER>';
print <<HTML;
<HR>
  <P CLASS="updated">If you have content-related comments or questions, please click the Contacts button on the lefthand menu. 
  <BR>If you receive errors while using this page, please contact Bob Heckel at esn 352-8901.
  <CENTER><BR><A HREF="http://triweb/CustSvcFin/usa/rtp" TARGET="_top">Home</a></CENTER>
<HR>
HTML

print $query->end_html;

