#!/usr/bin/perl -w
##############################################################################
#    Name: collapse_dhtml.pl
#
# Summary: Generate DHTML output based on an existing filesystem structure.
#          Used in IWS weblet filebrowser.
#          E.g. ./collapse_dhtml.pl >| junk.html && st junk.html
#          Assumes the directory structure in @fqp already exists.
#
# Created: Fri, 16 Feb 2001 13:21:41 (Bob Heckel)
##############################################################################

$DEBUG = 1;

# Sorted alphabetically.
@fqp = qw(
  /home/bheckel/todel/subcollapse/topone
  /home/bheckel/todel/subcollapse/anotherdir
  /home/bheckel/todel/subcollapse/anotherdir/anotherfile
  /home/bheckel/todel/subcollapse/subsubd
  /home/bheckel/todel/subcollapse/subsubd/asubsubfile
  /home/bheckel/todel/subcollapse/subsubd/bsubsubfile
  /home/bheckel/todel/subcollapse/subsubd/sub3
  /home/bheckel/todel/subcollapse/subsubd/sub3/filesub3
  /home/bheckel/todel/subcollapse/zzz
);

my $chunk =<<'EOT';
<SCRIPT LANGUAGE="JavaScript1.2">
  var head = "display:''"

  function doit(header) {
    var head = header.style

    if ( head.display == "none" )
      head.display = ""
    else
      head.display = "none"
  }
</SCRIPT>

EOT

my $users_homedir = '/home/bheckel/todel/subcollapse';
# DHTML.
my $h3 = '<H3 style="cursor:hand" onClick="doit(document.all[this.sourceIndex+2])">';
my $h3end = '</H3>';
# DHTML.
my $span = '<SPAN STYLE="display:none" style=&{head};>';
my $spanend = "</SPAN>\n";
my $br = '<BR>';
my $ckbox = '<INPUT TYPE="checkbox" NAME="';
my $fileicon = '/cygwin/usr/local/apache/icons/text.gif';
my $diricon = '/cygwin/usr/local/apache/icons/folder.gif';
my $ckboxend = qq/"><IMG SRC="$fileicon" BORDER="0" ALIGN="middle">/;
my $dimg = qq/<IMG SRC="$diricon">/;
my $nbspace = '&nbsp;';
my $lastlevel = ($users_homedir =~ tr/\///) + 1;
my $beglevel = $lastlevel;
my $chg = undef;

# Want files at the top level to display after the directories.
foreach my $file ( @fqp )  {
  my $level = ($file =~ tr/\///);
  if ( -f $file && $level == $lastlevel ) {
    push(@toplvlfiles, $file);
  } else {
    push(@therest, $file);
  }
}

foreach my $file ( @therest )  {
  # E.g. /home/bheckel/todel/subcollapse is 4.
  my $level = ($file =~ tr/\///);
  my $indent = $nbspace x $level;

  warn $level;
  if ( $level != $lastlevel ) {
    $chg = $level - $lastlevel;
    warn "just changed $chg level, now at level $level" if $DEBUG;
  } else {
    $chg = 0;
  }

  abs($chg) ? $abschg = abs($chg) : $abschg = 1;
  $ind = $indent x ($level - $beglevel);
  if ( -f $file && $chg == 0) {
    # No level change.
    $chunk .= "$ind $ckbox$file$ckboxend $file $level $br \n";
  } elsif ( -f $file && $chg > 0 ) {
    # Level increase.
    $chunk .= "$ind $ckbox$file$ckboxend $file $level $br \n";
  } elsif ( -f $file && $chg < 0 ) {
    # Level decrease.
    $spanendtags = "$spanend\n" x $abschg;
    $chunk .= "$ind $spanendtags $file $level $br \n";
  }

  if ( -d $file && $chg == 0 ) {
    # No level change.
    if ( $level != $beglevel ) {
      # In a subdir that needs to be indented.
      $chunk .= "$h3 $indent $dimg $file $h3end\n$span\n";
      $flag = 1;
    } else {
      # At top level dir that doesn't need to be indented.
      $chunk .= "$h3 $dimg $file $h3end\n$span\n";
    }
  } elsif ( -d $file && $chg > 0 ) {
    # Level increase.
    $chunk .= "$spanend\n $h3 $dimg $file $h3end\n$span\n";
  } elsif ( -d $file && $chg < 0 ) {
    # Level decrease.
    $chunk .= "$spanend\n $h3 $dimg $file $h3end\n$span\n";
  }

  $lastlevel = $level;
  $chg       = undef;
}

# Want a break before top level files display.
$chunk .= $br;

# Close nested spans from the directory section.
my $startlevel = ($users_homedir =~ tr/\///) + 1;
my $closes = $lastlevel - $startlevel;
$chunk .= $spanend x $closes ;

# Now display files (alphabetized).
foreach my $file ( @toplvlfiles ) {
  $chunk .= "$ckbox$file$ckboxend $file $br\n";
}

print $chunk;


__END__

E.g. 

<H3>anotherdir</H3>
<SPAN>
  anotherfile
</SPAN>

<H3>subsubd</H3>
<SPAN>
  asubsubfile
  bsubsbufile
  <H3>sub3</H3>
  <SPAN>
  filesub3
  </SPAN>
</SPAN>

topone
zzz
