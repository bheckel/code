
options metaserver="sas-01.twa.ateb.com"
        metaport=8561
        metauser="sasadm@saspw"
        metapass="sasadm"
        metarepository="Foundation";

proc metaoperate action=status; run;
