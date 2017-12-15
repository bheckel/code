#!/bin/sh

read yesno

if [ "$yesno" = 'y' ]; then
  echo 'yes'
else 
  echo 'not yes'
fi

echo 'done'



echo "Shall I remove the temporary files now? [y/n] "
read tmp
case $tmp in
  [Yy]*)
    cd
    \ls -l ${WORKDIR}
    ;;
esac
