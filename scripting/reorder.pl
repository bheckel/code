#!/usr/bin/perl -w
##############################################################################
#     Name: reorder.pl
#
#  Summary: Accepts 
#             - checklist
#             - [section name]
#             - number to be moved
#             - number after which to insert the number to be moved
#           Reorders the records and returns modified array.
#
#  Created: Mon, 29 May 2000 15:15:29 (Bob Heckel)
# Modified: Fri, 09 Jun 2000 09:32:31 (Bob Heckel)
##############################################################################

# DEBUG stub
print reorder(@ARGV);

sub reorder {
  use strict;

  my $header         = 'header';
  my $prebuild       = 'prebuild';
  my $build          = 'build';
  my $postbuild      = 'postbuild';

  # DEBUG
  my $cl_file        = '/todel/SOL5678_01.cl';
  my $changetype     = 'postbuild';
  my $movethisnum    = 5;
  my $insertafternum = 2;
  ###my($cl_file, $changetype, $movethisnum, $insertafternum) = @_;

  open(F, "$cl_file") or die "can't read input file: $cl_file";

  my @records = ();
  # Read each [section] into a record.
  {
    # Paragraph mode.
    local $/ = '';
    while ( <F> ) {
      push(@records, $_);
    }
  }
  close(F) or die "can't close input file: $cl_file";
  
  # Make sure bottom-most record is terminated by a newline in case it is
  # reordered.  If not included, the reordered checklist items are fused
  # together.
  foreach my $record ( @records ) {
    unless ( $record =~ /\n\n$/ ) {
      $record .= "\n";
    }
  }
  
  my @type = ();
  foreach my $record ( @records ) {
    if ( $record =~ /^\[$changetype:\d+\]/ ) {
      # Only deal with the changetype requiring reorder, in a separate array
      # to be merged back later.
      push(@type, $record);
      # Remove old ordering.
      $record = '';
    }
  }

  # A.
  # Replace $movethisnum with a placeholder.
  foreach my $line ( @type ) {
    $line =~ s/\[$changetype:$movethisnum\]/\[$changetype:999999\]/;
  }

  # Used by B and C:
  my $insertplusone = $insertafternum + 1;

  # B.
  # Find the [section] that comes before $movethisnum and bump it up two
  # places.
  foreach my $line ( @type ) {
    if ( $line =~ /^\[$changetype:(\d+)\]/ ) {
      my $onedollar = $1;
      next if $onedollar != $insertplusone;
      # $1 must therefore equal $insertplusone;
      my $bump_up_one = $onedollar + 1;
      $line =~ s/$changetype:$onedollar/$changetype:$bump_up_one/;
    }
  }

  # C.
  # Replace placeholder so that sort below works.
  foreach my $line ( @type ) {
    $line =~ s/:999999\]/:$insertplusone\]/;
  }
  
  # Keep records separated by blank line.
  unshift(@type, "\n");
  push(@records, @type);

  # Resort to order task numbers. (Still out of order [build] [header] ...)
  my @sortedrecords = sort(@records);

  # Sections in @allbuildtypes appear in desired output order.
  my @header    = ();
  my @prebuild  = ();
  my @build     = ();
  my @postbuild = ();
  foreach my $section ( @sortedrecords ) {
    if ( $section =~ /$header/ ) {
      push(@header, $section);
    } elsif ( $section =~ /$prebuild/ ) {
      push(@prebuild, $section);
    } elsif ( $section =~ /$build/ ) {
      push(@build, $section);
    } elsif ( $section =~ /$postbuild/ ) {
      push(@postbuild, $section);
    }
  }

  # At this point, [sections] are renumbered and orderered alphabetically.
  my @final = ();
  push(@final, @header);
  push(@final, @prebuild);
  push(@final, @build);
  push(@final, @postbuild);

  open(F, "+>$cl_file") or die "can't read input file: $cl_file";
  print F @final;
  close(F) or die "can't close input file: $cl_file";
  # DEBUG
  ###return @final;
  return 1;
}

