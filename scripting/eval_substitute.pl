#!/usr/bin/perl -w

# If the target of a link in an html page is "_top", then we replace that link
# with a link to http://yahoo.com. 

###$html = '<A HREF="http://foo" TARGET="_top">bar</A>';
$html = '<A HREF="http://foo" TARGET="">bar</A>';

$html =~ s#<A HREF="([^"]*)" TARGET="([^"]*)"#
                                              eval{
                                                if ( $2 eq "_top" ){ 
                                                  $string = qq{<a href="http://yahoo.com" target="_top"};
                                                } else {
                                                  $string = qq{<a href="$1" target="$2"};
                                                }
                                                $string
                                              }
                                              #iges;

print $html;
