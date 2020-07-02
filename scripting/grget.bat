@rem = '--*-PERL-*--';
@rem = '
@echo off
rem setlocal
set ARGS=
:loop
if .%1==. goto endloop
set ARGS=%ARGS% %1
shift
goto loop
:endloop
rem ***** This does not assume PERL is in the PATH *****
set PERL5LIB=c:\local\lib
c:\local\bin\Perl.exe c:\local\bin\grget.bat %ARGS%
goto endofperl
@rem ';
#!/usr/local/bin/perl
#
# Retrieve test program files from archive server via FTP
#
# 21-Nov-1996
# Mark Hewett
# Northern Telecom, RTP, NC
# Modified: 14-Apr-2000 (Bob Heckel -- CAD files are retrieved from their own
#                        directory ../cad now)
# Modified: 17-Apr-2000 (Bob Heckel -- increase security, no
#                        longer allow source to be automatically
#                        downloaded. Require -t and then authenticate)
# Modified: 06-Jun-2000 (Bob Heckel -- force authentication for
#                        all requests for source)
# Modified: Fri, 25 Aug 2000 12:54:43 (Bob Heckel -- adapt for Net::FTP,
#                                      eliminate need for modified ftp.pl)
# Modified: Tue, 12 Sep 2000 14:43:59 (Bob Heckel -- add to @INC, cleanup)
# Modified: Mon, 23 Oct 2000 12:29:25 (Bob Heckel -- prevent gr228x from 
#                                      specifying release at a DOS prompt)
# Modified: Thu, 26 Oct 2000 16:17:10 (Bob Heckel -- protect single file
#                                      transfers from network disruptions)
# Modified: Wed, 15 Nov 2000 12:50:11 (Bob Heckel -- allow gr228x to grget
#                                      specific release (w/o authorization)
#                                      if and only if it is the default
#                                      release)
# Modified: Thu, 28 Dec 2000 14:10:35 (Bob Heckel -- fix bug that prevented
#                                      patch files from downloading)
# Modified: Fri 27 Apr 2001 12:54:17 (Bob Heckel -- allow access to grbch.bat
#                                     so that individual .bch files can
#                                     be retrieved)
# Modified: Tue 22 May 2001 08:37:26 (Bob Heckel -- auto detection of testers,
#                                     i.e. LX or non-LX, to allow the proper 
#                                     release to automatically be retrieved,
#                                     assuming a grrel has been performed
#                                     previously e.g. grrel swtest 555LX)
# Modified: Wed 13 Jun 2001 10:51:42 (Bob Heckel -- reversed auto detection
#                                     changes per Mike Cook.  Added read-only
#                                     protection)
# Modified: Fri 13 Jul 2001 13:58:27 (Bob Heckel -- dot-dot will retrieve .tpg)
# Modified: Thu 23 Aug 2001 11:14:00 (Bob Heckel -- when workdir is \boards,
#                                     force .inv contents up one level, 
#                                     normally to \users\gr228x\)

BEGIN 
    {
    # GRSUITE_HOME, if it exists, is used for development.
    @INC = ('C:/local/bin','C:/local/lib','C:/local/site',
            'C:/local/site/lib','C:/local/lib/Getopt',$ENV{GRSUITE_HOME}); 
    }

# Allow development modules to be tested without removing production version.
if ($ENV{'PERLLIB'}) { unshift(@INC,$ENV{'PERLLIB'}); }

use Getopt::Std;
require 'grlib.pl';
require 'grlib-auth.pl';

$GRPROG_ID="206";
gr::minLibVersion(200);
gros::minLibVersion(104);
grauth::minLibVersion(101);

# parse command line switches
getopts('hr:w:l:dvtfgp:');

gr::version() if ($opt_v);

$ftpdebug   = 1 if $opt_d;
$force      = $opt_f || $opt_g;
$gold       = $opt_g;
$archroot   = $opt_r;
$singlemode = 0;	# single file transfer mode flag
($account,$password,$server) = gr::splitACI($opt_l);

if ((! $opt_p) || ($opt_p =~ /latest/i))
    { $reqpch = 0; }
elsif ($opt_p =~ /all/i)
    { $reqpch = -1; }
elsif ($opt_p =~ /\d+/)
    { $reqpch = $opt_p; }
else
    { gr::finish(1,"[*] Patch must be a number in the range 1-99\n"); }

# First argument is required, otherwise deliver usage msg.
if ((! ($argc=@ARGV)) || $opt_h)
    { Usage(); }
else
    {
    if ($ARGV[0] =~ /\d+\.bch$/i)    # if it looks like a bch request
       {
       # Assumes grbch.bat is on PATH.
       system("grbch.bat -g $ARGV[0]") 
             && die "\n[*] Failed to run grbch.bat.  Is it on your PATH?\n" .
                    "[*] Try running the latest Service Pack (search\n" .
                    "[*] intranet for 'genrad') if the problem persists.\n";   
       # Additional error handling is provided by grbch.bat.
       exit;
       }
    # Ignore user input if they ask for an L or an LX.  An L will only work on
    # an L anyway (same for LX).  What matters is that the machine is detected
    # as an L or LX and release.dat can handle a fixture id like 555LX.
    # REMOVED 06/13/01 PER MIKE COOK.
    ###$ARGV[1] =~ s/LX?//i if $ARGV[1];
    $fixture_id = gros::fixture_chooser($ARGV[1] ? $ARGV[1] : 'ANY', $ARGV[0]);
    # REMOVED 06/13/01 PER MIKE COOK.
    ###$fixture_id =~ s/ANYLX/ANY/;  # cleanup "No release data for Fixture#ANY"
    $fixture_id =~ tr/a-z/A-Z/;
    $pecrel = gros::chooser($ARGV[0],$fixture_id);
    ($pec,$rel,$forcetype) = gr::splitPecrel($pecrel);
    }

# Provide default values for options.
$server   = $DEFSERVER   if ($server   eq "");
$account  = $DEFACCOUNT  if ($account  eq "");
$password = $DEFPASSWORD if ($password eq "");
$archroot = $DEFARCHROOT if ($archroot eq "");

$workdir = gr::setWorkDir($opt_w);
# If working out of \boards (e.g. user is gr228x), force the d/l of contents
# of the .inv file up one level above the \boards or /boards directory
# (usually \users\gr228x\).
if ( $workdir =~ m#[/\\]boards# ) {
  $invdir = $1 if $workdir =~ m|(.*[/\\:])+[^/\\:]+$|;
  $invmsg = "[i] Inventoried files (downloaded to $invdir)...\n";
} else {  # workdir is not \boards (e.g. user is an engineer)
  $invdir = $workdir;
  $invmsg = "[i] Inventoried files...\n";
}

gr::connect($server,$account,$password,$ftpdebug);

# New security model requires authorization for ANYONE requesting the source
# files.
if ($opt_t || ($forcetype eq "tpg") || isMemberOf($forcetype, @SRC_FILELIST))
    {
    if (! grauth::dialog("[?] Checking authorization...\n",$AUTHORIZED_GIDS,
                          $opt_t))
        { gr::finish(1,"[*] Authorization failed, aborting GET operation\n"); }
    }

if ($archroot)
    { $pecroot = $archroot.$FS.$pec; }
else
    { $pecroot = $pec; }

# cd to the specified PEC directory
gr::cd($pecroot);

$defrel = gr::getDefaultRelease($fixture_id);
# Forcing release as gr228x is not allowed without authorization unless you're
# forcing the default release.  11/15/00 per Mike Cook.
if ($rel ne "DEFAULT" and $rel ne $defrel and $main::USER eq $main::TEST_ACCOUNT 
                                                        and !$grauth::authentic) 
     { 
     if (! grauth::dialog("[?] Checking authorization...\n",
                                                 $AUTHORIZED_GIDS, $opt_t) ) 
          {
        gr::finish(1,"[*] Authorization failed, aborting GET operation\n");
         }
     }

if ($rel eq "DEFAULT") 
    {
    if (($rel = $defrel) !~ /NONE/)
        { 
        # Cleanup for display.  User didn't key an L or LX, it was appended
        # silently by the tester detection.
        # REMOVED 06/13/01 PER MIKE COOK.
        ###($fixid_short = $fixture_id) =~ s/LX?$//;
        ###print "[i] Default release for Fixture#$fixid_short is \'$rel\'\n"; 
        print "[i] Default release for Fixture#$fixture_id is \'$rel\'\n"; 
        }
    else
        { gr::finish(1,"[*] No release data for Fixture#%s\n",$fixture_id); }
    }

# cd to the release directory
gr::cd($rel);

# get a listing of files here and their attributes
gr::catalog("");
gr::displayCatalog() if ($opt_d);

%gr::FileTrace = ();
if ($forcetype eq "")
    {
    print "[i] Run-time files...\n";
    $numfiles = @TEST_FILELIST;
    $numfiles_rcvd = gr::retrieveFiles($pec,$rel,*TEST_FILELIST,$workdir);

    # All machines will receive a .tpg during dot-dot.  It will translated on
    # the fly.  The .obc on the server is now irrelevant.  It will be
    # recreated dynamically during each dot-dot.
    # DOS window will properly vanish at end of this pgm.
    ###local $is_an_LX = gros::detectTester();
    ###if ($is_an_LX && $ENV{GR_FROMBATCH})
    if ($ENV{GR_FROMBATCH})
        {
        local $tpgfile = $pec.$rel.'.tpg';
        # TODO don't hardcode.
        gr::getTextFile($tpgfile,'c:\temp\translate.tpg');
        }

     # Make sure everyone, including administrator, is forced to authenticate.
    if ($opt_t)
        {
        print "[i] Source files...\n";
        $numfiles += @SRC_FILELIST;
        $numfiles_rcvd += gr::retrieveFiles($pec,$rel,*SRC_FILELIST,$workdir);
        }

    # find any inventory files in the run-time file list
    foreach $item (@TEST_FILELIST)
        {
        if ($FILE_OPTIONS{$item} =~ /INVENTORY/i)
            {
            # Non-CAD inv files:
            # If workdir is not the boards dir, do normal grget:
            print $invmsg;
            @fileList = gr::readInventory($pec, $rel, $item, $workdir);
            $numfiles += @fileList;
            # CAD files explicitly skipped in retrieveFiles() because they
            # reside in ../cad
            $numfiles_rcvd += gr::retrieveFiles($pec,$rel,*fileList,
                                                    $invdir);

            print "[i] CAD files...\n";
            @fileListCAD = gr::readInventory($pec, $rel, $item, $workdir);
            $numfiles += @fileListCAD;
            $numfiles_rcvd += gr::retrieveCADFiles($pec,$rel,*fileListCAD,
                                                       $workdir,$archroot);
            # Make sure transfer was not interrupted.
            gr::sizeIntegrity();
            }
        }
    }
else
    {
    @FILELIST = (".".$forcetype);
    print "[i] Single file transfer...\n";
    $numfiles = 1;
    $numfiles_rcvd = gr::retrieveFiles ($pec,$rel,*FILELIST,$workdir);
    $singlemode = 1;
    $singlefilename = $pec . $rel . '.' . $forcetype;
    # Make sure transfer was not interrupted.
    gr::sizeIntegrity($singlefilename);
    }

# Look for patch directories unless otherwise directed by invoking "gold"
# mode.
if (! ($gold || $singlemode))
    {
    foreach $patchdir (gr::findPatch($reqpch))
        {
        next if (! $patchdir);
        print "[i] Patch files...\n";

        $pdf = $patchdir . '/' . $patchdir . '.pdf';
        $tmpfile = join($FS,$TEMPDIR,"grget$$.tmp");
        if (gr::getTextFile($pdf,$tmpfile))
            {
            ($pchdate,$oneliner) = gr::summarizePdf($tmpfile);
            print "[i]  $patchdir created $pchdate\n";
            print "[i]  Msg=$oneliner\n";

            @TEMP_FILELIST = @PATCH_FILELIST;

            if ($reqpch < 0)
                {
                ($pchnum) = ($patchdir =~ /patch-(\d+)$/i);
                $destFileFormat = sprintf("%%NAME%%-p%02d.%%TYPE%%",$pchnum);
                push (@TEMP_FILELIST,$pdf);
                }
            else
                { $destFileFormat = ""; }

            $numfiles += @TEMP_FILELIST;
            # Re-catalog and cd, otherwise get the non-patch directory's
            # contents.
            gr::catalog($patchdir);
            gr::cd($patchdir);
            $numfiles_rcvd += gr::retrieveFiles($pec,
                                                $rel,
                                                *TEMP_FILELIST,
                                                $workdir,
                                                $destFileFormat);
            unlink ($tmpfile);
            }
        else
            { print STDERR ("[*] Cannot get patch description file\n"); }
        }
    }

print "[i] $numfiles_rcvd/$numfiles files downloaded from archive.\n";

if (! $singlemode)
    {
    # Now prepare the batch file for loading this program.
    $batfile = $workdir.$FS.$pec.".bat";
    $bchfile = $workdir.$FS.$pec.".bch";
    $lnkfile = $workdir.$FS."grload.bch";
    if (-f $batfile)
        {
        $identifier{'PEC'}      = $pec;
        $identifier{'RELEASE'}  = $rel;
        $identifier{'PROGNAME'} = $pec.$rel;

        if (gr::tokenReplace($batfile,$bchfile,*identifier))
            {
            print "[i] Batch load file $pec.bch prepared for use.\n";
            gros::symlink($bchfile, $lnkfile);
            }
        else
            { print "[*] Batch load file $pec.bch may contain the wrong release.\n"; }
        }
    }

# Certain .bat files on the grserver have been adjusted to translate the tpg
# as an L or an LX and delete it after translation.  This code is added
# protection to avoid editing any .tpg files that are not automatically
# deleted by the .bat file.
system("attrib +R c:/temp/translate.tpg >nul");
local $batfile = $workdir.$FS.$pec.".bat";
system("attrib +R $batfile >nul");

gr::disconnect();

# Call the finish routine to generate a pause.
gr::finish(0,"");

exit; # finish doesn't return, this is just for looks...


# ---------------------------- subroutines ----------------------------

# Determines if requested file is a member of the known source list.
sub isMemberOf 
  {
  my $forcetype = shift;
  my(@sourcefile_extensions) = @_;
  
  $forcetype = uc($forcetype);
  foreach $ext (@sourcefile_extensions) 
    {
    $ext = '.' . uc($ext);
    return(1) if ($ext eq $forcetype);
    }
  }


# REMOVED 06/13/01 PER MIKE COOK.
###If a fixture_id is specified and this machine is an L, the desired fixture_id
###will be retrieved.
###
###If a fixture_id is specified and this machine is an LX, the requested
###fixture_id will silently be combined with with an LX suffix.  If the search
###for an LX-suffixed release is not successful, the suffix-less number will be
###used.  E.g. if 123LX has not been grrel(eased), release 123 will be used.
sub Usage
    {
    print STDERR <<EOD;

GRGET downloads test program files from the server for a particular PEC code.

If no test program release is specified, it gets the current default release.  

If no fixture_id is specified, it gets the current default release for fixture
"ANY".  

Also performs single file bch file downloads.  If the requested file has a
.bch extension, that fixture file will be downloaded.  E.g. grget 211.bch

Usage: grget [options] pec[rel[.filetype]] [fixture_id]

  Options:
  -t         force source download
  -f         force overwrite of local files regardless of dates (CAREFUL!)
  -g         get "gold" version only without patches (implies -f)
  -p number  get a specific patch number, or specify 'all' to retrieve
             all patch files using unique filenames for each one

  Standard Options:
  -h         display this message
  -r path    specify server root directory [$DEFARCHROOT]
  -w path    specify local working directory to receive files
             [$workdir]
  -l login   specify login information [$DEFACCOUNT:<password>\@$DEFSERVER]
  -d         turn debug mode on

EOD
    exit (1);
    }

__END__
:endofperl
if defined GR_FROMBATCH exit
