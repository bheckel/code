#!/usr/bin/perl
##############################################################################
#     Name: bobackup.pl
#
#  Summary: Incremental network backup system
#
#           TODO email on error (install ssmtp?)
#
#  Created: Sun 26 Nov 2006 17:45:13 (Bob Heckel)
# Modified: Sat 02 Dec 2006 10:58:59 (Bob Heckel)
##############################################################################
use strict;
use warnings;
use File::Find;
use File::stat;
use Data::Dumper;

##### Config #####
use constant DEBUG => 0;
my $locpath = 'c:/cygwin/home/bheckel/projects/bobackup/testdir'; # recursive
my $rempath = 'x:/';  # single timestamped tarball is copied here at each run
my $tstamp = '/cygdrive/c/util/bobackup/tstamp.txt';  # unixdate
my $logfile = '/cygdrive/c/util/bobackup/log.txt';
my @fs;  # all files in $locpath
##################


sub Fnd {
	push @fs, $File::Find::name;
}


sub LastRunTime {
	my $lastrun;

	open FH, "$tstamp" or die "uh oh can't open timestamp $tstamp: $0: $!";
	{ 
		local $/ = undef;  # slurp
		$lastrun = <FH>; 
	} 
	close FH;  

	return $lastrun;
}


sub GatherAttributes {
	my @filesdirs = @_;

	my @allfiles = map { my $f = stat $_;
											 $_  = (defined $f) ? { name  => $_, 
											                        size  => $f->size(), 
																				      mtime => $f->mtime() 
                            								} : undef 
							  } grep { -f $_ } @filesdirs;

	return @allfiles;
}


sub GatherNew {
	my $last = shift;
	my @f = @_;
	my @n;

	for ( @f ) {
		###print Dumper $_;
		if ( $_->{mtime} gt $last ) {
			push @n, $_;
		}
	}

	return @n;
}


sub ZipNewFiles {
	my @f = @_;
	my @zipme;

  for ( @f ) {
		###print "$_->{name} is $_->{mtime}\n";
		push @zipme, $_->{name};
	}

  my $now = time;
	# Two steps to allow verification by tar and better compression by bzip2
	my $tarrc = system('/bin/tar', 'cfPW', "$ENV{TMP}/zippy.$now.tar", @zipme);
	my $bzrc = system('/bin/bzip2', '-9', "$ENV{TMP}/zippy.$now.tar");

  if ( $tarrc + $bzrc == 0 ) {
		return "$ENV{TMP}/zippy.$now.tar.bz2"
	} else {
		return 'fail';
	}
}


sub CopyToNet {
	my $z = shift;

  my $basefn = $1 if $z =~ m|[/\\:]+([^/\\:]+)$|;
	###my $rc = system('cp', '-v', $z, "x:/$basefn");
	my $rc = system('cp', $z, "x:/$basefn");

	return $rc;
}


sub WriteNewTstamp {
	open FH, ">$tstamp" or die; 
	print FH time;
	close FH;
	
	return 0;
}


sub MD5LocVsNet {
	my $loc = $_[0];

  my $basefn = $1 if $loc =~ m|[/\\:]+([^/\\:]+)$|;
	my $rem = "x:/" . $basefn;

  my $locsum = `/bin/md5sum $loc`;
	my $remsum = `/bin/md5sum $rem`;

	$locsum = (split / /, $locsum)[0];
	$remsum = (split / /, $remsum)[0];

  if ( $locsum ne $remsum ) {
		print "\$locsum is $locsum and \$remsum is $remsum\n";
		return 1;
	} else {
		return 0;
	}
}


sub CleanUp {
	my $f = shift;
	unlink $f;
}


sub WriteLog {
	my $msg = shift;

	open LOG, ">>$logfile" or die;
	print LOG scalar localtime, ': ', $msg;
}



########## Main ###########
my $last = LastRunTime();
WriteLog("scanning for files newer than " . scalar localtime $last . "\n");

find(\&Fnd, "$locpath/");

my @allf = GatherAttributes(@fs);
WriteLog("scanned " . scalar @allf . " files...\n");
die "Problem gathering file attributes\n" if scalar @allf == 0;

my @newf = GatherNew($last, @allf);
print Dumper @newf if DEBUG;
die "No new files found\n" if scalar @newf == 0;
my $plural = '';
$plural = 's' if scalar @newf gt 1;
print $ENV{fg_yellow},"backing up ", scalar @newf, " new file$plural...\n", $ENV{normal};

my $tarball = ZipNewFiles(@newf);
die "Problem creating tarball ($tarball)\n" if $tarball eq 'fail';

my $copysuccess = CopyToNet($tarball);
die "Problem copying to network\n" if $copysuccess ne 0;

my $stampok = WriteNewTstamp;
die "Problem writing new timestamp file\n" if $stampok ne 0;

my $compared = MD5LocVsNet($tarball);
print $ENV{fg_yellow}, "md5sum check successful\n",$ENV{normal} if $compared eq 0;

# Save the tarball in case it took a while to build it but the network was
# down or something.  But normally delete it so it doesn't back itself up on
# the next run.
my $clean = CleanUp($tarball) if $compared eq 0;

WriteLog("backup successful\n");

###########################
