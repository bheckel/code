#!/usr/bin/perl -w
##############################################################################
#    Name: conflib_textlib.pl
#
# Summary: Templates and substitution.
#
# Created: Tue, 13 Feb 2001 09:07:30 (Bob Heckel)
##############################################################################

BEGIN
    {
    # GRSUITE_HOME, if it exists, is used for development.
    @INC = ('C:/local/bin','C:/local/lib','C:/local/site',
            'C:/local/site/lib',$ENV{GRSUITE_HOME});
    }

use ConfLib;
use TextLib;

$ini           = 'testconf.txt';
$template      = 'testconftempl';
$sectionwanted = 'mainsect'; 

$cfg = new ConfLib;
$cfg->load($ini) || die "$ini load failed";

%section = $cfg->section($sectionwanted);
$result  = tokenReplace($template, \%section);
print $result;


__END__
Sample ini for all
[mainsect]
GOAL=goaltext
EXP=exptext
...


Template A (a text file)
lsdkfj %GOAL%
lsdjl
...


Template B (an html doc)
<HTML>
sldfj %GOAL% sldkfj
...
</HTML>
