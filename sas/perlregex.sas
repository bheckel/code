options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: perlregex.sas
  *
  *  Summary: Demo of using Perl regular expressions in SAS 9.
  *
  *           TODO can't use ? * etc in regex via Connect, must be on the mf
  *           to run
  *
  *                                                     g
  *           description=prxchange('s/MTM Program//', -1, description);
  *
  *  Adapted: Thu 15 Jan 2004 14:24:13 (Bob Heckel --
  *  http://support.sas.com/rnd/base/topics/datastep/perl_regexp/regexp2.html
  *                     or see ~/code/sas/perlregex.doc.html for my version)
  * Modified: Wed 11 Jan 2017 14:10:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data regex_substitute;
  x='one, two';
  x2=prxchange('s/(\w+), (\w+)/$2, $1/', -1, x);

  /* Remove @ and 1 */
  y='B@b-test_1';
  y2=prxchange('s/[^A-z-_]//', -1, y);

  output;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



data t;
  length text $20;
  id=1; text="acura car dealer"; output;
  id=2; text="acura used car dealer"; output;
  id=3; text="toyota deals"; output;
  id=4; text="deals for acura"; output;
  id=5; text="chevy car sales"; output;
run;
data t2;
  length type $20;
  set t;

  if prxmatch('/acura|toyota|hyundai|kia|honda/i', text) then type='Import';
  else if prxmatch('/ford|chevy|mercury|gm|jeep|pontiac/i', text) then type='Domestic';

  pos = prxmatch('/acura/', text);
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /*~~~~~~~~~~~~~~~~~~~~~~~~~V8+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
data _NULL_;
  retain rx;
  /* Only compile regex once. */
  if _N_ = 1 then 
    rx = rxparse("ave|avenue|dr|drive|rd|road");

  /* Matching */
  /* -------- */

  /* print "ok" if $foo =~ /ave/; 
   * or
   * perl -e '$foo='avenue';print "ok" if $foo=~/ave/'
   */
  rc = rxmatch(rx, 'Mulholland drive');

  if rc then
    put "!!!ok " rc=;
  else
    put "!!!didn't find it " rc=;

run;



 /*~~~~~~~~~~~~~~~~~~~~~~~~~V9+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
%let MYPAT=cat;

data tmp;
  /* This avoids having to recompile the regex for every obs. */
  if _n_ = 1 then 
    pattern_num = prxparse("/&MYPAT/"); 
  if missing(pattern_num) then
    do;
      put 'ERROR: problem compiling regex';
      stop;
    end;
  retain pattern_num; 

  input mystr $30.;
  /* prxmatch returns 0 on failure, otherwise first pos of match. */
  /*                 can use raw regex here but less efficient */
  /*                  ___________                              */
  position = prxmatch(pattern_num, mystr); 

  file PRINT; 
  put pattern_num= mystr= position=; 
  file LOG;
  put '!!!creating obs if ' position 'ne 0';
  
  if position gt 0 then 
    output;

  datalines; 
There is a cat in this line. 
Does not match CAT 
cat in the beginning 
At the end, a cat 
cat
  ;
run;
proc print data=_LAST_; run;


data _NULL_;
  retain rx;
  /* Only compile regex once. */
  if _N_ = 1 then 
    rx = rxparse("ave|avenue|dr|drive|rd|road");

  /* Matching */
  /* -------- */

  /* print "ok" if $foo =~ /ave/; 
   * or
   * perl -e '$foo='avenue';print "ok" if $foo=~/ave/'
   */
  rc = rxmatch(rx, 'Mulholland drive');

  if rc then
    put "!!!ok " rc=;
  else
    put "!!!didn't find it " rc=;

run;



 /* Simple match for data integrity/validation purposes. */
data tmp (drop= prx);
  retain prx;
  /* Only compile regex once. */
  if _N_ = 1 then 
    prx = prxparse("/bob+|heck/i");

  ***call prxdebug(prx);

  input username $;

  if ^prxmatch(prx, username) then
    do;
      putlog "NOTE: invalid username " username;
      delete;
    end;

  cards;
bobs
bo
bobobo
andheck
hecks
badone
  ;
run;
proc print; run;


 /* Simple match for text replacement purposes. */
data tmp (drop= prx);
  retain prx;
  if _N_ = 1 then 
    prx = prxparse("s/bob/WTF/i");

  input username $;

  /*              do max substitutions */
  /*                  __               */
  call prxchange(prx, -1, username);
  cards;
boBs
bo
bobobob
andheck
hecks
badone
  ;
proc print; run;


 /* Simple match for text extraction purposes. */
data tmp (drop= prx);
  retain prx;
  if _N_ = 1 then 
    prx = prxparse("/(\d\d\d)-(.*)/");

  input phone $;

  if prxmatch(prx, phone) then
    do;
      /* $1 */
      call prxposn(prx, 1, pos, len);
      exchange = substr(phone, pos, len);

      /* $2 */
      call prxposn(prx, 2, pos, len);
      suffix = substr(phone, pos, len);
    end;

  cards;
123-4567
338-9761
adjlbaddata
999-asdf
232-6752
  ;
run;
proc print; run;


data _NULL_;
  retain prx;
  if _N_ = 1 then 
    prx = prxparse("/ave|avenue|dr|drive|rd|road/i");

  /* Matching */
  /* -------- */

  /* print "ok" if $foo =~ /ave/; 
   * or
   * perl -e '$foo='avenue';print "ok" if $foo=~/ave/'
   */
  rc = prxmatch(prx, 'Mulholland Drive');

  if rc then
    put "!!!ok " rc=;
  else
    put "!!!didn't find it " rc=;

  /* Supposed to be like m/foo/g but not sure this is the best approach. */
  start = 1;  /* must > 0 */
  /* Not greedy!  Finds Dr instead of Drive! */
  call prxnext(prx, start, -1, 'Mulholland Drive Road St ave', pos, len);
  put "!!! " start= pos= len=;
  /* Finds 'Road' */
  call prxnext(prx, start, -1, 'Mulholland Drive Road St ave', pos, len);
  put "!!! " start= pos= len=;
  /* Finds 'ave' */
  call prxnext(prx, start, -1, 'Mulholland Drive Road St ave', pos, len);
  put "!!! " start= pos= len=;

  call prxfree(prx);


  /* Substitution */
  /* ------------ */

  /* $ perl -e 'BEGIN{$x='bobdylan'};($y=$x)=~s/o/aaa/g;END{print $y}' */
  s = 'Mulholland Drive';
  prx2 = prxparse("s/(.*)\sDrive/$1 Boulevard/");
  call prxchange(prx2, -1, s);
  put "!!! " s=;
run;


data _NULL_;
  retain prx;
  if _N_ = 1 then 
    prx = prxparse("/ave|avenue|dr|drive|rd|road/i");

  input street $80.;

  /* Roughly  $ perl -e '$x='bobh';$x =~ /bob/;print length $&' */
  /* Variable pos, the 1st char at which match occurred, is filled 
   * indirectly. 
   */
  call prxsubstr(prx, street, pos, len);

  if pos then
    do;
      put "!!! " pos=;
      match = substr(street, pos, len);
      ***put match:$QUOTE. 'found in ' street:$QUOTE.;
      put "!!! " match ' found in ' street;
    end;

  datalines;
153 First Street
6789 64th Ave
4 Moritz Road
7493 Wilkes Place
  ;
run;


%macro bobh;
 /* TODO this one won't run on MF, probably EBCDIC crap */
data _NULL_;
  retain prx;
  if _N_ = 1 then
    prx = prxparse('/(\d+):(\d\d)(?:\.(\d+))?/');

  array match[3] $ 8;
  input minsec $80.;

  /* pos filled directly */
  pos = prxmatch(prx, minsec);

  if pos ne 0 then
    do;
      do i = 1 to prxparen(prx);
        call prxposn(prx,i,start,len);
        if start ne 0 then
          match[i] = substr(minsec,start,len);
    end;

    put match[1] 'minutes, ' match[2] 'seconds' @;
    if not missing(match[3]) then
      put ', ' match[3] 'millsec';
  end;

  datalines;
14:56.456
45:32
  ;
run;
%mend bobh;
