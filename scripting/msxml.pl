#!/usr/bin/perl -w
### #!C:\Perl\bin -w
##############################################################################
#    Name: msxml.pl
#
# Summary: Demo of XML manipulation.  Must be run with ActiveState Perl.
#          Requires MSXML 3.0 parser from Microsoft website be installed.
#          Perl will control it via OLE.
#          Requires toptimes.xml datafile and toptimes.xsl stylesheet be in
#          same directory.
#          Creates newtoptimes.xml and newertoptimes.xls files.
#
# Adapted: Fri 20 Apr 2001 13:30:43 (Bob Heckel --
#                          http://www.perl.com/print/2001/04/17/msxml.html)
##############################################################################

use Win32::OLE qw(in with);
use strict;

my $msxml_parser = Win32::OLE->new('MSXML2.DOMDocument.3.0') 
                   or die "couldn't create OLE instance of the MSXML parser.";

#  Parsing the XML (not using stylesheet yet).
$msxml_parser->{async} = "False";
$msxml_parser->{validateOnParse} = "True";

my $load_bool = $msxml_parser->Load("toptimes.xml");
$load_bool or die "topten.xls did not load\n";

# Iterating through the XML Document.
# <TOP_TEN_TIMES> is the root Node.
my $Top_Ten_Times = $msxml_parser->DocumentElement();  # assign the root Node
# <EVENT ...> are all of the child Nodes (actually a NodeList, a collection
# object).
my $Events = $Top_Ten_Times->childNodes();

# 'in' distinguishes an OLE collection object from a standard Perl array. 
foreach my $eventnode ( in $Events) {
  my $back_or_butter = $eventnode->Attributes->getNamedItem("NAME")->{Text};
  if ( $back_or_butter =~  /100 (Backstroke|Butterfly)/ ) {
    # Print the event name stored in the NAME attribute.
    print "---$back_or_butter---\n";
    # Create a $Swimmers a NodeList collection.
    my $Swimmers = $eventnode->childNodes();    
    # Iterate through all swimmers.
    foreach my $swimmernode ( in $Swimmers ) {
      # Print swimmer's time.
      print $swimmernode->Attributes->getNamedItem("TIME")->{Text}, "\n";
    }
  }
}

# You notice that the design of toptimes.xml is suboptimal.  So you transform
# from attribute data (e.g. TIME="55.07") to element data (e.g.
# <TIME>55.07</TIME>.  Start using stylesheet.
#            old             stylesheet        new
Transform("toptimes.xml", "toptimes.xsl", "newtoptimes.xml");


sub Transform {
  # Assign the File Names
  my $xml_doc_file     = shift;
  my $stylesheet_file  = shift;
  my $new_xml_doc_file = shift;
  my $load_bool;

  # Create the three OLE DOM instances.
  my $doc_to_transform = Win32::OLE->new('MSXML2.DOMDocument.3.0');  
  my $style_sheet_doc  = Win32::OLE->new('MSXML2.DOMDocument.3.0');
  my $transformed_doc  = Win32::OLE->new('MSXML2.DOMDocument.3.0');

  # The first instance loads the Top Times document.
  $doc_to_transform->{async} = "False";
  $doc_to_transform->{validateOnParse} = "True";
  $load_bool = $doc_to_transform->Load("$xml_doc_file");

  $load_bool or die "The Top Times did not load\n";

  # The second instance loads the Stylesheet.
  $style_sheet_doc->{async} = "False";
  $style_sheet_doc->{validateOnParse} = "True";
  $load_bool = $style_sheet_doc->Load($stylesheet_file);

  $load_bool or die "The Stylesheet did not load\n";

  # Perform the transformation and save the resulting DOM object into the
  # third instance, an XML doc that conforms to toptimes.xsl.
  $doc_to_transform->transformNodeToObject($style_sheet_doc, $transformed_doc);
  # Write new XML document (which conforms to the new XML syntax) to disk.
  $transformed_doc->save("$new_xml_doc_file");
}


# You notice a typo so you update the XML Document to correct a misspelled
# swimmer name Myer to Meyer.
my $new_msxml_parser = Win32::OLE->new('MSXML2.DOMDocument.3.0'); 
$new_msxml_parser->{async} = "False";
$new_msxml_parser->{validateOnParse} = "True";
$load_bool = $new_msxml_parser->Load("newtoptimes.xml");

$load_bool or die "The new Top Times did not load\n";

my $xpathqry = "TOP_TEN_TIMES/EVENT/SWIM/SWIMMER[. = \"Peter Myers\"]";
# Rets a NodeList of all Nodes matching the XPath query.
my $Peter_Nodes = $new_msxml_parser->selectNodes($xpathqry);

# Iterate the NodeList.
foreach my $Peter (in $Peter_Nodes) {
  $Peter->{nodeTypedValue} = "Peter Meyers"  # update the value
}

$new_msxml_parser->save("newertoptimes.xml"); # save the changes

