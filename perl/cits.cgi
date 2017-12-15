#!/usr/bin/perl
##############################################################################
#     Name: cits.cgi
#
#  Summary: Accept Org and Dept info from user, produce link to relevant 
#           spreadsheet.
#           TODO use separate file to encapsulate data from code.
#
#  Created: Fri, 11 Feb 2000 15:38:04 (Bob Heckel)
# Modified: Mon, 06 Mar 2000 10:28:15 (Bob Heckel)
##############################################################################

use CGI;
use CGI::Carp qw(fatalsToBrowser);

$query = new CGI;

# Initialize Org Structure.
@busop  = qw(5401405 5401407 5401470 5403431 5403432 540T108 540T109 mOps);
@carnet = qw(1151920 1151923 115S910 115S936 5401410 5401440 5401441 540T085 mPCN);
@cross  = qw(116D524 166C151 166D510 166D525 166D526 166D527 mCROSS);
@datnet = qw(1151926 5401460 mDATA);
@docum  = qw(115S947 5018418 5018447 5403319 5403450 5403459 5403807 5403822 mDOC);
@execab = qw(5401401 540T021 mEXE);
@hood   = qw(1451928 5491438 5491456 549T069 mHOOD);
@nnet   = qw(115C467 mNNET);
@randd  = qw(115C471 115C473 115C474 115C555 540T080 540T083 540T084 mR&D);
@succ   = qw(540T081 mSUCC);
@trans  = qw(1011330 1011331 1151910 115S948 192001C 211001B 313001U 3252026 342MTPR 3482131 3482399 351MTPC 351MTPR 5018488 5019769 5402423 5402433 6056345 mTRA);
@west   = qw(166D580 166D581 166D581 166D582 166D583 166D584 166D585 166D586 mWESTWOOD);
@wirel  = qw(1070323 107W715 5982333 5982334 5982335 5982336 5982337 5982338 5987417 mRITA);

print $query->header;
print $query->start_html(-title=>'Training and Documentation Services',
                         -style=>{-src=>'http://triweb/CustSvcFin/finance.css'});


print "<CENTER><H1>T &amp; DS Organization Details</H1>\n";
###print '<LINK REL=stylesheet TYPE="text/css" HREF="http://triweb/CustSvcFin/finance.css">';

# Program assumes it's called from within the CustSvcFin main frame.
# Recycle current window.
print $query->startform(-target=>'indexmainrightpane');
# DEBUG
###print $query->startform(-target=>'_top');
  print qq{<P><FONT SIZE="+1">Select Organization:</FONT><P>},
        $query->scrolling_list(-name=>'orgs',
                         -values=>['All T&DS', 'Business Operations',
                                   'Carrier Network Training',
                                   'Cross', 'Data Networks Training',
                                   'Documentation', 'Executive Cabinet',
                                   'Hood', 'NNet Training', 'R&D Training',
                                   'Succession Networks Training',
                                   'Translations', 'Westwood',
                                   'Wireless Training']);
  print "<P>";
  print $query->submit(-name=>'action1',
                       -value=>'Display Departments');
print $query->endform;

# Capture org selected from scrolling_list after user clicks "Display Depts".
$orgselected = $query->param('orgs');

# Capture button clicked from Org section -- it will always 
# be "Display Departments" after it's clicked.
$action = $query->param('action1');


# Start new subform.
print $query->startform(-target=>'indexmainrightpane');
  # If they're clicked the first button.
  if ( $action =~ /Display Departments/ ) {
    print "<HR>";
    if ( $orgselected =~ /All T\&DS/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>['Not Yet Available']);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');

    } elsif ( $orgselected =~ /Business Operations/ ) {
      # A flattened list is created from @busop.
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@busop]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@busop");

    } elsif ( $orgselected =~ /Carrier Network Training/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@carnet]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@carnet");

    } elsif ( $orgselected =~ /Cross/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@cross]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@cross");

    } elsif ( $orgselected =~ /Data Networks Training/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@datnet]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@datnet");

    } elsif ( $orgselected =~ /Documentation/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@docum]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@docum");

    } elsif ( $orgselected =~ /Executive Cabinet/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@execab]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@execab");

    } elsif ( $orgselected =~ /Hood/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@hood]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@hood");

    } elsif ( $orgselected =~ /NNet Training/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@nnet]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@nnet");

    } elsif ( $orgselected =~ /R\&D Training/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@randd]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@randd");

    } elsif ( $orgselected =~ /Succession Networks Training/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@succ]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@succ");

    } elsif ( $orgselected =~ /Translations/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@trans]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@trans");

    } elsif ( $orgselected =~ /Westwood/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@west]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@west");

    } elsif ( $orgselected =~ /Wireless Training/ ) {
      print $query->radio_group(-name=>'deptgroup',
                                -values=>[@wirel]);
      print "<P>",$query->submit(-name =>'action2',
                                 -value =>'Display Available Dept Info');
      print $query->hidden(-name=>'hid',
                           -default=>"@wirel");

    } else {
      print "Error--see Bob Heckel";
    }
  }
print $query->endform;

# Capture Display Available Dept Info button clicked.
$action2 = $query->param('action2');

# Capture radio button user selected.
$deptselected = $query->param('deptgroup');

# Pass the array that captures which FTP site to look for G/L textfiles.
# TODO use the radio_group values instead.
# Flattened list.
$hiddenval = $query->param('hid');

# If clicked "Display Available Dept Info" button, print the customized links.
# TODO how to make this less verbose.  Passing arrays fails (need references?) ??
if ( $action2 =~ /Display Available Dept Info/ ) {
  ###$hiddenval_ref = \@hiddenval;
  ###&determine_ftp($deptselected, @hiddenval);
  &determine_ftp($deptselected, $hiddenval);
  ###&determine_ftp($deptselected, \@hiddenval);
}
  
# DEBUG
###print $query->dump;

# Standard tail.
print <<HTML;
</CENTER><HR>
  <P CLASS="updated">If you have content-related comments or questions, please click the Contacts button on the lefthand menu. 
  <BR>If you receive errors while using this page, please contact Bob Heckel at esn 352-8901.
  <BR><B>Please note: certain Departments are not yet available online.</B>
  <CENTER><BR><A HREF="http://triweb/CustSvcFin/usa/rtp" TARGET="_top">Home</a></CENTER>
<HR>
HTML

print $query->end_html;


# Depending on dept radio button clicked, find FTP server where its G/L data
# can be found, print general GES, A/P and PriorMo archive, custom download
# option.
sub determine_ftp() {
  ###my ($deptin) = @_;
  my ($deptin, $orgsdeptsin) = @_;
  ###my ($deptin, $orgsdeptsin_ref) = @_;
  @orgsdeptsinsplit = split(/\W+/, $orgsdeptsin);

  # Where to find FTP G/L detail.  Dept suffixes only.
  ###@ftp_rtp  = qw/1405 1407 1470 3431 3432 1440 1410 1441 1460 3319 3459 3807 3822 1401 2434 2433/;
  @ftp_rtp  = qw(1401 1405 1407 1410 1440 1441 1460 1470 2433 2434 3319 3431 3432 3459 3807 3822);
  @ftp_nash = qw(8418 9769);
  # 115
  @ftp_cnd1 = qw(1920 1923 1926 C473 C555 S910 S947 S948);
  # 166
  @ftp_cnd2 = qw(D524 D525 D526 D527 D580 D581 D582 D583 D584 D585 D586);
  @ftp_cnd3 = qw(1928);
  @ftp_cnd4 = qw(1330 1331);
  @ftp_cnd5 = qw(0323 W715);

  print "<P><HR>";
  foreach $element ( @orgsdeptsinsplit ) {
    if ( $element == $deptin ) {
      # Extract the dept number 4 digit suffix to create the ftp address string.
      $fourdigit = substr($deptin, 3, 4);
      ###print "fourdigz $fourdigit";
      # There are several FTP sites holding G/L detail textfiles.  Select appropriate one.
      # If the arrays don't hold a dept, nothing will display (which is a feature, not a
      # bug).
      foreach $deptno_a ( @ftp_rtp ) {
        if ( $deptno_a =~ /$fourdigit/ ) {
          # E.g. ftp://47.158.0.16/READ_ONLY/FINANCE/RTPADV2/dept1405_mullen_trng
          print "<P><A HREF=ftp://47.158.0.16/READ_ONLY/FINANCE/RTPADV2/dept" . $fourdigit . "_mullen_trng>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          # You've found it, will repeat the print... without this.
          last;
        }
      }
      # Not available on the RTP FTP site, try Nash.
      foreach $deptno_b ( @ftp_nash ) {
        if ( $deptno_b =~ /$fourdigit/ ) {
          # E.g. ftp://47.158.0.16/READ_ONLY/FINANCE/NSHADV2/501_DEPT8418_RIGSBEE
          print "<P><A HREF=ftp://47.158.0.16/READ_ONLY/FINANCE/NSHADV2/501_DEPT" . $fourdigit . "_RIGSBEE>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          last;
        }
      }
      # Not available on either the RTP FTP Nash try Cnd.
      foreach $deptno_c ( @ftp_cnd1 ) {
        if ( $deptno_c =~ /$fourdigit/ ) {
          # E.g. ftp://advdiv:mtd773@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/115/115.S947.DEPT_GL
          print "<P><A HREF=ftp://advdiv:mtd773\@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/115/115." . $fourdigit . ".DEPT_GL>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          last;
        }
      }
      foreach $deptno_d ( @ftp_cnd2 ) {
        if ( $deptno_d =~ /$fourdigit/ ) {
          # E.g. ftp://advdiv:mtd773@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/115/115.S947.DEPT_GL
          print "<P><A HREF=ftp://advdiv:mtd773\@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/166/166." . $fourdigit . ".DEPT_GL>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          last;
        }
      }
      foreach $deptno_e ( @ftp_cnd3 ) {
        if ( $deptno_e =~ /$fourdigit/ ) {
          # E.g. ftp://advdiv:mtd773@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/115/115.S947.DEPT_GL
          print "<P><A HREF=ftp://advdiv:mtd773\@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/145/145." . $fourdigit . ".DEPT_GL>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          last;
        }
      }
      foreach $deptno_f ( @ftp_cnd4 ) {
        if ( $deptno_f =~ /$fourdigit/ ) {
          # E.g. ftp://advdiv:mtd773@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/115/115.S947.DEPT_GL
          print "<P><A HREF=ftp://advdiv:mtd773\@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/101/101." . $fourdigit . ".DEPT_GL>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          last;
        }
      }
      foreach $deptno_g ( @ftp_cnd5 ) {
        if ( $deptno_g =~ /$fourdigit/ ) {
          # E.g. ftp://advdiv:mtd773@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/115/115.S947.DEPT_GL
          print "<P><A HREF=ftp://advdiv:mtd773\@47.158.0.16/acc1/ADVANCEII/Dept_Exp/GL/107/107." . $fourdigit . ".DEPT_GL>General Leger Detail (via FTP, not part of this website) for Dept. $fourdigit</A>";
          last;
        }
      }
    }
  }

  # Print generic links regardless of selection.
  print qq{<P><A HREF="http://47.146.32.20/~norgxn01/invoice.html">GES Charges Home Page (not part of this website)</A>};
  print qq{<P><A HREF="http://47.140.224.116/apweb8/apwebcb.htm">Accounts Payable Home Page (not part of this website)</A>};
  print qq{<P><A HREF="http://triweb/CustSvcFin/usa/rtp/cits/priormos">Prior Months G/L Detail Archive (all Depts)</A>};

  # Provide downloadable spreadsheet.  Assumes your CWD is .../rtp/cits
  $fullspdsht = "/triweb/CustSvcFin/usa/rtp/cits/download/$deptselected" . '.xls';
  # Required to pass valid URL for the anchor tag.
  $clickfile = "http:/$fullspdsht";
  # Has spreadsheet been uploaded/exists?  Avoids 404 Errors.
  if ( -e $fullspdsht ) {
    print qq{<P><A HREF=$clickfile>Download Departmental Detail vs. Forecast for $deptselected</A></FONT><BR>};
  } else {
    print "<P><B>Sorry, spreadsheet either does not exist for this department or it has not been uploaded yet.<BR>Please use the Contacts button on the left if you have questions.  Thanks.</B><P>";
  }
}

