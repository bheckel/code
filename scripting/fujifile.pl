##############################################################################
#     Name: fujifile.pl
#
#  Summary: Take DMS100/UE9000, Cadence/Allegro or Fiducial files and parse
#           into specific Fujicam format, outputting as text in the browser.
#
# Sample DMSorUE input file:
#   $ITEM$ 110,5006,124195,172.000,EA,,A0618849,CHC0603X7R104K4B,,
#   C3-C65,C67,C69-C71,C74,C93-C95.1,C100,C114-C116,C119,C122,C128,C145,C159-C163,C169,C175-C177,C187,C188,C194-C199,C202,C203,C205,C210-C282
#   $ITEM$ 130,5024,136567,104.000,EA,,A0681158,CHC0603X7R103J5B,,
#   C75-C92,C96-C99,C101.5-C113,C117,C118,C120,C121,C123-C127,C129-C144,C146-C158,C164-C168,C170-C174,C178-C186,C189-C193,C200,C201,C204,C206-C209
#
# Sample Cadence input file:
#   Title:         Bill of Materials
#   Design:        NTLX72BA
#   Date:          Aug 2 9:14:12 2000
#   Template: /ntcad/tools/cadence/share/etc/text/concept_msl.bom
# 
#   Item   Part Name         Ref Des                Qty   CPCode         Eng Code                          
#   ====   ===============   ====================   ===   ============   ================================  
#      1   0805PSEUDO        R39-R44,R117,           24   PSE0348        0805PSEUDO                        
#                            R128-R137,R155,                                                               
#                            R295-R297,R314-R316                                                           
#      2   0S1210            E1-E4                    4   A0376368       CHR11B0000CU                      
#      3   100UFTK10A        C24,C41                  2   A0639979       CTS10Y2917T101K10E                
#      4   22UFAM100C        C31,C38                  2   A0644294       CA10Z220M100SGP                   
#      5   22UFTK10B_1       C17,C19,C20,C30,C32,     8   A0329886       CTS10Y2917T220K16                 
#                            C33,C39,C42                                            0k
#
# Sample Fiducial input file:
#
#   Number of Global Fiducials on Top Side =    4
# 
#   Fiducial diameter = r61 at x=-0.295  y=11.457 
#   Fiducial diameter = r62 at x=-11.614 y=11.457 
#   Fiducial diameter = r63 at x=-11.693 y=0.079 
#   Fiducial diameter = r64 at x=-0.295  y=0.039 
# 
#   Number of Global Fiducials on Bottom Side = 4
# 
#   Fiducial diameter = r65 at x=-0.295  y=11.457 
#   Fiducial diameter = r66 at x=-11.614 y=11.457 
#   Fiducial diameter = r67 at x=-11.693 y=0.079 
#   Fiducial diameter = r68 at x=-0.295  y=0.039 
#
#  Created: Fri, 30 Jun 2000 14:16:29 (Bob Heckel using Mark Hewett's upload
#                                      algorithm)
# Modified: Wed, 25 Oct 2000 11:10:32 (Bob Heckel -- allow input files from
#                                      DDMez to have multiple blank spaces.
#                                      Replace . with _ for DMS100/UE9000)
# Modified: Thu, 30 Nov 2000 15:56:41 (Bob Heckel -- wrap DMS100/UE9000 lines
#                                      when they hit 600 characters.)
# Modified: Mon 26 Mar 2001 08:27:21 (Bob Heckel -- insert 25 char wide
#                                     engineering code after CPC and before 
#                                     designators)
##############################################################################

package Fujifile;

$; = ":";
$PUB = '/Public/uploadCache/';

# Every module requires a Dispatch() function to decide which of our page
# routines to call.  The main dispatcher will call this dispatcher, providing
# a reference to the context hash ($Ctx), a reference to the configuration
# data ($Cfg), and the function name ($Function).  Note the function name may
# be blank.
sub Dispatch {
  local($Ctx, $Cfg, $Function) = @_;

  # Override higher level title from parent.
  $Ctx->{TITLE} = $Ctx->{MODULE_DESC};

  # Provide better error message on failure to find a function handler.
  $Pkg = $Cfg->{module}{package};

  # Now dispatch the appropriate function.
  if ( $Function eq "Form1" || $Function eq "" ) {
    ($rc, $msg) = Browse('Please select file to be uploaded'); 
  } 
  elsif ( $Function eq "Upload" ) {
    ($rc, $msg) = Upload(); 
  } 
  elsif ( $Function eq "ParseDMSorUE" ) {
    ($rc, $msg) = ParseDMSorUE(); 
  } 
  elsif ( $Function eq "ParseCadence" ) {
    ($rc, $msg) = ParseCadence(); 
  } 
  elsif ( $Function eq "ParseFiducial" ) {
    ($rc, $msg) = ParseFiducial(); 
  } 
  else {
    return (-1, "$Pkg: No handler for function \"$Function\"");
  }
  return ($rc, $msg);
}


# User selects input textfile.
sub Browse {
  $Ctx->{TITLE}   = $Ctx->{MODULE_DESC};
  $Ctx->{MESSAGE} = $msg;

  Util::AddToolbar("browse");

  # Build a simple file upload widget.
  return Screen::BuildPage('browse');
}


sub Upload {
  $Ctx->{TITLE}   = "Uploaded File - Results";

  ($status, $msg) = Util::Validate(
        ['fn',  'NOTNULL',              "Please enter name of file to upload"],
        ['fn',  'MINFILESIZE(1)',       "File is empty"],
        ['fn',  'MAXFILESIZE(8500000)', "File is too big (%d bytes)"],
        );

  return Browse(Util::Format('attention', $msg)) unless ($status > 0);

  # Protect against ugly table layout due to missing cell value.
  $Ctx->{'_TYPE:fn'} ? $Ctx->{'_TYPE:fn'} : $Ctx->{'_TYPE:fn'} = '&nbsp;';
  # Looks like a text file less than 4K in size
  if (($Ctx->{'_TYPE:fn'} =~ /^text/) && ($Ctx->{'_SIZE:fn'} < 4096)) {
    # METHOD #1 - get entire contents into one variable
    $contents = Util::UploadFile('fn');

    $Ctx->{DISPLAY} = Util::Format('display_text', $contents);
  }

  # METHOD #2 - save file to  a directory on the server's file system
  # First, determine a suitable name/place to put the file.
  ($name, $path, $url) = Util::UploadPath('fn');
  $Ctx->{FSHORTNAME} = $name;     # Save for use in sub ParseDMSorUE();

  # Then copy the file to its new home.
  ($rc, $msg) = Util::UploadFile('fn', $path);

  # Then check that it worked okay.
  if ( $rc > 0 ) {
    # non-zero size must be good.
    $Ctx->{MESSAGE} = sprintf("%s\n - uploaded to - \n%s\n (%d bytes)\n",
                              $Ctx->{fn},
                              $path,
                              $rc,
                             );
    $Ctx->{FN_ANCHOR} = Util::Format('fn_anchor', $url, $name);
  } else {
    # Zero or negative size is treated as a failure.
    $Ctx->{MESSAGE} = sprintf("%s not uploaded<BR>\n%s\n",
                               $Ctx->{fn},
                               $msg,
                              );
    $Ctx->{FN_ANCHOR} = "";
  }

  Util::PostForward(FSHORTNAME);
  Util::AddToolbar('upload');

  return Screen::BuildPage('upload');
}


sub ParseDMSorUE {
  # Max width of 600 is desired by Dzung Nguyen, Fuji can handle 999.
  # This value cannot be reached exactly and probably will be exceeded if many
  # of the designators look like this e.g. R890-R891 instead of R890.  The
  # average is thrown off by wide elements.  Best to go 100 less than your
  # desired max.
  my $maxwidth    = 500;
  my @wholeline   = ();
  my $designation = '';
  my $filename    = $PUB . "$Ctx->{FSHORTNAME}";

  open(FH, "$filename") 
          || return(Screen::Error("Can't open $filename: $! on machine $^O."));

  (my $one, my $two, my $three) = <FH>;

  DetectValidInput('DMS100/UE9000', $one, $two, $three)
                     || return(Screen::Error(WarnMsg($one, $two, $three)));

  # Rewind.
  seek(FH, 0, 0);

  $/ = '$ITEM$';     # Strange delimiter put to use for us.

  # Visual confirmation of file that user selected and how output was generated.
  $Ctx->{LINEITEM} = Signature('DMS100/UE9000', $Ctx->{FSHORTNAME});

  # Sample record:
  #         0   1      2    3    4  5    6        7      8
  # $ITEM$ 100,5024,173463,1.000,EA,F,P0881992,NTLX8201,07,
  # C431-C432,C444
  while ( <FH> ) {
    my $bytes = 0;
    # Remove $ITEM$ indicators.
    chomp;    
    $bytes = length($_);
    # Remove carriage ret/newlines that force CPC to be on one line and
    # the Designators on another.
    s/\r*\n//g;
    # Elim multiple spaces in DDMez web files.
    s/,\s+(\w+)/,$1/;
    s/,\s+$/, / unless $. == 1;
    s/\./_/g;  # Replace periods with underscores per Dzung Nguyen.
    @wholeline = split(',', $_);

    # Found a long line that will choke Fuji...
    if ( $bytes > $maxwidth ) { 
      # ...so this CPC will have to wrap at least once.
      my $avgelement = 0;
      my $maxelems   = 0;
      my $tmp        = undef;
      my $cpc        = $wholeline[6];
      # Rough average of element length, rounded up.
      $avgelement = round($bytes / scalar(@wholeline)) + 1;
      # S/b around 63. 
      $maxelems = round($maxwidth / $avgelement);
      # Number of times to break the long line (not including first line).
      my $breakline = round(scalar(@wholeline) / $maxelems);
      my $i = 0;
      # Don't jump off the end of the array.
      while ( $breakline > 0 ) {
        $i += $maxelems;
        if ( defined($wholeline[$i]) ) {
          my $tmp = $wholeline[$i];
          # Insert.
          ###$wholeline[$i] = "\n$cpc, " . $tmp;
          $wholeline[$i] = "\n$cpc, " . pack('A25', $wholeline[7]) . ", $tmp";
          $breakline--;
        } else {
          $breakline--;
        }
      }
    }

    # Cpc code always located at position 6.
    $Ctx->{LINEITEM} .= $wholeline[6];
    # Eng code always located at position 7.
    # The 'if-then' loop protects against tacking a trailing comma on the
    # signature line.
    if ( defined($wholeline[7]) ) {
      # Padded to 25 per Dzung Nguyen (this will generate a 25 space blank if
      # there is no eng code, as requested).
      my $padded = pack('A25', $wholeline[7]);
      $Ctx->{LINEITEM} .= ", $padded";
    }
    # Designation always spans array element 8 thru end of array.
    for ( $i=8; $i<=$#wholeline; $i++ ) {
      $Ctx->{LINEITEM} .= $wholeline[$i];
      # Don't use a comma after the final element.
      unless ( $i == $#wholeline ) {
        $Ctx->{LINEITEM} .= ', ';
      }
    }
  $Ctx->{LINEITEM} .= "\n";
  }
  close(FH);

  ###return Screen::BuildPage('output1');    # DEBUG
  return Screen::BuildPage('output1', 'text/plain');
}


sub ParseCadence {
  my $cpccode = '';     # Don't use undef.
  my $desig   = '';     # Don't use undef.
  my %cpchash = ();

  my $filename = $PUB . "$Ctx->{FSHORTNAME}";

  # E.g. 8_2_ntlx72ba.bom
  open(FH, "$filename")
          || return(Screen::Error("Can't open $filename: $! on $^O machine."));

  (my $one, my $two, my $three) = <FH>;

  # Rewind. NOT WORKING, doing an explicit, wasteful, close and reopen.
  ###seek(FH, 0, 0);
  close(FH);

  DetectValidInput('Cadence', $one, $two, $three)
                     || return(Screen::Error(WarnMsg($one, $two, $three)));

  open(FH, "$filename")
          || return(Screen::Error("Can't open $filename: $! on $^O machine."));

  while ( <FH> ) {
    # Remove top of page garbage.
    next unless ( $. > 5 );
    next if /^Item|^====/;
    # Elim blank lines (just in case they appear in the future).
    next if /^\s*$/;
    
    # Start new record...
    if ( $_ =~ /^ *(\d+)   / ) { 
      # First flush out any old data if you're on a new record.
      # Finished with CPC record if arrive at a new Item number.
      # The only indication of a new record is a new Item number.
      # Create %cpchash whose keys are cpccodes and values are (references to)
      # arrays of desigs.
      push( @{$cpchash{$cpccode}}, "$desig\t" ) if $1;
      # ... add more push statements here to add other fields besides $desig.
      $cpccode = substr($_, 54, 8);
      $desig = undef;     # Start a new desig which might span several lines.
    }
    # Add to existing record...
    # Use $cleanup_desig to clean data before concat with $desig.
    if ( $cleanup_desig = substr($_, 25, 20) ) {
      $cleanup_desig =~ s/\s+//;       # Clean spaces created from short lines, etc.
      $desig .= $cleanup_desig;
    }
  }
  close(FH);

  $Ctx->{LINEITEM} = Signature('Cadence', $Ctx->{FSHORTNAME});

  DisplayCadence(\%cpchash);

  ###return Screen::BuildPage('output1');    # DEBUG
  return Screen::BuildPage('output1', 'text/plain');
}


sub DisplayCadence {
  my $rcpchash = $_[0];
  my %cpchash  = %$rcpchash;

  my $line1flag = 1;
  foreach $hashkey (sort keys %cpchash) {
    $Ctx->{LINEITEM} .=  "$hashkey\t";     # Set up the cpc's line.
    my @desigline = @{$cpchash{$hashkey}};
    foreach $element ( @desigline ) {
      $element =~ s/^\s+//;      # Ltrim just in case.
      # Warning: input data can have duplicate cpccodes.  I'm assuming that
      # they will always be adjacent to each other.
      # This regex will force the multiple collections of desigs into one.
      $element =~ s/ +\t/,/;
    }
    # There's only one element in @desigline.
    # Elim trailing comma.  Can't do it above due to interference from the
    # duplicate cpc potential and the fact that those elements run together.
    chop($desigline[0]);     
    # Signature line shouldn't receive a comma.
    $Ctx->{LINEITEM} .= "$desigline[0],\n" unless $line1flag;
    $Ctx->{LINEITEM} .= "$desigline[0]\n"  if     $line1flag;
    $line1flag = 0;
  }
}


sub ParseFiducial {
  my $filename = $PUB . "$Ctx->{FSHORTNAME}";
  open(FH, $filename)
         || return(Screen::Error("Can't open $filename: $! on $^O machine."));

  (my $one, my $two, my $three) = <FH>;

  DetectValidInput('Fiducial', $one, $two, $three)
                     || return(Screen::Error(WarnMsg($one, $two, $three)));

  # Rewind.
  seek(FH, 0, 0);

  $Ctx->{LINEITEM} = Signature('Fiducial', $Ctx->{FSHORTNAME}) . "\n";

  $Ctx->{LINEITEM} .= sprintf("%-14s %10s %9s %9s %9s\n", 'Fid Name', 'X Loc', 'Y Loc',
                                        'Side', 'Size');

  # Intialize new section.
  my $fline         = undef;
  my $itemname_odd  = undef;
  my $itemname_even = undef;
  my $odd           = undef;
  my $even          = undef;

  while ( <FH> ) {
    next if /^$/;
    # New entry...
    if ( /^Number of\s+\w+\s+Fiducials on (\w)\w+ Side \= +(\d+)/i ) {
      ###$glob_or_loc = $1;
      ###$t_or_b      = $2;
      $t_or_b      = $1;
      ###$numlines    = $3;
      $numlines    = $2;

      # Initialize if this is the first run.
      $odd  = -1 unless ( $numlines == $been_here_before );
      $even =  0 unless ( $numlines == $been_here_before );

      $been_here_before = $3;

      # Finish up previous datablock.
      if ( $fline ) {
        $Ctx->{LINEITEM} .= $fline;
        $fline = undef;
      }
      if ( $t_or_b eq 'T' ) {
        $odd += 2;
        $itemname_odd = 1;
        $itemname_even = undef;
      } else {
        $t_or_b = 'B';
        $even += 2;
        $itemname_even = 1;
        $itemname_odd = undef;
      }
    }
    # Continued entry...
    if ( /Fiducial diameter = r(\d+) at x=(-?\d+\.?\d+)\s+y=(-?\d+\.?\d+)/i ) {
      if ( $itemname_odd ) {
        $fidname = $t_or_b . 'FID' . $odd;
        $fline .= sprintf("%-14s %10.3f %9.3f %9d %9d\n", $fidname, $2, $3, $odd, $1); 
        $odd += 2;
      } else {
        $fidname = $t_or_b . 'FID' . $even;
        $fline .= sprintf("%-14s %10.3f %9.3f %9d %9d\n", $fidname, $2, $3, $even, $1); 
        $even += 2;
      }
    }
  }
  $Ctx->{LINEITEM} .= "\n";
  close(FH);

  ###return Screen::BuildPage('output1');    # DEBUG
  return Screen::BuildPage('output1', 'text/plain');
}


sub round {
  # Handles negative numbers as well.
  use POSIX;
  $arg = $_[0];

  if ( $arg > 0.0 ) {
    $arg = floor($arg + 0.5);
  } elsif ( $arg < 0.0 ) {
    $arg = ceiling($arg - 0.5);
  } else {
    $arg = 0.0;
  }

  return $arg;
}


# First line of output gives file stats.
sub Signature {
  my $inputtype = shift;
  my $inputfile = shift;

  my $created = scalar localtime();

  return "$inputtype file $inputfile parsed by Solectron IWS " .
         "(http://47.143.212.30/Services/fujifile) on $created";
}


# Sniff the first few rows.
sub DetectValidInput {
  my $style = shift;
  my $line1 = shift;
  my $line2 = shift;
  my $line3 = shift;

  my $foundvalid = undef;
  my $regex = undef;

  if ( $style eq 'DMS100/UE9000' ) {
    $regex = 'ITEM';
  } elsif ( $style eq 'Cadence' ) {
    $regex = 'Title';
  } elsif ( $style eq 'Fiducial' ) {
    $regex = 'Number';
  } else {
    $foundvalid = 1;
  }

  for ( $line1, $line2, $line3 ) {
    if ( m/$regex/o ) {
      $foundvalid = 1;
    }
  }

  $foundvalid ? return 1 : return 0; 
}


# Why it failed and where to find samples.
sub WarnMsg {
  $l1 = shift;
  $l2 = shift;
  $l3 = shift;

  # Build href to this module's start page.
  $Ctx->{HOMESITE} =~ m#(http://\d+\.\d+\.\d+/)#;
  my $href = "$1$Ctx->{SCRIPT}\/$Ctx->{MODULE_NAME}";

  return my $warnmsg=<<"EOT";
<B>Your file does not appear to be in the proper format.  
Please retry.  Sample file formats are available at 
<A HREF="$href">http:/$href</A><BR>
First 3 lines of your file:<BR><BR></B>
  Line 1: $l1<BR>
  Line 2: $l2<BR>
  Line 3: $l3<BR>
EOT
}


1;
