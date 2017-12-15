#!/usr/bin/perl -w
##############################################################################
# Program Name: database.jc.cgi
#
#      Summary: Online database.  From WebReview website.
#               Modified for SEARCH only.
#
#      Created: 1999 (Brent Michalski)
#     Modified: Tue, 16 Nov 1999 10:14:08 (Bob Heckel--removed add, modify,
#                                          delete.)
##############################################################################

use CGI;
use CGI::Carp qw(fatalsToBrowser);
 
$q = new CGI;
print $q->header;
 
$config=$ENV{QUERY_STRING};
unless(require $config) {
  print "No Configuration File Specified!\n";
  exit;
}
 
# @fields is from config.jc.txt fields.
$field_count = @fields;
# Only want to sort on non $ fields like COEO, Prodtype, not Ctr$, Toti, etc.
###$smallfield = $field_count - 10;
# Table width used below.
$colspan = $field_count + 1;
# Parameter passed via radio button in "Sort Ascending On:"
$sort         = $q->param("sort_on");
$search_for   = $q->param("search_for");
$search_field = $q->param("search_field");
$action       = $q->param("action");
###@keys         = $q->param("key");
$search_field = "all" if($search_field eq "");
$search_for   = 'blank'   if ($search_for eq "");
 
if($action =~ /search/i){
  # Search database and display the results
  &search_database($search_for);
  &sort_db;
  $count = @results;
  if($count > 0) {
    if($count > 150) {
      # Warn - limit query or dl spdsht.
      &print_toobig($count);
      exit;
    }
    $button_text = "Back to Database";
    $caption = "Search Results";
    &multiple_match;
  } else {
    &no_match;
  }
}
else { &print_default; }
exit;
 
sub multiple_match {
  print $q->start_html(-TITLE=>'Match Results',-BGCOLOR=>'white');
  print <<HERE;
   <FONT SIZE=6 FACE=ARIAL><CENTER>$caption</CENTER></FONT>
   <FONT FACE=ARIAL><CENTER>Matches found: $count</CENTER></FONT>
   <FORM METHOD=POST ACTION="$form_action?$config">
   <HR WIDTH=75%>
   <P>
   <CENTER><TABLE BORDER=1 CELLSPACING=0><TR BGCOLOR="#e0e0e0">
HERE
 
###  if($@ =~ /(modify|delete)/){
###    print "<TD ALIGN=CENTER>";
###    print "<FONT SIZE=2 FACE=ARIAL><B>Select</B></FONT></TD>";
###  }
 
  foreach $field (@fields){
    print "<TD ALIGN=CENTER>";
    print "<FONT SIZE=2 FACE=ARIAL><B>\u$field</B></FONT></TD>";
  }
  print "</TR>";
  foreach $record (@results){
    ($key,@field_vals) = split(/\t/, $record);
    print "<TR BGCOLOR=\"#efefef\">";
    ###if($_[1] =~ /(modify|delete)/){
    ###if($@ =~ /(modify|delete)/){
      ### print "<TD ALIGN=CENTER><FONT SIZE=2 FACE=ARIAL>";
       ###print "<INPUT TYPE=$_[0] NAME=key VALUE=$key>";
       ###print "</FONT></TD>";
    ###} # End of if.
      for($x=0;$x<$field_count;$x++){
      $item = &check_empty($field_vals[$x]);
      print "<TD><FONT SIZE=2 FACE=ARIAL>$item</FONT></TD>";
    }
     print "</TR>";
  }
  print<<HERE;
  <TR BGCOLOR="#e0e0e0">
  <TD COLSPAN=$colspan ALIGN=CENTER>
  <INPUT TYPE=SUBMIT NAME=action VALUE="$button_text"></TD>
  </TR>
  </TABLE></FORM></BODY></HTML>
HERE
} # End of multiple_match subroutine.
 
sub no_match{
  print $q->start_html(-TITLE=>'No Match',-BGCOLOR=>'white');
  print "<H2><CENTER>There was no match for <I>$search_for</I>, ";
  print "please go <A HREF=# onClick='history.go(-1);'>back</A> and try again.</CENTER></H2>";
  print $q->end_html;
  exit;
} # End of no_match subroutine.
 
sub search_database{
  my $search_for = $_[0];
  open(DB, $database) or die "Error opening file: $!\n";
    while(<DB>){
      if($search_field =~ /all/i){
        if(/$search_for/oi){push @results, $_};
      } else {
        ($key,@field_vals) = split(/\t/, $_);
        if($field_vals[$search_field] =~ /$search_for/oi){push @results, $_};
      }
    }
  close (DB);
} # End of search_database subroutine.
 
sub print_default {
 print<<HERE;
   <HTML><HEAD>
   <TITLE>Carrier Global Service Finance Job Costing Database</TITLE>
   </HEAD><BODY BGCOLOR="#FFFFFF">
   <FORM METHOD="post"  ACTION="$form_action?$config">
   <CENTER><FONT SIZE=5 FACE="ARIAL" color="#003399"><B>
   NOT YET ACTIVE 
   <br>Carrier Global Service Finance Job Costing Actuals
   </B></FONT>
   <CENTER><P><H3>Database provides Actual Costs by job for the ILEC region</H3>
   <H4>Material (from ECMS), RFT Labor (from ISS), Contractor Labor (from ISS),
       Travel & Living (from EVS) for jobs that have
       <A HREF="/CustSvcFin/usa/rtp/jobcost/jc_criteria.html">"Finalled"</A>
   </H4>
   <H4>Entire database (about 2-3MB) is available as an 
   <A HREF="/CustSvcFin/usa/rtp/jobcost/jc_final.xls">Excel spreadsheet</A></H4>
   <TABLE BORDER=1 WIDTH="75%" BGCOLOR="#e0e0e0" CELLSPACING="0">
   <TR>
     <TD COLSPAN=2>
       <CENTER><FONT FACE="ARIAL" SIZE=2>QUERY DATABASE</FONT></CENTER>
     </TD>
    </TR>
   <TR>
     <TD><FONT FACE="ARIAL" SIZE=2><B>Search (case insensitive) For:</B></FONT></TD>
     <TD><INPUT TYPE="text" NAME="search_for" SIZE="40"></TD>
   </TR>
   <TR>
     <TD><FONT FACE="ARIAL" SIZE=2><B>Search On:</B></FONT></TD>
     <TD><FONT FACE="ARIAL" SIZE=2><INPUT TYPE="radio" NAME="search_field" VALUE="all" CHECKED>All
HERE
  $x=0;
  foreach $field (@fields){
    # 7 fields are "searchable", the other 10 are $ oriented.
    if ($x < 7) {
    print "<INPUT TYPE=radio NAME=search_field VALUE=$x>\u$field";
    }
    $x++;
  }
  # Add a sort radio row to user interface.
  print <<HERE;
    </FONT></TD></TR>
    <TR>
      <TD><FONT FACE="ARIAL" SIZE=2><B>Sort Ascending On:</B></FONT></TD>
      <TD><FONT FACE="ARIAL" SIZE=2>
HERE
  $x=0;
  # Force 1st item in radio button group to be selected.
  $CH = "CHECKED";
  # Create new radio buttons, one at a time.
  foreach $field (@fields){
    print "<INPUT TYPE=radio NAME=sort_on VALUE=$x $CH>\u$field";
    $x++;
    $CH="";
  }
  print <<HERE;
    </FONT></TD>
    </TR><TR>
    <TD COLSPAN=2>
     <CENTER>
      <INPUT TYPE="submit" NAME="action" VALUE="Search">
     </CENTER>
    </TD>
  </TR>
 </TABLE></FORM>
  <table bgcolor="#e0e0e0" border="1">
    <caption><b>Fields Available Key:</b></caption>
    <tr>
      <td>COEO</td>
      <td>Central Office Equipment Order</td>
    </tr>
    <tr>
      <td>D-Date</td>
      <td>Date shipped from Nortel</td>
    </tr>
    <tr>
      <td>Region</td>
      <td>Region Code</td>
    </tr>
    <tr>
      <td>Ops_Mgr</td>
      <td>Operations Manager (OM)</td>
    </tr>
    <tr>
      <td>FTS_Dt</td> 
      <td>Final Timesheet Date (K plus 4)</td>
    </tr>
    <tr>
      <td>Status</td> 
      <td>Current status</td>
    </tr>
    <tr>
      <td>Prodtype</td> 
      <td>Product Type H, T, A, Y or B</td>
    </tr>
    <tr>
      <td>Matl\$</td> 
      <td>Material Cost</td>
    </tr>
    <tr>
      <td>RFTID/L\$</td> 
      <td>Regular Fulltime Direct Labor for Installation</td>
    </tr>
    <tr>
      <td>CtrD/L\$</td> 
      <td>Contractor Direct Labor for Installation</td>
    </tr>
    <tr>
      <td>TravelI\$</td> 
      <td>Perdiem + Travel + Mileexp for Installation</td>
    </tr>
    <tr>
      <td>TotI\$</td> 
      <td>Total Installation Cost of job</td>
    </tr>
    <tr>
      <td>RFTED/L\$</td> 
      <td>Regular Fulltime Direct Labor for Engineering</td>
    </tr>
    <tr>
      <td>CtrD/L\$</td> 
      <td>Contractor Direct Labor for Engineering</td>
    </tr>
    <tr>
      <td>TravelE\$</td> 
      <td>Perdiem + Travel + Mileexp for Engineering</td>
    </tr>
    <tr>
      <td>TotE\$</td> 
      <td>Total Engineering Cost of job</td>
    </tr>
    <tr>
      <td>TotJob_MEI\$</td>
      <td>Total Cost (Material + Engineering + Installation) of job</td>
    </tr>
  </table>
   <br>
   <br>
   <hr>
     <p><font color="green" size="small">If you have content-related comments or questions,
     please contact <a href="mailto:bheckel\@nortelnetworks.com">Bob Heckel</a> at esn 352-8901.</font></p>
     <center><a href="http://triweb/CustSvcFin/usa/rtp" target="_top">Home</a></center>
   <hr>
 </BODY></HTML>
HERE
} # End of print_default subroutine.

sub print_toobig {
  my $recs = $_[0];
  print $q->start_html(-TITLE=>'Sorry',-BGCOLOR=>'white');
  print<<HERE;
    <HTML><BODY><H1>Query returns $recs records.  Please click <A HREF=# onClick='history.go(-1) ;'>back</A> and revise your query or download spreadsheet.</H1></BODY></HTML>
HERE
}
             
sub check_empty {
  $r_val = $_[0];
  if($r_val =~ /^\s*$/){$r_val="&nbsp;"}
  return($r_val);
}
 
sub sort_db {
  #  @results was created in search_database() and contains the matching
  #  records.
  foreach $curr (@results){
    # Store key ($key) and the fields of data (@rest).
    ($key, @rest) = split(/\t/, $curr);
    # Number of elements in @fields from the config.jc.txt file.
    $max = @fields;
    $code = '$record{$key} = { key => "$key", ';
    # $code below contains when finished looping:
    #
    # $record{$key} = {
    # key        => "$key",
    # $fields[0] => "$rest[0]",  
    # $fields[1] => "$rest[1]",  
    # $fields[2] => "$rest[2]",  
    # ...etc...
    for($x=0; $x<$max; $x++){
      $code .= "\$fields[$x] => \"\$rest[$x]\",\n";
    }
    $code .= '};';
    eval $code;
  }
  $sort_on = "$fields[$sort]";
  # Empty it, otherwise get duplicates when push below.
  @results=();
  # Data is accessed via Record Pointer.
  # If sorting on the numerics (coeo, d-date, etc... position 0 thru 6)
  if ($sort > 6) {
    foreach $rp (sort { $a->{$sort_on} <=> $b->{$sort_on} } values %record) {
      $new_rec = $rp->{key};
      for($x=0; $x<$max; $x++) {
        $new_rec .= "\t$rp->{$fields[$x]}";
      }
      push @results, $new_rec;
    }
  } else {
    # If sorting on alphabeticals.
    foreach $rp (sort { $a->{$sort_on} cmp $b->{$sort_on} } values %record) {
      $new_rec = $rp->{key};
      for($x=0; $x<$max; $x++){
        $new_rec .= "\t$rp->{$fields[$x]}";
      }
      push @results, $new_rec;
    }
  }
} # End of sub sort_db

