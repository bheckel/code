#!/usr/bin/perl -w

use Win32::OLE;

unless ( $ARGV[0] ) {
  print "e.g. getguid.pl '{88018F4E-40FE-4A97-A72A-FB2777008555}'\n";
  exit 1;
}

print "read the readme 1st\n";
print "keep going? "; <STDIN> eq "y\n" ? print "ok\n" : die "dead\n";

$eqobj = Win32::OLE->new('EQualityConnectClient.ConnectManager');
$x=Win32::OLE->LastError;
if ($x) {
  print("Error","Error establishing connection to COM object [$x]");
  exit;
}

$x=$eqobj->Configure("Adapter URL","us8n05.corpnet1.com:3021");
$location=$eqobj->QueryURLStates();
print "QueryURLStates location is $location\n";
$result=$eqobj->isValidContact("TestingConnection");
if ( !($result eq "ContactNotFound") && !($result eq "ContactError") ) {
  print("Error establishing connection to eQuality server at us8n05 ($result)");
  exit;
}

print "running $ARGV[0]...\n";
print "should export to \\\\us8n05\\Exports\\\n";
$result=$eqobj->ExportContact("$ARGV[0]", 3);
print "result is [$result]\n";


