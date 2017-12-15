####################################################################
#
#  Program Lockup
#  Written by Stephen G. Keilholz
#  Purpose: Identify directories of contact data that exceed
#           a configured threshold and generate requests to
#           copy this data, up to that threshold, to the
#           specified media
#
#  22-Mar-2007 Bob Heckel - New module created to find contacts
#                           based on Caller Role.  New AVI 
#                           file reading (CPAN) module 
#                           integrated.  New Ini reading module
#                           integrated.  All inline SQL 
#                           converted to Oracle packages.
#
# 12-Sep-2007 Bob Heckel  - Modified to accomodate non-product 
#                           oriented data (plus future expansion).  
#                         - Moved hardcoded data to the .ini file 
#                           to increase flexibility.
#                         - Tightened variable scope where possible.
#
####################################################################
use warnings;
use DBI;
use POSIX qw(strftime);
use File::Copy;
use File::Path;
use archDB;
use Ini;
use archLogging;
use archActLogging;

### Use statements required for perl2exe compiled version
use Carp::Heavy;
use DBD::Oracle;
use DBD::Oracle qw(:ora_types);


initializeProgram();
scanForThresholds();
if ($dumpMode) {
  dumpQueue($dumpFile);
  $dumpFile ||= '<STDOUT>';
  # E.g. c:\> Lockup.exe DUMP foo.txt
  actLog("Normal","Queue information sent to file $dumpFile");
} else {
  processQueue();
}
actLog("Normal","Program ended normally.");
close(STDOUT);close(STDERR);

exit;



# Get program configuration from configuration file and create GLOBALS.
sub initializeProgram {
  $|=1;select(STDERR);$|=1;select(STDOUT); # unbuffer both STDERR and STDOUT

  $PROGNAME="Lockup";

  $W2LIni=new Ini;
  unless ($W2LIni->read('W2L.ini')) {
    die 'Error: No W2L.ini file available.';
  }
#
# Get error handling variables from configuration file, specifying defaults
# if they aren't there.
#
  $logLevel=$W2LIni->{ErrorHandling}{LogLevel} || "None";
  $errorLogDateFmt=$W2LIni->{ErrorHandling}{errorLogDateFmt} || "%y%d%m%H%M%S";
  $errorNotification=$W2LIni->{ErrorHandling}{ErrorNotification} || "None";
  @addresses=split /,/, $W2LIni->{ErrorHandling}{'Notify_'.$errorNotification} unless $errorNotification eq "None";
  $mailHost=$W2LIni->{ErrorHandling}{MailHost} unless $errorNotification eq "None";
  $mailOriginator=$W2LIni->{ErrorHandling}{MailOriginator} unless $errorNotification eq "None";
  actLog("Program started");
#
# Get base of directory structure into which data is to be stored
#
  $templateDir=$W2LIni->{DirStructure}{templateDir};
  $sourceBase=$W2LIni->{DirStructure}{Base};
  $tempBase=$W2LIni->{DirStructure}{tempBase};
  $remoteLoc=$W2LIni->{DirStructure}{remoteLoc};
  $remoteSourceBase=$W2LIni->{DirStructure}{remoteSourceBase};
#
# Get information about database
#
  $logActivityDB=$W2LIni->{Databases}{LogActivity};
#
# Get recording media-specific variables to populate .nwp file
#
no warnings;
  $discSize=$W2LIni->{Recording}{mediaSize};
  $mediaType=$W2LIni->{Recording}{mediaType};
  $discDirSizeLimit=$W2LIni->{Recording}{discDirSizeLimit};
  $imageType=$W2LIni->{Recording}{imageType};
  $fixate=$W2LIni->{Recording}{fixate};
  $numCopies=$W2LIni->{Recording}{copies};
  $priority=$W2LIni->{Recording}{priority};
  $templateFileName=$W2LIni->{Recording}{templateFile};
  $orderDateFormat=$W2LIni->{Recording}{orderDateFormat};
  $labelPath=$W2LIni->{Recording}{labelPath};
use warnings;
 
  $buildDisc=$W2LIni->{Debugging}{buildDisc};  # generate and send order (0 to not send, 1 to send)
  $keepSource=$W2LIni->{Debugging}{keepSource};  # keep source files (0 to remove, 1 to keep)
#
# Get list of valid types of files to archive
#
  @filetypes = split /\s*,\s*/, $W2LIni->{FileTypes}{Types};

# Get list of possible output header types and build a hash of their header
# titles.
  @hdrtypes = split /\s*,\s*/, $W2LIni->{FileHeaders}{hdrTypes};
  for ( @hdrtypes ) { 
    $headers{$_} = lc $W2LIni->{FileHeaders}{$_};
  }

  # Get utility files that are to be copied everytime
  @utilfiles = split /\s*,\s*/, $W2LIni->{UtilityFiles}{utils};

#
# Initialize each module with local copies of configuration variables
#
  archLogging::init($logActivityDB);
  actLogInit($logLevel,$errorNotification,$PROGNAME,$mailHost,$mailOriginator,
             $errorLogDateFmt,@addresses);
#
#  Allow for dump mode where activity information is dumped to file rather than
#  performed
#
  $dumpMode=$dumpFile="";
  if ("\U$ARGV[0]" eq "DUMP") {
    shift @ARGV;
    $dumpMode=1;
    $dumpFile=shift @ARGV;
#    delete $ARGV[1];
#    delete $ARGV[0];
    actLog("Normal","Operating in request dump mode, no requests will be processed");
  } else {
  print "[$buildDisc] [$keepSource]\n";
    if ($buildDisc) {
      actLog("Normal","Will build discs");
    } else {
      actLog("Normal","Will not build discs");
    }
    if ($keepSource) {
      actLog("Normal","Will keep source files");
    } else {
      actLog("Normal","Will not keep source files");
    }
  }
#
# Set up onlyProcess pattern if arguments exist
  $onlyProcess="";
  foreach $pat (@ARGV) {
    next unless $pat; # skip blank values
    $onlyProcess.="$pat|";
  }
  chop($onlyProcess) if $onlyProcess;
  actLog("Normal","Limiting to directories matching $onlyProcess") if $onlyProcess;
}


sub scanForThresholds {
#
# Scan all directories in structure for those that exceed threshold; queue
# file list (and start/end date of list) for each directory found
#
  actLog("Normal","Scanning for directories exceeding threshold of $discSize Meg");
#
# Initialize count of archives needed and open the base directory containing
# the subdirectories for each potential disc to create.
#
  $archive{'COUNT'}=0;

  opendir(DIR,$sourceBase) or die "$sourceBase does not exist\n";

  while ( defined ($groupdir = readdir DIR) ) {
    next if $groupdir =~ /^\.\.?$/;     # skip . and ..
    next unless -d "$sourceBase\\$groupdir"; # Skip non-directories
    opendir(GDIR,"$sourceBase\\$groupdir");
    while ( defined ($file = readdir GDIR) ) {
      next if $file =~ /^\.\.?$/;     # skip . and ..
      next unless -d "$sourceBase\\$groupdir\\$file"; # Skip non-directories
      next if $onlyProcess && !("$groupdir\\$file"=~/$onlyProcess/i); # Skip if limited
      $groupfile="$groupdir\\$file";
      if (&haveDiscFull("$groupfile")) {
#
# If we need to archive, increment the count and put into hash the information
# about the data to archive including the start and end date as well as the
# list of files to copy.
#
        $archive{$groupfile}=$archive{'COUNT'}++;
        $x=@copyfiles;
        actLog("Normal","Queueing $x files for group $groupdir area $file [$groupfile]");
        $archive{$groupfile}{'LIST'}=[ @copyfiles ];
        $archive{$groupfile}{'STARTDATE'}=$startdate;
        $archive{$groupfile}{'ENDDATE'}=$enddate;
      }
    }
    closedir(GDIR);
  }
  closedir(DIR);
}


sub haveDiscFull {
#
# Determine if the amount of data in the passed directory would exceed the
# amount that would fit on the media.  As an optomization, maintain a list
# of the files that would fit in an array.  Return boolean as to whether or not
# this list is full and requires archiving.
#
  local($dirname)=@_;
  local($file,$size,$lsize,$overLimit,$record);
  local($rectime,$fname,$reason,$sesdate,$dur,$callerfn,$callerln,$state,$AE,$fileSize,%seenFile);
#
# Undefine values of startdate, enddate, curfile, and copyfiles
#
  undef $startdate;
  undef $enddate;
  undef $curfile;
  undef @copyfiles; # For some reason, doesn't work if array appended to previous line
  undef %seenFile;
#
# Log activity, initialize variables to keep track of total size of files, and
# open the log file.
#
  actLog("Normal","Getting dir size for $dirname from $sourceBase\\$dirname\\logfile.txt");
  $size=0;
  $lsize=0;
  $overLimit='';
#
#  Sort contents before processing to make sure that date range includes all
#  available files in that range when disc is created -- files with earlier
#  dates may be added to file for various reasons
#
  open(FILELIST,"<$sourceBase\\$dirname\\logfile.txt");
  @recordList = <FILELIST>;
  close(FILELIST);

  foreach $record (sort byDate @recordList) {
    #
    # Parse the record and skip it if the file is the same as the current one
    # to prevent possibility of multiple copies of files from being put on
    # disc.  This shouldn't happen since data shouldn't have been created that
    # way.
    #
    ($rectime,$fname,$reason,$sesdate,$dur,$product,$callerfn,$callerln,$state,$AE,$fileSize)=split(/,/,$record);
    next if defined($seenFile{$fname});  # skip multiple reason records for same file
    $fileSize=(int($fileSize/1024)+1)/1024; # get next highest whole number value of K converted to Megs
      
    $size+=$fileSize; # size after adding this file
    $curfile=$fname;
    #
    # If we're not over the limit and adding this file wouldn't exceed the
    # discsize, add the record to the list of those to copy and increment the
    # size of the files "in queue".  Otherwise, set the overlimit flag and
    # leave loop.
    #
    # overlimit flag is holdover and possibly could be removed since loop is
    # exited the first thie that a file would exceed the limit.
    #
    if (!$overLimit && ($size <= $discSize)) {
      $startdate=$sesdate unless $startdate; # set startdate first time only
      $enddate=$sesdate;
      push @copyfiles,$record;
      $lsize+=$fileSize;
    } else {
      $overLimit = 1; # set over limit indicator
      last;
    }
  }
#
# Close the log file; log result and return value indicating whether or not
# we are over the limit.  Array copyfiles is used if over the limit.
#
  if ($overLimit) {
    actLog("Normal","Have full disk of $lsize MB in $dirname directory of $size MB");
  } else {
    actLog("Normal","Directory isn't full, total $dirname directory size is only $size MB");
  }

  return $overLimit;
}


sub analyzeLogRecords {
#
# For given area, check log to see what fields are available and thus what
# columns will be necessary in the output file.  Return array of boolean
# values with one element per (defined) field.
#
  my $grouparea = shift;

  my(@fieldsWithValues,@fields,$record,$filetype,$fileExt);
#
# Undefine haveFileTypes because we set the value for use elsewhere but we are
# called multiple times in a given run.
#
  undef %haveFileTypes;
#
# For each record in the list for this grouparea, split it and determine which
# fields have values.  Then check field 1 for each of the defined filetypes,
# setting the haveFileTypes flag if the specified type of file is found.
#
  foreach $record (@{ $archive{$grouparea}{'LIST'} }) {
    @fields=split(/,/,$record);
    for (my $i=0;$i<=$#fields;$i++) {
      $fieldsWithValues[$i]=1 if $fields[$i] ne "";
    }
    foreach $filetype (@filetypes) {
      $fileExt="\\.$filetype";
      $haveFileTypes{$filetype}=1 if $fields[1]=~/$fileExt/;
    }
  }

  return @fieldsWithValues
}


# Get and locally cache the formal, long, group name from database
sub getGroupName {
  my $group = shift;

  local(@row,$dbh,$getGroup);
  $dbh=openDB($logActivityDB);

  # TODO is there a performance hit for doing this >1 time?
  $getGroup_h = $dbh->prepare( q{
    BEGIN
        :getGroup := CRCARCH_BATCH.ARCH.get_group_name(:group);
    END;
  } );
  $getGroup_h->bind_param(":group", $group);
  $getGroup_h->bind_param_inout(":getGroup", \$getGroup, 255);

  $getGroup_h->execute;
  $groupName{$group}=$getGroup;  # global

  return $getGroup;
}


# Get and locally cache the formal, long, area name from database
sub getAreaName {
  my $area = shift;

  local(@row,$dbh);
  $dbh=openDB($logActivityDB);
  $getArea_h = $dbh->prepare( q{
    BEGIN
        :getArea := CRCARCH_BATCH.ARCH.get_area_name(:area);
    END;
  } );
  $getArea_h->bind_param(":area", $area);
  $getArea_h->bind_param_inout(":getArea", \$getArea, 255);

  $getArea_h->execute;
  $areaName{$area}=$getArea;  # global

  return $getArea;
}


sub generateHeaders {
  #
  # Generate html top of file, text top of file
  #
  # include jscript for filetypes present
  # include headings for filetypes present
  #
  # build basic header for all files
  my($grouparea,@fieldsWithValues)=@_;

  my $shortnm = getShortName($grouparea);

  local($htmlTop,$line,@potentialHeaderFields);
  
  $htmlTop="";
  local($groupdirnm,$areadirnm) = split(/\\/,$grouparea);
  # Populate file with %tags% for HTML HEAD and partial BODY
  open(ITOP,"<$templateDir\\indexTop.txt") or die "can't open indexTop.txt";
  while ($line=<ITOP>) { 
    next if $line=~/^\s*;/; 
    $line=~s/%(.*?)%/$$1/g; 
    $htmlTop .= $line; 
  }
  close ITOP;
  $htmlTop.="\n<!- END indexTop ->\n";

  #-- Unused (empty) section on 2007-09-17 --#
  foreach $filetype (keys %haveFileTypes) {
  # copy template from templatedir with name based on filetype into header
    if (-e "$templateDir\\$filetype".".txt") {
      open(INP,"<$templateDir\\$filetype".".txt");
      while ($line=<INP>) { next if $line=~/^\s*;/; 
        $line=~s/%(.*?)%/$$1/g; 
        $htmlTop .= $line; 
      }
      close(INP);
    }
  }
  #-- Unused (empty) section on 2007-09-17 --#
  $htmlTop.="\n<!- END file-type specific  ->\n";

  # Populate file with %tags% for HTML BODY TH
  if ( ! defined $groupName{$groupdirnm} ) {
    $groupdb = getGroupName($groupdirnm);
    $groupName{$groupdirnm} = $groupdb;
  } else {
    $groupdb = $groupName{$groupdirnm};
  }
  if ( ! defined $areaName{$areadirnm} ) {
    $areadb = getAreaName($areadirnm);
    $areaName{$areadirnm} = $areadb;
  } else {
    $areadb = $areaName{$areadirnm};
  }
  # Use the appropriate rowHeaders file (usually rowHeaders-default.txt)
  open ROWH,"<$templateDir\\rowHeaders-$shortnm.txt" or die "can't open rowHeader-$shortnm.txt";
  chomp($line=<ROWH>);
  @potentialHeaderFields=split(/,/,$line);
  chomp($line=<ROWH>);
  %fileNames4Nums=split(/,/,$line);  # global!
  chomp($line=<ROWH>);
  %sortSubs=split(/,/,$line);

  # Used for the header that spans the mindex columns (usually 7).
  $colspan=0;
  foreach $potHdrFld (@potentialHeaderFields) {
    $colspan++ if $fieldsWithValues[$potHdrFld];
  }

  while ($line=<ROWH>) {
    next if $line=~/^\s*;/; # skip any line beginning with ";"
    ($field,$line)=split(/:/,$line,2);
    if ($field eq "*" || $fieldsWithValues[$field]) {
      $line=~s/%(.*?)%/$$1/g;
      $htmlTop .= $line;
    }
  }
  close ROWH;

  $htmlTop.="\n<!- END field-specific  ->\n";

  return $htmlTop;
}


sub moveFilesAndGenerateIndices {
  local($htmlTop,$grouparea,@fieldsWithValues)=@_;

  open TINDEX,">$tempBase\\$grouparea\\files\\index.txt";

  my $shortnm = getShortName($grouparea);

  # Write the header line based on the type we're working on.  E.g. if we have
  # caller_role, a special case, use that line from the INI (i.e. skip
  # Product).
  #             GLOBAL
  print TINDEX "$headers{$shortnm}\n";
  
  $dirnum=1;
  $filesindir=0;
  $recnum=0;
  undef @order;
  undef @sessionlist;
  undef @reasonlist;
  $x=@{ $archive{$grouparea}{LIST} };
  actLog("Normal","For $grouparea, archiving $x files");
  foreach $record (@{ $archive{$grouparea}{LIST} }) {
    ($rectime,$fname,$reason,$sesdate,$dur,$product,$callerfn,$callerln,$state,$AE,$fileSize)=split(/,/,$record);
#
# Process individual field changes necessary
#
    $sname=$fname;
    $sname=~s/(.*?)\..*/$1/i; # change file name to session name (remove anything after first "."
    push @sessionlist,$sname;
    push @reasonlist,$reason;
    $sesdate=~s/(....)(..)(..)(..)(..).*/$1-$2-$3 $4:$5/;
    $posn=substr("0000000$recnum",-8,8);

    mkpath("$tempBase\\$grouparea\\files\\$dirnum") unless -d
    "$tempBase\\$grouparea\\files\\$dirnum";

# href to different jscript based on filetype, change va to view, parameter is type
    $snamel="<a href='$dirnum\\$fname' onMouseOver=\"return va()\" onMouseOut=\"return clr()\">$sname</a>";
    $html[$recnum]="<TR><TD>$snamel</TD><TD>$sesdate</TD>";
    $order[1]{"$sname.$posn"}=$recnum; # for field file (session)

#
# Process field-specific translations for view and sorting in left-to-right
# order
#
    if ($fieldsWithValues[4]) { # Duration
      if ($dur eq "x.xx") {
        $ndur=0;
      } else {
        ($m,$s)=split(/:/,$dur);
        $ndur=$m*60+$s;
      }
      $html[$recnum].="<TD align=right>$dur</TD>";
      $order[4]{"$ndur.$posn"}=$recnum;
    }

    # If Lockup expands in the future to include other than Product or
    # Caller Role types, apply this logic to the other Ifs
    if ( $fieldsWithValues[5] and elemWanted($shortnm, 'Product') ) { # Product
      $html[$recnum].="<TD>$product</TD>";
      $order[5]{"$product.$posn"}=$recnum;
    }

    if ($fieldsWithValues[6] | $fieldsWithValues[7]) { # First / Last name
      $html[$recnum].="<TD>$callerfn $callerln</TD>";
      $order[6]{"$callerfn.$posn"}=$recnum;
      $order[7]{"$callerln.$posn"}=$recnum;
    }
    if ($fieldsWithValues[8]) { # State
      $stateh=($state) ? $state : "&nbsp;";
      $html[$recnum].="<TD>$stateh</TD>";
      $order[8]{"$state.$posn"}=$recnum;
    }
    if ($fieldsWithValues[9]) { # Adverse Event
      $AEh=($AE eq "F") ? "&nbsp;" : "Yes";
      $AEt=($AE eq "F") ? "" : "Yes";
      $AEr=($AE eq "F") ? "No" : ""; # needed for "reverse" sorting when creating html files
      $html[$recnum].="<TD>$AEh</TD>";
      $order[9]{"$AEr.$posn"}=$recnum;
    }
    $html[$recnum].="</TR>\n";
    $recnum++;

    # E.g. default=Session,File,Date,Duration,Product,CallerFN...
    if ( grep { /Product/ } @hdrtypes ) {  # GLOBAL
        print TINDEX  "$sname,$dirnum\\$fname,$sesdate,$dur,$product,$callerfn,$callerln,$state,$AEt\n";
      } else {  # for now this is just caller_role
        print TINDEX  "$sname,$dirnum\\$fname,$sesdate,$dur,$callerfn,$callerln,$state,$AEt\n";
      }
    $renameOk="";

    # File might not exist if it's already been moved because associated with
    # another product
    if (-e "$sourceBase\\$grouparea\\$fname") {
      if (!$keepSource) {
        $renameOk=move("$sourceBase\\$grouparea\\$fname","$tempBase\\$grouparea\\files\\$dirnum\\$fname");
        if (!$renameOk) {
          $copyOk=copy("$sourceBase\\$grouparea\\$fname","$tempBase\\$grouparea\\files\\$dirnum\\$fname");
          if ($copyOk) {
            unlink "$sourceBase\\$grouparea\\$fname";
            $renameOk=$copyOk;
          } else {
            actLog("Error","Unable to move file $sourceBase\\$grouparea\\$fname to $tempBase\\$grouparea\\files\\$dirnum\\: [$!]");
            exit;
          }
        }
      } else {
        $copyOk=copy("$sourceBase\\$grouparea\\$fname","$tempBase\\$grouparea\\files\\$dirnum\\$fname");
        actLog("Warning","Unable to copy file $sourceBase\\$grouparea\\$fname to $tempBase\\$grouparea\\files\\$dirnum\\: [$!]") unless $copyOk;
      }
      if (++$filesindir >= $discDirSizeLimit) {
        $dirnum++;
        $filesindir=0;
      }
    }
  }
  close TINDEX;
#
# Build required html files
#
  for ($i=0;$i<=$#fieldsWithValues;$i++) {
    if ($fieldsWithValues[$i]) {
      buildHtmlFileFor($i);
    }
  }

  actLog("Debug","Copying $templateDir\\infofile.htm to $tempBase\\$grouparea\\files\\index.htm");
  $copyOk=copy("$templateDir\\infofile.htm","$tempBase\\$grouparea\\files\\index.htm");
  actLog("Debug","Successful copy") if $copyOk;
  actLog("Debug","Failed to copy") if ! $copyOk;
}


sub buildHtmlFileFor {
  my $fieldNo = shift;
  my $filename;

  $filename=$fileNames4Nums{$fieldNo};

  return unless $filename;

  open HTML,">$tempBase\\$grouparea\\files\\$filename".".htm" or die $!;

  print HTML $htmlTop;

  if (!defined $sortSubs{$fieldNo}) {
    foreach $ptrkey (sort keys %{ $order[$fieldNo] }) {
      print HTML $html[$order[$fieldNo]{$ptrkey}];
    }
  } else {
    $subName=$sortSubs{$fieldNo};
    foreach $ptrkey (sort $subName keys %{ $order[$fieldNo] }) {
      print HTML $html[$order[$fieldNo]{$ptrkey}];
    }
  }

  print HTML "</TBODY>\n</TABLE>\n</BODY>\n</HTML>\n";

  close HTML;
}


sub generateStandardFiles {
  my $grouparea = shift;

  # GLOBAL
  actLog("Normal","Copying @utilfiles autorun.inf and creating label data file");

  for ( @utilfiles ) {
    copy("$templateDir\\$_","$tempBase\\$grouparea\\files\\$_");
  }
    
# autorun.ini label= is currently blank 2007-09-27 
### Copy autorun.inf substituting program variables where needed
###    open(INP,"<$templateDir\\autorun.inf");
###    open(OUT,">$tempBase\\$area\\files\\autorun.inf");
###    while ($line = <INP>) { 
###      $line =~ s/%(.*?)%/$$1/g; 
###      print OUT $line; 
###    }
###    close(INP);
###    close(OUT);

  # Create data file for field-based text on CD/DVD label split "area" into
  # group/area
  ($g,$a)=split(/\\/,$grouparea);

  open DATA,">$tempBase\\$grouparea\\labelData.txt";
  print DATA "$g,$a,Start Date: $startdate,End Date: $enddate\n";
  close DATA;
}


sub generateOrder {
  my $grouparea = shift;

  my ($g,$a) = split(/\\/,$grouparea);

  $orderId = $a;  # global!
  $orderId =~ s/ //g;

  $volumeNo = substr($orderId,0,18);  # global!

  $orderId = substr("$orderId",0,8);
  $orderId .= strftime($orderDateFormat,localtime(time));

  $volumeNo .= "-".strftime($orderDateFormat,localtime(time));

  # Used in orderFileTemplate.txt to write orderfile.nwp
no warnings;
  $sourcePath = "$remoteSourceBase\\$grouparea\\files";
  $labelTextPath = "$remoteSourceBase\\$grouparea\\labelData.txt";
use warnings;

  # E.g. order_id=%orderId%<CR>priority=%priority%<CR>...
  open(INP,"<$templateDir\\$templateFileName");
  open(OUT,">$tempBase\\$grouparea\\orderfile.nwp");

  while ($line = <INP>) { 
    next unless $line;
    $line =~ s/%(.*?)%/$$1/g; 
    print OUT $line; 
  }
  close(INP);
  close(OUT);

  actLog("Normal","!!!DEBUG - DISABLED!!!-Updating media information $volumeNo $orderId");
  ###newMediaAssociation($volumeNo,$orderId);

  if ($buildDisc) {
    copy("$tempBase\\$grouparea\\orderfile.nwp","$remoteLoc\\$orderId".".nwp");
    actLog("Normal","Sent request $orderId to disc creation server");
    resetTextIndex("$sourceBase\\$grouparea");
  } else {  # send request to recorder
    actLog("Warning","Skipped sending request $orderId to server");
  }
}


sub resetTextIndex {
  my $basedir= shift;
  my ($now,$record,$file,$dummy);

  $now=strftime($orderDateFormat,localtime(time));

  open LOG,"<$basedir\\logfile.txt";
  open GONE,">>$basedir\\queuedlogfile.txt";
  open TEMP,">$basedir\\templogfile.txt";

  while ($record=<LOG>) {

    ($dummy,$file,$dummy)=split(/,/,$record);
    if (-e "$basedir\\$file") {
      print TEMP $record;
    } else {
      print GONE "$now,$record";
    }
  }
  close(LOG);close(GONE);close(TEMP);
  move("$basedir\\logfile.txt","$basedir\\oldlogfile.txt");
  move("$basedir\\templogfile.txt","$basedir\\logfile.txt");
  unlink("$basedir\\oldlogfile.txt")
}


sub newMediaId {
  local($dbh,$volumeNo,$orderId)=@_;
  
  my $mid=0;  # set default (Oracle sequence error)
  
  if (!defined $newMediaId_h) {
  $newMediaId_h = $dbh->prepare( q{
    BEGIN
        :mid := CRCARCH_BATCH.ARCH.add_media(:volumeNo, :orderId);
    END;
  } );
  }
  $newMediaId_h->bind_param(":volumeNo", $volumeNo);
  $newMediaId_h->bind_param(":orderId", $orderId);
  $newMediaId_h->bind_param_inout(":mid", \$mid, 32);
  $newMediaId_h->execute;
  
  if ($mid == 0) {
    actLog("Error","Error on retrieving Media ID from database ($volumeNo, $orderId)\n");
  }
  
  return $mid;
}


sub newMediaAssociation {
  # Create crc_arc_media record.  Associate CRC_ARCH_LOG records (id by
  # sess/reason_id) to media and update status.
  local($volumeNo,$orderId)=@_;
  local($dbh,$sess,$i,$status,$insertOK);
  
  $dbh=openDB($logActivityDB);
  
  # Get next media id
  #
  $mediaId=newMediaId($dbh,$volumeNo,$orderId);
  
  # Define sql to update log records with media status
  #
  if (!defined $updateLogMediaStatus_h) {
  $updateLogMediaStatus_h = $dbh->prepare( q{
     DECLARE
        insertOK VARCHAR2(32);
  
        FUNCTION from_bool( i BOOLEAN ) RETURN NUMBER IS
        BEGIN
           IF    i IS NULL THEN RETURN NULL;
           ELSIF i         THEN RETURN 1;
           ELSE                 RETURN 0;
           END IF;
        END;
     BEGIN
        :insertOK := from_bool(CRCARCH_BATCH.ARCH.UPDATE_LOG(:sess,:reason,:mediaId,:status));
     END;
  } );
  }
  
  # Update all records in list
  #
  $status="WRITING DISC";
  for ($i=0;$i<=$#sessionlist;$i++) {
    $sess=$sessionlist[$i];
    $reason=$reasonlist[$i];
  
    $updateLogMediaStatus_h->bind_param(":sess", $sess);
    $updateLogMediaStatus_h->bind_param(":reason", $reason);
    $updateLogMediaStatus_h->bind_param(":mediaId", $mediaId);
    $updateLogMediaStatus_h->bind_param(":status", $status);
  
    $updateLogMediaStatus_h->bind_param_inout(":insertOK", \$insertOK, 32);
    $updateLogMediaStatus_h->execute;
  }
  
  unless ( $insertOK ) {
    actLog("Error","Unable to update crc_arch_log [$sess, $reason, $mediaId, $status]");
    exit;
  }
}


sub dumpQueue {
  my ($disc,$area,$startdate,$enddate,$group,$rarea,$record);
  if ($_[0]) {
    open(DUMP,">$_[0]");
  } else {
    open(DUMP,">&STDERR");
  }
  
  print "WARNING: not implemented for Caller_Role yet!\n" if lc $area =~ /caller_role/;
  print DUMP "disc,group,area,rectime,fname,reason,sesdate,dur,product,callerfn,callerln,state,AE,fileSize\n";
  $disc=0;
  foreach $area (sort keys %archive) {
    next if $area eq "COUNT";
    next if -d "$tempBase\\$area";
    $startdate=$archive{$area}{STARTDATE};
    $startdate=~s/(....)(..)(..)(..)(..).*/$1-$2-$3 $4:$5/;
    $enddate=$archive{$area}{ENDDATE};
    $enddate=~s/(....)(..)(..)(..)(..).*/$1-$2-$3 $4:$5/;
    ($group,$rarea)=split(/\\/,$area);
    foreach $record (@{ $archive{$area}{LIST} }) {
      print DUMP "$disc,$group,$rarea,$record\n";
    }
    $disc++;
  }
  close(DUMP);
}


sub processQueue {
  actLog("Normal","Queueing disc creation for $archive{COUNT} discs");

  foreach my $grouparea (sort keys %archive) {
    next if $grouparea eq "COUNT";

    if (-d "$tempBase\\$grouparea") {
      actLog("Warning","Directory already exists for $tempBase\\$grouparea!");
      next;
    }
    if (!(mkpath "$tempBase\\$grouparea")) {
      actLog("Error","Unable to create $tempBase\\$grouparea");
      exit;
    }

    if (!(mkdir "$tempBase\\$grouparea\\files")) {
      actLog("Error","Unable to create $tempBase\\$grouparea\\files");
      exit;
    }
    
    $startdate=$archive{$grouparea}{STARTDATE};
    $startdate=~s/(....)(..)(..)(..)(..).*/$1-$2-$3 $4:$5/;
    $enddate=$archive{$grouparea}{ENDDATE};
    $enddate=~s/(....)(..)(..)(..)(..).*/$1-$2-$3 $4:$5/;
    
    @fieldsWithValues=analyzeLogRecords($grouparea);
    $htmlTop=generateHeaders($grouparea,@fieldsWithValues);
    moveFilesAndGenerateIndices($htmlTop,$grouparea,@fieldsWithValues);
    generateStandardFiles($grouparea);
    generateOrder($grouparea);
  }
}


# Determine if X contains Y
sub elemWanted {
  my ($x, $y) = @_;
  my (%lookup, %found);

  for ( @hdrtypes ) {
    # %headers is a GLOBAL hash of keys (types) and values (their header list)
    $lookup{$_} = [ split /\s*,\s*/, $headers{$_} ];
  }

  while ( (my $k, my $v) = each %lookup ) {
    for my $hdrname ( @{$v} ) {
      $found{$k}++ if $hdrname eq $y;
    }
  }

  $found{$x} ? return 1 : return 0;
}


# Standardize the long group/area type name from e.g. 'Caller_Role\FIELD' to
# 'caller_role' comparisons.  If the type is in the .ini list, return 
# it, otherwise return 'default'
sub getShortName {
  my $grouparea = shift;

  my $short;  

  for ( @hdrtypes ) {  # GLOBAL
    if ( $grouparea =~ /^$_.*/i ) {
      $short = lc $_;  # we have caller_role or other non-standard type
      last;
    } else {
      $short = 'default';  # same as .ini
    }
  }

  return $short;
}


sub byNum {
#
# For numeric sort
#
return $a <=> $b;
}


sub noCase {
#
# For sort regardless of case
#
return lc($a) cmp lc($b)
}


sub byDate {
#
# For record sort by date field
#
return (split(/,/,$a))[3] <=> (split(/,/,$b))[3];
}

