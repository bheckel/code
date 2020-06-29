#!/bin/sh
##############################################################################
#     Name: ls-fulltime.sh
#
#  Summary: Change the 8th field of 'ls -l' from time to year.
#           Alternative to GNU  $ ls -l --full-time foo
#
#  Adapted: Wed 15 Dec 2004 10:31:55 (Bob Heckel --
#                      http://www.unixreview.com/documents/s=8989/ur0412d/)
##############################################################################

# If no command line arguments, display only the current directory

xmon=`date '+%m'`
xyear=`date '+%Y'`

\ls -l $* |awk ' {
  #if(NF < 9)
  #   continue

  if(index($8, ":") )
     if(month_no($6) > mm)
        $8=yy-1
     else
        $8=yy

  fname=$9
  # if more than 9 fields, the file name is actually a link.
  # append the link fields so it displays.
  if(NF > 9)
     for(i=10; i<=NF; i++)
        fname=fname" "$i

  printf("%s %s %-8s %-8s %9s %3s %2s %4s %s \n", $1, $2, $3, $4, $5, $6, $7, $8, fname)
  } 

  function month_no(mm) {
  if(mm == "Jan")
     return 1
  if(mm == "Feb")
     return 2
  if(mm == "Mar")
     return 3
  if(mm == "Apr")
     return 4
  if(mm == "May")
     return 5
  if(mm == "Jun")
     return 6
  if(mm == "Jul")
     return 7
  if(mm == "Aug")
     return 8
  if(mm == "Sep")
     return 9
  if(mm == "Oct")
     return 10
  if(mm == "Nov")
     return 11
  if(mm == "Dec")
     return 12
  return 0
} 

' mm="$xmon" yy="$xyear"
  
