drop database link RION_PROD_RO.VSP.AS.COM;

CREATE DATABASE LINK RION_PROD_RO.VSP.AS.COM CONNECT TO SE_ATLAS IDENTIFIED BY "xxxx" 
  USING
  '
  (DESCRIPTION=(ENABLE=BROKEN)
               (RETRY_COUNT=20)
               (RETRY_DELAY=3)
               (ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=plcm05.unx.as.com)(port=6500)))
               (ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=plcm06.unx.as.com)(port=6500)))
               (ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=plcm07.unx.as.com)(port=6500)))
               (ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=plcm08.unx.as.com)(port=6500)))
               (CONNECT_DATA=(SERVICE_NAME=rndbprd01ro.vsp.as.com))
  )
  '
;
