#!/usr/bin/perl -w

# Did not use.  See better version in ~/code/perl/collapse_dhtml.pl

# To allow substitution in JavaScript template.
use TextLib;
# To separate out the directory(s).
use File::Find;


# Created on the fly so that DHTML works.
$hash{CSSFILE} = 'temp.css';
# TODO use            $ENV{HOME};
$users_homedir = '/home/bheckel/todel/collapse/subcollapse';
$idxfile       = '/home/bheckel/todel/collapse/index.html';

@shortdnames = GetDirs($users_homedir);
@shortfnames = GetFiles($users_homedir); 

# Top-level directory contents placed into hash (dirs are saved for later).
###$hash{FILES} = 'junk.html, junk2.html, junk3.html';
$hash{FILES} = join(',', @shortfnames);
# Each of those top-level files are either CHECKED or not, determined somehow
# by either XML or a config.dat
# Must assume FILES and CHECKED are aligned.
$hash{CHECKED} = 'CHECKED, ,CHECKED,CHECKED, ,';

# TODO need to count all files in the user's tree so that DHTML can
# have correct number of lItems and DIV IDs.  Counter will be incremented
# while traversing the entire directory(s).
$hash{NUMFILES} = @shortfnames + 4;
# Keep track of how many subdirs.
$hash{NUMDIRS} = @shortdnames;

CreateCSS($hash{NUMFILES}, $hash{CSSFILE}) 
               || warn "$hash{CSSFILE} not created.  May be using an old CSS";

# Only the toplevel dirs will display with triangles next to them.
# TODO how to do > 1??
$hash{SUBDIR} = $shortdnames[0];
# 1st level subdir.  TODO how to do more?? while ( $hash{NUMFILES} ) ...?
###@subshortfnames = GetFiles('/home/bheckel/todel/collapse/subcollapse/subsubd');
@subshortfnames = GetFiles($fqp . '/' . $hash{SUBDIR});
$hash{FILES_SUB} = join(',', @subshortfnames);
$hash{CHECKED_SUB} = 'CHECKED,,,';

$result = tokenReplace($idxfile, \%hash);
# DEBUG
print $result;


# Create cascading style sheet here b/c it is used in the HEAD of index.html,
# (template substitution not possible).
sub CreateCSS {
  # Number of filesystem objects.
  $numfso  = shift;
  $cssfile = shift;

  open FILE, ">$cssfile"  || return 0;
  
  for ( my $i=0; $i<$numfso; $i++ ) {
    print FILE '#lItem' . $i . '{ position:absolute; }' . "\n";
  }

  close FILE || return 0;
  
  return 1;
}


sub GetFiles {
  $fqp = shift;

  @files = ();
  @f     = ();
  @sf    = ();

  opendir(DIR, $fqp) || die "Can't open directory: $!\n";
  @files = grep(!/^..?$/, readdir DIR);
  closedir(DIR);

  foreach $file ( @files ) {
    $file = $fqp . '/' . $file;
  }

  # prune=0 descends.
  find sub { $File::Find::prune=1; sort(push(@f, $File::Find::name)) unless -d }, @files;

  for ( @f ) {
    $shortf = $1 if m|[/\\:]+([^/\\:]+)$|;
    push(@sf, $shortf);
  }
  
  return @sf;
}


sub GetDirs {
  $fqp = shift;

  @files = ();
  @d     = ();
  @sd    = ();

  opendir(DIR, $fqp) || die "Can't open directory: $!\n";
  @files = grep(!/^..?$/, readdir DIR);
  closedir(DIR);

  foreach $file ( @files ) {
    $file = $fqp . '/' . $file;
  }

  # prune=0 descends.
  find sub { $File::Find::prune=0; sort(push(@d, $File::Find::name)) if -d }, @files;

  for ( @d ) {
    $shortd = $1 if m|[/\\:]+([^/\\:]+)$|;
    push(@sd, $shortd);
  }
  
  ###return (\@sd, \@sf);
  return @sd;
}
