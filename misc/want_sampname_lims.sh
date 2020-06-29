#!/bin/sh

# S/b symlinked as ~/bin/wantsampname

if [ $# = 0 ]; then
  echo 'e.g. $ want_sampname_lims.sh 169194'
  echo '     Have samp_id, want Study Code or Batch i.e. LIMS'' sampname'
  echo '     wildcards the parm and does a putclip to be pasted into LIMS SQL*Plus'
  exit 1
fi

echo "select distinct sampid, sampname from result where sampid = '$1';"|putclip

echo clipboarded for lims
