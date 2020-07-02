###################################################################
#
#  WITNESSPRODUCT.pm
#
#  Provide standard processing to enqueue requests for WITNESSPRODUCTS
#
#  Always used as class, never instantiated
#
###################################################################

package WITNESSPRODUCT;
use Exporter ();
@ISA=qw(Exporter);

@EXPORT=qw();

use archActLogging;
use archLogging;
use archCache;
use archRequests;
use archReasons; # for areaForReason hash
use archWitnessUtil; # exports %witnessSessions
use archBeaconUtil; # exports @beaconSessions

sub process{
  my($self,$reasonNo,$group,$area,$value)=@_;
  my($thisGuid,$sc,$qc,$dq);

  cacheWitnessSessions() unless isCached("witness");
  cacheBeaconSessionProductInfo($witnessSessions{'earliest'}) unless isCached('beacon');
  cacheLogTable($witnessSessions{'earliest'}) unless isCached('log');

  $sc=0;$qc=0;
  for ($bsp=0;$bsp<=$#beaconSessions;$bsp++) {

    $thisGUID=$beaconSessions[$bsp]{'GUID'};
    if (!defined $witnessSessions{$thisGUID}) { # No witness session
      $sc++;
      next;
    }
    if ($value eq $beaconSessions[$bsp]{'PRODUCT'}) { # product is of interest
      $sr=$beaconSessions[$bsp]{"SESSIONID"}.".$reasonNo";
      if (isLogged(Session=>$beaconSessions[$bsp]{"SESSIONID"},Reason=>$reasonNo)) {
        next; # Logged for this reason, skip entirely
      }
      if ($why=isLogged(GUID=>$thisGUID,Area=>$areaForReason{$reasonNo})) {
        actLog("Debug","Logging Dup using ($why,$reasonNo,$area,$beaconSessions[$bsp]{'GUID'}) for GUID $thisGUID, area $areaForReason{$reasonNo}");
        # TODO 2007-05-30 did not fix function, commented out for now
        ###addLogRecordDup($why,$reasonNo,$area,$beaconSessions[$bsp]{'GUID'});
        next; # Logged for another reason, log as duplicate and skip
      }
      archRequests::enqueue('Witness','beacon',$area,$group,$value,$reasonNo,%{ $beaconSessions[$bsp] });
      $qc++;
    }
  }
}

1;
