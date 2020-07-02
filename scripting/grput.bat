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
c:\local\bin\perl.exe c:\local\bin\grput.bat %ARGS%
goto endofperl
@rem ';
#!/usr/local/bin/perl
#
# Upload a test program and all related files to the archive server.
#
# 21-Nov-1996
# Mark Hewett
# Northern Telecom, RTP, NC
# Modified: 22-May-2000 (Bob Heckel -- CAD files reside in separate directory
#                        to avoid duplication within the release directories)
# Modified: 06-Jun-2000 (Bob Heckel -- elim $srcmode)
# Modified: Fri, 25 Aug 2000 12:54:43 (Bob Heckel -- adapt for Net::FTP,
#                                      eliminate need for hacked ftp.pl)
# Modified: Tue, 12 Sep 2000 14:46:19 (Bob Heckel -- add to @INC)
# Modified: Fri, 20 Oct 2000 14:23:55 (Bob Heckel -- catch network failures)
# Modified: Fri 27 Apr 2001 12:54:17 (Bob Heckel -- allow access to grbch.bat
#                                     so that individual .bch files can
#                                     be uploaded)
# Modified: Tue 22 May 2001 14:22:19 (Bob Heckel -- warn user that PUTs should
#                                     be carefully performed w.r.t. L vs. LX)
# Modified: Fri 25 May 2001 11:15:51 (Bob Heckel -- warn user if a patch
#                                     exists for the pec being grput)
# Modified: Tue 05 Jun 2001 15:57:09 (Bob Heckel -- change L vs LX user 
#                                     warning)
# Modified: Thu 14 Jun 2001 13:04:16 (Bob Heckel -- reverse L vs LX changes)

# $Id$

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
use Carp;
require 'grlib.pl';
require 'grlib-auth.pl';

$GRPROG_ID = "207";
gr::minLibVersion(204);
grauth::minLibVersion(101);

$AUTHORIZED_GIDS = $AUTHORIZED_GIDS{'PUT'};

getopts('hr:w:l:dvtfgp:s');

gr::version if ($opt_v);

$ftpdebug = 1 if $opt_d;
$force    = $opt_f;
$archroot = $opt_r;
# 06/05/00 No longer using, all upload/download of source files require
# authentication.
($account,$password,$server) = gr::splitACI($opt_l);

# first argument is required, otherwise deliver usage msg
if ((! ($argc=@ARGV)) || $opt_h)
	{ Usage(); }
else
	{ 
    if ($ARGV[0] =~ /\d+\.bch/)    # if it looks like a bch request
       {
       chomp($ARGV[0]);
       system("grbch.bat -p $ARGV[0]");  # assumes grbch.bat is on user's PATH
       exit(0);
       }
    ($pec,$rel,$forcetype) = gr::splitPecrel($pecrel=$ARGV[0]); 
    }

if (($rel eq "") || ($rel eq "DEFAULT"))
	{
	print STDERR "[*] You must specify a release\n\n";
	Usage();
	}

# provide default values for options
$server   = $DEFSERVER   if ($server   eq "");
$account  = $DEFACCOUNT  if ($account  eq "");
$password = $DEFPASSWORD if ($password eq "");
$archroot = $DEFARCHROOT if ($archroot eq "");

$workdir  = gr::setWorkDir($opt_w);

# check rules for compliance
if ($wcnt = checkPutRules($pec,$rel,$forcetype))
	{
	print "[*] There were ($wcnt) warnings!\n";
	print "[?] Continue the PUT operation? y/[n] ";
	$answer=<STDIN>;
	if ($answer !~ /^y/i) { gr::finish(1,"[*] PUT aborted.\n"); }
	}

# REMOVED 06/13/01 PER MIKE COOK.
###unless ($opt_s)
###    {
###    print "[i] Please be sure that this grput request places the\n" .
###          "[i] proper (L or LX) test program with the proper release.\n" .
###          "[i] \n" .
###          "[i] Example:\n" .
###          "[i]   grput 6X21AC108   <---relates to an LX test program\n" .
###          "[i]                     because it was released like this:\n" .
###          "[i]                     c:> grrel 6X21AC108 212LX\n" .
###          "[i]   grput 6X21AC109   <---relates to an L test program\n" .
###          "[i]                     because it was released like this:\n" .
###          "[i]                     c:> grrel 6X21AC109 212\n" .
###          "[i] \n" .
###          "[i] How it was release can be determined by:\n" .
###          "[i] c:> grls 6X21AC108\n" .
###          "[i] \n" .
###          "[i] When gr228x later runs the '..' command, the machine type \n" .
###          "[i] will be detected.  At that point, LX machines will receive \n" .
###          "[i] the 212LX release and non LX machines will receive the \n" .
###          "[i] 212 release.\n" .
###          '[?] Continue the GRPUT operation? [y]/n ';
###    my $ok = <STDIN>; chomp $ok;
###    gr::finish(0, "[*] Operation canceled by user.\n") 
###                                                  if $ok =~ /^no?/i;
###    }

gr::connect($server,$account,$password,$ftpdebug);

if (! grauth::dialog("[?] Checking authorization...\n",$AUTHORIZED_GIDS))
	{ gr::finish(1,"[*] Authorization failed, aborting PUT operation\n"); }

if ($archroot) { gr::cd($archroot); }

gr::catalog("");

if ($gr::catType{$pec} eq "d")
	{ print "[i] PEC directory \'$pec\' already exists\n"; }
else
	{ gr::mkdir($pec); }

gr::cd($pec);
gr::catalog("");

if ($gr::catType{$rel} eq "d")
	{ print "[i] Release directory \'$rel\' already exists\n"; }
else
	{ gr::mkdir($rel); }

# CADfiles reside in $pec/cad
if ( exists $gr::catType{'cad'} )
	{ print "[i] CAD file directory \'cad\' already exists\n"; }
else
	{ gr::mkdir('cad'); }

gr::cd($rel);
gr::catalog("");

# Alert user that patch dir(s) exist which will effectively render his changes
# invisible on '..' requests.  '..' does a grget -f which uses the highest
# numbered patch to overwrite the gold files that grput downloads first.
foreach $name (keys %gr::catType)
    {
    if (($gr::catType{$name} eq "d") && ($name =~ /^patch/))
        {
            unless ($opt_s)
                {
                print "\n[i] Warning: $pec$rel has been patched.\n";
                print "[i] Therefore grget run via '..' will use the\n";
                print "[i] patched files in preference to the file(s)\n";
                print "[i] you are currently uploading.\n";
                print "[?] Continue the PUT operation? y/[n] ";
                my $ok = <STDIN>; chomp $ok;
                gr::finish(0, "[*] Operation canceled by user.\n") 
                                                       if $ok !~ /^y|^yes/i;
                last;     # finding just one patch dir is enough
               }
        }
    }

%gr::FileTrace = ();
if ($forcetype eq "")
	{
	print "[i] Run-time files...\n";
	$numfiles = @TEST_FILELIST;
	$numfiles_sent = gr::sendFiles ($pec,$rel,*TEST_FILELIST,$workdir);

	print "[i] Source files...\n";
	$numfiles += @SRC_FILELIST;
	$numfiles_sent += gr::sendFiles ($pec,$rel,*SRC_FILELIST,$workdir);

	# find any inventory files in the run-time file list
	foreach $item (@TEST_FILELIST)
		{
		if ($FILE_OPTIONS{$item} =~ /INVENTORY/i)
			{
            # Non-CAD inv files.
			print "[i] Inventoried files...\n";
			@fileList = gr::readInventory($pec, $rel, $item, $workdir);
            # Assumes that grget was performed as gr228x and the .inv
            # referenced files to send are in c:\users\gr228x\
            if ($main::workdir =~ m#gr228x[/\\]boards#)
                 {
                 # Uniquely (temporarily) identify .inv referenced files.
                 @fileList = grep { s/^/INVFLAG/ } @fileList;
                 }
			$numfiles += @fileList;
            # CAD files explicitly skipped in sendFiles() because they
            # reside in ../cad
			$numfiles_sent += gr::sendFiles($pec,$rel,*fileList,$workdir);
			
			print "[i] CAD files...\n";
			(@fileListCAD) = gr::readInventory($pec, $rel, $item, $workdir);
			$numfiles += @fileListCAD;
			$numfiles_sent += gr::sendCADFiles($pec,$rel,*fileListCAD,
                                                   $workdir,$archroot);
			}
		}
	}
else
	{
	@FILELIST = (".".$forcetype);
	print "[i] Single file transfer...\n";
	$numfiles = 1;
	$numfiles_sent = gr::sendFiles($pec,$rel,*FILELIST,$workdir);
	}

print "[i] $numfiles_sent/$numfiles files uploaded to archive.\n";

gr::sizeIntegrity();
gr::disconnect();

print "\n[i] Cleanup local files...\n";
gr::cleanFiles($pec,$rel,*CLEAN_FILELIST,$workdir);

exit;

# ---------------------- subroutines -----------------------------

sub checkPutRules
	{
	# Check to see if there are missing files or modification-date
	# inconsistencies.  Report all violations and return the number
	# of violations.  It is left up to the caller to determine if
	# a non-zero violation count is fatal.
	#
	# It would be nice to specify the archival rules in the config
	# file but for now they're hard-coded.

	local($pec,$rel,$sft) = @_;

	$warnings = $sft_on_list = 0;

	# check existence and save stats
	foreach $item (@TEST_FILELIST,@SRC_FILELIST)
		{
		($exists,$size,$date,$name,$type) = gr::statFile($item,$pec,$rel);
		if ($exists)
			{
			($size{$type},$date{$type}) = ($size,$date);
			}
		else
			{
			$warnings++;
			print "[*] WARNING, \"$name.$type\" does not exist\n";
			}

		$sft_on_list += ($sft eq $type);
		}

	# stat the dbt file separately since it isn't likely to be on the 
	# test or source lists processed above
	($dbt_exists,$size{'dbt'},$date{'dbt'},$name,$type) =
		gr::statFile(".dbt",$pec,$rel);

	if ($sft)
		{
		($sft_exists,$size{$sft},$date{$sft},$name,$type) =
			gr::statFile(".$sft",$pec,$rel);

		if (! $sft_exists)
			{ gr::finish(1,"[*] ERROR, \"$name.$type\" does not exist\n"); }
		
		if ($sft_on_list)
			{
			$warnings++;
			print "[*] WARNING, \".$sft\" files are not usually uploaded individually\n";
			}
		else
			{ return $warnings; }
		}

	# check for non-empty debug-trace file newer than source program
	if ($size{'dbt'} > 0)
		{
		if ($date{'dbt'} > $date{'tpg'})
			{
			$warnings++;
			print "[*] WARNING, recent debug trace(DBT) exists\n";
			print "[*] Have the changes been incorporated in the source(TPG)?\n";
			}
		}
	
	# check for source program newer than the translated binary object
	if ($date{'tpg'} > $date{'obc'})
		{
		$warnings++;
		print "[*] WARNING, source(TPG) is newer than object(OBC)\n";
		print "[*] Has the source been translated?\n";
		}

	return $warnings;
	}

 
sub checkForPatches
    {
    my ($pec, $rel) = @_;

    my $patch_rel = undef;
    my $dirpath   = $DEFARCHROOT . $pec . '/' . $rel;

    gr::catalog();

    return $patch_rel;
    }


sub Usage
	{
	print STDERR <<EOD;

GRPUT uploads the test program files, for a specified PEC and test program
release, to the archive server.

Usage: grput [options] pecrel[.filetype]

Also performs single file bch file uploads.  If the file has a .bch 
extension, that fixture file will be uploaded.  E.g. grput 211.bch

  Options:
  -f         force overwrite of local files regardless of date (CAREFUL!)
  -s         silent - avoid upload warnings

  Standard Options:
  -h         display this message
  -r path    specify server root directory [$DEFARCHROOT]
  -w path    specify local working directory for test programs
             [$workdir]
  -l login   specify login information [$DEFACCOUNT:<password>\@$DEFSERVER]
  -d         turn debug mode on

EOD
	exit(1);
	}

__END__
:endofperl
