#!/usr/bin/perl -w
##############################################################################
#     Name: msoffice.pl
#
#  Summary: Control MS Office apps.  MS Word in this case.
#
#  Adapted: Mon 10 May 2004 12:56:36 (Bob Heckel -- Steve's place Perl tut 
#                                     lesson 12)
##############################################################################
use strict;
use Win32::OLE;

my $Word = Win32::OLE->new('Word.Application'); 

# Using standard perl OO syntax.

$Word->{'Visible'} = 1; 

my $Document = $Word->Documents->Add(); 

my $Selection = $Word->Selection();

$Selection->TypeText('Hello world'); 

$Selection->TypeParagraph();

print 'Save this document as... ';

chomp (my $filenm = <STDIN>);

$Document->SaveAs($filenm);

$Word->Quit();

exit 0;
