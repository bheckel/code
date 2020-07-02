package MyModule;

# Adapted: Wed May 05 15:36:07 2004 (Bob Heckel -- Steve's Place Perl tut 
#                                    lesson 8)
#
# Must symlink as MyModule.pm
#
# This file was generated via  $ h2xs -AXn MyModule

# When this module is called from a .pl (e.g. use MyModule;), it is equivalent
# to:
# BEGIN { require MyModule; import( MyModule ) }

use 5.008002;
# Modules written with lowercase names are often called pragmata or pragma
# modules; they affect how perl deals with your script itself, rather than
# giving you extra functionality.
use strict;
use warnings;

# Exporter is just a perl module that exports things (like subroutines) from
# one package to another.
require Exporter;

# So now you know how to go about writing a module: you simply need to write
# some functions, and write a subroutine called import that exports these
# functions from one package to another. The latter is a simple matter of
# setting a typeglob in the caller's symbol table to a reference to the
# subroutine you wish to export.
#
# Erm, yeah. In fact, almost no one rolls their own import function. Almost
# everyone just borrows the one in Exporter, which is what this line does:
our @ISA = qw(Exporter);
# @ISA is where you can put the names of modules that perl should search to
# find functions you can't be bothered to define. So, if you can't be bothered
# to define import() yourself, you can tell perl to look for this function in
# Exporter.pm instead.
# Said another way:
# @ISA contains places to look if you can't find a function in the module
# itself.  In OO programming, unlike this non-OO code, looking somewhere else
# is called "inheriting methods".
# 
# In English the line above would say:
# "MyModule IS A Exporter, and inherits functions I can't be bothered to
# define from it"

# Items to export into caller's namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
our @EXPORT = qw(Hi);

# This allows declaration	use MyModule ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
###our %EXPORT_TAGS = ( 'all' => [ qw(
###
###) ] );

# E.g. in our code using this module:  our @EXPORT_OK = qw( parse boil melt );
# Then users of your module could...
# use MyModule "parse", "boil"; # or
# use MyModule qw( parse boil); # avoid all those quotes
###our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01';

###BEGIN { $Exporter::Verbose = 1; }

# Preloaded methods go here:
srand;
sub Hi {
  my $name = shift;

  $name ||= "you";
  my $message = rand(1) > 0.5 ? "a waste of time" : "a lot of fun";

  return "Hello, $name, isn't this $message?\n";
}

1;


__END__

=head1 NAME
Hello - Perl extension for printing a stupid message      
=head1 SYNOPSIS
  use Hello;
  $msg = Hi( "Steve" );
  print $msg;
=head1 DESCRIPTION
Stub documentation for MyModule, created by h2xs. It looks like the author 
of the module took careful note of the importance of documentation, 
and here it is...
=head2 EXPORTED FUNCTIONS
=item * Hi( $arg )
=over 4
Randomly prints one of two stupid message for $arg, which should be a name,
but will default to 'you'.
=back
=head1 AUTHOR
Steve Cook, E<lt>steve@steve.gb.comE<gt>
=head1 SEE ALSO
L<perl>.
=cut
