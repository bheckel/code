#!/usr/bin/perl -w
##############################################################################
#    Name: xml_functions.pl
#
# Summary: Using XML with functions.
#
# Adapted: Tue, 30 Jan 2001 08:30:27 (Bob Heckel --
#                      http://www-106.ibm.com/developerworks/library/xml-perl/)
##############################################################################

use XML::Parser;
 
my $file = shift;

my $parser = new XML::Parser(Style        => 'Subs',
                             Pkg          => 'SubHandlers',
                             ErrorContext => 2
                            );

$parser->setHandlers(Char => \&char_handler);

$parser->parsefile($file);

sub char_handler {
  my ($p, $data) = @_;

  print $data;
}


####################
package SubHandlers;

#.....
sub stock_quotes {
  print "<TITLE>Stock Quotes</TITLE>\n";
  print '<BODY BGCOLOR="#ffffff" LINK="#0000ff" ALINK="#ff0000">';
}


sub stock_quote_ {
  print "</TR>\n</TABLE>\n</TD>\n</TR>\n</TABLE>\n";
}
#.....


#.....
sub symbol {
  print "<IMG SRC=images/";
}


sub symbol_ {
  print ".gif>\n";
}
#.....


#.....
sub when {
  print "<BR>\n";
}


sub when_ {
  print "</TD>\n<TD>\n<TABLE WIDTH=100%>\n<TR>\n";
}
#.....


#.....
sub price {
  # Discarded.
  my $expat   = shift; 
  my $element = shift;

  # Read the attributes
  while ( @_ ) {
    my $att     = shift;
    my $val     = shift;
    $attr{$att} = $val;
  }

  my $type  = $attr{'type'};
  my $price = $attr{'value'};

  my $rowbreak = 0;

  if ( $type eq 'ask' ) {
    $label="Ask Price";
  } elsif ( $type eq 'open' ) {
    $label="Opening Price";
    $rowbreak = 1;
  } elsif ( $type eq 'dayhigh' ) {
    $label="Today's High";
  } elsif ( $type eq 'daylow' ) {
    $label="Today's Low";
    $rowbreak = 1;
  }

  print "<TD ALIGN=LEFT>\n<B>$label</B></TD>\n";
  print "<TD ALIGN=RIGHT>$price</TD>\n";

  if ( $rowbreak ) {
    print "</TR><TR>\n";
  }
}

sub price_ {
}
#.....


#.....
sub change {
  print "<TD ALIGN=LEFT>\n<B>Change</B>\n</TD>\n";
  print "<TD ALIGN=RIGHT>";
}

sub change_ {
  print "</TD>\n";
}
#.....


#.....
sub volume {
  print "<TD ALIGN=left>\n<B>Volume</B>\n</TD>\n<TD ALIGN=right>";
}

sub volume_ {
  print "</TD>\n";
}
#.....

__END__

<stock_quotes>

  <stock_quote>
    <symbol>IBM</symbol>
    <when>
      <date>12/16/1999</date>
      <time>4:40PM</time>
    </when>
    <price type="ask" value="109.1875"/>
    <price type="open"    value="108"/>
    <price type="dayhigh" value="109.6875"/>
    <price type="daylow"  value="105.75"/>
    <change>+2.1875</change>
    <volume>7050200</volume>
  </stock_quote>

  <stock_quote>
    <symbol>MSFT</symbol>
    <when>
      <date>12/16/1999</date>
      <time>4:01PM</time>
    </when>
    <price type="ask" value="113.6875"/>
    <price type="open"    value="109.25"/>
    <price type="dayhigh" value="115"/>
    <price type="daylow"  value="108.9375"/>
    <change>+5.25</change>
    <volume>64282200</volume>
  </stock_quote>

</stock_quotes>
