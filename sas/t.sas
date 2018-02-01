%let amp = %nrstr(&);
%let param = s=sugi&amp.c=sugi&amp.x=;
%let lex = http://lexjansen.com/cgi-bin/xsl_transform.php?&param;
filename sgf2010 url "&lex.sgf2010" encoding="utf-8"; /* c */
data titles;
 infile sgf2010 lrecl=10000 truncover;
 input line $10000.;
 sgf = prxmatch("|sgf2010\.|", line); /* d */
 hilite = prxmatch("|hilite|", line);
 if sgf and not hilite;
 id = substr(substr(line,sgf), 9, 8);
 title = prxchange("s|.*>([^>]+)</a><br />.*$|$1|", 1, line); /* e */
 keep id title;
run;
filename sgf2010 clear; 
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
