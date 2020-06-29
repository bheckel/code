#!/bin/bash

# from /Drugs/Archive/readme.txt
# 
# This directory is being populated programmatically as certain files in /Drugs 
# age past n days.  Please do not add or delete files.
# 
# The directory structure /Drugs/Archive/Drugs is the same as /Drugs (a.k.a. /sasdata)
# 
# See /Drugs/Cron/Weekly/ArchiveOldFiles/archive.sh and Analytics' Folder
# Structure Specification.doc for details.
# 
# If a restore is required e.g. the archived folder T:\TMMEligibility\BowenPhar\Imports\20160115\Data 
# exists as T:\Archive\Drugs\TMMEligibility\BowenPhar\Imports\20160115\Data you can either use Putty:
# 
#   # This may not be necessary because folders are removed programmatically only if empty:
#   mkdir -p /Drugs/TMMEligibility/BowenPhar/Imports/20160115/Data
# 
#   $ cd /Drugs/TMMEligibility/BowenPhar/Imports/20160115/Data
# 
#   $ cp -i /Drugs/Archive/Drugs/TMMEligibility/BowenPhar/Imports/20160115/Data/wtf.sas7bdat.gz .
# 
#   # This is sometimes not necessary:
#   $ chmod g-s wtf.sas7bdat.gz
# 
#   $ gunzip wtf.sas7bdat.gz
# 
#   $ touch wtf.sas7bdat  # reset the clock on this file otherwise it'll be re-archived next Wednesday
# 
#   $ rm /Drugs/Archive/Drugs/TMMEligibility/BowenPhar/Imports/20160115/Data/wtf.sas7bdat.gz
# 
# Or open a JIRA ticket to Bob.

# EDIT
RESTORE=/Drugs/TMMEligibility/AssoFoodSt/Imports/20170228/Data

ARCH=/Drugs/Archive/${RESTORE}

mkdir -p $RESTORE

cp -i $ARCH/* $RESTORE

chmod g-s $RESTORE/*

for f in $(find $RESTORE -name *.gz);
  do
    echo $f
    gunzip $f
    # Reset the clock on the gunzipped file
    touch ${f%.*}
  done;


for f in $(find $ARCH -name *.gz);
  do
    # Re-archiving in n days needs this dir to be empty
    rm -v $f
  done;

# Intentionally not rmdir'ing the arch dir as a signal that "this archive has been restored"
