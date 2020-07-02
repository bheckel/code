
$objName='EQualityConnectClient.ConnectManager';
$objName=$ARGV[0] if $ARGV[0];
use Win32::OLE;
$eqobj = Win32::OLE->new($objName);
$x=Win32::OLE->LastError;
if ($x) {
  print "Error establishing connection to COM object $objName\nError is: [$x]\n";
  exit;
}
print "Was able to establish a connection to COM object $objName.\n";
