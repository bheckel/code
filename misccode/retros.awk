#!/bin/awk -f

# Retrospect log check:

BEGIN {
  FS="\t";RS="\r";OFS="\t"
}

{
  three = substr($3,0,6);
  four = substr($4,0,7);
  # TODO wtf! this regex is not working
  if ( $9 !~ /Successful/ ) 
    ###if ( NR>1 ) printf "%-8s %-8s %-8s %-5s %-5s\n",$1,three,four,$5,$9
    print "ok"$9"then";
}
