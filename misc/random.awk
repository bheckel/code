#!/bin/awk -f


BEGIN {
  # Returns repeatable random numbers if you delete this line:
  srand();
  while( i<1000 ) {
    n = int(rand()*100);
    arr[n]++;
    i++;
  }
  for( i=0;i<=99;i++ ) {
    print i,"Occured", arr[i], "times";
  }
}
