#!/usr/bin/perl
##############################################################################
#     Name: fips_qry.pl  http://158.111.250.128/bheckel/cgi-bin/fips_qry.pl
#
#  Summary: Web-based query tool to search for FIPS information.
#           
#           Assumes database 'fips' has been populated by the 4
#           ~/projects/fips/load_mysql_db.*.fips.pl scripts.
#
#          TODO use cookies to maintain last query in the inputbox
#
#  Created: Mon 28 Apr 2003 13:49:57 (Bob Heckel)
# Modified: Fri 09 May 2003 14:39:14 (Bob Heckel)
# Modified: Mon 12 May 2003 10:25:25 (Bob Heckel -- added ORDER BY for the 
#                                     Place qry per Kryn)
# Modified: Tue 20 May 2003 08:06:50 (Bob Heckel -- maintain state across
#                                     queries per Kryn)
# Modified: Tue 24 Jun 2003 12:55:58 (Bob Heckel -- eliminate the need for
#                                     cookies, fix one-textbox-only bug)
# Modified: Wed 25 Jun 2003 16:16:23 (Bob Heckel -- don't maintain last
#                                     used except for the state dropdowns)
# Modified: Wed 11 Feb 2004 10:00:42 (Bob Heckel -- update data location)
# Modified: Tue 29 Jun 2004 12:44:11 (Bob Heckel -- adapt for Solaris box)
##############################################################################
use strict;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
# MySQL
use constant DBASE => 'fips';
$|++;

my $DEBUG = 0;


# Holds form values provided by user.
my %FORM = ();
###my $cookie_expire = CvtimeHTTP();
my $cookiename = undef;
my $cookieval = undef;
my $stcookie = undef;
my $cntycookie = undef;
my $bgcolor = undef; 

$DEBUG ? ($bgcolor='#BCBCBC') : ($bgcolor='#FFFFFF');

my $buf = undef;
if ( $ENV{'QUERY_STRING'} eq "" && $ENV{'CONTENT_LENGTH'} ) {
  read(STDIN, $buf, $ENV{'CONTENT_LENGTH'}); 
} elsif ( $ENV{'QUERY_STRING'} && !$ENV{'CONTENT_LENGTH'}) { 
  $buf = $ENV{'QUERY_STRING'}; 
}

# Number of name/value pairs passed in.
my $argc_pairs = 0;	
my @pairs = split '&', $buf;

foreach my $pair ( @pairs ) {
  my ($name, $value) = split '=', $pair;
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  $argc_pairs++;
}


print <<"EOT";
Content-type: text/html

<HTML>
<HEAD>
  <TITLE>FIPS $cntycookie -- Query</TITLE>
  <SCRIPT LANGUAGE="JavaScript">
    // User may enter data in only one of the four inputboxes at a time.
    function FillOnlyOne() {
      var bx = 0;
      if (document.countryfrm.countrybox.value) {
        bx++;
      } 
      if (document.statefrm.statebox.value) {
        bx++;
      }
      if (document.countyfrm.countybox.value) {
        bx++;
      }
      if (document.placefrm.placebox.value) {
        bx++;
      }
      
      if ( bx > 1 ) {
        alert("Please enter a value in only one of these textboxes.");
        // Do not submit query.
        return false;
      } else {
        return true;
      }
    }
  </SCRIPT>
</HEAD>
<BODY BGCOLOR="$bgcolor">
  <CENTER><U><H3><FONT COLOR="#000080">National Center for Health Statistics, RTP, NC</H3>
  <H3>FIPS -- Query (please complete only <I>one</I> of these queries
  at a time)</H3></FONT></U></CENTER><BR>

EOT

if ( $DEBUG ) {
  print '<BR><BR>DEBUG: all form values--<BR>';
  while ( (my $key, my $val) = each %FORM ) { print "$key=$val\n" };
  print "<BR><BR>";
}


PrintForm();

# If an inputbox has a string, search db.
for ( 'country', 'state', 'county', 'place' ) {
  QueryDB($FORM{"${_}box"}, "$_") if $FORM{"${_}box"};
}

# Time stamp the last modified date.
my $mtime = (stat($0))[9];
my $t = localtime $mtime;
# Footer.
print <<"EOT";
  <BR><BR><BR><BR><BR><FONT SIZE=-2>
  <!--   <BR>Regular Expressions are available if you use single or double quotes. -->
  <BR><B>Searches are case-insensitive.</B>
  For multi-word search strings, use single or double quotes to request exact
  matches, otherwise the search will match on <i>each</i> word entered.
  <BR>
  Data sources: 
  <A HREF='http://158.111.250.37/~bheckel/cgi-bin/fips/countries.txt'>countries.txt</A>
  <A HREF='http://158.111.250.37/~bheckel/cgi-bin/fips/states.txt'>states.txt</A>
  <A HREF='http://158.111.250.37/~bheckel/cgi-bin/fips/FIPS_all_counties.txt'>FIPS_all_counties.txt</A>
  <A HREF='http://158.111.250.37/~bheckel/cgi-bin/fips/Fips_all.txt'>Fips_all.txt</A>
  <BR>Please contact Bob Heckel at 
  <A HREF=mailto:bheckel\@cdc.gov?Subject=fips_qry.pl>bheckel\@cdc.gov</A> 
  if you have any questions or suggestions.
  <BR>Last updated: $t</FONT>
</BODY></HTML>
EOT

exit 0;


##############################################################################

# Query database and generate HTML.
sub QueryDB {
  my $str  = shift;  # search string
  my $type = shift;  # country or state or county or place

  my $sql  = undef;  # full SQL statement without trailing semicolon
  print "DEBUG: \$str is $str and \$type is $type<BR><BR>" if $DEBUG;

  # TODO untaint to avoid cracking
  $str =~ /(.*)/;
  $str = $1;
  # Convert user's idea of 'ALL' to this pgm's idea of 'ALL'.
  $str =~ s/^\*$/\.\*/;

  my $ss = PrepSearchStr($str); 
  
  my $dbh = DBI->connect("DBI:mysql:database=" . DBASE . ";host=localhost",
                         "bheckel",
                         "",     # MySQL pw
                         {'RaiseError' => 1}
                        );
  print '<TABLE BORDER=0>';
  my $color = undef;
  my $n = 0;
  # TODO loop over country, state, etc.  The DBI references might be trouble.
  if ( $type eq 'country' ) {
    $sql = BuildQry($ss, $type);
    my $sth = $dbh->prepare($sql);
    # Prints to Apache's error_log
    ###$sth->trace(2) if $DEBUG;
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
      # Alternate colors every other row for readability.
      (($n++ % 2) == 0) ? ($color = '#C1FFC1') : ($color = '#CAE1FF');
      print "<TR>" .
            "<TD BGCOLOR=$color>$ref->{countrycode}" .
            "<TD BGCOLOR=$color>$ref->{countryname}" .
            "<TD BGCOLOR=$color>$ref->{flag}" .
            "</TR>";
    }
  }
  if ( $type eq 'state' ) {
    $sql = BuildQry($ss, $type);
    my $sth = $dbh->prepare($sql);
    # Prints to Apache's error_log
    ###$sth->trace(2) if $DEBUG;
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
      # Alternate colors every other row for readability.
      (($n++ % 2) == 0) ? ($color = '#C1FFC1') : ($color = '#CAE1FF');
      print "<TR>" .
            "<TD BGCOLOR=$color>$ref->{statecode}" .
            "<TD BGCOLOR=$color>$ref->{statename}" .
            "</TR>";
    }
  }
  elsif ( $type eq 'county' ) {
    $sql = BuildQry($ss, $type);
    my $sth = $dbh->prepare($sql);
    # Prints to Apache's error_log
    ###$sth->trace(2) if $DEBUG;
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
      # Alternate colors every other row for readability.
      (($n++ % 2) == 0) ? ($color = '#C1FFC1') : ($color = '#CAE1FF');
      print "<TR>" .
            "<TD BGCOLOR=$color>$ref->{statecode}" .
            "<TD BGCOLOR=$color>$ref->{countyname}" .
            "<TD BGCOLOR=$color>$ref->{countynum}" .
            "</TR>";
    }
  }
  elsif ( $type eq 'place' ) {
    $sql = BuildQry($ss, $type);
    my $sth = $dbh->prepare($sql);
    # Prints to Apache's error_log
    ###$sth->trace(2) if $DEBUG;
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
      # Alternate colors every other row for readability.
      (($n++ % 2) == 0) ? ($color = '#C1FFC1') : ($color = '#CAE1FF');
      print "<TR>" .
            "<TD BGCOLOR=$color>$ref->{statecode}" .
            "<TD BGCOLOR=$color>$ref->{placename}" .
            "<TD BGCOLOR=$color>$ref->{placecode}" .
            "<TD BGCOLOR=$color>$ref->{cityname}" .
            "<TD BGCOLOR=$color>$ref->{citycode}" .
            "<TD BGCOLOR=$color>$ref->{class}" .
            "<TD BGCOLOR=$color>$ref->{popflag}" .
            "</TR>";
    }
  }
  print '</TABLE>';

  return 0;
}


sub PrintForm {
  my $selwidget = undef;
  my $padding = undef;
  my $size = 81;
  # Example data.
  my $hr = {
    country => [ 'Country', 'United States' ],
    state   => [ 'State', 'North Carolina' ],
    county  => [ 'County', 'Wake' ],
    place   => [ 'Place', 'Raleigh' ],
  };

  my $tmpcook = undef;
  # Can't use 'for ( keys %$hr ) {...' b/c we want specific sort order.
  for ( 'country', 'state', 'county', 'place' ) {
    $size = 70;
    if ( $_ eq 'county' or $_ eq 'place' ) {
      $selwidget = BuildSelectWidget();
      $size = 46;
      # Move the "Enter Full or Par..." to the right if there's a state
      # dropdown widget.
      $padding = '&nbsp;' x 40;
    }
    my $foo = $_ . 'box';
    $tmpcook = $FORM{$foo};
    print <<"EOT";
<FORM ACTION="$ENV{SCRIPTFILENAME}" METHOD="GET" NAME="${_}frm">
  <TABLE>
    <TR>
      <TD>$padding Enter Full or Partial FIPS $$hr{$_}->[0] (e.g. $$hr{$_}->[1])
    </TR>
    <TR>
      <TD>$selwidget<INPUT NAME="${_}box" TYPE="text" VALUE="" SIZE=$size>
      <INPUT TYPE="submit" onClick="return FillOnlyOne()" VALUE="Query $$hr{$_}->[0]">
    </TR>
  </TABLE>
</FORM>
EOT
  $selwidget = '';
  }
 
  return 0;
}


# Parse a (potentially multiword) string into an SQL pattern to use in a LIKE
# statment.
sub PrepSearchStr {
  my $s = shift;
  my $parsed = undef;

  $s = uc $s;

  # Search string surrounded by quotes should NOT be parsed.
  if ( $s =~ s/^['"](.*)['"]$/$1/g ) {
    $parsed = $s;
  } else {
    my @words = split /\s+/, $s;

    if ( @words > 1 ) {
      my $n = 0;
      foreach my $word ( @words ) {
        if ( $n == 0 ) {
          $parsed = $word;
        } else {
          $parsed .= "|$word";
        }
        ++$n;
      }
    } else {
      $parsed = $words[0];
    }
  }

  return $parsed;
}


sub BuildQry {
  my $search_str = shift;
  my $search_typ = shift;  # country or state or county or place

  my $sql = undef;
  my $type = undef;

  # TODO use the hashref concept
  if ( $search_typ eq 'country' ) { $type = 'Country'; }
  elsif ( $search_typ eq 'state' ) { $type = 'State'; }
  elsif ( $search_typ eq 'county' ) { $type = 'County'; }
  elsif ( $search_typ eq 'place' ) { $type = 'Place'; }
  
  print "<H4> $type Query Results for <I> $search_str :</I></H4>";
  if ( $search_typ eq 'country' ) {
    print "<TR ALIGN=center><TD><B>Country Code</B><TD><B>Country</B><TD><B>Flag</B></TR>";
    $sql = qq(SELECT * FROM country WHERE countryname REGEXP ".*$search_str.*");
  } 
  elsif ( $search_typ eq 'state' ) {
    print "<TR ALIGN=center><TD><B>State Code</B><TD><B>State</B><TD></TR>";
    $sql = qq(SELECT * FROM state WHERE statename REGEXP ".*$search_str.*");
  } 
  elsif ( $search_typ eq 'county' ) {
    print "<TR ALIGN=center><TD><B>State Code</B><TD><B>County</B><TD><B>County Number</B></TR>";
    $sql = qq(SELECT * FROM county WHERE statecode = "$FORM{state2digalpha}" AND countyname REGEXP ".*$search_str.*");
  } 
  elsif ( $search_typ eq 'place' ) {
    print '<TR ALIGN=center><TD><B>State Code</B><TD><B>Place</B><TD>' .
          '<B>Place Code</B><TD><B>County</B>' . 
          '<TD><B>County Code</B>' .
          '<TD><B>Class</B><TD><B>Population Flag</B></TR>'
          ;
    $sql = qq/SELECT * FROM place 
              WHERE statecode = "$FORM{state2digalpha}" 
                                  AND placename REGEXP ".*$search_str.*"
              ORDER BY placename, placecode, class
             /;
  } 
  else {
    print '<B>fips_qry.pl: Error</B>';
    exit 1;
  }

  print "DEBUG: \$sql is $sql\n" if $DEBUG;

  return $sql;
}


# Create a dynamic select dropdown for certain queries.
sub BuildSelectWidget {
  my $widget = undef;
  # Don't want Canadians.
  my $sql = qq/SELECT * FROM state WHERE statecode 
               NOT IN ('AB', 'BC', 'MB', 'NB', 'NF', 'NT', 'NS',
                       'NU', 'ON', 'PE', 'QC', 'SK', 'YT')/
            ;

  my $dbh2 = DBI->connect("DBI:mysql:database=" . DBASE . ";host=localhost",
                          "bheckel",
                          "",     # MySQL pw
                          {'RaiseError' => 1}
                         );
  my $sth2 = $dbh2->prepare($sql);
  # Prints to Apache's error_log
  $sth2->trace(2) if $DEBUG;
  $sth2->execute();

  my $select_default = undef;
  my $select_state = undef;
  
  $widget = '<SELECT NAME=state2digalpha>';
  $widget .= "<OPTION VALUE=''>--choose state--";
  while ( my $ref2 = $sth2->fetchrow_hashref() ) {
    if ( $ref2->{statecode} eq $FORM{state2digalpha} ) {
      $widget .= "<OPTION VALUE=$ref2->{statecode} SELECTED> $ref2->{statename}";
    } else {
      $widget .= "<OPTION VALUE=$ref2->{statecode}> $ref2->{statename}";
    }
  }
  $widget .= '</SELECT>';

  return $widget;
}


# Build RFC822 compliant date string for cookie.
sub CvtimeHTTP {
  my($t) = @_;

  my @weekdays = ('Sunday','Monday','Tuesday','Wednesday', 'Thursday','Friday',
                                                                  'Saturday');
  my @months = ('January','February','March','April','May','June', 'July',
                        'August','September','October','November','December');

  # Let cookie live for one glorious month if nothing passed to this sub.
  $t = $t || time+(86400*30);

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($t);

  printf("%s, %02d-%3s-%4d %02d:%02d:%02d GmT",
                                          $weekdays[$wday],
                                          $mday, $months[$mon], $year+1900,
                                          $hour,$min,$sec);
  return 0;
}
