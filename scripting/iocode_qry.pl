#!/usr/bin/perl
##############################################################################
#     Name: iocode_qry.pl
#
#  Summary: Web-based query tool to search for Ind and Occ literals. 
#
#           http://158.111.250.128/bqh0/cgi-bin/iocode_qry.pl
#           
#           Assumes database 'DBASE' has been populated by 
#           ~/projects/iocode/load_mysql_db.indxls.pl
#           ~/projects/iocode/load_mysql_db.occxls.pl
#
#          TODO use cookies to maintain last query in the inputbox
#
#  Created: Fri 06 Sep 2002 15:14:31 (Bob Heckel)
# Modified: Mon 11 Nov 2002 09:16:52 (Bob Heckel)
# Modified: Fri 13 Dec 2002 09:46:23 (Bob Heckel -- cosmetic) 
# Modified: Wed 29 Jan 2003 12:48:28 (Bob Heckel -- search each word in user's
#                                                   search string with ORs) 
##############################################################################
use strict;
use CGI::Carp qw(fatalsToBrowser);
use DBI;
use constant DBASE   => 'indocc';
use constant ITBLNAME => 'indxls';
use constant OTBLNAME => 'occxls';

$|++;

my $DEBUG = 0;

# ------------------ Begin HTTP/1.0 Standard Header -------------------------
print "Content-type: text/html\n\n";
if ( $DEBUG ) {
  print "<BR><BR><FONT COLOR=RED>This program is temporarily unavailable.  ";
  print "Please check back later today.  Thanks.</FONT><BR><BR>";
}
print <<'EOT';
<HTML>
<HEAD>
  <TITLE>I&O Coding of a Decedent's Employment (IOCODE) -- Query</TITLE>
  <SCRIPT>
    // User may enter data in only one of the two inputboxes.
    function FillOnlyOne(f, g) {
      if ( f.ilitbox.value && g.olitbox.value ) {
        alert("Please enter a value in only one of these textboxes.  Only able to search for I and O independently at this time.");
      }
    }
  </SCRIPT>
</HEAD>
<BODY BGCOLOR="#FFF8DC">
  <CENTER><U><H3>National Center for Health Statistics, RTP, NC</U></H3></CENTER>
  <BR><H4>I&O Coding of Decedent's Employment (IOCODE) Application -- 
  Manual Query Module</H4>
  <H4>Please complete only <FONT COLOR=green>one</FONT> of these two textboxes
  at a time:</<H4>
EOT

my $buf = undef;
if ( $ENV{'QUERY_STRING'} eq "" && $ENV{'CONTENT_LENGTH'} ) {
  print "Getting FORM (i.e. POST method) input...<P>" if $DEBUG;
  read(STDIN, $buf, $ENV{'CONTENT_LENGTH'}); 
} elsif ( $ENV{'QUERY_STRING'} && !$ENV{'CONTENT_LENGTH'}) { 
  print "Getting URL (i.e. GET method) input...<P>" if $DEBUG;
  $buf = $ENV{'QUERY_STRING'}; 
}

PrintForm();

# Number of name/value pairs passed in.
my $argc_pairs = 0;	
my @pairs = split '&', $buf;

my %FORM = ();
foreach my $pair ( @pairs ) {
  my ($name, $value) = split '=', $pair;
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  $argc_pairs++;
}
# ------------------------ End Standard Header ----------------------------


if ( $DEBUG ) {
  while ( (my $key, my $val) = each(%FORM) ) { print "$key=$val\n" };
  print "<BR><BR>";
}

QueryDB($FORM{ilitbox}, 'I') if $FORM{ilitbox};
QueryDB($FORM{olitbox}, 'O') if $FORM{olitbox};

print <<"EOT";
  <BR><BR><BR><BR><BR><FONT SIZE=-2>
  <BR>Searches are case-insensitive.  Regular expressions are
      available if you use single or double quotes.
  <BR>Use single or double quotes for exact matches, otherwise the
      search will be on each word entered (which may or may not be
      what you want).
  <BR>Ind or Occ queries must be run one at a time.
  <BR>
  <BR>Data source is Instruction Manual Part 19B 2000.
  <BR>Please contact Bob Heckel at 
  <A HREF=mailto:bheckel\@cdc.gov?Subject=ioquery.pl>bheckel\@cdc.gov</A> 
  if you have any questions or suggestions.
  <BR>Last updated: 2003-02-03</FONT>
</BODY></HTML>
EOT

exit 0;


sub QueryDB {
  my $str  = shift;  # search string
  my $type = shift;  # I or O
  my $sql  = undef;  # full SQL statement without trailing semicolon
  print "DEBUG: \$str is $str and \$type is $type<BR><BR>" if $DEBUG;

  # TODO untaint to avoid cracking
  $str =~ /(.*)/;
  $str = $1;

  my $ss = PrepareSString($str); 
  print "DEBUG: \$ss is $ss" if $DEBUG;
  
  my $dbh = DBI->connect("DBI:mysql:database=" . DBASE . ";host=localhost",
                         "bqh0",
                         "",     # MySQL pw
                         {'RaiseError' => 1}
                        );
  print "<TABLE BORDER=0>";
  my $color = undef;
  # Prints to Apache's error_log
  my $n = 0;
  if ( $type eq 'I' ) {
    $sql = BuildQry($ss, $type);
    my $sth = $dbh->prepare($sql);
    $sth->trace(2) if $DEBUG;
    $sth->execute();
    # Prints to Apache's error_log
    while ( my $ref = $sth->fetchrow_hashref() ) {
      # Alternate colors every other row for readability.
      (($n++ % 2) == 0) ? ($color = '#C1FFC1') : ($color = '#CAE1FF');
      print "<TR>" .
            "<TD BGCOLOR=$color>$ref->{literal}" .
            "<TD BGCOLOR=$color><B>$ref->{indnum}</B>" .
            "<TD BGCOLOR=$color>$ref->{naics}" .
            "</TR>";
    }
  }
  if ( $type eq 'O' ) {
    $sql = BuildQry($ss, $type);
    my $sth = $dbh->prepare($sql);
    $sth->trace(2) if $DEBUG;
    $sth->execute();
    while ( my $ref = $sth->fetchrow_hashref() ) {
      (($n++ % 2) == 0) ? ($color = '#F0E68C') : ($color = '#FFEFD5');
      print "<TR>" .
            "<TD BGCOLOR=$color>$ref->{literal}" .
            "<TD BGCOLOR=$color>$ref->{restriction}" .
            "<TD BGCOLOR=$color><B>$ref->{occnum}</B>" .
            "<TD BGCOLOR=$color>$ref->{soic}" .
            "</TR>";
    }
  }
  print "</TABLE>";

  return 0;
}


sub PrintForm {
  print <<"EOT";
<FORM ACTION="$ENV{SCRIPTFILENAME}" METHOD="GET" NAME="ilitfrm">
  <CAPTION>Enter Full or Partial Industry Literal (e.g. zoo or 'city zoo')</CAPTION><BR>
  <INPUT NAME="ilitbox" TYPE="text" VALUE="" SIZE='60' 
   onChange="FillOnlyOne(document.ilitfrm, document.olitfrm); return false">
  <INPUT NAME="myigetsubmit" TYPE="submit">
</FORM>
EOT

  print <<"EOT";
<FORM ACTION="$ENV{SCRIPTFILENAME}" METHOD="GET" NAME="olitfrm">
  <CAPTION>Enter Full or Partial Occupation Literal (e.g. cow
  or "cow buyer" or cow buyer)</CAPTION><BR>
  <INPUT NAME="olitbox" TYPE="text" VALUE="" SIZE='60'
   onChange="FillOnlyOne(document.ilitfrm, document.olitfrm); return false">
  <INPUT NAME="myogetsubmit" TYPE="submit">
</FORM>
EOT
}


# Parse a (potentially multiword) string into an SQL pattern to use in a LIKE
# statment.
sub PrepareSString {
  my $s = shift;
  my $parsed = undef;

  $s = uc $s;

  # Search string surrounded by quotes should not be parsed.
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
  my $search_typ = shift;
  my $sql = undef;
  my $type = undef;

  $search_typ eq 'I' ? ($type = 'Industry') : ($type = 'Occupation');
  
  print "<H4> $type Query Results for <I> $search_str :</I></H4>";
  if ( $search_typ eq 'I' ) {
    print "<TR><TD><B>Literal</B><TD><B>Code</B><TD><B>NAICS Code</B></TR>";
    ###$sql = qq(SELECT * FROM indxls WHERE literal LIKE $search_str);
    $sql = qq(SELECT * FROM indxls WHERE literal REGEXP ".*$search_str.*");
  } else {
    print "<TR><TD><B>Literal</B><TD><B>Center Restriction</B><TD><B>Code</B><TD><B>SOC Code</B></TR>";
    ###$sql = qq(SELECT * FROM occxls WHERE literal LIKE $search_str);
    $sql = qq(SELECT * FROM occxls WHERE literal REGEXP ".*$search_str.*");
  }

  print "DEBUG: \$sql is $sql\n" if $DEBUG;

  return $sql;
}
