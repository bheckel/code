#!/bin/bash
##############################################################################
#     Name: dpcfg.sh
#
#  Summary: Apply (actually override) XSLT to an XML file.
#
#           E.g.
#           $ dpcfg x
#           $ dpcfg 'U:\x\Datapost91484\cfg'
#
#  Created: Fri 18 Mar 2011 09:10:40 (Bob Heckel)
# Modified: Wed 20 Apr 2011 10:00:33 (Bob Heckel)
##############################################################################
  
[ $# -lt 1 ] && echo \
"Usage: $0 [c|x|y|z|yourpathtoXML]
Provides snapshot of current XML config state 
Uses dev xslt in c:\datapost\cfg" \
&& exit 1

rm $TEMP/dpcfg.xml

cat <<HEREDOC > $TEMP/dpcfg.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="file:///c:/datapost/cfg/DataPost_Configuration.xslt"?>
HEREDOC

if [ $1 = 'c' -o $1 = 'x' -o $1 = 'y' -o $1 = 'z' ];then
  F=/cygdrive/${1}/DataPost/cfg/DataPost_Configuration.xml
###elif [ $1 = 'c' ];then
  ###F=/cygdrive/c/DataPost/cfg/DataPost_Configuration.xml
else
  F="$1/DataPost_Configuration.xml"
fi

# Insert header and XSLT ref - note this is fragile!
tail -n +2 "$F" >> $TEMP/dpcfg.xml

###echo -n 'open in default browser? '
###read yn
###if [ ! -z $yn ];then
  cygstart $TEMP/dpcfg.xml
###fi
