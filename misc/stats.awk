# This awk program collects statistics on two 
# "random variables" and the relationships 
# between them. It looks only at fields 1 and 
# 2 by default Define the variables F and G 
# on the command line to force it to look at
# different fields.  For example: 
# awk -f stat_2o1.awk F=2 G=3 stuff.dat \
# F=3 G=5 otherstuff.dat
# or, from standard input: 
# awk -f stat_2o1.awk F=1 G=3
# It ignores blank lines, lines where either 
# one of the requested fields is empty, and 
# lines whose first field contains a number 
# sign. It requires only one pass through the
# data. This script works with vanilla awk 
# under SunOS 4.1.3.
BEGIN{
  F=1;
  G=2;
}
length($F) > 0 && \
length($G) > 0 && \
$1 !~/^#/ {
  sx1+= $F; sx2 += $F*$F;
  sy1+= $G; sy2 += $G*$G;
  sxy1+= $F*$G;
  if( N==0 ) xmax = xmin = $F;
  if( xmin > $F ) xmin=$F;
  if( xmax < $F ) xmax=$F;
  if( N==0 ) ymax = ymin = $G;
  if( ymin > $G ) ymin=$G;
  if( ymax < $G ) ymax=$G;
  N++;
}
 
END {
  printf("%d # N\n"   ,N   );
  if (N <= 1) 
    {
    printf("What's the point?\n");
    exit 1;
    }
  printf("%g # xmin\n",xmin);
  printf("%g # xmax\n",xmax);
  printf("%g # xmean\n",xmean=sx1/N);
  xSigma = sx2 - 2 * xmean * sx1+ N*xmean*xmean;
  printf("%g # xvar\n"         ,xvar =xSigma/  N  );
  printf("%g # xvar unbiased\n",xvaru=xSigma/(N-1));
  printf("%g # xstddev\n"         ,sqrt(xvar ));
  printf("%g # xstddev unbiased\n",sqrt(xvaru));
  
  printf("%g # ymin\n",ymin);
  printf("%g # ymax\n",ymax);
  printf("%g # ymean\n",ymean=sy1/N);
  ySigma = sy2 - 2 * ymean * sy1+ N*ymean*ymean;
  printf("%g # yvar\n"         ,yvar =ySigma/  N  );
  printf("%g # yvar unbiased\n",yvaru=ySigma/(N-1));
  printf("%g # ystddev\n"         ,sqrt(yvar ));
  printf("%g # ystddev unbiased\n",sqrt(yvaru));
  if ( xSigma * ySigma <= 0 )
    r=0;
  else 
    r=(sxy1 - xmean*sy1- ymean * sx1+ N * xmean * ymean) / sqrt(xSigma * ySigma);
  printf("%g # correlation coefficient\n", r);
  if( r > 1 || r < -1 )
    printf("SERIOUS ERROR! CORRELATION COEFFICIENT");
    printf(" OUTSIDE RANGE -1..1\n");

  if( 1-r*r != 0 )
    printf("%g # Student's T (use with N-2 degfreed)\n&", \
      t=r*sqrt((N-2)/(1-r*r)) );
  else
    printf("0 # Correlation is perfect,");
    printf(" Student's T is plus infinity\n");
  b = (sxy1 - ymean * sx1)/(sx2 - xmean * sx1);
  a = ymean - b * xmean;
  ss=sy2 - 2*a*sy1- 2*b*sxy1 + N*a*a + 2*a*b*sx1+ b*b*sx2 ;
  ss/= N-2;
  printf("%g # a = y-intercept\n", a);
  printf("%g # b = slope\n"      , b); 
  printf("%g # s^2 = unbiased estimator for sigsq\n",ss);
  printf("%g + %g * x # equation ready for cut-and-paste\n",a,b);
  ra = sqrt(ss * sx2 / (N * xSigma));
  rb = sqrt(ss       / (    xSigma));
  printf("%g # radius of confidence interval ");
  printf("for a, multiply by t\n",ra);
  printf("%g # radius of confidence interval ");
  printf("for b, multiply by t\n",rb);
}    
