options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_stream.sas
  *
  *  Summary: Demo of inserting data from two sources into an .html
  *
  *  Adapted: Wed 10 Aug 2016 11:18:40 (Bob Heckel--http://support.sas.com/resources/papers/proceedings14/1738-2014.pdf)
  * Modified: Fri 02 Dec 2016 08:53:50 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

filename temp "~/bob/t.html";

%macro create_table;
  ods html file=temp(nobot notop);
  proc print data=sashelp.orsales(obs=5); run;
  ods html close;
%mend;

%let co=ABC;
%let bulletsymbol=%nrstr(&#8226);

filename output "~/bob/stream.html";

proc stream outfile=output resetdelim='label';
  BEGIN
  <html>
    <head>
      <style>
        .header {background-color:lightblue}
        .footer {font-weight:bold}
        h2,h3 {text-align:center}
      </style>
      <h2>&bulletsymbol Report for Company &co &bulletsymbol</h2>
      <h3> Date: %sysfunc(date(),date.)</h3>
    </head>
    <body>
      label;
        %let rc=%sysfunc(dosubl('%create_table'));
        %include temp;
        %let rc=%sysfunc(dosubl(
          proc sql noprint;
            select sum(profit) %str(,) avg(profit) %str(,) max(profit) into :sum %str(,):avg %str(,):max
            from sashelp.orsales
            ;
          quit;
        ));
        <table>
          <tr>
            <td class="footer">Sum_Profit: %sysfunc(putn(&sum,dollar14.2))</td>
          </tr>
          <tr>
            <td class="footer">Avg_Profit: %sysfunc(putn(&avg,dollar10.2))</td>
          </tr>
          <tr>
            <td class="footer">Max_Profit: %sysfunc(putn(&max,dollar10.2))</td>
          </tr>
        </table>
    </body>
    </html>
;;;; 
run;
