#!/bin/awk -f

BEGIN {
  FS="\t";RS="\r";OFS="\t"
}

{
  three = substr($3,0,6);
  four = substr($4,0,7);

  if ( $1 ~ /eplic.nt/ ) 
    # printf "%-8s\n",$1;
    print $1
    # if ( NR>1 )
      # printf "%-8s %-8s %-8s %-5s %-5s\n",$1,three,four,$2,$3;
}
