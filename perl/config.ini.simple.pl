#!/usr/bin/perl -w
##############################################################################
#     Name:
#
#  Summary:
#
#  Created:
##############################################################################

use Config::Ini::Simple;


$W2CIni=new Config::INI::Simple;
$W2CIni->read('junk.ini');
$logLevel=$W2CIni->{ErrorHandling}{LogLevel} || 'None';
print $logLevel;


__END__
junk.ini:

[ErrorHandling]
; Valid values of LogLevel are None,Trace,Debug with or without Interactive
LogLevel=DebugI nteractive
LogDateFmt=%Y%m%d%H%M%S
