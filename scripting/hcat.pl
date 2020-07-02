#!/usr/bin/perl -w
##############################################################################
#     Name: hcat.pl
#
#  Summary: Socket based hypertext version of UNIX cat with ability to pass
#           text directly to webserver (hyper-shell).
#
#  Adapted: Fri 11 May 2001 16:21:22 (Bob Heckel)
#                                     with Perl Chapter 4 The Socket Library)
##############################################################################
 
use strict;
use Socket;  # for open_TCP()
use vars qw($opt_h $opt_H $opt_r $opt_d $opt_s);
use Getopt::Std;
 
getopts('hHrds');
 
if ( defined $opt_h || $#ARGV<0 ) { help(); }
 
# If it wasn't an option, it was a URL
while ( $_ = shift @ARGV ) {
  hcat($_, $opt_r, $opt_H, $opt_d);
}
 
 
sub usage {
  print "usage: $0 -rhHds URL(s)\n";
  print "       -h           help\n";
  print "       -r           print out response\n";
  print "       -H           print out header\n";
  print "       -d           print out data\n\n";
  print "       -s           interactive input is passed to server\n\n";
  exit(-1);
}
 
 
sub help {
  print "Hypertext cat (http:// requests only):\n\n";
  print "This program prints out documents on a remote web server.\n";
  print "By default, the response code, header, and data are printed\n";
  print "but can be selectively (or in combination) printed with the\n";
  print "-r, -H, and -d options.\n\n";
  print<<EOT;
  Can be used interactively with -s 
  For example type:
  PUT ~/junk.txt HTTP/1.0
  User-Agent: hcat/1.0
  Content-type: text/plain
                        <-- blank line and Ctrl-d

EOT
 
  usage();
}
 
 
# Given a URL, print out the server's response, header or data.
sub hcat {
  # Command line parameters.
  my ($full_url, $fullresponse, $header, $data) = @_;
 
  # Assume that response, header, and data will be printed.  Rets 1 if all 3
  # are undef, undef if any of the 3 hold a value.
  my $all = !($fullresponse || $header || $data);
 
  # If the URL isn't a full URL, assume that it is a http request.
  $full_url="http://$full_url" if ($full_url !~ 
                                      m/(\w+):\/\/([^\/:]+)(:\d*)?([^#]*)/);
 
  # Break up URL into meaningful parts.
  my @the_url = parse_URL($full_url);
  if ( ! @the_url ) {
    print "Please use fully qualified valid URL.\n";
    exit(-1);
  }
 
  # We're only interested in HTTP URL's.
  help() if ( $the_url[0] !~ m/http/i );
 
  # Connect to server specified in 1st parameter.
  if ( !defined open_TCP('F', $the_url[1], $the_url[2]) ) {
    print "Error connecting to web server: $the_url[1]\n";
    exit(-1);
  }
 
  if ( $opt_s ) {
    # Go interactive.
    while ( <STDIN> ) { print F; }
  } else {
    # Request (from the server) the path of the document to get.
    print F "GET $the_url[3] HTTP/1.0\n";
    print F "Accept: */*\n";
    print F "User-Agent: hcat/1.0\n\n";
  }
 
  # Get the server's HTTP response line.
  my $the_response = <F>;
  print $the_response if ( $all || defined $fullresponse );
 
  # Get the header data
  while ( <F> =~ m/^(\S+):\s+(.+)/ ) {
    print "$1: $2\n" if ( $all || defined $header );
  }
 
  # Get the entity body
  if ( $all || defined $data ) {
    print while (<F>);
  }
 
  # Close the network connection
  close(F);
 
}


# Input: $FS   is the name of the filehandle socket to use
#        $dest is the name of the destination computer, either IP address or
#              hostname
#        $port is the port number
#
# Output: successful network connection in file handle, rets 1 on success,
#         undef on error
#
sub open_TCP {
  no strict 'refs';
  # Get parameters
  my ($FS, $dest, $port) = @_;
 
  my $proto = getprotobyname('tcp');
  socket($FS, PF_INET, SOCK_STREAM, $proto);
  my $sin = sockaddr_in($port, inet_aton($dest));
  connect($FS,$sin) || return undef;
  
  my $old_fh = select($FS); 
  $| = 1; 		        # don't buffer output
  select($old_fh);

  1;
}


# Given a full URL, return the scheme, hostname, port, and path
# into ($scheme, $hostname, $port, $path).  We'll only deal with
# HTTP URLs.
sub parse_URL {
  # Put URL into variable
  my ($url) = @_;
 
  # Attempt to parse.  Return undef on failure.
  (my @parsed =$url =~ m@(\w+)://([^/:]+)(:\d*)?([^#]*)@) || return undef;
 
  # Remove colon from port number, even if it wasn't specified in the URL
  if ( defined $parsed[2] ) {
    $parsed[2] =~ s/^://;
  }
 
  # The path is "/" if one wasn't specified
  $parsed[3] = '/' if ( $parsed[0] =~ /http/i && (length $parsed[3]) == 0 );
 
  # If port number was specified, we're done
  return @parsed if ( defined $parsed[2] );
 
  # Otherwise, assume port 80, and then we're done.
  $parsed[2] = 80;
 
  return @parsed;
}
 

# Returns an array of links that are referenced from within html. 
sub grab_urls {
  my($data, %tags) = @_;

  my @urls;
 
  # While there are HTML tags
  SKIP_OTHERS: while ( $data =~ s/<([^>]*)>// )  {
    my $in_brackets=$1;
    my $key;
    foreach $key ( keys %tags ) {
      if ( $in_brackets =~ /^\s*$key\s+/i ) {    # if tag matches, try parms
        if ( $in_brackets =~ /\s+$tags{$key}\s*=\s*"([^"]*)"/i ) {
          my $link = $1;
          $link =~ s/[\n\r]//g;  # Kill newlines,returns anywhere in url
          push (@urls, $link);
          next SKIP_OTHERS;
        } 
        # Handle case when url isn't in quotes (ie: <a href=thing>)
        elsif ( $in_brackets =~ /\s+$tags{$key}\s*=\s*([^\s]+)/i ) {
          my $link = $1;
          $link =~ s/[\n\r]//g;  # Kill newlines,returns anywhere in url
          push(@urls, $link);
          next SKIP_OTHERS;
        }    
      }       # if tag matches
    }         # foreach tag
  }           # while there are brackets

  return @urls;
}
 
