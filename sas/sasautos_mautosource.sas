
options compress=yes source source2 fullstimer ls=180 ps=max mautosource 
        sasautos="./lib" mprint NOmlogic sgen NOcenter xsync NOxwait
        ;

 /* lib/m.sas holds 2 macros, %ok and %nok, there's no macro called %m 
  * but the other 2 aren't visible without this call
  */
%m

%ok
%nok
