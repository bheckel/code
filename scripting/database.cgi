#!/usr/bin/perl -w
##############################################################################
# Program Name: database.cgi
#
#      Summary: Online database.  From WebReview website.
#               Usage: http://triweb/CustSvcFin/cgi-bin/cgiwrap/csf1/dbase/
#                      database.cgi?config.txt
#
#      Created: ?? (Brent Michalski)
#      Modified: Fri Apr 16 1999 15:18:56 (Bob Heckel--mostly comments)
##############################################################################

use CGI qw (:standard);
use CGI::Carp qw(fatalsToBrowser);

$q = new CGI;
print $q->header;

$config=$ENV{QUERY_STRING};
unless(require $config){  # Must have file config.txt in same dir.
  print "No Configuration File Specified!\n";
  exit;
}

$field_count = @fields;
$colspan = $field_count+1;

$EXCLUSIVE = 2;
$UNLOCK    = 8;

$sort         = $q->param(sort_on);       # Line added for sorting
$search_for   = $q->param(search_for);
$search_field = $q->param(search_field);
$action       = $q->param(action);
@keys         = $q->param(key);
$key_matches  = @keys;

$search_field = "all" if($search_field eq "");
$search_for   = '.'   if ($search_for eq "");

if($action =~ /add record/i){
 # Add the record passed from the add record page
  &add_record;
  $message="Record Added";
  &print_message($message);
}
elsif($action =~ /add/i){
 # Display the add record page
  &print_add_screen;
}
elsif($action =~ /modify record/i){
 # Display the results of the search
  &search_database($q->param(key));
  &sort_db;              ### Line Added for sorting.
  $count = @results;
  &no_match if($count < 1);
  &print_modify_page;
}
elsif($action =~ /modify this record/i){
 # Modify the record that was passed
  &delete_records;
  &add_record;
  $message="Record Modified";
  &print_message($message);
}
elsif($action =~ /modify/i){
 # Search and display results for modification
  &search_database($search_for);
  &sort_db;              ### Line Added for sorting.
  $count = @results;
  if($count < 1){
    &no_match;
  }
  elsif($count == 1){
    &print_modify_page;
  }
  else {
    $caption="Modify Which Record?";
    $button_text="Modify Record";
    &multiple_match("RADIO","modify");
  }
}
elsif($action =~ /delete record/i){
 # Delete the record(s) that were passed
  &delete_records;
  $message="Record(s) Deleted";
  &print_message($message);
}
elsif($action =~ /delete/i){
 # Search and display results for modification
  &search_database($search_for);
  $count = @results;
  &no_match if($count < 1);
  $caption="Delete Which Record(s)?";
  $button_text="Delete Record(s)";
  &multiple_match("CHECKBOX","delete");
}
elsif($action =~ /search/i){
 # Search database and display the results

  &search_database($search_for);
  &sort_db;              ### Line Added for sorting.

  $count = @results;
  if($count > 0){
    $button_text = "Back to Database";
    $caption = "Search Results";
    &multiple_match;
  } else {
    &no_match;
  }
}
else { &print_default; }

exit;

### Subroutines go below here.

sub add_record {
  $key   = time();
  $record=$key;
  foreach $field (@fields){
    ${$field}  = $q->param($field);
    ${$field}  = filter(${$field});
    $record   .= "\|${$field}";
  }

  unless (-e $database){
    open (DB, ">$database") || die "Error creating database.  $!\n";
  } else {
    open (DB, ">>$database") || die "Error opening database.  $!\n";
  }
   flock DB, $EXCLUSIVE;
   seek DB, 0, 2;
   print DB "$record\n";
   flock DB, $UNLOCK;
  close(DB);
} # End of add_record subroutine.

sub print_add_screen{
  print<<HTML;
   <HTML><HEAD><TITLE>Add a Record</TITLE></HEAD>
    <BODY BGCOLOR="#FFFFFF">
     <CENTER><FONT SIZE=5 FACE="ARIAL">
      Add a Record
     </FONT></CENTER>
     <P>
     <FORM  ACTION="$form_action?$config" METHOD=POST>
      <CENTER><TABLE BORDER=1 CELLSPACING=0>
HTML
  foreach $field (@fields){
       print<<HTML;
        <TR>
         <TD BGCOLOR="e0e0e0"><B>\u$field:</B></TD>
         <TD><INPUT TYPE=TEXT NAME="$field"></TD>
        </TR>
HTML
  } # End of foreach.
      print<<HTML;
       <TR>
        <TD COLSPAN=2 BGCOLOR="e0e0e0">
         <CENTER>
          <INPUT TYPE=SUBMIT NAME=action VALUE="Add Record">
         </CENTER>
        </TD>
       </TR>
      </TABLE></CENTER>
     <P>
    </FONT>
   </BODY></HTML>
HTML
} # End of print_add_screen subroutine.

sub delete_records{
  $tempfile="$database.tmp";

  open (DB,   $database)    or die "Error opening file: $!\n";
  open (TEMP, ">$tempfile") or die "Error opening file: $!\n";
  flock TEMP, $EXCLUSIVE;

  while(<DB>){
    $match="";
    ($key,$rest)=split(/\|/);
    foreach $current (@keys){
      if($current == $key){$match=1;}
    } # End of foreach loop.
   print TEMP $_ unless ($match == 1);
  } # End of while loop.

# NT Changes.  (Had to close file before rename and unlink on NT)
  flock TEMP, $UNLOCK;
  close(DB);
  close(TEMP);
  unlink($database)           || die "Could not delete file! $!";
  rename($tempfile,$database) || die "Could not rename file! $!";

} # End of subroutine.

sub print_modify_page{
  ($key,@field_vals) = split(/\|/, $results[0]);
  $fs="<FONT SIZE=2 FACE=ARIAL>";
  $fc="</FONT>";

  print $q->start_html(-TITLE=>'Modify Record',-BGCOLOR=>'white'),
        $q->start_form(-ACTION=>"$form_action?$config");

  print<<HTML;
   <CENTER><FONT SIZE=5 FACE=ARIAL>
    Modify Record
   </FONT></CENTER>
   <HR WIDTH=75%>
   <INPUT TYPE=HIDDEN NAME=key value="$key">
   <CENTER>
    <TABLE BORDER=1 CELLSPACING=0>
HTML

  $x=0;
  foreach $field (@fields){
    print<<HTML;
     <TR BGCOLOR="e0e0e0">
      <TD>$fs<B>\u$field:</B>$fc</TD>
      <TD><INPUT TYPE=TEXT NAME="$field" VALUE="$field_vals[$x]" SIZE=40></TD>
     </TR>
HTML
    $x++;
  } # End of foreach.

print<<HTML;
     <TR BGCOLOR="efefef">
      <TD COLSPAN=2>
       <CENTER>
        <INPUT TYPE=SUBMIT NAME=action VALUE="Modify This Record">
       </CENTER>
      </TD>
     </TR>
    </TABLE>
   </CENTER>
   <P><HR WIDTH=75%>
  </BODY></HTML>
HTML
}

sub multiple_match{
  print $q->start_html(-TITLE=>'Match Results',-BGCOLOR=>'white');
  print<<HTML;
   <FONT SIZE=6 FACE=ARIAL>
    <CENTER>$caption</CENTER>
   </FONT>
   <FONT FACE=ARIAL>
    <CENTER>There were $count matches</CENTER>
   </FONT>
   <FORM METHOD=POST ACTION="$form_action?$config">
   <HR WIDTH=75%>
   <P>
   <CENTER><TABLE BORDER=1 CELLSPACING=0>
    <TR BGCOLOR="#e0e0e0">
HTML

  if($_[1] =~ /(modify|delete)/){
    print "<TD ALIGN=CENTER>";
    print "<FONT SIZE=2 FACE=ARIAL><B>Select</B></FONT></TD>";
  }

  foreach $field (@fields){
    print "<TD ALIGN=CENTER>";
    print "<FONT SIZE=2 FACE=ARIAL><B>\u$field</B></FONT></TD>";
  } # End of foreach

  print "</TR>";

  foreach $record (@results){
    ($key,@field_vals) = split(/\|/, $record);

    print "<TR BGCOLOR=\"#efefef\">";

    if($_[1] =~ /(modify|delete)/){
       print "<TD ALIGN=CENTER><FONT SIZE=2 FACE=ARIAL>";
       print "<INPUT TYPE=$_[0] NAME=key VALUE=$key>";
       print "</FONT></TD>";
    } # End of if.

    for($x=0;$x<$field_count;$x++){
      $item = &check_empty($field_vals[$x]);
      print "<TD><FONT SIZE=2 FACE=ARIAL>$item</FONT></TD>";
    }
     print "</TR>";
  } # End of foreach loop.

  print<<HTML;
  <TR BGCOLOR="#e0e0e0">
   <TD COLSPAN=$colspan ALIGN=CENTER>
    <INPUT TYPE=SUBMIT NAME=action VALUE="$button_text">
   </TD>
  </TR>
 </TABLE>
</FORM></BODY></HTML>
HTML
} # End of multiple_match subroutine.

sub no_match{
  print $q->start_html(-TITLE=>'No Match',-BGCOLOR=>'white');
  print "<H2><CENTER>There was no match for <I>$search_for</I>, ";
  print "please hit <B>back</B> and try again.</CENTER></H2>";
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
        ($key,@field_vals) = split(/\|/, $_);
        if($field_vals[$search_field] =~ /$search_for/oi){push @results, $_};
      } # End of else.
    } # End of while.
  close (DB);
} # End of search_database subroutine.

sub print_default {
 print<<HTML;
        <HTML><HEAD>
   <TITLE>Simple Database Main Screen</TITLE>
  </HEAD><BODY BGCOLOR="#FFFFFF">

  <FORM METHOD="post"  ACTION="$form_action?$config">
  <CENTER><FONT SIZE=4 FACE="ARIAL"><B>
   The Simple Database
  </B></FONT></CENTER><P>

  <CENTER>
   <TABLE BORDER=1 WIDTH="75%" BGCOLOR="#e0e0e0" CELLSPACING="0">
   <TR>
    <TD COLSPAN=2>
     <CENTER><FONT FACE="ARIAL" SIZE=2>
      To <I>add</I> a record, click on the Add button.
      To <I>search/modify/delete</I> records, enter the text in
      the box below and choose the field to search on. Then
      click to appropriate button.
     </FONT></CENTER>
    </TD>
   </TR><TR>
    <TD><FONT FACE="ARIAL" SIZE=2><B>Search For:</B></FONT></TD>
    <TD><INPUT TYPE="text" NAME="search_for" SIZE="40"></TD>
   </TR><TR>
    <TD><FONT FACE="ARIAL" SIZE=2><B>Search On:</B></FONT></TD>
    <TD><FONT FACE="ARIAL" SIZE=2>
     <INPUT TYPE="radio" NAME="search_field" VALUE="all" CHECKED>All
HTML

  $x=0;
  foreach $field (@fields){
    print "<INPUT TYPE=radio NAME=search_field VALUE=$x>\u$field";
    $x++;
  }

#######  The below HTML was added...  #######
  print<<HTML;
    </FONT></TD></TR><TR>
    <TD><FONT FACE="ARIAL" SIZE=2><B>Sort On:</B></FONT></TD>
    <TD><FONT FACE="ARIAL" SIZE=2>
HTML
  $x=0;
  $CH = "CHECKED";
  foreach $field (@fields){
    print "<INPUT TYPE=radio NAME=sort_on VALUE=$x $CH>\u$field";
    $x++;
    $CH="";
  }
####### End of HTML modifications.  #######

  print<<HTML;
    </FONT></TD>
   </TR><TR>
    <TD COLSPAN=2>
     <CENTER>
      <INPUT TYPE="submit" NAME="action" VALUE="   Add   ">
      <INPUT TYPE="submit" NAME="action" VALUE="Search">
      <INPUT TYPE="submit" NAME="action" VALUE="Modify">
      <INPUT TYPE="submit" NAME="action" VALUE="Delete">
     </CENTER>
    </TD>
  </TR>
 </TABLE></FORM></BODY></HTML>
HTML
} # End of print_default subroutine.

sub filter{
  $temp = $_[0];
  $temp =~ s/\|//; # Remove pipe symbols in text.
  return ($temp);
}

sub print_message{
  print<<HTML;
    <HTML><BODY BGCOLOR="#FFFFFF" TEXT=ARIAL>
     <FONT SIZE=6><CENTER>$_[0]</CENTER></FONT><HR WIDTH=75%>
     <P>
     <FONT SIZE=5><CENTER>
      Back To <A HREF="$form_action?$config">Main Database Screen</A>
     </CENTER></FONT>
    </BODY></HTML>
HTML
}

sub check_empty{
  $r_val = $_[0];
  if($r_val =~ /^\s*$/){$r_val="&nbsp;"}

  return($r_val);
}

#### This entire subroutine was added.
sub sort_db{
  foreach $curr (@results){
    ($key,@rest) = split(/\|/, $curr);
    $max = @fields;

    $code='$record{$key} = { key => "$key", ';

    for($x=0;$x<$max;$x++){
      $code .= "\$fields[$x] => \"\$rest[$x]\",\n";
    } # End of for

    $code .= '};';

   eval $code;
  } # End of foreach

  $sort_on = "$fields[$sort]";

  @results=();
  foreach $rp (sort { $a->{$sort_on} cmp $b->{$sort_on} } values %record){
    $new_rec = $rp->{key};
    for($x=0;$x<$max;$x++){
      $new_rec .= "\|$rp->{$fields[$x]}";
    } # End of for
    push @results, $new_rec;
  } # End of foreach
} # End of sub sort_db
