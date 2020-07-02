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
rem ***** This does not assume Perl.exe is in the PATH *****
set PERL5LIB=c:\local\lib
c:\local\bin\Perl.exe c:\local\bin\grbch.bat %ARGS%
goto endofperl
@rem ';
#!/usr/local/bin/perl
#
# Upload/download bch programs (one or many at a time) to/from GenRad Test
# Archive server.  Upon initial installation of the Custom GenRad
# Applications, this program is called by the installer executable like this: 
#            grbch.bat -sa c:\users\gr228x\boards\
#
# This program will usually be called indirectly from grget.bat
#
#  Created: Wed 25 Apr 2001 11:13:06 (Bob Heckel)
# Modified: Mon 30 Apr 2001 10:57:42 (Bob Heckel)

BEGIN 
    {
    # GRSUITE_HOME, if it exists, is used for development.
    @INC = ('C:/local/bin','C:/local/lib','C:/local/site',
            'C:/local/site/lib','C:/local/lib/Getopt',$ENV{GRSUITE_HOME}); 
    }

# Allow development modules to be tested without removing production version.
if ($ENV{'PERLLIB'}) { unshift(@INC,$ENV{'PERLLIB'}); }

use Getopt::Std;
use constant BCHDIR => '/bch/';  # subdir in /gr8xprog tree
require 'grlib.pl';
require 'grlib-auth.pl';


$GRPROG_ID = '200';    # this pgm's version
gr::minLibVersion(200);
gros::minLibVersion(104);
grauth::minLibVersion(101);

getopts('hvdasw:r:g:p:');

gr::version() if $opt_v;

# Globals.
$ftpdebug = 1 if $opt_d;
$archroot = $opt_r;
$workdir  = gr::setWorkDir($opt_w);
($account,$password,$server) = gr::splitACI($opt_l);
# Provide default values for options.
$server   = $DEFSERVER   if ($server   eq "");
$account  = $DEFACCOUNT  if ($account  eq "");
$password = $DEFPASSWORD if ($password eq "");
$archroot = $DEFARCHROOT if ($archroot eq "");
$bchdir   = $archroot . BCHDIR;

# Some switch is required, otherwise deliver usage msg.
Usage() unless ($opt_a || $opt_g || $opt_p || $opt_h);

# Error checking is handled in grlib.pl.
gr::connect($server,$account,$password,$ftpdebug);

grauth::dialog() if $opt_p;

# cd to the specified PEC directory.  Error checking is handled in grlib.pl.
gr::cd($bchdir);

# Get a listing of files here and their attributes.
gr::catalog("") 
            || gr::finish(1, "[*] Error: Can\'t catalog remote directory.\n");

gr::displayCatalog() if ($opt_d);

my $n = 0;
if ($opt_a)
   {
   ($n=getBchFile('all')) && successMsg('downloaded', $n)
              || gr::finish(1, "[*] Error: no .bch files were downloaded\n");
   }
elsif ($opt_g)
   {
   ($n=getBchFile($opt_g)) && successMsg('downloaded', $n)
              || gr::finish(1, "[*] Error: no .bch files were downloaded\n");
   }
elsif ($opt_p)
   {
   ($n=putBchFile($opt_p)) && successMsg('uploaded', $n)
              || gr::finish(1, "[*] Error: no .bch files were uploaded\n");
   }
else   # technically, an "impossible" condition
   {
   Usage();
   }

gr::disconnect();

gr::finish(0,"");

exit; # finish doesn't return, this is just for looks...


# ---------------------------- subroutines ----------------------------

# Returns zero on failure, number of files retrieved otherwise.
sub getBchFile
   {
   my $fname = shift;

   my $numfiles_rcvd = 0;

   if ($fname ne 'all')
       {
       $numfiles_rcvd = singleGet($fname);
       }
   # Get the most recent collection of _all_ .bch files on server.
   else
       {
       $numfiles_rcvd = multipleGet();
       }

   %gr::catType = ();

   $main::fc_download = $numfiles_rcvd;   # logfile indicator

   return $numfiles_rcvd;
   }


sub singleGet 
    {
    my $fname = shift;

    if (-f $fname)   # may have to warn user about overwrites
       {
       # Silent overwriting requested by user.
       unless ($opt_s)
           {
           if (isNewer($fname, 'get'))   # than file on server
              {
              print "[?] File on this machine is newer than the server's\n";
              print "[?] version.  Overwrite local copy? y/[n] ";
              # Ask user if ok to overwrite his newer local copy.
              unless (<STDIN> =~ /^y|^yes|^ok/i)
                 {
                 userDeclines();
                 return 0;
                 }
              }
           }
       }

   return $numfiles_rcvd += gr::getTextFile($fname, "$workdir\\$fname");
   }


# Retrieve 'all' bch files from server.
sub multipleGet 
    {
     # Silent overwriting requested by user.
     if ($opt_s)
        {
        for (keys %gr::catType)
           {
           next unless m/bch$/;
           $numfiles_rcvd += gr::getTextFile($_, "$workdir\\$_");
           }
        }
     else
        {
        print "[?] This download may overwrite local .bch\n";
        print "[?] files in $workdir.  Continue? y/[n]";
        if (<STDIN> =~ /^y|^yes|^ok/i)
           {
           print "\n[i] Downloading...this may take a few minutes...\n";
           for (keys %gr::catType)
               {
               next unless m/bch$/;
               $numfiles_rcvd += gr::getTextFile($_, "$workdir\\$_");
               }
            }
         else
            {
            userDeclines();
            }
        }

    return $numfiles_rcvd;
    }


# Always single file uploading.  Returns zero on failure.
sub putBchFile
    {
    my $numfiles_put = 0;

    if (-f $opt_p)      # may have to warn user about overwrites
        {
        if ($opt_s)
           {
           $numfiles_put += gr::putTextFile($opt_p, $opt_p);
           }
        else
           {
           if (isNewer($opt_p, 'put'))
              {
              print "[?] File on server is newer than yours.  Overwrite\n";
              print "[?] server's version? [no]\n";
              if (<STDIN> =~ /^y|^yes|^ok/i)
                  {
                  $numfiles_put += gr::putTextFile($opt_p, $opt_p);
                  }
              else
                  {
                  userDeclines();
                  }
              }
           else
              {
              $numfiles_put += gr::putTextFile($opt_p, $opt_p);
              }
           }
        }

	$main::fc_upload++;

    return $numfiles_put;
    }


# Is one file going to overwrite a newer one.
sub isNewer
   {
   my $file       = shift;
   my $trans_type = shift;

   my $localdate = gr::trimSeconds((stat($file))[9]);

   if ($trans_type eq 'put')
       {
       ($localdate >= $gr::catDate{$file}) ? return 0 : return 1;
       }
   elsif ($trans_type eq 'get')
       {
       ($localdate <= $gr::catDate{$file}) ? return 0 : return 1;
       }
   else
       {
       gr::finish(1, "Error in sub isNewer().\n");
       }
   }


sub userDeclines
   {
   gr::disconnect();
   gr::finish(0, "[i] Exiting.  No files transferred.\n");
   }


sub successMsg
   {
   my $type          = shift;
   my $numfiles_rcvd = shift;

   my $where = undef;
   $where = 'from' if $type eq 'uploaded';
   $where = 'to'   if $type eq 'downloaded';

   printf("[i] Succesfully %s %d .bch file%s %s %s\n",
                             $type,
                             $numfiles_rcvd,
                             $numfiles_rcvd==1 ? '' : 's',
                             $where,
                             $workdir,);
   }


sub Usage
   {
   print STDERR <<"EOT";

GRBCH uploads or downloads .bch files to or from the server for a 
particular fixture (or for all fixtures).

Usage: grbch -[sagp] fixture_id.bch
       E.g. grbch -g 211.bch  for a single file transfer
       grbch -a               for all current .bch files on server

  Options:
  -a         to retrieve all .bch files from $DEFARCHROOT 
  -g         to get a specific .bch file from $DEFARCHROOT to this machine 
  -p         to put a specific .bch file from this machine to $DEFARCHROOT 
  -s         silent, no user prompts - ok to overwrite files
             (must be used with, and precede, other switches)

  Standard Options:
  -h         display this message
  -r path    specify server root directory [$DEFARCHROOT]
  -l login   specify login information [$DEFACCOUNT:<password>\@$DEFSERVER]
  -w path    specify local working directory to receive files
             [$workdir]
  -d         turn debug mode on

EOT
   exit (1);
   }


__END__
:endofperl
