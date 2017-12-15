#!/bin/sh

# Must be tested on a system with a running procmail.

if [ $# -ne 2 ]; then
  echo "usage: procmail_sim.sh < mail.msg"
  exit 1
fi

TESTDIR=$HOME/tmp/testing/procmailtest
if [ ! -d ${TESTDIR} ]; then
  echo "Directory ${TESTDIR} does not exist; First create it"
  exit 0
fi

# Feed an email message to procmail. Apply proctest.rc recipes file.
# First prepare a mail.msg email file which you wish to use for the
# testing.
procmail ${TESTDIR}/rc.subjpattern < ${TESTDIR}/mail.msg
#
# Show the results.
less ${TESTDIR}/Procsim.log
###less ${TESTDIR}/Procsim.mail
#
# Clean up.
###rm -v ${TESTDIR}/Procsim.log
###rm -i ${TESTDIR}/Procsim.mail



# Sample rc.subjpattern:
###SHELL=/bin/sh
###TESTDIR=$HOME/tmp/testing/procmailtest
###MAILDIR=${TESTDIR}
###LOGFILE=${TESTDIR}/Procsim.log
###LOG="--- Logging for ${LOGNAME}, "
###
####Troubleshooting:
###VERBOSE=yes
###LOGABSTRACT=all
###
#### This catches spamming bastards who uses spaces to conceal one of their
#### identifier strings at the end of the subject line.
#### E.g. The Road to Financial Freedom               qpwrtixhhv
###:0:
###* ^Subject:.*(                  ?)+[a-z0-9]+$
###PotentialSpam
