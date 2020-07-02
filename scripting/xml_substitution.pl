#!/usr/bin/perl -w
##############################################################################
#    Name: xml_substitution.pl
#
# Summary: Substitution-based transformations.  No ability to implement logic
#          using this approach.
#
# Adapted: Fri, 26 Jan 2001 16:54:29 (Bob Heckel --
#                     http://www-106.ibm.com/developerworks/library/xml-perl/)
##############################################################################

# ---------------------------------------------
# Define substitutions.

%startsub = (
            "stock_quote" => "<HR><P>",
            "symbol"      => "<H2>",
            "price"       => "<BR><B>Price:</B>",
            "date"        => "<BR><B>Date:</B><I>",
            "time"        => "<BR><B>Time:</B><I>",
            "change"      => "<BR><B>Change:</B>",
            "volume"      => "<BR><B>Volume:</B>"
);

%endsub =   (
            "stock_quote" => "",
            "symbol"      => "</H2>",
            "price"       => "",
            "date"        => "</I>",
            "time"        => "</I>",
            "change"      => "",
            "volume"      => ""
);

# ---------------------------------------------

use XML::Parser;

my $file = shift;

###my $parser = new XML::Parser(ErrorContext => 2);
my $parser = XML::Parser->new(ErrorContext => 2);

$parser->setHandlers(Start => \&start_handler,
                     End   => \&end_handler,
                     Char  => \&char_handler
                    );

$parser->parsefile($file);


# ---------------------------------------------
# The handlers for the XML Parser.

sub start_handler {
  # element is the name of the tag
  my $expat   = shift; 
  my $element = shift;

  print $startsub{$element} if defined($startsub{$element});

  # Handle the attributes
  while ( @_ ) {
    my $att = shift;
    my $val = shift;
    print "$att=$val ";
  }
}

sub end_handler {
  my $expat = shift; 
  my $element = shift;

  print $endsub{$element} if defined($endsub{$element});;
}


sub char_handler {
  my ($p, $data) = @_;
  print $data;
}

__END__
Sample data follows:


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
