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
c:\local\bin\perl.exe c:\local\bin\grpatch.bat %ARGS%
goto endofperl
@rem ';
#!/usr/local/bin/perl
#
# Send debug-trace and modified obc or pod files back to the server for
# distribution of temporary patches.
#
# 21-Nov-1996
# Mark Hewett
# Northern Telecom, RTP, NC
# Modified: Mon, 22 May 2000 14:19:43 (Bob Heckel)
# Modified: Fri, 25 Aug 2000 12:54:43 (Bob Heckel -- adapt for Net::FTP,
#                                      eliminate need for hacked ftp.pl)
# Modified: Tue, 12 Sep 2000 14:46:19 (Bob Heckel -- compartmentalize @INC,
#                                      add .pod per Mike Cook)
# Modified: Mon, 18 Sep 2000 16:34:54 (Bob Heckel -- added -s to allow
#                                      suppression of new patch notification)
# Modified: Fri 23 Mar 2001 15:00:43 (Bob Heckel -- fix logfile entries)

BEGIN 
    {
    # GRSUITE_HOME, if it exists, is used for development.
    @INC = ('C:/local/bin','C:/local/lib','C:/local/site',
            'C:/local/site/lib',$ENV{GRSUITE_HOME}); 
    }


# Allow development modules to be tested without removing production version.
if ($ENV{'PERLLIB'}) { unshift(@INC,$ENV{'PERLLIB'}); }

use Getopt::Std;
use Net::FTP;
require 'grlib.pl';
require 'grlib-auth.pl';

$GRPROG_ID = "204";
gr::minLibVersion(200);
grauth::minLibVersion(101);

$AUTHORIZED_GIDS = $AUTHORIZED_GIDS{'PATCH'};

getopts('hr:w:l:dvfxsp:');

gr::version if ($opt_v);

$ftpdebug = 1 if $opt_d;
$force    = $opt_f;
$archroot = $opt_r;
($account,$password,$server) = gr::splitACI($opt_l);

if ((! $opt_p) || ($opt_p =~ /latest/i))
    { $pchnum = 0; }
elsif ($opt_p =~ /all/i)
    { $pchnum = -1; }
elsif ($opt_p =~ /\d+/)
    { $pchnum = $opt_p; }
else
    { gr::finish(1,"[*] Patch must be a number in the range 1-99\n"); }

# first argument is required, otherwise deliver usage msg
if ((! @ARGV) || $opt_h)
	{ Usage(); }
else
	{ ($pec,$rel) = gr::splitPecrel($pecrel=$ARGV[0]); }

if (($rel eq "") || ($rel eq "DEFAULT"))
	{
	print STDERR "\n[*] You must specify a PEC and a RELEASE\n\n";
	Usage();
	}

# provide default values for options
$server   = $DEFSERVER   if ($server   eq "");
$account  = $DEFACCOUNT  if ($account  eq "");
$password = $DEFPASSWORD if ($password eq "");
$archroot = $DEFARCHROOT if ($archroot eq "");

$workdir = gr::setWorkDir($opt_w);

gr::connect($server,$account,$password,$ftpdebug);

if (! grauth::dialog("[?] Checking authorization...\n",$AUTHORIZED_GIDS))
	{ gr::finish(1,"[*] Authorization failed, aborting PATCH operation\n"); }

if ($archroot) { gr::cd($archroot); }
gr::cd($pec);
gr::cd($rel);

gr::catalog("");

if ($opt_x)
	{ removePatch(); }
else
	{ addPatch(); }

gr::disconnect;

unlink($pdfn);

exit(0);


sub addPatch
	{
	$patch_id = gr::buildPatchDesc($pec,$rel);

	# make a directory for this patch id
	if ($gr::catType{$patch_id} ne "d")
		{
		$patchdir = "patch-".$patch_id;
		gr::mkdir($patchdir);
		}

	gr::cd($patchdir);

	gr::catalog("");

	# add the patch description file to the list
	$pdfn = "patch-".$patch_id.".pdf";
	$numfiles = unshift(@PATCH_FILELIST,$pdfn);

	gr::log($gr::msgPATCH,$patch_id,$pec,$rel);

	print "[i] Patch files...\n";
	$numfiles_sent = gr::sendFiles ($pec,$rel,*PATCH_FILELIST,$workdir);

	print "[i] $numfiles_sent/$numfiles files uploaded to archive.\n";

	# have the butler server announce the new patch
	if (($numfiles_sent) && (!$opt_s))
		{ gr::butler("ANP",$pec,$rel,$patch_id,$archroot); }
	}

sub removePatch
	{
	foreach $patchdir (gr::findPatch($pchnum))
		{
		next if (! $patchdir);
		gr::rmdir($patchdir);
		print "[i] $patchdir removed.\n";
		gr::log($gr::msgDELPCH,$patchdir,$main::pec,$main::rel);
		}
	}

sub Usage
	{
	print STDERR <<"EOD";

GRPATCH creates a directory on the server and uploads a "patched" .obc or
.pod file and a corresponding .dbt file from your local working directory.
A patch description file is created containing the details about the time
and place of the patch, along with a message describing the patch.  A 
broacast notification is delivered to all Tester machines after a successful 
patch has been submitted.

Usage: grpatch [options] pecrel

  Options:
  -x         deletes the latest patch or one specified with -p
  -p number  specifies which patch to delete (valid only with -x)
  -s         suppress broadcast notification of new patch

  Standard Options:
  -h         display this message
  -r path    specify server root directory [$DEFARCHROOT]
  -w path    specify local working directory for test programs
             [$workdir]
  -l login   specify login information [$DEFACCOUNT:<password>\@$DEFSERVER]
  -d         turn debug mode on

EOD
	exit (1);
	}
__END__
:endofperl
