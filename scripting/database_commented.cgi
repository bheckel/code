#!/usr/bin/perl -w
##############################################################################
# Program Name: database.cgi
#
#      Summary: Online database.  From WebReview website.
#
#               Directory setup:
#               /triweb/CustSvcFin/cgi-bin/dbase contains
#               config.txt /data database.cgi
#               ./data contains database.txt
#
#               See bottom of this commented file for sample.
#
#      Created: ?? (Brent Michalski)
#     Modified: Mon Jul 12 1999 14:40:09 (Bob Heckel--comments added,
#                                         this version is for learning 
#                                         purposes, see triweb for live 
#                                         version)
##############################################################################

#########################
# Simple Database
# By Brent Michalski
#########################
# bobh This loads CGI.pm and ':standard' imports std functions into this
# script.  Part of CGI.pm.
# Located in /triweb/tools/perl/lib/5.005/
use CGI qw(:standard);
  1	# bobh Part of CGI.pm helps with more graceful error msgs.  'fatals..'
  2	# sends error to browser, no ugly "500 Internal..." msg.
  3	# Found in /triweb/tools/perl/lib/5.005/CGI
  4	use CGI::Carp qw(fatalsToBrowser);
     # bobh Create new CGI object. 
  5	$q = new CGI;
     # bobh Same as 'print "Content-type: text/html\n\n"'
  6	print $q->header;
     # bobh Used for pointing to my config.txt file.
  7	$config=$ENV{QUERY_STRING};
  8	unless(require $config) {
  9	  print "No Configuration File Specified!\n";
 10	  exit;
 11	}
     # bobh $field_count is num of fields database has. 
     # bobh fields come from config.txt
 12	$field_count = @fields;
 13	$colspan = $field_count+1;
     # bobh Use English to simplify code when using flock later in pgm. 
 14	$EXCLUSIVE = 2;
 15	$UNLOCK    = 8;
    
 16	$sort         = $q->param(sort_on);       # Line added for sorting
     # bobh ??
 17	$search_for   = $q->param(search_for);
 18	$search_field = $q->param(search_field);
 19	$action       = $q->param(action);
     # bobh Need since possible to match > 1 so with this, can traverse array
     # and present user with a page to choose a record to modi or del.
 20	@keys         = $q->param(key);
     # bobh Used for multiple deletes.
 21	$key_matches  = @keys;
    
 22	$search_field = "all" if($search_field eq "");
     # bobh Regex dot
 23	$search_for   = '.'   if ($search_for eq "");
     # bobh action comes from value of the button on calling page. 
 24	if($action =~ /add record/i){
 25	 # Add the record passed from the add record page
 26	  &add_record;
 27	  $message="Record Added";
 28	  &print_message($message);
 29	}
 30	elsif($action =~ /add/i){
 31	 # Display the add record page
 32	  &print_add_screen;
 33	}
 34	elsif($action =~ /modify record/i){
 35	 # Display the results of the search
       # bobh key is the radio button selected
 36	  &search_database($q->param(key));
 37	  &sort_db;              ### Line Added for sorting.
       # bobh ?? where is results array created??
 38	  $count = @results;
 39	  &no_match if($count < 1);
       # bobh if you got here, must have exactly one match
 40	  &print_modify_page;
 41	}
     # bobh gets called when new info has been keyed into textbox and user
     # clicks Modify This Record button.
 42	elsif($action =~ /modify this record/i){
 43	 # Modify the record that was passed
      # bobh actually destroys & recreates old record, not modifies
 44	  &delete_records;
 45	  &add_record;
 46	  $message="Record Modified";
 47	  &print_message($message);
 48	}
     # bobh shortest match goes last
 49	elsif($action =~ /modify/i){
 50	 # Search and display results for modification
      # bobh ??what is in search_for vari??
 51	  &search_database($search_for);
 52	  &sort_db;              ### Line Added for sorting.
 53	  $count = @results;
 54	  if($count < 1){
 55	    &no_match;
 56	  }
 57	  elsif($count == 1){
 58	    &print_modify_page;
 59	  }
 60	  else {
 61	    $caption="Modify Which Record?";
 62	    $button_text="Modify Record";
 63	    &multiple_match("RADIO","modify");
 64	  }
 65	}
 66	elsif($action =~ /delete record/i){
 67	 # Delete the record(s) that were passed
 68	  &delete_records;
 69	  $message="Record(s) Deleted";
 70	  &print_message($message);
 71	}
 72	elsif($action =~ /delete/i){
 73	 # Search and display results for modification
 74	  &search_database($search_for);
 75	  $count = @results;
 76	  &no_match if($count < 1);
 77	  $caption="Delete Which Record(s)?";
 78	  $button_text="Delete Record(s)";
 79	  &multiple_match("CHECKBOX","delete");
 80	}
 81	elsif($action =~ /search/i){
 82	 # Search database and display the results
    
 83	  &search_database($search_for);
 84	  &sort_db;              ### Line Added for sorting.
    
 85	  $count = @results;
 86	  if($count > 0){
 87	    $button_text = "Back to Database";
 88	    $caption = "Search Results";
         # bobh this time pass no parameters
 89	    &multiple_match;
 90	  } else {
 91	    &no_match;
 92	  }
 93	}
     # bobh default database page
 94	else { &print_default; }
    
 95	exit;
    
 96	### Subroutines go below here.
    
 97	sub add_record {
 98	  $key   = time();
 99	  $record=$key;
       # bobh e.g. from config.txt "Name" "E-Mail" "Phone" etc.
100	  foreach $field (@fields){
       # bobh dont need braces here
       # bobh e.g. first pass creates a new vari $Name
       # ---------
       # bobh then populates $Name with value passed from inputbox
       # bobh Same as           $Name
       # bobh         -----------------
101	    ${$field}  = $q->param($field);
       # bobh this is a justincase if data includes the pipe delimiter
       # bobh         homemade--removes pipes |
102	    ${$field}  = filter(${$field});
103	    $record   .= "\|${$field}";
104	  }
    
105	  unless (-e $database){
106	    open (DB, ">$database") || die "Error creating database.  $!\n";
107	  } else {
108	    open (DB, ">>$database") || die "Error opening database.  $!\n";
109	  }

110	   flock DB, $EXCLUSIVE;
111	   seek DB, 0, 2;
112	   print DB "$record\n";
113	   flock DB, $UNLOCK;
114	  close(DB);
115	} # End of add_record subroutine.
    
     # bobh $config is from the query string, usually config.txt
116	sub print_add_screen{
117	  print<<HTML;
118	   <HTML><HEAD><TITLE>Add a Record</TITLE></HEAD>
119	    <BODY BGCOLOR="#FFFFFF">
120	     <CENTER><FONT SIZE=5 FACE="ARIAL">
121	      Add a Record
122	     </FONT></CENTER>
123	     <P>
124	     <FORM  ACTION="$form_action?$config" METHOD=POST>
125	      <CENTER><TABLE BORDER=1 CELLSPACING=0>
126	HTML
127	  foreach $field (@fields){
128	       print<<HTML;
129	        <TR>
130	         <TD BGCOLOR="e0e0e0"><B>\u$field:</B></TD>
131	         <TD><INPUT TYPE=TEXT NAME="$field"></TD>
132	        </TR>
133	HTML
134	  } # End of foreach.
135	      print<<HTML;
136	       <TR>
137	        <TD COLSPAN=2 BGCOLOR="e0e0e0">
138	         <CENTER>
139	          <INPUT TYPE=SUBMIT NAME=action VALUE="Add Record">
140	         </CENTER>
141	        </TD>
142	       </TR>
143	      </TABLE></CENTER>
144	     <P>
145	    </FONT>
146	   </BODY></HTML>
147	HTML
148	} # End of print_add_screen subroutine.
    
149	sub delete_records{
150	  $tempfile="$database.tmp";
    
151	  open (DB,   $database)    or die "Error opening file: $!\n";
152	  open (TEMP, ">$tempfile") or die "Error opening file: $!\n";
153	  flock TEMP, $EXCLUSIVE;
    
154	  while(<DB>){
155	    $match="";
156	    ($key,$rest)=split(/\|/);
157	    foreach $current (@keys){
158	      if($current == $key){$match=1;}
159	    } # End of foreach loop.
160	   print TEMP $_ unless ($match == 1);
161	  } # End of while loop.
    
162	# NT Changes.  (Had to close file before rename and unlink on NT)
163	  flock TEMP, $UNLOCK;
164	  close(DB);
165	  close(TEMP);
166	  unlink($database)           || die "Could not delete file! $!";
167	  rename($tempfile,$database) || die "Could not rename file! $!";
    
168	} # End of subroutine.
    
169	sub print_modify_page{
       # bobh ??
170	  ($key,@field_vals) = split(/\|/, $results[0]);
       # bobh Timesavers
171	  $fs="<FONT SIZE=2 FACE=ARIAL>";
172	  $fc="</FONT>";
    
       # bobh Using CGI.pm features
173	  print $q->start_html(-TITLE=>'Modify Record',-BGCOLOR=>'white'),
174	        $q->start_form(-ACTION=>"$form_action?$config");
    
175	  print<<HTML;
176	   <CENTER><FONT SIZE=5 FACE=ARIAL>
177	    Modify Record
178	   </FONT></CENTER>
179	   <HR WIDTH=75%>
180	   <INPUT TYPE=HIDDEN NAME=key value="$key">
181	   <CENTER>
182	    <TABLE BORDER=1 CELLSPACING=0>
183	HTML
    
184	  $x=0;
185	  foreach $field (@fields){
186	    print<<HTML;
187	     <TR BGCOLOR="e0e0e0">
188	      <TD>$fs<B>\u$field:</B>$fc</TD>
189	      <TD><INPUT TYPE=TEXT NAME="$field" VALUE="$field_vals[$x]" SIZE=40></TD>
190	     </TR>
191	HTML
192	    $x++;
193	  } # End of foreach.
    
194	print<<HTML;
195	     <TR BGCOLOR="efefef">
196	      <TD COLSPAN=2>
197	       <CENTER>
198	        <INPUT TYPE=SUBMIT NAME=action VALUE="Modify This Record">
199	       </CENTER>
200	      </TD>
201	     </TR>
202	    </TABLE>
203	   </CENTER>
204	   <P><HR WIDTH=75%>
205	  </BODY></HTML>
206	HTML
207	}
    
208	sub multiple_match{
       # bobh Using CGI.pm features
       # bobh </form> closes around line 253
209	  print $q->start_html(-TITLE=>'Match Results',-BGCOLOR=>'white');
210	  print<<HTML;
211	   <FONT SIZE=6 FACE=ARIAL>
212	    <CENTER>$caption</CENTER>
213	   </FONT>
214	   <FONT FACE=ARIAL>
215	    <CENTER>There were $count matches</CENTER>
216	   </FONT>
217	   <FORM METHOD=POST ACTION="$form_action?$config">
218	   <HR WIDTH=75%>
219	   <P>
220	   <CENTER><TABLE BORDER=1 CELLSPACING=0>
221	    <TR BGCOLOR="#e0e0e0">
222	HTML
    
       # bobh Add leftmost Select col 
223	  if($_[1] =~ /(modify|delete)/){
224	    print "<TD ALIGN=CENTER>";
225	    print "<FONT SIZE=2 FACE=ARIAL><B>Select</B></FONT></TD>";
226	  }
       # bobh Print header row 
227	  foreach $field (@fields){
228	    print "<TD ALIGN=CENTER>";
229	    print "<FONT SIZE=2 FACE=ARIAL><B>\u$field</B></FONT></TD>";
230	  } # End of foreach
    
231	  print "</TR>";

       # bobh Still don't understand next line
232	  foreach $record (@results){
233	    ($key,@field_vals) = split(/\|/, $record);
    
234	    print "<TR BGCOLOR=\"#efefef\">";
    
235	    if($_[1] =~ /(modify|delete)/){
236	       print "<TD ALIGN=CENTER><FONT SIZE=2 FACE=ARIAL>";
            # bobh $_[0] is either RADIO or CHECKBOX as determined above
237	       print "<INPUT TYPE=$_[0] NAME=key VALUE=$key>";
238	       print "</FONT></TD>";
239	    } # End of if.
    
240	    for($x=0;$x<$field_count;$x++){
           # bobh $item holds current field for the record we are handling.
           # bobh Value is " " if blank.
           # bobh Want to be sure no tabs, linefeeds, etc.  Replace with a
           # bobh space.
241	      $item = &check_empty($field_vals[$x]);
242	      print "<TD><FONT SIZE=2 FACE=ARIAL>$item</FONT></TD>";
243	    }
244	     print "</TR>";
245	  } # End of foreach loop.
    
246	  print<<HTML;
247	  <TR BGCOLOR="#e0e0e0">
248	   <TD COLSPAN=$colspan ALIGN=CENTER>
249	    <INPUT TYPE=SUBMIT NAME=action VALUE="$button_text">
250	   </TD>
251	  </TR>
252	 </TABLE>
253	</FORM></BODY></HTML>
254	HTML
255	} # End of multiple_match subroutine.
    
256	sub no_match{
257	  print $q->start_html(-TITLE=>'No Match',-BGCOLOR=>'white');
258	  print "<H2><CENTER>There was no match for <I>$search_for</I>, ";
259	  print "please hit <B>back</B> and try again.</CENTER></H2>";
260	  print $q->end_html;
261	  exit;
262	} # End of no_match subroutine.
    
263	sub search_database{
264	  my $search_for = $_[0];
265	  open(DB, $database) or die "Error opening file: $!\n";
266	    while(<DB>){
267	      if($search_field =~ /all/i){
268	        if(/$search_for/oi){push @results, $_};
269	      } else {
270	        ($key,@field_vals) = split(/\|/, $_);
             # bobh @results is where successful matches are stored.
             # bobh pushes successful match onto @results
271	        if($field_vals[$search_field] =~ /$search_for/oi){push @results, $_};
272	      } # End of else.
273	    } # End of while.
274	  close (DB);
275	} # End of search_database subroutine.
    
     # bobh This prints if none of the conditions are met at pgm startup.
276	sub print_default {
277	 print<<HTML;
278	        <HTML><HEAD>
279	   <TITLE>Simple Database Main Screen</TITLE>
280	  </HEAD><BODY BGCOLOR="#FFFFFF">
    
281	  <FORM METHOD="post"  ACTION="$form_action?$config">
282	  <CENTER><FONT SIZE=4 FACE="ARIAL"><B>
283	   The Simple Database
284	  </B></FONT></CENTER><P>
    
285	  <CENTER>
286	   <TABLE BORDER=1 WIDTH="75%" BGCOLOR="#e0e0e0" CELLSPACING="0">
287	   <TR>
288	    <TD COLSPAN=2>
289	     <CENTER><FONT FACE="ARIAL" SIZE=2>
290	      To <I>add</I> a record, click on the Add button.
291	      To <I>search/modify/delete</I> records, enter the text in
292	      the box below and choose the field to search on. Then
293	      click to appropriate button.
294	     </FONT></CENTER>
295	    </TD>
296	   </TR><TR>
297	    <TD><FONT FACE="ARIAL" SIZE=2><B>Search For:</B></FONT></TD>
298	    <TD><INPUT TYPE="text" NAME="search_for" SIZE="40"></TD>
299	   </TR><TR>
300	    <TD><FONT FACE="ARIAL" SIZE=2><B>Search On:</B></FONT></TD>
301	    <TD><FONT FACE="ARIAL" SIZE=2>
302	     <INPUT TYPE="radio" NAME="search_field" VALUE="all" CHECKED>All
303	HTML
    
304	  $x=0;
305	  foreach $field (@fields){
306	    print "<INPUT TYPE=radio NAME=search_field VALUE=$x>\u$field";
307	    $x++;
308	  }
    
309	#######  The below HTML was added...  #######
310	  print<<HTML;
311	    </FONT></TD></TR><TR>
312	    <TD><FONT FACE="ARIAL" SIZE=2><B>Sort On:</B></FONT></TD>
313	    <TD><FONT FACE="ARIAL" SIZE=2>
314	HTML
315	  $x=0;
316	  $CH = "CHECKED";
317	  foreach $field (@fields){
318	    print "<INPUT TYPE=radio NAME=sort_on VALUE=$x $CH>\u$field";
319	    $x++;
320	    $CH="";
321	  }
322	####### End of HTML modifications.  #######
    
323	  print<<HTML;
324	    </FONT></TD>
325	   </TR><TR>
326	    <TD COLSPAN=2>
327	     <CENTER>
328	      <INPUT TYPE="submit" NAME="action" VALUE="   Add   ">
329	      <INPUT TYPE="submit" NAME="action" VALUE="Search">
330	      <INPUT TYPE="submit" NAME="action" VALUE="Modify">
331	      <INPUT TYPE="submit" NAME="action" VALUE="Delete">
332	     </CENTER>
333	    </TD>
334	  </TR>
335	 </TABLE></FORM></BODY></HTML>
336	HTML
337	} # End of print_default subroutine.
    
338	sub filter{
339	  $temp = $_[0];
340	  $temp =~ s/\|//; # Remove pipe symbols in text.
341	  return ($temp);
342	}
    
343	sub print_message{
344	  print<<HTML;
345	    <HTML><BODY BGCOLOR="#FFFFFF" TEXT=ARIAL>
346	     <FONT SIZE=6><CENTER>$_[0]</CENTER></FONT><HR WIDTH=75%>
347	     <P>
348	     <FONT SIZE=5><CENTER>
349	      Back To <A HREF="$form_action?$config">Main Database Screen</A>
350	     </CENTER></FONT>
351	    </BODY></HTML>
352	HTML
353	}
    
354	sub check_empty{
355	  $r_val = $_[0];
356	  if($r_val =~ /^\s*$/){$r_val="&nbsp;"}
    
357	  return($r_val);
358	}
    
359	#### This entire subroutine was added.
360	sub sort_db{
361	  foreach $curr (@results){
362	    ($key,@rest) = split(/\|/, $curr);
363	    $max = @fields;
    
364	    $code='$record{$key} = { key => "$key", ';
    
365	    for($x=0;$x<$max;$x++){
366	      $code .= "\$fields[$x] => \"\$rest[$x]\",\n";
367	    } # End of for
    
368	    $code .= '};';
    
369	   eval $code;
370	  } # End of foreach
    
371	  $sort_on = "$fields[$sort]";
    
372	  @results=();
373	  foreach $rp (sort { $a->{$sort_on} cmp $b->{$sort_on} } values %record){
374	    $new_rec = $rp->{key};
375	    for($x=0;$x<$max;$x++){
376	      $new_rec .= "\|$rp->{$fields[$x]}";
377	    } # End of for
378	    push @results, $new_rec;
379	  } # End of foreach
380	} # End of sub sort_db
    


#############################################################################
Samples:

config.txt

## This array is the names of the fields that you want in your database.
@fields = ("Name","E-mail","Phone","Notes");

## This variable is the location of the database that this
## configuration file points to.
$database = "data/database.txt";

## This variable is the "relative path" to the database.cgi program.
###$form_action="/98/10/23/perl/database.cgi";
$form_action="./database.cgi";
 

/data/database.txt

924276092|one|lkd@elkje.com|555-2222|none
924276196|bob|lkj@dslkj.com|555-3330|3rd
924276254|bob|ldkj@slkj.com|555-2345|second OK....
924290072|zat|lsdk|0398|s;ds
924548096|amt|om88|;dklj|d;lkj

#############################################################################

