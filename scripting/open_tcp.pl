
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

