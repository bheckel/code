#!/bin/sh

META=//rtpsawnv0312/pucc/ADVAIR_HFA/INPUT_DATA_FILES/LINKS_DATA/

date

if [ `find $META -maxdepth 1 -name 'lemetadata_advairhfa.sas7bdat' -not -mtime 0` ];then
  ls -l $META/lemetadata_advairhfa.sas7bdat
  cp -v //rtpsawn323/SQL_Loader/Metadata/lemetadata_advairhfa.sas7bdat $META/
  ls -l $META/lemetadata_advairhfa.sas7bdat
else
  echo no copy needed
fi

date
