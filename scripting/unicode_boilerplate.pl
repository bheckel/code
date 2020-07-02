# http://stackoverflow.com/questions/6162484/why-does-modern-perl-avoid-utf-8-by-default/6163129#6163129
use 5.014;

use utf8;
use strict;
use autodie;
use warnings; 
use warnings    qw< FATAL  utf8     >;
use open        qw< :std  :utf8     >;
use charnames   qw< :full >;
use feature     qw< unicode_strings >;

use File::Basename      qw< basename >;
use Carp                qw< carp croak confess cluck >;
use Encode              qw< encode decode >;
use Unicode::Normalize  qw< NFD NFC >;

END { close STDOUT }

if (grep /\P{ASCII}/ => @ARGV) { 
   @ARGV = map { decode("UTF-8", $_) } @ARGV;
}

$0 = basename($0);  # shorter messages
$| = 1;

binmode(DATA, ":utf8");

# give a full stack dump on any untrapped exceptions
local $SIG{__DIE__} = sub {
    confess "Uncaught exception: @_" unless $^S;
};

# now promote run-time warnings into stackdumped exceptions
#   *unless* we're in an try block, in which 
#   case just generate a clucking stackdump instead
local $SIG{__WARN__} = sub {
    if ($^S) { cluck   "Trapped warning: @_" } 
    else     { confess "Deadly warning: @_"  }
};

while (<>)  {
    chomp;
    $_ = NFD($_);
    ...
} continue {
    say NFC($_);
}

__END__
--------------------------------------------------------------------------------
