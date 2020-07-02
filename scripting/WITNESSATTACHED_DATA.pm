###################################################################
#
#  WITNESSATTACHED_DATA.pm
#
#  Provide standard processing to enqueue requests for 
#  WITNESSATTACHED_DATA
#
#  Always used as class, never instantiated
#
###################################################################

package WITNESSATTACHED_DATA;
use Exporter ();
@ISA=qw(Exporter);

@EXPORT=qw();

use archActLogging;
use archLogging;
use archCache;
use archRequests;
use archReasons; # for areaForReason hash
use archWitnessUtil; # exports %witnessADSessions
use archBeaconUtil; # exports @beaconSessions

sub process{
  my($self,$reasonNo,$group,$area,$value)=@_;
  my($thisGuid,$sc,$qc,$dq);

  cacheWitnessSessions() unless isCached("witness");
  cacheBeaconSessionProductInfo($witnessSessions{'earliest'}) unless isCached('beacon');
  cacheLogTable($witnessSessions{'earliest'}) unless isCached('log');

  # For the existing Lit Hold reasons (where SEARCH_TYPE_ID = '1') we use the
  # existing product matching logic.  For caller reasons (SEARCH_TYPE_ID =
  # '2') we will use the CRCARCH.WITNESS.get_attached_data_contacts and
  # CRCARCH.BEACON.get_all_contacts The merge will be based on GUIDs that
  # appear in both lists.

  $sc=0;$qc=0;
  for ($bsp=0;$bsp<=$#beaconSessions;$bsp++) {
    $thisGUID=$beaconSessions[$bsp]{'GUID'};
    if (!defined $witnessADSessions{$thisGUID}) { # no witness AD session
      $sc++;
      next;
    } else { # witness AD session is of interest
      $sr=$beaconSessions[$bsp]{'SESSIONID'}.".$reasonNo";
      if (isLogged(Session=>$beaconSessions[$bsp]{'SESSIONID'},Reason=>$reasonNo)) {
        next; # Logged for this reason, skip entirely
      }
      if ($why=isLogged(GUID=>$thisGUID,Area=>$areaForReason{$reasonNo})) {
#        actLog("Debug","Logging Dup using ($why,$reasonNo,$area,$beaconSessions[$bsp]{'GUID'}) for GUID $thisGUID, area $areaForReason{$reasonNo}");
        next; # Logged for another reason, log as duplicate and skip
      }
      archRequests::enqueue('Witness','beacon',$area,$group,$value,$reasonNo,%{ $beaconSessions[$bsp] });
      $qc++;
    }
  }
}

1;
