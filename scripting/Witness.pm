###################################################################
#
#  Witness.pm
#
#  Provide processing for witness sessions
#
#
###################################################################

package Witness;

use warnings;
use Exporter ();
@ISA=qw(Exporter);

@EXPORT=qw();

use archWitnessUtil;
use archActLogging;

sub process{
  my($self,$guid,$sessionid,$base,$group,$area)=@_;
  if ($duration=convertSession($guid,"$base\\$group\\$area",$sessionid)) {
    $fname=sessionFileName();
    $fsize=sessionFileSize();
    return ($duration,$fname,$fsize);
  } else {
    $@="[$@]" if $@; # put brackets around error message only if it exists.
    actLog("Error","Unable to convert/store WITNESS $guid $@");
    return ("Error","Error","Error");
  }
}

1;
