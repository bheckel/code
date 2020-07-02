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
rem ***** This assumes PERL is in the PATH *****
set PERL5LIB=c:\local\lib
c:\local\bin\perl.exe c:\local\bin\grrel.bat %ARGS%
goto endofperl
@rem ';
#!/usr/local/bin/perl
#
# Set the default release on a test program if the release directory exists
# and contains the required files.
#
# 25-Nov-1996
# Mark Hewett
# Northern Telecom, RTP, NC
# Modified: Mon, 22 May 2000 14:20:32 (Bob Heckel)
# Modified: Fri, 25 Aug 2000 12:54:43 (Bob Heckel -- adapt for Net::FTP,
#                                      eliminate need for hacked ftp.pl)
# Modified: Tue, 12 Sep 2000 14:46:19 (Bob Heckel -- add to @INC)
# Modified: Tue, 24 Oct 2000 12:40:16 (Bob Heckel -- modi for Net::FTP
#                                      differences)
# Modified: Tue 05 Jun 2001 15:21:29 (Bob Heckel -- add LX vs L warning)
# Modified: Thu 14 Jun 2001 09:55:22 (Bob Heckel -- rollback 6/5/01 changes)

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

$AUTHORIZED_GIDS = $AUTHORIZED_GIDS{'RELEASE'};

# parse command line switches
getopts('hr:w:l:dvxsS');

gr::version if ($opt_v);

$ftpdebug = 1 if $opt_d;
$force    = $opt_f;
$archroot = $opt_r;
($account,$password,$server) = gr::splitACI($opt_l);

# first argument is required, otherwise deliver usage msg
if ((! ($argc=@ARGV)) || $opt_h)
	{ Usage(); }
else
	{
	($pec,$rel) = gr::splitPecrel($pecrel=$ARGV[0]);
	$fixture_id = $ARGV[1] ? $ARGV[1] : 'ANY';
	$fixture_id =~ tr/a-z/A-Z/;
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

# REMOVED 06/13/01 PER MIKE COOK.
###unless ( $opt_s ) {
###  print "[i] Please be sure that any grrel request associates the\n" .
###        "[i] proper test program with the proper release.\n" .
###        "[i] \n" .
###        "[i] Example:\n" .
###        "[i]   6X21AC102 212LX     <---if you're on an LX GenRad\n" .
###        "[i]   6X21AC102 212       <---if you're not on an LX GenRad\n" .
###        "[i] \n" .
###        "[i] When gr228x later runs the '..' command, the machine type \n" .
###        "[i] will be detected.  At that point, LX machines will be given \n" .
###        "[i] the 212LX release and non LX machines will be given the \n" .
###        "[i] 212 release.\n" .
###        '[?] Continue the GRREL operation? [y]/n ';
###  my $ok = <STDIN>; chomp $ok;
###  gr::finish(0, "[*] Operation canceled by user.\n") 
###                                              if $ok =~ /^no?/i;
###}

gr::connect($server,$account,$password,$ftpdebug);

if (! grauth::dialog("[?] Checking authorization...\n",$AUTHORIZED_GIDS))
	{ gr::finish(1,"[*] Authorization failed, aborting RELEASE operation\n"); }

if ($archroot)
    { $pecroot = $archroot."/".$pec; }
else
    { $pecroot = $pec; }

gr::cd($pecroot);

# catalog the current directory and check for the release
gr::catalog("");
if ($gr::catType{$rel} ne "d")
	{
	print STDERR "[*] Release directory \'$rel\' does not exist\n";
	exit(1);
	}

if ($opt_x)
	{
	gr::removeDefaultRelease($rel,$fixture_id);
	print "[i] Default release for $pec on Fixture#$fixture_id deleted\n";
	}
else
	{
	# now catalog the release directory and check for required files
    gr::cd($rel);
	gr::catalog($rel);
    # move back to pec's toplevel dir so that release.dat can be written.
    gr::cd($pecroot);
	$fc = 0;

	# check existence of all run-time files
	$rfc = @TEST_FILELIST;
	foreach $item (@TEST_FILELIST)
		{
		$pfile = gr::formatFileSpec($item,$pec,$rel);

		if (($gr::catSize{$pfile}) || ($FILE_OPTIONS{$item} =~ /OPTIONAL/i))
			{ $fc++; }
		else
			{
			print STDERR "[*] required file \'$pfile\' is missing from archive\n";
			}
		}

	# check existence of all development (source) files
	#$rfc += @SRC_FILELIST;
	#foreach $item (@SRC_FILELIST)
	#	{
	#	$pfile = &gr'formatFileSpec($item,$pec,$rel);
	#
	#	if ($gr'catSize{$pfile})
	#		{ $fc++; }
	#	else
	#		{
	#		print STDERR "[*] required file \'$pfile\' is missing from archive\n";
	#		}
	#	}

	# scream and die if any files are missing
	if (($fc != $rfc) && (! $force))
		{ gr::finish(1,"[*] Failed to change default release for $pec\n"); }

	gr::setDefaultRelease($rel,$fixture_id);
	print "[i] Default release for $pec on Fixture#$fixture_id is now $rel \n";
	gr::butler("ANR",$pec,$rel) if (!$opt_S);
	}

gr::disconnect;

exit (0);

sub Usage
	{
	print STDERR <<EOD;

GRREL sets or removes the default test program release for a given PEC code
and fixture ID.  The default release is retrieved by GRGET whenever the test
program release is not specified (eg. "grget 4k67ac 248").  If the fixture ID
is omitted from the GRREL command, the program is released for 'ANY' fixture.

Usage: grrel [options] pecrel [fixture_id]

  Options:
  -x         remove the specified release data
  -S         suppress popup announcement broadcast

  Standard Options:
  -h         display this message
  -r path    specify server root directory [$DEFARCHROOT]
  -l login   specify login information [$DEFACCOUNT:<password>\@$DEFSERVER]
  -d         turn debug mode on

EOD
	exit (1);
	}
__END__
:endofperl
