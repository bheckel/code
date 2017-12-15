options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: trafficlight.sas
  *
  *  Summary: Demo of red yellow green highlighting
  *
  *  Created: Tue 15 Oct 2013 10:51:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc format;
  value traffic LOW-10  = 'red'
                11-20   = 'yellow'
                21-HIGH = 'green'
                ;
run;

ods listing close;
ods html body='t.htm';
proc report data=sashelp.shoes;
  columns subsidiary product stores;
  define subsidiary / order;
  define stores / style(column)={background=traffic.};
run;
ods html close;
ods listing;



endsas;
proc format;
  value $bgclr 'M'='blue'
               'F'='red'
               ;
run;
ods html body='t.htm';
proc report data=sashelp.class;
  columns name sex;
  define name / order;
  define sex / style(column)={background=$bgclr.};
run;
ods html close;



endsas;
data _null_ ; 
/***      file _webout ; ***/
  file 't.html'; 
  set SASHELP.shoes(keep=region sales) end=last ; 
  /* Conditionally format all the fields */ 
  if _n_=1 then do; 
    put '<HTML>'; 
    put '<HEAD>'; 
    put "<TITLE>Thymesheet</TITLE>"; 
    put '<STYLE>'; 
    put '#header { background-color:#6495ED; color:white; }'; 
    put '#rowA { background-color:#FFFFFF; }'; 
    put '#rowB { background-color:#EEEEEE; }'; 
    put '#region { width:100%; height:320; overflow:scroll; }'; 
    put '@media print {'; 
    put '#noprint { display:none; }'; 
    put '#region { width:100%; height:100%; overflow:visible; }'; 
    put '}'; 
    put '</STYLE>'; 
    put '</HEAD>'; 
    put '<BODY>'; 
    put "<H2 ALIGN=center>Annual Thymesheet</H2>"; 
    put '<HR>'; 
    put '<TABLE ALIGN=center><TR><TD>'; 
    put '<TABLE CELLPADDING=4 BORDER=1>'; 
    /* Build the colgroup */ 
    put '<TR ID=header ALIGN=center>'; 
    put '<TD TITLE="Region">Region</TD>'; 
    put '<TD TITLE="Sales">sales</TD>'; 
    put '</TR>'; 
    put '</TABLE>'; 
    put '</TD></TR><TR><TD>'; 
    put '<DIV ID=region>'; 
    put '<TABLE CELLPADDING=4 BORDER=1>'; 
    /** Build the colgroup as before **/ 
  end; 
  if mod(_n_, 2)=1 then put '<TR ID=rowA>'; 
  else put '<TR ID=rowB>'; 
  put '<TD>' region '</TD><TD>' sales '</TD>';
  if last then do; 
    put '</TABLE></DIV>'; 
    put '</TD></TR></TABLE>'; 
  end; 
run; 
