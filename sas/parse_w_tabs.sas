/*----------------------------------------------------------------------------
 * Program Name: parse_w_tabs.sas
 *
 *      Summary: Output a tab delim file.
 *
 *      Created: Fri Jan 22 1999 11:55:18 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer number serror merror;

title; footnote;
options source notes stimer errors=5 symbolgen mlogic mprint;

macro templmcr(rgn=);
  filename REGION '~bh1/Todel/&rgn.txt' lrecl=400;
  data _null_ ;
    set work.temp2;
     file REGION;
       where rptg_rgn=&rgn;
       if _n_=1 then
         do;
           put 'Reporting Rgn'     '09'x
               'Class'             '09'x
               'Job'               '09'x
               'Location'          '09'x
               'State'             '09'x
               'Holdco'            '09'x
               'Supervisor'        '09'x
               'Product Line'      '09'x
               'Product Code'      '09'x
               'Sched DCI'         '09'x
               'H-Date'            '09'x
               'Committed K-Date'  '09'x
               'Inst Source'       '09'x
               'Inst Tgt Hrs'      '09'x
               'Inst Act Hrs'      '09'x
               'Inst Hrs Left'     '09'x
               'Inst Tgt Cost'     '09'x
               'Inst Act Cost'     '09'x
               'Inst Complete'     '09'x
               ;
         end;

         put rptg_rgn            '09'x
             class               '09'x
             job_id              '09'x
             job_loc             '09'x
             st                  '09'x
             holdco              '09'x
             supervsr            '09'x
             prodline            '09'x
             prodcode            '09'x
             schd_dci            '09'x
             h_date              '09'x
             k_date              '09'x
             source_i            '09'x
             hrstrgi             '09'x
             iacthrs             '09'x
             ihrslft             '09'x
             dolrtrgi            '09'x
             i_cost              '09'x
             ipercom             '09'x
             ;
  run;
mend templmcr;

/* Sample call: */
%templmcr(rgn='BAT');
