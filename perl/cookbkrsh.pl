# Establish a default value.
#-------------------------------
# use $b if $b is true, else use $c
$a = $b || $c;              

# set $x to $y unless $x is already true
$x ||= $y

# use $b if $b is defined, else use $c
$a = defined($b) ? $b : $c;



# Put comma in number
#-------------------------------
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}



# Print correct plurals
#----------------------------
printf "It took %d hour%s\n", $time, $time == 1 ? "" : "s";

printf "%d hour%s %s enough.\n", $time, 
        $time == 1 ? ""   : "s";
        $time == 1 ? "is" : "are";



# Add or subtract dates
#------------------------------
$when = $now + $difference;
$then = $now - $difference;



# Print list with commas and an and before the last item.
#------------------------------
# commify_series - show proper comma insertion in list output

@lists = (
    [ 'just one thing' ],
    [ qw(Mutt Jeff) ],
    [ qw(Peter Paul Mary) ],
    [ 'To our parents', 'Mother Theresa', 'God' ],
    [ 'pastrami', 'ham and cheese', 'peanut butter and jelly', 'tuna' ],
    [ 'recycle tired, old phrases', 'ponder big, happy thoughts' ],
    [ 'recycle tired, old phrases', 
      'ponder big, happy thoughts', 
      'sleep and dream peacefully' ],
    );

foreach $aref (@lists) {
  print "The list is: " . commify_series(@$aref) . ".\n";
} 

sub commify_series {
  my $sepchar = grep(/,/ => @_) ? ";" : ",";
  (@_ == 0) ? ''                                      :
  (@_ == 1) ? $_[0]                                   :
  (@_ == 2) ? join(" and ", @_)                       :
                join("$sepchar ", @_[0 .. ($#_-1)], "and $_[-1]");
}


# Extract unique, non duplicate elements from a list.
#----------------------------
%seen = ();
@uniq = ();
foreach $item (@list) {
  unless ($seen{$item})
      # if we get here, we have not seen it before
      $seen{$item} = 1;
      push(@uniq, $item);
  }
}
#--------------------------
# Faster
#--------------------------
%seen = ();
foreach $item (@list) {
  push(@uniq, $item) unless $seen{$item}++;
}
#--------------------------
%seen = ();
foreach $item (@list) {
  $seen{$item}++;
}
@uniq = keys %seen;
#--------------------------
%seen = ();
@unique = grep { ! $seen{$_} ++ } @list;
#--------------------------


 
# Sort an array numerically.
#------------------------------
@sorted = sort { $a <=> $b } @unsorted;



# Does a hash have a particular key?
#-------------------------
# does %HASH have a value for $KEY ?
if (exists($HASH{$KEY})) {
  # it exists
} else {
  # it doesn't
}



# Delete an item from a hash.
#----------------------
# remove $KEY and its value from %HASH
delete($HASH{$KEY});



# Hash w/ multiple values per key.
#------------------------
%ttys = ();

open(WHO, "who|")                   or die "can't open who: $!";
while (<WHO>) {
  ($user, $tty) = split;
  push( @{$ttys{$user}}, $tty );
}

foreach $user (sort keys %ttys) {
  print "$user: @{$ttys{$user}}\n";
}



# Find common or different keys in two hashes.
#----------------------------
my @common = ();
foreach (keys %hash1) {
	push(@common, $_) if exists $hash2{$_};
}
# @common now contains common keys
#----------------------------
my @this_not_that = ();
foreach (keys %hash1) {
	push(@this_not_that, $_) unless exists $hash2{$_};
}
#----------------------------


# Find the most common anything.
#---------------------------
%count = ();
foreach $element (@ARRAY) {
  $count{$element}++;
}



# Test for valid pattern.
#---------------------------
do {
  print "Pattern? ";
  chomp($pat = <>);
  eval { "" =~ /$pat/ };
  warn "INVALID PATTERN $@" if $@;
} while $@;



# or standalone pgm.
#---------------------------
sub is_valid_pattern {
  my $pat = shift;
  return eval { "" =~ /$pat/; 1 } || 0;
}



# Approximate matching.
#---------------------------
use String::Approx qw(amatch);

if (amatch("PATTERN", @list)) {
  # matched
}

@matches = amatch("PATTERN", @list);
#---------------------------
use String::Approx qw(amatch);
open(DICT, "/usr/dict/words")               or die "Can't open dict: $!";
while(<DICT>) {
  print if amatch("balast");
}

ballast
balustrade
blast
blastula
sandblast



# Detect duplicate words.
#--------------------------
$/ = '';                      # paragrep mode
while (<>) {
  while ( m{
              \b            # start at a word boundary (begin letters)
              (\S+)         # find chunk of non-whitespace
              \b            # until another word boundary (end letters)
              (
                  \s+       # separated by some whitespace
                  \1        # and that very same chunk again
                  \b        # until another word boundary
              ) +           # one or more sets of those
           }xig
       )
  {
      print "dup word '$1' at paragraph $.\n";
  }
}
#--------------------------
This is a test
test of the duplicate word finder.
#--------------------------


# Misc regex
#--------------------------------
IP address 
m/^([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])\.
   ([01]?\d\d|2[0-4]\d|25[0-5])\.([01]?\d\d|2[0-4]\d|25[0-5])$/;


Removing leading path from filename 
s(^.*/)()

North American telephone numbers regex
m/ ^
    (?:
     1 \s (?: \d\d\d \s)?            # 1, or 1 and area code
     |                               # ... or ...
     \(\d\d\d\) \s                   # area code with parens
     |                               # ... or ...
     (?: \+\d\d?\d? \s)?             # optional +country code
     \d\d\d ([\s\-])                 # and area code
    )
    \d\d\d (\s|\1)                   # prefix (and area code separator)
    \d\d\d\d                         # exchange
      $
 /x



# Modify a file in place with a temporary file.
#-----------------------------
open(OLD, "< $old")         or die "can't open $old: $!";
open(NEW, "> $new")         or die "can't open $new: $!";
select(NEW);                # new default filehandle for print
while (<OLD>) {
  # change $_, then...
  print NEW $_            or die "can't write $new: $!";
}
close(OLD)                  or die "can't close $old: $!";
close(NEW)                  or die "can't close $new: $!";
rename($old, "$old.orig")   or die "can't rename $old to $old.orig: $!";
rename($new, $old)          or die "can't rename $new to $old: $!";



# Store filehandle in variable.
#---------------------------
$variable = *FILEHANDLE;        # save in variable
subroutine(*FILEHANDLE);        # or pass directly

sub subroutine {
  my $fh = shift;
  print $fh "Hello, filehandle!\n";
}

use FileHandle;                   # make anon filehandle
$fh = FileHandle->new();

use IO::File;                     # 5.004 or higher
$fh = IO::File->new();



# Retrieve or alter when a file was last modified.
#----------------------------
($READTIME, $WRITETIME) = (stat($filename))[8,9];

utime($NEWREADTIME, $NEWWRITETIME, $filename);
#----------------------------
$SECONDS_PER_DAY = 60 * 60 * 24;
($atime, $mtime) = (stat($file))[8,9];
$atime -= 7 * $SECONDS_PER_DAY;
$mtime -= 7 * $SECONDS_PER_DAY;

utime($atime, $mtime, $file)
  or die "couldn't backdate $file by a week w/ utime: $!";
#----------------------------


# Delete many files and report on success.
#----------------------------
unless (($count = unlink(@filelist)) == @filelist) {
  warn "could only delete $count of "
          . (@filelist) . " files";
}



# Rename several files.
#-------------------------
foreach $file (@NAMES) {
  my $newname = $file;
  # change $file
  rename($file, $newname) or  
      warn "Couldn't rename $file to $newname: $!\n";
}

