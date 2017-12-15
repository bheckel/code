
filename F 'e:\datapost\cfg\t.xml';

/***ods html body=_WEBOUT (dynamic title='browser titlebar') style=brick rs=none;***/
/***ods markup body=_WEBOUT tagset=xhtml;***/
/***proc print; run;***/
  data _null_;
  file _webout;
    infile F;
    input ;
    put _infile_;
  run;
/***ods html close;***/

%put _ALL_;
