###############################################################
#
#  Program Cleanup
#  Written by Stephen G. Keilholz
#  Purpose: Verify media creation, remove temporary files, and
#           record information in database
#
#  22-Mar-2007 Bob Heckel - New module created to find contacts
#                           based on Caller Role.  New AVI 
#                           file reading (CPAN) module 
#                           integrated.  New Ini reading module
#                           integrated.  All inline SQL 
#                           converted to Oracle packages.
#
###############################################################

use DBI;
use POSIX qw(strftime);
use File::Path;
use Ini;
use archLogging;
use archActLogging;
use archDB;
use Time::Local;

# Use statements required for perl2exe compiled version
use Carp::Heavy;
use DBD::Oracle;
use DBD::Oracle qw(:ora_types);


initializeProgram();
actLog("Normal","Initialization complete");
identifyActive(); # generate list of discs in an active status in database
scanTempDirs(); # Generates list of discs/contents
scanResultFiles(); # Determines which discs were created
analyseData(); # analyse/determine what should be done
if ($dumpMode) {
  &dumpActions($dumpFile);
  actLog("Normal","Request information sent to file $dumpFile");
} else {
  processActions(); # Process queued actions
}
actLog("Normal","Program ended normally.");
close(STDOUT);close(STDERR); # To avoid message from compiled program

exit;


sub dieGracefully{
#
# provide for way to "die" while workng with actlog and avoiding message
# from compiled program
#
  actLog("Warning","Exiting progam under abnormal circumstances");
  close(STDOUT);close(STDERR); # To avoid message from compiled program
  exit;
}


sub dumpActions{
#
#  Report on actions determined to be performed at this time.  If a filename
#  is passed, results are sent to that file, otherwise, they are sent to STDERR
#
if ($_[0]) {
  open(DUMP,">$_[0]");
} else {
  open(DUMP,">&STDERR");
}
print DUMP "Action\tParameters\n";
actLog("DUMP","Action\tParameters\n");
foreach $action (@Actions) {
  ($action,$params)=split(/,/,$action,2);
  print DUMP "$action\t$params\n";
  actLog("DUMP","$action\t$params\n");
}
close(DUMP);
}


sub initializeProgram{
#
# Get program configuration from configuration file
#
  $|=1;select(STDERR);$|=1;select(STDOUT); # unbuffer both STDERR and STDOUT

  $PROGNAME="Cleanup";

  $CleanIni=new Ini;
  unless ($CleanIni->read('Cleanup.ini')) {
    die 'Error: No Cleanup.ini file available.';
  }
#
# Get error handling variables from configuration file, specifying defaults
# if they aren't there.
#
  $logLevel=$CleanIni->{ErrorHandling}{LogLevel} || "None";
  $errorLogDateFmt=$CleanIni->{ErrorHandling}{errorLogDateFmt} || "%y%d%m%H%M%S";
  $errorNotification=$CleanIni->{ErrorHandling}{ErrorNotification} || "None";
  @addresses=split /,/, $CleanIni->{ErrorHandling}{'Notify_'.$errorNotification} unless $errorNotification eq "None";
  $mailHost=$CleanIni->{ErrorHandling}{MailHost} unless $errorNotification eq "None";
  $mailOriginator=$CleanIni->{ErrorHandling}{MailOriginator} unless $errorNotification eq "None";
  $activityLog="";
  actLog("Program started");
#
# Get base of directory structure into which data is to be stored
#
  $tempBase=$CleanIni->{DirStructure}{tempBase};
  $remoteLoc=$CleanIni->{DirStructure}{remoteLoc};
#
# Get information about database
#
  $logActivityDB=$CleanIni->{Databases}{LogActivity};

  archLogging::init($logActivityDB);
  actLogInit($logLevel,$errorNotification,$PROGNAME,$mailHost,$mailOriginator,
             $errorLogDateFmt,@addresses);
#
# Process command line for dump request
#
  $dumpMode=$dumpFile="";
  if ("\U$ARGV[0]" eq "DUMP") {
    shift @ARGV;
    $dumpMode=1;
    $dumpFile=shift @ARGV;
    actLog("Normal","Operating in request dump mode, no requests will be processed");
  }
}


sub identifyActive{
#
# Get informaton from database on what media are currently "Active" in that the
# system doesn't know that they have been procesed yet.
#
my $activeStatuses="REQUESTED";
$dbh=openDB($logActivityDB);
$dbh->{FetchHashKeyName} = 'NAME_lc';  # tell DBI to lowercase keys
my $sth2;

$getCurrent_h = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.ARCH.get_media_for_status(:activeStatuses);
  END;
} );

$getCurrent_h->bind_param(":activeStatuses", $activeStatuses);
$getCurrent_h->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$getCurrent_h->execute;
$activeRecords = $sth2->fetchall_hashref(order_id);
if ($DBI::errstr) {
  $msg=$DBI::errstr;
  actLog("Error","Error getting active media records from database: $msg");
  &dieGracefully;
}

$numRecs=keys %{ $activeRecords };
actLog("Normal","Identified $numRecs active requests");
}


sub scanTempDirs{
#
# Look at temporary directories representing content to be copied to disc and
# the associated order file.  Build hash of orderids along with associated
# arrays of file information used to update log.
#
  opendir(DIR,$tempBase);
  while ( defined ($group = readdir DIR) ) { # look at group level
    next if $group =~ /^\.\.?$/;     # skip . and ..
    next unless -d "$tempBase\\$group"; # Skip non-directories
    opendir(ADIR,"$tempBase\\$group"); # look at each area within group
    while ( defined ($area = readdir ADIR) ) {
      next if $area =~ /^\.\.?$/;     # skip . and ..
      next unless -d "$tempBase\\$group\\$area"; # Skip non-directories
#
# Get volume and orderid from order file
#
      open(ORDERFILE,"<$tempBase\\$group\\$area\\orderfile.nwp");
      $volume=$orderid="";
      while (chomp($line=<ORDERFILE>)) {
        $orderid=$1 if $line=~/^order_id=(.*)$/;
        $volume=$1 if $line=~/^volume=(.*)$/;
      }
      close ORDERFILE;
      if ($volume eq "" || $orderid eq "") {
        actLog("Warning","Missing orderid and/or volume for $group $area, skipping");
        next;
      }
      $volumeForOrder{$orderid}=$volume;
      $groupForOrder{$orderid}=$group;
      $areaForOrder{$orderid}=$area;
### May not need this but may need for removal of records from main index file ###
#      open(INDEX,"<$tempBase\\$group\\$area\\files\\index.txt");
#      $line=<INDEX>; # skip headings
#      while (chomp($line=<INDEX>)) {
#        if ($line=~/(.*?),.*/) {
#          push @sessions,$1;
#        }
#      close INDEX;
#      }
#      @{ $sessionsForOrder{$orderid} }=@sessions;
#      undef @sessions;
### May not need above ###
    }
    closedir ADIR;
  }
  closedir DIR;
  $numRecs=keys %volumeForOrder;
  actLog("Normal","Identified $numRecs directories for images");
}


sub scanResultFiles{
#
# For each orderid found in RIMAGE order area, check status by looking for file
# in order directory with same name.  Possible conditions are exists with a file
# type of "nwp", "inp#", "err#", or "don#" which indicate that fiile hasn't been
# seen by the network order manager, is in queue, errored out, or is completed
# respectively.
#
# If type is "err#", file nwplog.txt should have a line which matches the
# orderid and has an error message -- get this here.
#
# Result is hash indexed by orderid with 0 for in process, 1 for complete, or
# error message for other condition.
#
# Order directory should have relatively few files so load info about all of
# them first
#
  my (@remoteLocFiles,$nonProcCount,$inpCount,$errCount,$donCount);
  $nonProcCount=$inpCount=$errCount=$donCount=0;
  opendir(DIR,$remoteLoc);
  while ( defined ($file = readdir DIR) ) {
    next if $file =~ /^\.\.?$/;     # skip . and ..
    next if -d "$remoteLoc\\$file"; # Skip directories
# skip any files that don't have types in which we are interested.
    next unless ($file =~/\.(err|inp|don)\d+$/o || $file=~/\.(nwp)/o);
    $file=~/(.*)\.(\w{3})/; # get first 3 characters of file type
    $orderid=$1;$type=$2;
    $procOrderType{$orderid}=$type;
    $procOrderFile{$orderid}="$remoteLoc\\$file";
    $procOrderFileDate{$orderid}=timeForNum((stat("$remoteLoc\\$file"))[9]);
  }
  foreach $orderid (keys %procOrderType) {
# Type is "nwp", "inp", "err", or don" -- generate hash value based on this
    if ($procOrderType{$orderid} eq "nwp") {
      $nonProcCount++;
      $procStatusForOrder{$orderid}="QUEUED BUT NOT IN PROCESS";
    } else {
    if ($procOrderType{$orderid} eq "inp") {
      $inpCount++;
      $procStatusForOrder{$orderid}="IN PROCESS"; # in proces
    } elsif ($procOrderType{$orderid} eq "err") { # for errors, dig into log
      $errCount++;
#
# Attempt to get information from nwplog.txt file on why order failed, get last
# line in file for this order since there may have been multiples. If no matchs,
# report as unknown reason
#
      $errormsg="Error: order $orderid failed";
      $errordet=" for an unknown reason!";
      open(LOG,"<$remoteLoc\\nwplog.txt");
      while (chomp($line=<LOG>)) {
        $errordet=": $1" if $line=~/.*$orderid\.err\d+: (.*)$/;
      }
      close(LOG);
      $procStatusForOrder{$orderid}="$errormsg$errordet";
    } elsif ($procOrderType{$orderid} eq "don") {
      $donCount++;
      $procStatusForOrder{$orderid}="COMPLETED"; # done
    } # No else since can't be anything else or next would have skipped it
  }
  $numRecs=keys %procOrderFile;
  actLog("Normal","Identified $numRecs order files, $donCount done, $nonProcCount not yet in progress,$inpCount in progress, and $errCount errors.");
  
}
}


sub numForTime{
#
# Convert time in yyyymmddhh24mmss format tp single number representing seconds
# since epoch as returned by timelocal
#
  local($timeVal)=@_;
  local($sc,$mi,$hr,$md,$mon,$yr);
  ($yr,$mon,$md,$hr,$mi,$sc)=unpack "a4a2a2a2a2a2a2",$timeVal;
  $mon--;$yr-=1900; # account for month being zero based and year 1900 based
  return timelocal($sc,$mi,$hr,$md,$mon,$yr);
}


sub timeForNum{
#
# Convert time in number of seconds since epoch to yyyymmddhh24mised format
#
  local($num)=@_;
  local($sc,$mi,$hr,$md,$mon,$yr);
  ($sc,$mi,$hr,$md,$mon,$yr)=localtime($num);
  $mon++;$yr+=1900; # account for month being zero based and year 1900 based
  return sprintf("%4.4d%2.2d%2.2d%2.2d%2.2d%2.2d",$yr,$mon,$md,$hr,$mi,$sc);
}


sub analyseData{
#
# At this point, we have information about three sets of orders, those in the
# database, those with temporary (image) directories, and those in the order
# directory on the RIMAGE system.
#
# Now we look at them, one at a time and determine what to do.
#
local($dbOrder,$dis,$d,$h,$m,$s,$duration);
  foreach $dbOrder (keys %{ $activeRecords } ) {
    if ($procStatusForOrder{$dbOrder} ) { # Order in database and on RIMAGE
      if ($procStatusForOrder{$dbOrder} eq "COMPLETED") { # listed as complete!
#
# For complete orders, update database and rename order file
#
        push @Actions,"DBUPDATE,$dbOrder,COMPLETED,$procOrderFileDate{$dbOrder}";
        push @Actions,"ORDERFILERENAME,$procOrderFile{$dbOrder}";
        if ($areaForOrder{$dbOrder}) { # should exist & be removed, if not warn
          push @Actions,"REMOVEDIR,$tempBase\\$groupForOrder{$dbOrder}\\$areaForOrder{$dbOrder}\\";
        } else {
          push @Actions,"WARNING,Image directory doesn't exist for $dbOrder";
        }
      } elsif ($procStatusForOrder{$dbOrder}=~/IN PROCESS/) {
#
# For orders found in database that are currently listed as in process or queued
# but not in process on the rimage box, update the database with status but do
# not do any other updating.  Provide warning with how long (actually since last
# status check, not original queueing.)
#
        push @Actions,"DBUPDATE,$dbOrder,$procStatusForOrder{$dbOrder}";
        $duration=timeForNum(time - numForTime($activeRecords->{$dbOrder}->{status_date}) +5*60*60)-9700101000000;
        ($dis,$d,$h,$m,$s)=unpack "a6a2a2a2a2",$duration;
        $duration="$d-$h:$m:$s";
        push @Actions,"WARNING,Order $dbOrder has been $procStatusForOrder{$dbOrder} for at least $duration";
      } else {
#
# There is an error of some kind, record it in the database and issue warning
#
        push @Actions,"DBUPDATE,$dbOrder,$procStatusForOrder{$dbOrder}";
        push @Actions,"WARNING,Order $dbOrder: $procStatusForOrder{$dbOrder}";
      }
    } else {
#
# If no order exists on server, update db and warn about it
#
      push @Actions,"DBUPDATE,$dbOrder,Error: No order on server";
      push @Actions,"WARNING,Order $dbOrder: No order on server";
    }
  }
#
# For temporary image directories, warn unless there is an active database entry
#
  foreach $dirOrder (keys %volumeForOrder) {
    push @Actions,"WARNING,Directory exists for order $dirOrder but no active database entry exists"
         unless $activeRecords->{$dirOrder};
  }
#
# For order requests that don't map to active records, provide notice but don't
# do anything else.  They may have been created outsice the Contact Data Archive
# process.
#
  foreach $fileOrder (keys %procOrderFile) {
    push @Actions,"NOTICE,Order on server $procOrderFile{$fileOrder} for $fileOrder but no active database entry exists"
         unless $activeRecords->{$fileOrder}
  }
}


sub processActions{
#
# Now we have an array with the actions to take, in order.  The actions have
# two parts, the action name and any parameters.  Split this out and dynamically
# build the name of the action to call, passing it the parameters.
#
foreach $action (@Actions) {
  ($action,$params)=split(/,/,$action,2);
  &{ "proc_$action" }($params);
}
}


sub proc_DBUPDATE{
#
# Process a DBUPDATE request.  Parameters are the orderID (Required), new status
# (also required) and create date (optional if complete)
#
  local($orderId,$newstatus,$createDate)=split(/,/,$_[0]);
  
  my ($sth2, $insertOK);
# get current status, media_id from media into oldstatus, media_id;
  $getMediaForOrd = $dbh->prepare( q{
    BEGIN
        :sth2 := CRCARCH_BATCH.ARCH.GET_MEDIA_FOR_ORDER(:orderId);
    END;
  } );

  $getMediaForOrd->bind_param(":orderId", $orderId);
  $getMediaForOrd->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });
  $getMediaForOrd->execute;

  ($oldstatus,$oldCreateDate,$media_id)=$sth2->fetchrow_array;

  if ($oldstatus eq "" || $media_id eq "") {
    actLog("Error","Unable to get old status or media_id from database for order $orderId");
    return;
  }
  actLog("Normal","Identified status of $oldstatus and media id of $media_id for order $orderId");
  ###$createDate = $oldCreateDate unless $createDate; # if not passed, keep old value
  # As of 2007-06-18 all create_date values (ultimately from crc_arch_reason's
  # end_date) are 12/31/9999 so we're hardcoding it here to avoid parsing.
  # This will need to change if this date becomes meaningful in the future.
  $createDate = 99991231;
#
# update media record to newstatus, create date for this orderid, then verify
# that update was successful meening that exactly 1 record was updated.
#
  ###$updMedia_h->execute($newstatus,$createDate,$orderId);
  ###$numRowsUpd=$updMedia_h->rows;
  $insertOK = 0;  # false

  # 2007-06-15 TODO is there a performance hit for not breaking this out of this sub and calling it only once?
  $updMedia_h = $dbh->prepare( q{
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
        :insertOK := from_bool(CRCARCH_BATCH.ARCH.update_media(:orderId, :newstatus, :createDate));
     END;

  } );

  $updMedia_h->bind_param(":orderId", $orderId);
  $updMedia_h->bind_param(":newstatus", $newstatus);
  $updMedia_h->bind_param(":createDate", $createDate);
  $updMedia_h->bind_param_inout(":insertOK", \$insertOK, 32);
  $updMedia_h->execute;

  unless ( $insertOK ) {
    actLog("Error","Unable to update crc_arch_media [$orderId, $newstatus, $createDate, $insertOK]");
    exit;
  }

  actLog("Normal","Updated media status for order $orderId to $newstatus from $oldstatus");

#
# update session log record status to ARCHIVED for all records associated with
# this media id, only if disc completed.
#
  if ($newstatus eq "COMPLETED") {
    $insertOK = 0;  # false

    $updLog_h = $dbh->prepare( q{
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
          :insertOK := from_bool(CRCARCH_BATCH.ARCH.update_log(:media_id, :status));
       END;

    } );

    $updLog_h->bind_param(":media_id", $media_id);
    $updLog_h->bind_param(":status", 'ARCHIVED');
    $updLog_h->bind_param_inout(":insertOK", \$insertOK, 32);
    $updLog_h->execute;


#
# Provide warning if no rows were updated or there was an error
#
  unless ( $insertOK ) {
    actLog("Error","Unable to update crc_arch_log [$media_id, 'ARCHIVED', $insertOK, $orderId]");
    exit;
  }

  actLog("Normal","Updated log records for media id $media_id order id $orderId");
  }
}


sub proc_ORDERFILERENAME{
#
# Rename RIMAGE order file so not found next time we look for order files
#
local($orderfile)=$_[0];
local($newName);
$newName=$orderfile.".archive";
rename $orderfile,$newName;
actLog("Normal","Renamed $orderfile to $newName");
}


sub proc_REMOVEDIR{
#
# Remove the image directory and it's files, sub-directories and their files
# Warn of errors removing files.  Possible cause is open file by another process
# in directory or sub-directory.
#

local($directory)=$_[0];
$nfr=rmtree($directory,"",1);
if (-d $directory) {
  actLog("Error","While removing $directory, removed $nfr files but directory still exists");
} else {
  actLog("Normal","Removed directory $directory including $nfr files");
}
}


sub proc_WARNING{
#
# Process warning requests by logging them as warnings in the log file
#
local($warningMsg)=$_[0];
actLog("Warning",$warningMsg);
}


sub proc_NOTICE{
#
# Process Notice requests by logging them as Notices in the log file
#

local($noticeMsg)=$_[0];
actLog("Notice",$noticeMsg);
}
