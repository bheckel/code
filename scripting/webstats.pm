package webstats;
##############################################################################
#     Name: webstats.pm
#
#  Summary: Count hits on specific webpages using CDC's IIS logfiles.
#
#           See webstats.pm webstats_if.pl choose_cgi.pl
#
#  Created: Wed 06 Nov 2002 13:37:07 (Bob Heckel)
# Modified: Wed 09 Jul 2003 08:38:03 (Bob Heckel -- allow separator that is
#                                     not a dot '.')
# Modified: Tue 04 Nov 2003 16:05:04 (Bob Heckel -- change filenames,
#                                     directories, position of filepath in IIS
#                                     logfile)
# Modified: Wed 28 Jan 2004 10:59:43 (Bob Heckel -- silence unzip chatter)
# Modified: Wed 03 Mar 2004 10:00:14 (Bob Heckel -- temp hacks for manual
#                                     operation)
# Modified: Mon 24 May 2004 12:41:57 (Bob Heckel -- remove manual hacks)
##############################################################################
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(GetZip Unzip Process Cleanup);

# Globals:
my $ZIPDIR = '/var/tmp/webstats/'; # where to put zipfile and logfiles
my $ZIPFILETMP = 'tmp.zip';        # overwritten on each run
my $FTPSVR = 'webstats.cdc.gov';
my $FTPDIR = 'www2a';


sub GetZip {
  my $y = shift;
  my $f = shift;
  # E.g.  www2a/2003/www2a-200310.zip
  my $z = $FTPDIR . '/' . $y . '/' . $f;

  use Net::FTP;

  my $ftp = Net::FTP->new($FTPSVR, Debug => 0)
                                     or die "Can't connect: $@ $? $!\n";
  $ftp->login('anonymous', 'bqh0\@cdc.gov') or die "Can't login: $@ $? $!\n";
  $ftp->binary;
  $ftp->get($z, "${ZIPDIR}$ZIPFILETMP") or die "Can't get $@ $? $!\n";
  $ftp->quit;

  return 0;
}


sub Unzip {
  my $z = $ZIPDIR . $ZIPFILETMP;

  {
    local $ENV{PATH} = '/usr/bin';
    # Remove the -qq to debug.
    system("unzip -qq $z -d $ZIPDIR") && 
                                  print "\n\nERROR! Cannot unzip: $z\n\n";
  }

  return 0;
}


sub Process {
  my $mo = shift;
  my $yr = shift;
  my $spacer = shift;  # usually a space, could be periods, dashes, etc.

  my %found = ();
  my $totctr = 0;
  my @files = ();

  opendir DH, $ZIPDIR || die "Can' open DIR: $!\n";
  @files = grep(/ex\d+\.log$/, readdir DH);
  for ( @files ) {
    # CDC IIS naming convention e.g. ex031001.log
    next unless /(ex\d+\.log)$/;  # capturing parens only to untaint
    open FH, "${ZIPDIR}$1" or die "Error: $0: $!";
    while ( <FH> ) {
      next if /^$/;  # skip blank lines
      next if /^#/;  # elim comments
      # old format Sep 2003-
      # 2002-10-01 17:02:33 164.165.225.4 stateuser W3SVC1 ACDC-ATL-WWW2 198.246.96.8 GET /nchs/vscp/homebotroll_r7_c1_f2.gif - 404 2 604 361 0 80 HTTP/1.0 Mozilla/4.0+(compatible;+MSIE+5.01;+Windows+NT+5.0;+Hotbar+4.1.7.0) - http://www2.cdc.gov/nchs/vscp/
      ###my ($clock, $uid, $ourfile) = (split ' ', $_)[1,3,8];
      # new format Oct 2003+
      # 2003-10-01 17:22:35 159.36.31.104 stateuser W3SVC1 ACDC-XDV-WWW2 198.246.96.22 80 GET /nchs/vscp/ - 302 0 323 396 0 HTTP/1.0 www2a.cdc.gov Mozilla/4.7+[en]C-CCK-MCD+NSCPCD47++(Win95;+I) SITESERVER=ID=1c850cd66be0f668ab223d76534db573 -
      my ($clock, $uid, $ourfile) = (split ' ', $_)[1,3,9];

      if ( $uid eq 'stateuser' ) {
        ###if ( $. lt 20 ) {
          ###print "$ourfile\n";
        ###}
        next unless $ourfile =~ /\/vscp\//i;
        # Filter out junk.
        next if $ourfile =~ /shtml\.dll/;
        next if $ourfile =~ /homebot\.js/;
        next if $ourfile =~ /^$/;
        next if $ourfile =~ /gif$/;
        $found{"$ourfile"}++;
        $totctr++;
      }
    }
  }

  print "              VSCP Web Usage for $mo $yr\n";
  my $width = 60;
  printf "%s%s%s\n", 'Path', ' ' x ($width-length('Hits')), 'Hits';
  printf "%s%s%s\n", '====', ' ' x ($width-length('====')), '====';
  foreach my $key ( sort keys %found ) { 
    my $lng = $width-length($key);
    printf "%s%s%2d  (%2d%%)\n", $key, $spacer x $lng, $found{$key}, 
                                              ($found{$key}/$totctr)*100;
  }
  printf "%s%s%s\n", '  Total Page Requests', ' ' x 
                            ($width-length('  Total Page Requests')), $totctr;

  return 0;
}


# Remove decompressed logfiles.
sub Cleanup {
  opendir DH, $ZIPDIR or die "Error: $0: $!";

  my @f = grep(/ex\d+\.log$/, readdir DH);

  foreach ( @f ) {
    /.*(ex\d+\.log)$/;  # capturing parens only to untaint
    my $fullpath = $ZIPDIR . $1;
    unlink $fullpath if $fullpath =~ /ex\d+\.log$/;
  }

  return 0;
}


1;
