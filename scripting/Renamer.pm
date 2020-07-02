package Renamer;

use 5.008002;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
  InteractiveRename
);

our $VERSION = '0.01';



use Getopt::Std;
our %opts;
getopts('dv', \%opts);


# Main
sub InteractiveRename {
  print "DEBUG \$ARGV[0] is $ARGV[0]\n" if $opts{d};
  RenameFiles(ParseChanges(EditFilesInEditor(ReadFiles($ARGV[0]))));
}


sub ReadFiles {
  opendir DH, $ARGV[0] || die "Can't open dirhandle $ARGV[0]: $!\n";
  # Skip dotfiles and directories.
  my @files = grep { !/^..?$/ && !-d } map "$ARGV[0]/$_", readdir DH;

  return @files;
}


sub EditFilesInEditor {
  my @orignames = @_;

  my $tmpfile = "$ENV{TMP}/renamer-pl$$.tmp";
  open TMPF, ">$tmpfile" || die "Can't create $tmpfile in $ENV{TMP}: $!\n";

  print TMPF <<"EOT";
#
# $0: changes to filenames will be made after exiting this
# tempfile.  Delete all lines to cancel.
#
EOT

  for ( @orignames ) {
    print TMPF "$_\n";
  }
  
  close TMPF;

  system "$ENV{EDITOR} $tmpfile";

  # We make changes to $tmpfile within our favorite editor...Vim, right? ;-)

  open TMPF, "<$tmpfile" || die "Can't open $tmpfile : $!\n";
  my @newnames = <TMPF>;
  @newnames = grep { !/^#/ } @newnames;

  if ( $opts{d} ) {
    close TMPF;
    print "DEBUG: $tmpfile\n";
  } else {
    # TODO only if user does not cancel
    close TMPF && unlink $tmpfile;
  }

  return \@orignames, \@newnames;
}


# Parse saved editor diffs into a hash.
sub ParseChanges {
  my $origarrref = shift;
  my $newarrref = shift;

  if ( scalar @$origarrref != scalar @$newarrref ) {
    die "Problem with parsing filename change file.  Different " .
        "number of files in old vs. new.  Exiting\n";
  }

  my %same = map { $_, 1 } @$origarrref;

  my %torename;
  my $i = 0;
  foreach my $f ( @$newarrref ) {
    chomp $f;  # take away newlines used previously for easier editing
    if ( ! $same{$f} ) {   
      $torename{@$origarrref[$i]} = @$newarrref[$i];
    }
    $i++;
  }

  return \%torename;
}


sub RenameFiles {
  my $hr = shift;

  print "No changes requested.\n" if $opts{v} && ! keys %$hr;
  print "We are about to rename:\n" if $opts{v} && keys %$hr;
  foreach ( sort keys %$hr ) {
    print "  FROM:\t$_\n    TO:\t$$hr{$_}\n\n" if $opts{v};
  }

  if ( $opts{v} ) {
    print "Proceed? [yes/no] ";
    if ( <STDIN> !~ /yes/i ) {
      print "cancelled\n";
      exit 1;
    }
  }

  foreach ( sort keys %$hr ) {
    rename $_, $$hr{$_};
  }

  if ( $opts{v} ) {
    print "Directory contents after committed changes:\n";
    map { print "  $_\n" } ReadFiles();
  }
}


1;

__END__

=head1 NAME

Renamer - Perl extension for performing interactive filename changes
          from within an editor.


=head1 SYNOPSIS

  use Renamer;

  InteractiveRename();


  Recognizes switches:
    -d debug mode
    -v verbose mode

  E.g. 
    $ cat mytest.pl
    #!/usr/bin/perl

    use strict;
    use warnings;
    use Renamer;

    # Rename any, all or no files in a directory passed in as @ARGV.
    InteractiveRename();

    $ mytest.pl -dv ~/mydir


=head1 DESCRIPTION

Interactive file renamer allows filename changes from within a user's
favorite editor.  Most useful when complicated or one-time repetitive
changes to a directory must be made but programmatic solutions are
probably not worth the time to implement.  Ignores subdirectories, if
any.

=head2 EXPORT

None by default.


=head1 SEE ALSO

Perl's rename function.


=head1 AUTHOR

Robert S. Heckel Jr., E<lt>bheckel@gmail.com<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Robert S. Heckel Jr.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
