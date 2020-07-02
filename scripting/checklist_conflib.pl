#!/usr/bin/perl 

# Demo text-based Checklist application.
# Created: Mon 26 Feb 2001 13:59:48 (Bob Heckel)

use ConfLib;

$ckl = new ConfLib;

# To be handled by IWS:
###Login();
###EditProfiles();
###Logout();
###Refresh();

###@checklist_sects = qw/header prebuild build postbuild/;
# Active Checklists, Templates, Archived Checklists, Rubbish Heap.
# Defaulting to Active Checklist for now.
ChooseArea();
DisplayMenu();
# Choose existing or create new cklist from template.
GenerateNewClist('SOL123.cl') if WantNewClist();
my $sel = SelectClist();
OpenClist($sel);
# Display original cklist.
$ckl->foreach_section(\&DisplayClist);
# Add, change, delete key=value pair.
ModiClist('prebuild:2', 'artwork', 'ONE');
# Added with empty values, populate via ModiClist.
AddToClist('prebuild:3');
###DelFromClist('prebuild:2', 'q_date');
ResortClist();
ReorderClist();
SaveClist($sel);
# Display newly saved cklist.
###$ckl->foreach_section(\&DisplayClist);


sub ChooseArea {
}


sub DisplayMenu {
  # TODO readdir to populate this print
  print <<'EOT'
Active Checklists:
      PEC            REL  AW  CIL   EC   Build Date   Status
  -------------      ---  --  ---   --   ----------   ------
  SOL5678_88.cl      00   aa  cil   01    03/03/01    NOSTAT
  SOL5678_89.cl      00   aa  cil   01    03/03/01    NOSTAT

EOT
}


sub SelectClist {
  # From DisplayMenu().
  my $sel = 'SOL5678_88.cl';

  return $sel;
}


sub OpenClist {
  my $list = shift;

  $ckl->load($list) || die "$0: can't open file $list: $!\n";
  # TODO lock the file.
}


sub DisplayClist {
  my ($section_name, $section_data) = @_;

  $i = 1;
  
  $section_name =~ /^(\w+):/;
  $x = $1;
  if ( $tmp eq $1 && $beenherebefore ) { 
    $i++;
  }
  if ( $beenherebefore ) {
    print "$sel $section_name Activities\n";
    print "        #                         \n";
  } else {
    print "$sel $section_name Header\n";
  }
  foreach $key (sort keys %{$section_data}) {
    if ( $beenherebefore ) {
      print "\t$i. $key = $section_data->{$key}\n";
    } else {
      print "\t    $key = $section_data->{$key}\n";
    }
  }
  $tmp = $x;
  $beenherebefore = 1;
}


sub ModiClist {
  # Read 3 items for each JavaScript-determined "dirty" form element.
  # To set elem to null: ModiClist('header', 'artwork', '');
  my @elements = @_;

  $ckl->set(@elements);
}


sub WantNewClist {
  return 0;
}


sub GenerateNewClist {
  my $newone = shift;

  $newckl = new ConfLib;

  # Will write to bottom of checklist.
  $newckl->set('header', 'prime', '');
  $newckl->set('header', 'release', '');
  $newckl->set('prebuild:1', 'a_date', '');
  # ...etc.

  $newckl->save($newone);
}


sub AddToClist {
  my $newone = shift;

  # Will write to bottom of checklist.
  if ( $newone =~ /header/ ) {
    $ckl->set($newone, 'prime', '');
    $ckl->set($newone, 'release', '');
  } elsif ( $newone =~ /prebuild/ ) {
    $ckl->set($newone, 'a_date', '');
    $ckl->set($newone, 'action', '');
    $ckl->set($newone, 'artwork', '');
    # ...etc.
  }

  ResortClist();
}


sub ResortClist {
  my @allsects = $ckl->sectionList; 

  foreach ( @allsects ) {
    push(@h, $_) if /header/;
    push(@p, $_) if /prebuild/;
    push(@b, $_) if /build/;
    push(@q, $_) if /postbuild/;
  }

  sort(@h, @p, @b, @q);

  $ckl2 = new ConfLib;

  foreach ( @h, @p, @b, @q ) {
    my %tmphash = $ckl->section($_);
    
    while ( (my $key, my $val) = each(%tmphash) ){ 
      $ckl2->set($_, $key, $val);
    }
  }

  $ckl2->save("junk.cl");
  # TODO Rename to overwrite.
}


sub ReorderClist {
}


sub SaveClist {
  my $list = shift;

  # ConfLib fails silently (e.g if file is open).
  $ckl->save($list) ? print "...saved successfully\n" 
                                            : print "...failed to save\n";

  ###return 0;
}

__END__

Sample SOL5678_88.cl

[header]
CIL=cilf
EC=ec
PEC=SOL5678
SL=sll
artwork=
buildDate=983595600
buildQuantity=100
by=bheckel
comment=<<EOT
5678 testing
EOT
desc=Standard Template
format=standard
group=prodeng
prime=bheckel
rdt=962801355
release=88
status=NOSTAT

[prebuild:1]
a_date=959572800
action=<<EOT
1xlskdjf design/data set files
(ARC, MSL, AD, FW, Phototool)
(Review Completed, Feedback to design Completed)
PCBA accepted, DFM, DFT Completed)
EOT
f_date=959745600
group=prodeng
p_date=959832000
prime=bheckel
update=changed 5/15.

[prebuild:2]
a_date=
action=fours
f_date=
group=
p_date=
prime=
update=
z_date=fooval
q_date=
artwork=ONE

[build:1]
a_date=
action=during2
f_date=
group=
p_date=
prime=
update=

[postbuild:1]
a_date=
action=<<EOT
one
Post Build DFM Complete
EOT
f_date=
group=prodeng;proceng
p_date=
prime=
update=

# added 02/28/01 14:43:54
[prebuild:3]
a_date=
action=
artwork=
