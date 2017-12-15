/*----------------------------------------------------------------------------
 *     Name: custfin.sas
 *
 *  Summary: Creates tab-delimited ("xls") Open & Final Job output for
 *                 The ILEC Region for both Installation and Engineering jobs.
 *
 *   Created: 20Apr98 (Joe Szigeti)
 *  Modified: 09Jul98 (Rick Guggemos / Bob Heckel)
 *  Modified: 11Aug98 (Bob Heckel - minor OM structure changes, etc.)
 *  Modified: 09Dec98 (Bob Heckel - Open criteria now captures current
 *                     week minus one that was formerly missed by
 *                     both Open and Final criteria)
 *  Modified: 06Jan99 (Bob Heckel - year end date modifications and add
 *                     regions C214 & C218)
 *  Modified: 21Jan99 (Bob Heckel - minor OM93 correction)
 *  Modified: 16Feb99 (Bob Heckel - OM arrays must be alphabetized for VB
 *                     to work properly; changed sort order costxtmp,
 *                     exchanging rgncode with distcode)
 *  Modified: 04May99 (Bob Heckel - OTHR category not capturing nulls.
 *                     Use macrovariable for prior yr end)
 *  Modified: 11Oct99 (Bob Heckel - include CP01, CP02, etc. OMs
 *                     to distcode ifthens section)
 *  Modified: 16Dec99 (Bob Heckel - add rgn C219, elim C218)
 *  Modified: 23Dec99 (Bob Heckel - remove ISPN from else ifs)
 *  Modified: 04Jan00 (Bob Heckel - Used only for yrend run from a frozen 
 *                     jobcost perf and perfd. Hardcode FWEEKs.) 
 *                     NEVER PUT INTO PRODUCTION.
 *  Modified: 07Jan00 (Bob Heckel - modi for yr 2000, undo all 04Jan00
 *                     changes.) NEVER PUT INTO PRODUCTION.
 *  Modified: Thu, 13 Jan 2000 10:21:58 (Bob Heckel - major revision--travel
 *                                       and contractor vs RFT added.  Intend
 *                                       to put into production on 1/31/00.)
 *                                       NEVER PUT INTO PRODUCTION.
 *  Modified: Fri, 28 Jan 2000 15:55:59 (Bob Heckel -- bug fixes, titles)
 *  Modified: Tue, 29 Feb 2000 10:13:54 (Bob Heckel -- new ISS OM Structure)
 *  Modified: Wed, 01 Mar 2000 11:19:49 (Bob Heckel -- new IOC regions)
 *  Modified: Sat, 08 Apr 2000 09:47:02 (Bob Heckel -- i_cost e_cost silently
 *                                       hold travel dollars so remove travel)
 *----------------------------------------------------------------------------
 */
options nosymbolgen mlogic mprint notes errors=3;

libname master '/disc/data/master';

/* Where to put costx and rgn independents. */
/* DEBUG */
/*** libname custfin '~bh1/tmp/testcustfin'; ***/
/* Use for production: */
libname custfin "&webpath/ServOpsFinance";

/* Change yearly to refer to last fiscal week of prior year. */
/* Use for production: */
%let YYYYWW = 199952;

/* DEBUG   No trailing slashes, no quotes. */
/*** %let OUTPUTTO = ~bh1/tmp/testcustfin; ***/
/* Use for production: */
%let OUTPUTTO = /DART2/ServOpsFinance;


/* Create tab delimited text file from a SAS data set. */
%macro dswrite(dsname=,    /* library.dataset */
               file=  ,    /* report file     */
               dlm=);      /* delimiter       */
  %put NOTE: *** Macro DSWRITE beginning execution ***;
  /* Assume zero records found */
  %let rptobs = 0;
  /* Create library and dataset name macro variables */
  %let lib = %upcase(%scan(%quote(&dsname), 1, %str(.)));
  %let dsn = %upcase(%scan(%quote(&dsname), 2, %str(.)));

   /* Get variable information for specific dataset */
  proc sql noprint;
    create view work.ds_dict as
      select *
        from dictionary.columns
          where libname = "&lib" and
                memname = "&dsn";
  quit;

  /* Setup variables and formats for writing to file */
  data _null_;
    set work.ds_dict end=eof;
    /* Use variable name if label is blank */
    if label eq ' ' then
       label = name;
    /* Report run date */
    call symput('RUNDATE', put(today(), yymmdd10.));
    /* Get variable names, labels and formats */
    call symput('VAR'   !! left(put(_n_, 3.)), name);
    call symput('LABEL' !! left(put(_n_, 3.)), label);
    if upcase(type) eq 'CHAR' then
       call symput('FORMAT' !! left(put(_n_, 3.)), '$' !! put(length, 3.) !! '.');
    else
    if format ne ' ' then
       call symput('FORMAT' !! left(put(_n_, 3.)), format);
    else
       call symput('FORMAT' !! left(put(_n_, 3.)), 'best10.');
    if (eof) then
       call symput('NUMVAR', left(put(_n_, 3.)));
  run;

  /* Reset macro variable if records found */
  data _null_;
    set &dsname nobs=rptobs;
    call symput('RPTOBS', rptobs);
    stop;
  run;

  %if &rptobs ne 0 %then
  %do;  /* records found */

  /* Write data to file */
  data _null_;
    set &dsname;
    array chars _character_;
    /* File name */
    file "&file" lrecl=32750;
    /* Strip out any tab characters */
    do over chars;
       chars = compress(chars, '09'x);
    end;
    if _n_ eq 1 then
    do;  /* Report title and header */
       /* Write header */
       put
       %do i=1 %to &numvar;
          "&&label&i" &dlm
       %end;
       ;
    end; /* Report title and header */
    /* Write data */
    put
    %do i=1 %to &numvar;
       &&var&i &&format&i &dlm
    %end;
    ;
  run;

  %end; /* Records found */
  %else
  %do;  /* No records found */
    data _null_;
       /* File name */
      file "&file" lrecl=32750;
      put 'No records found';
    run;
  %end; /* No records found */
%mend dswrite;

 /************************************************************************/
 /************************************************************************/

 /* This macro will produce Open Jobs reports for each of the accounts. */
 %macro openreg;
   /* Create reporting region datasets. */
   %do j=1 %to &norgns;
      data work.&&rgn&j;
      /* Common */
        attrib distcode label = 'Ops Mgr'
                       length = $5
              class    label  = 'Class'
                       length = $1
              job_id   label  = 'Job'
              job_loc  label  = 'Location'
              st       label  = 'State'
              holdco   label  = 'Holdco'
              supervsr label  = 'Supervisor'
              prodline label  = 'Product Line'
              prodcode label  = 'Product Code'
/***               schd_dci label  = 'Sched DCI' ***/
              d_date   label  = 'D-Date'
              h_date   label  = 'H-Date'
              k_date   label  = 'Committed K-Date'

              source_i label  = 'Inst Source'
              hrstrgi  label  = 'Inst Tgt Hrs'
              emphrsi  label  = 'Inst RFT Hrs'
              ctrhrsi  label  = 'Inst Contractor Hrs'
              iacthrs  label  = 'Inst Tot Act Hrs'
              ihrslft  label  = 'Inst Hrs Left'
              dolrtrgi label  = 'Inst Tgt Cost'
              i_cost   label  = 'Inst Act Labor Cost'
              ipercom  label  = 'Inst Complete'
                       format = percent10.0
              itottrav label  = 'Inst Travel Cost'
              itotdol  label  = 'Inst Labor+Trav Act Cost'

              source_e label  = 'Total Eng Source'
              hrstrge  label  = 'Total Eng Tgt Hrs'
              emphrse  label  = 'Total Eng RFT Hrs'
              ctrhrse  label  = 'Total Eng Contractor Hrs'
              eacthrs  label  = 'Total Eng Act Hrs'
              ehrslft  label  = 'Total Eng Hrs Left'
              dolrtrge label  = 'Total Eng Tgt Cost'
              e_cost   label  = 'Total Eng Act Labor Cost'
              epercom  label  = 'Total Eng Complete'
                       format = percent10.0
              etottrav label  = 'Total Eng Travel Cost'
              etotdol  label  = 'Total Eng Labor+Trav Act Cost'

              htrgeea    label  = 'EAE Tgt Hrs'
              eactheae   label  = 'EAE Act Hrs'
              ehlfteae   label  = 'EAE Hrs Left'
              dtrgeea    label  = 'EAE Tgt Cost'
              e_csteae   label  = 'EAE Act Cost'
              eperceae   label  = 'EAE Complete'
                         format = percent10.0

              htrgefe    label  = 'FE Tgt Hrs'
              eacthfe    label  = 'FE Act Hrs'
              ehlftfe    label  = 'FE Hrs Left'
              dtrgefe    label  = 'FE Tgt Cost'
              e_cstfe    label  = 'FE Act Cost'
              epercfe    label  = 'FE Complete'
                         format = percent10.0

              htrgeot    label  = 'OTHR Tgt Hrs'
              eacthot    label  = 'OTHR Act Hrs'
              ehlftot    label  = 'OTHR Hrs Left'
              dtrgeot    label  = 'OTHR Tgt Cost'
              e_cstot    label  = 'OTHR Act Cost'
              epercot    label  = 'OTHR Complete'
                         format = percent10.0

              htrgepa     label  = 'PAE Tgt Hrs'
              eacthpae    label  = 'PAE Act Hrs'
              ehlftpae    label  = 'PAE Hrs Left'
              dtrgepa     label  = 'PAE Tgt Cost'
              e_cstpae    label  = 'PAE Act Cost'
              epercpae    label  = 'PAE Complete'
                          format = percent10.0

              htrgesa     label  = 'SAE Tgt Hrs'
              eacthsae    label  = 'SAE Act Hrs'
              ehlftsae    label  = 'SAE Hrs Left'
              dtrgesa     label  = 'SAE Tgt Cost'
              e_cstsae    label  = 'SAE Act Cost'
              epercsae    label  = 'SAE Complete'
                          format = percent10.0

              htrgesd     label  = 'SDE Tgt Hrs'
              eacthsde    label  = 'SDE Act Hrs'
              ehlftsde    label  = 'SDE Hrs Left'
              dtrgesd     label  = 'SDE Tgt Cost'
              e_cstsde    label  = 'SDE Act Cost'
              epercsde    label  = 'SDE Complete'
                          format = percent10.0

              htrgess     label  = 'SSE Tgt Hrs'
              eacthsse    label  = 'SSE Act Hrs'
              ehlftsse    label  = 'SSE Hrs Left'
              dtrgess     label  = 'SSE Tgt Cost'
              e_cstsse    label  = 'SSE Act Cost'
              epercsse    label  = 'SSE Complete'
                          format= percent10.0
              ;

        set work.costxtmp ;
          /* Open Criteria (D's a maximum of 12 weeks after the run week).
           * TWELVEWK is 84 days in future
           *
           * NO LONGER REQUIRED 1/2000---
           * Without PRIORWKO, jobs with FTSDT == prior wk are not reported as
           * Open nor Final.  They would be "missing" from the two reports.
           * 199200 is prior to the creation of DART.
           */
/***           where (ftsdate < 199200 or ftsdate = &PRIORWKO) and ***/
          where (ftsdate < 199200) and
                d_date < &TWELVEWK and
                prodcode not in ('SWBILL','NTBILL','CSBILL','SABILL') and
                /* O was added for 2000. */
                prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
                rptg_rgn = "&&rgn&j";

                 /* Common */
            keep distcode
                 class
                 job_id
                 job_loc
                 st
                 holdco
                 supervsr
                 prodline
                 prodcode
/***                  schd_dci ***/
                 d_date
                 h_date
                 k_date

                 /* Installation */
                 source_i
                 hrstrgi
                 emphrsi
                 ctrhrsi
                 iacthrs
                 ihrslft
                 dolrtrgi
                 i_cost
                 ipercom
                 itottrav
                 itotdol

                 /* Engineering */
                 source_e
                 hrstrge
                 emphrse
                 ctrhrse
                 eacthrs
                 ehrslft
                 dolrtrge
                 e_cost
                 epercom
                 etottrav
                 etotdol
                 etotdol

                 /* EAE */
                 htrgeea
                 eactheae
                 ehlfteae
                 dtrgeea
                 e_csteae
                 eperceae

                 /* FE */
                 htrgefe
                 eacthfe
                 ehlftfe
                 dtrgefe
                 e_cstfe
                 epercfe

                 /* OTHR */
                 htrgeot
                 eacthot
                 ehlftot
                 dtrgeot
                 e_cstot
                 epercot

                 /* PAE */
                 htrgepa
                 eacthpae
                 ehlftpae
                 dtrgepa
                 e_cstpae
                 epercpae

                 /* SAE */
                 htrgesa
                 eacthsae
                 ehlftsae
                 dtrgesa
                 e_cstsae
                 epercsae

                 /* SDE */
                 htrgesd
                 eacthsde
                 ehlftsde
                 dtrgesd
                 e_cstsde
                 epercsde

                 /* SSE */
                 htrgess
                 eacthsse
                 ehlftsse
                 dtrgess
                 e_cstsse
                 epercsse
                 ;
      run;

     /* Create macro var for file naming convention. */
     %let rgn = &&rgn&j;

     /* Write reporting region info to file */
     %dswrite(dsname=work.&&rgn&j,
              file=&OUTPUTTO/&rgn.op.xls,
              dlm='09'x);
  %end;
 %mend openreg;

 /************************************************************************/
 /************************************************************************/

/*----------------------------------------------------------------------------
 * Produce Final Jobs textfiles for each of the regions.
 *----------------------------------------------------------------------------
 */
%macro finalreg;
  /* Create reporting region data sets */
  %do j=1 %to &norgns;
    data work.&&rgn&j;
      /* Common Final jobs*/
      attrib rgncode   label  = 'ISS Rgn'
             distcode  label  = 'Ops Mgr'
                       length = $5
             catgy     label  = 'Catgy'
                       length = $5
             class     label  = 'Class'
                       length = $1
             job_id    label  = 'Job'
             job_loc   label  = 'Location'
             st        label  = 'State'
             holdco    label  = 'Holdco'
             supervsr  label  = 'Supervisor'
             prodline  label  = 'Product Line'
             prodcode  label  = 'Product Code'
             d_date    label  = 'D-Date'
             k_date    label  = 'Committed K-Date'
             ftsdate   label  = 'FTS Dt'

             /* Inst source, hours, dollars, and percent complete */
             source_i label  = 'Inst Source'
             hrstrgi  label  = 'Inst Tgt Hrs'
             emphrsi  label  = 'Inst RFT Hrs'
             ctrhrsi  label  = 'Inst Contractor Hrs'
             iacthrs  label  = 'Inst Tot Hrs'
             ihrslft  label  = 'Inst Hrs Variance'
             dolrtrgi label  = 'Inst Tgt Cost'
             i_cost   label  = 'Inst Act Labor Cost'
             ibwdol   label  = 'Inst $ B/(W)'
             ipercom  label  = 'Inst Variance'
                      format = percent10.0
             itottrav label  = 'Inst Travel Cost'
             itotdol  label  = 'Inst Labor+Trav Act Cost'

             source_e label  = 'Total Eng Source'
             hrstrge  label  = 'Total Eng Tgt Hrs'
             emphrse  label  = 'Total Eng RFT Hrs'
             ctrhrse  label  = 'Total Eng Contractor Hrs'
             eacthrs  label  = 'Total Eng Act Hrs'
             ehrslft  label  = 'Total Eng Hrs Variance'
             dolrtrge label  = 'Total Eng Tgt Cost'
             e_cost   label  = 'Total Eng Act Labor Cost'
             ebwdol   label  = 'Total Eng $ B/(W)'
             epercom  label  = 'Total Eng Variance'
                      format = percent10.0
             etottrav label  = 'Total Eng Travel Cost'
             etotdol  label  = 'Total Eng Labor+Trav Act Cost'

             htrgeea    label  = 'EAE Tgt Hrs'
             eactheae   label  = 'EAE Act Hrs'
             ehlfteae   label  = 'EAE Hrs Variance'
             dtrgeea    label  = 'EAE Tgt Cost'
             e_csteae   label  = 'EAE Act Cost'
             ebwdeae    label  = 'EAE $ B/(W)'
             eperceae   label  = 'EAE Variance'
                        format = percent10.0

             htrgefe    label  = 'FE Tgt Hrs'
             eacthfe    label  = 'FE Act Hrs'
             ehlftfe    label  = 'FE Hrs Variance'
             dtrgefe    label  = 'FE Tgt Cost'
             e_cstfe    label  = 'FE Act Cost'
             ebwdfe     label  = 'FE $ B/(W)'
             epercfe    label  = 'FE Variance'
                        format = percent10.0

             htrgeot    label  = 'OTHR Tgt Hrs'
             eacthot    label  = 'OTHR Act Hrs'
             ehlftot    label  = 'OTHR Hrs Variance'
             dtrgeot    label  = 'OTHR Tgt Cost'
             e_cstot    label  = 'OTHR Act Cost'
             ebwdot     label  = 'OTHR $ B/(W)'
             epercot    label  = 'OTHR Variance'
                        format = percent10.0

             htrgepa     label  = 'PAE Tgt Hrs'
             eacthpae    label  = 'PAE Act Hrs'
             ehlftpae    label  = 'PAE Hrs Variance'
             dtrgepa     label  = 'PAE Tgt Cost'
             e_cstpae    label  = 'PAE Act Cost'
             ebwdpae     label  = 'PAE $ B/(W)'
             epercpae    label  = 'PAE Variance'
                         format = percent10.0

             htrgesa     label  = 'SAE Tgt Hrs'
             eacthsae    label  = 'SAE Act Hrs'
             ehlftsae    label  = 'SAE Hrs Variance'
             dtrgesa     label  = 'SAE Tgt Cost'
             e_cstsae    label  = 'SAE Act Cost'
             ebwdsae     label  = 'SAE $ B/(W)'
             epercsae    label  = 'SAE Variance'
                         format = percent10.0

             htrgesd     label  = 'SDE Tgt Hrs'
             eacthsde    label  = 'SDE Act Hrs'
             ehlftsde    label  = 'SDE Hrs Variance'
             dtrgesd     label  = 'SDE Tgt Cost'
             e_cstsde    label  = 'SDE Act Cost'
             ebwdsde     label  = 'SDE $ B/(W)'
             epercsde    label  = 'SDE Variance'
                         format = percent10.0

             htrgess     label  = 'SSE Tgt Hrs'
             eacthsse    label  = 'SSE Act Hrs'
             ehlftsse    label  = 'SSE Hrs Variance'
             dtrgess     label  = 'SSE Tgt Cost'
             e_cstsse    label  = 'SSE Act Cost'
             ebwdsse     label  = 'SSE $ B/(W)'
             epercsse    label  = 'SSE Variance'
                         format= percent10.0
              ;

        set work.costxtmp ;
          /* Final Jobs criteria */
          where ftsdate ^= . and
            ftsdate > &YYYYWW and
            /*  NO LONGER USING------&PRIORWKF is current wk minus 1; same as rptg wk plus 1. */
            ftsdate < &CLOSEWK and 
            prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
            /* H1X172 was an ITW problem job in 1998. */
            /* AQ260820 doesn't exist in Conled or ISS. */
            job_id not in ('H1X172', 'AQ260820') and
            rptg_rgn = "&&rgn&j";

                   /* Common Final*/
              keep rgncode
                   distcode
                   catgy
                   class
                   job_id
                   job_loc
                   st
                   holdco
                   supervsr
                   prodline
                   prodcode
                   d_date
                   k_date
                   ftsdate

                   /* Installation */
                   source_i
                   hrstrgi
                   emphrsi
                   ctrhrsi
                   iacthrs
                   ihrslft
                   dolrtrgi
                   i_cost
                   ibwdol
                   ipercom
                   itottrav
                   itotdol

                   /* Engineering */
                   source_e
                   hrstrge
                   emphrse
                   ctrhrse
                   eacthrs
                   ehrslft
                   dolrtrge
                   e_cost
                   ebwdol
                   epercom
                   etottrav
                   etotdol
                   etotdol

                   /* EAE */
                   htrgeea
                   eactheae
                   ehlfteae
                   dtrgeea
                   e_csteae
                   ebwdeae
                   eperceae

                   /* FE */
                   htrgefe
                   eacthfe
                   ehlftfe
                   dtrgefe
                   e_cstfe
                   ebwdfe
                   epercfe

                   /* OTHR */
                   htrgeot
                   eacthot
                   ehlftot
                   dtrgeot
                   e_cstot
                   ebwdot
                   epercot

                   /* PAE */
                   htrgepa
                   eacthpae
                   ehlftpae
                   dtrgepa
                   e_cstpae
                   ebwdpae
                   epercpae

                   /* SAE */
                   htrgesa
                   eacthsae
                   ehlftsae
                   dtrgesa
                   e_cstsae
                   ebwdsae
                   epercsae

                   /* SDE */
                   htrgesd
                   eacthsde
                   ehlftsde
                   dtrgesd
                   e_cstsde
                   ebwdsde
                   epercsde

                   /* SSE */
                   htrgess
                   eacthsse
                   ehlftsse
                   dtrgess
                   e_cstsse
                   ebwdsse
                   epercsse
                   ;
    run;

     /* Create macro var for file naming convention. */
    %let rgn = &&rgn&j;

     /* Write reporting region info to file. */
    %dswrite(dsname=work.&&rgn&j,
             file=&OUTPUTTO/&rgn.fi.xls,
             dlm='09'x);

  %end;
 %mend finalreg;

 /**************************************************************************/
 /**************************************************************************/

 /**************************************************************************/
 /*****                                                                *****/
 /*****                    Main routine                                *****/
 /*****                                                                *****/
 /**************************************************************************/
proc sql;
  create table work.costxtmp as
    select a.job_id,
           a.class,
           a.distcode,
           a.d_date,
/***            a.schd_dci, ***/
           a.act_hrs,
           a.i_cost,
           a.e_cost,
           a.ftsdate,
           a.h_date,
           a.holdco,
           a.job_loc,
           a.k_date,
           a.ord_stat,
           a.prodline,
           a.prodcode,
           a.rgncode,
           a.source_i,
           a.source_e,
           a.supervsr,
           a.st,
           b.dolrtrgi,
           b.emphrsi,
           b.ctrhrsi,
           b.travexpi,
           b.mileexpi,
           b.perdi,
           b.hrstrgi,
           b.hrstrge,
           b.dolrtrge,
           b.emphrse,
           b.ctrhrse,
           b.travexpe,
           b.mileexpe,
           b.perde
    from master.jobcost a,
         master.jobperf b
           where a.d_date > 199500
           and a.job_id = b.job_id;
quit;

/*----------------------------------------------------------------------------
 *  Collapse jobperfd to obtain the 7 engineering categories (EAE, FE, OTHR,
 *  PAE, SAE, SDE, SSE).
 *----------------------------------------------------------------------------
 */
proc sort data=master.jobperfd out=work.jobperfd;
  by job_id empfunc;
run;

data work.jobperfd(keep =
  dtrgeea empheea ctrheea traveeea mileeeea perdeea htrgeea
  dtrgefe emphefe ctrhefe traveefe mileeefe perdefe htrgefe
  dtrgeot empheot ctrheot traveeot mileeeot perdeot htrgeot
  dtrgepa emphepa ctrhepa traveepa mileeepa perdepa htrgepa
  dtrgesa emphesa ctrhesa traveesa mileeesa perdesa htrgesa
  dtrgesd emphesd ctrhesd traveesd mileeesd perdesd htrgesd
  dtrgess emphess ctrhess traveess mileeess perdess htrgess
  e_csteae e_cstfe e_cstot e_cstpae e_cstsae e_cstsde e_cstsse job_id);
  set work.jobperfd;
    by job_id;
    retain
      dtrgeea empheea ctrheea traveeea mileeeea perdeea htrgeea
      dtrgefe emphefe ctrhefe traveefe mileeefe perdefe htrgefe
      dtrgeot empheot ctrheot traveeot mileeeot perdeot htrgeot
      dtrgepa emphepa ctrhepa traveepa mileeepa perdepa htrgepa
      dtrgesa emphesa ctrhesa traveesa mileeesa perdesa htrgesa
      dtrgesd emphesd ctrhesd traveesd mileeesd perdesd htrgesd
      dtrgess emphess ctrhess traveess mileeess perdess htrgess
      e_csteae e_cstfe e_cstot e_cstpae e_cstsae e_cstsde e_cstsse 0;

     if first.job_id then
       do;
         dtrgeea    = 0;
         empheea    = 0;
         ctrheea    = 0;
         traveeea   = 0;
         mileeeea   = 0;
         perdeea    = 0;
         htrgeea    = 0;
         e_csteae   = 0;

         dtrgefe    = 0;
         emphefe    = 0;
         ctrhefe    = 0;
         traveefe   = 0;
         mileeefe   = 0;
         perdefe    = 0;
         htrgefe    = 0;
         e_cstfe    = 0;

         dtrgeot    = 0;
         empheot    = 0;
         ctrheot    = 0;
         traveeot   = 0;
         mileeeot   = 0;
         perdeot    = 0;
         htrgeot    = 0;
         e_cstot    = 0;

         dtrgepa    = 0;
         emphepa    = 0;
         ctrhepa    = 0;
         traveepa   = 0;
         mileeepa   = 0;
         perdepa    = 0;
         htrgepa    = 0;
         e_cstpae   = 0;

         dtrgesa    = 0;
         emphesa    = 0;
         ctrhesa    = 0;
         traveesa   = 0;
         mileeesa   = 0;
         perdesa    = 0;
         htrgesa    = 0;
         e_cstsae   = 0;

         dtrgesd    = 0;
         emphesd    = 0;
         ctrhesd    = 0;
         traveesd   = 0;
         mileeesd   = 0;
         perdesd    = 0;
         htrgesd    = 0;
         e_cstsde   = 0;

         dtrgess    = 0;
         emphess    = 0;
         ctrhess    = 0;
         traveess   = 0;
         mileeess   = 0;
         perdess    = 0;
         htrgess    = 0;
         e_cstsse   = 0;
       end;

     select;
       when ( empfunc = 'EAE' )
         do;
           dtrgeea    = dolrtrge;
           empheea    = emphrse;
           ctrheea    = ctrhrse;
           traveeea   = travexpe;
           mileeeea   = mileexpe;
           perdeea    = perde;
           htrgeea    = hrstrge;
           e_csteae   = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       when ( empfunc = 'FE' )
         do;
           dtrgefe    = dolrtrge;
           emphefe    = emphrse;
           ctrhefe    = ctrhrse;
           traveefe   = travexpe;
           mileeefe   = mileexpe;
           perdefe    = perde;
           htrgefe    = hrstrge;
           e_cstfe    = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       /* Modified 5/99 to capture nulls, and other miskeys that were being
        * missed in the 7 category breakout.
        */
       when ( empfunc in ('OTHR', '.', '', ' ') )
         do;
           dtrgeot    = dolrtrge;
           empheot    = emphrse;
           ctrheot    = ctrhrse;
           traveeot   = travexpe;
           mileeeot   = mileexpe;
           perdeot    = perde;
           htrgeot    = hrstrge;
           e_cstot    = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       when ( empfunc = 'PAE' )
         do;
           dtrgepa    = dolrtrge;
           emphepa    = emphrse;
           ctrhepa    = ctrhrse;
           traveepa   = travexpe;
           mileeepa   = mileexpe;
           perdepa    = perde;
           htrgepa    = hrstrge;
           e_cstpae   = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       when ( empfunc = 'SAE' )
         do;
           dtrgesa    = dolrtrge;
           emphesa    = emphrse;
           ctrhesa    = ctrhrse;
           traveesa   = travexpe;
           mileeesa   = mileexpe;
           perdesa    = perde;
           htrgesa    = hrstrge;
           e_cstsae   = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       when ( empfunc = 'SDE' )
         do;
           dtrgesd    = dolrtrge;
           emphesd    = emphrse;
           ctrhesd    = ctrhrse;
           traveesd   = travexpe;
           mileeesd   = mileexpe;
           perdesd    = perde;
           htrgesd    = hrstrge;
           e_cstsde   = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       when ( empfunc = 'SSE' )
         do;
           dtrgess    = dolrtrge;
           emphess    = emphrse;
           ctrhess    = ctrhrse;
           traveess   = travexpe;
           mileeess   = mileexpe;
           perdess    = perde;
           htrgess    = hrstrge;
           e_cstsse   = sum(ctrwgee, empburde, travexpe, mileexpe,
                            perde, empwgee);
         end;

       otherwise;

     end;

     if last.job_id then
       output;
run;

/*----------------------------------------------------------------------------
 *  Merge costx (pre-engbreakout style) with collapsed jobperfd -- left join.
 *----------------------------------------------------------------------------
 */
data work.costxtmp;
  merge work.jobperfd (in=in_perf)
        work.costxtmp (in=in_cost);
    by job_id;
    if (in_cost);
run;

/*----------------------------------------------------------------------------
 * General criteria for both Open & Final Job runs. Adds calculated variables,
 * filters unwanted jobs, creates reporting regions, adds labels.
 *----------------------------------------------------------------------------
 */
data work.costxtmp;
  set work.costxtmp;
  where d_date ^= . and
        ord_stat ^= 'CAN' and
        /* C208 and C213 combined into C214.  C218 added 1/1999. */
        /* This assumes all old C208 & C213 were not combined into C214. */
        /* C218 eliminated and C219 created to hold jobs worked by CLEC
         * employees for ILEC regions 12/1999.
         * C203 eliminated and replaced by C227,8,9, C30.
         */
        rgncode in ('C201','C202','C204','C206','C208', 'C209','C210',
                    'C211','C212','C213','C214','C219','C227','C228',
                    'C229','C230') and
        job_id not like '$%';

  /* Region Variables */
  length rptg_rgn $ 4;

  /* Create a list of all numeric variables. */
  array nums _numeric_;
  /* Process list, replace blanks with zeros. */
  do over nums;
    if nums = . then
       nums = 0;
  end;

  /* Inst */
  iacthrs = sum(emphrsi, ctrhrsi);

  /* Total travel $. */
  itottrav = perdi + travexpi + mileexpi;

  /* i_cost silently holds travel */
  i_cost = i_cost - itottrav;

  /* Inst percent complete and prevent div by 0. */
  if dolrtrgi > 0 then ipercom = ((dolrtrgi - i_cost) / dolrtrgi);
    else ipercom = 0;

  /* Inst hours left on job (or hours vari on Final). */
  ihrslft = hrstrgi - iacthrs;

  /* Inst dollars better (worse). */
  ibwdol = dolrtrgi - i_cost;

  /* Total labor (contractor and RFT) plus travel $. */
  itotdol = i_cost + itottrav;


  /* Eng */
  eacthrs = sum(emphrse, ctrhrse);

  etottrav = perde + travexpe + mileexpe;

  /* e_cost silently holds travel */
  e_cost = e_cost - etottrav;

  if dolrtrge > 0 then epercom = ((dolrtrge - e_cost) / dolrtrge);
    else epercom = 0;

  ehrslft = hrstrge - eacthrs;

  ebwdol = dolrtrge - e_cost;

  etotdol = e_cost + etottrav;


  /* Begin 7 Eng breakouts. */
  /* TODO Probably don't need the travel breakouts. */
  /* EAE */
  eactheae = sum(empheea,ctrheea);

  if dtrgeea > 0 then eperceae = ((dtrgeea - e_csteae) / dtrgeea);
    else eperceae = 0;

  ehlfteae = htrgeea-eactheae;

  ebwdeae = dtrgeea-e_csteae;

/***     tottrvea = perdeea + traveeea + mileeeea; ***/

/***     totdolea = e_cstea + tottrvea; ***/

  /* FE */
  eacthfe = sum(emphefe, ctrhefe);

  if dtrgefe > 0 then epercfe = ((dtrgefe - e_cstfe)/ dtrgefe);
    else epercfe = 0;

  ehlftfe = htrgefe - eacthfe;

  ebwdfe = dtrgefe - e_cstfe;

/***     tottrvfe = perdefe + traveefe + mileeefe; ***/

/***     totdolfe = e_cstfe + tottrvea; ***/

  /* OTHR */
  eacthot = sum(empheot,ctrheot);

  if dtrgeot > 0 then epercot = ((dtrgeot - e_cstot)/ dtrgeot);
    else epercot = 0;

  ehlftot = htrgeot - eacthot;

  ebwdot = dtrgeot - e_cstot;

/***     tottrvot = perdeot + traveeot + mileeeot; ***/

/***     totdolot = e_cstot + tottrvot; ***/

  /* PAE */
  eacthpae = sum(emphepa,ctrhepa);

  if dtrgepa > 0 then epercpae = ((dtrgepa - e_cstpae) / dtrgepa);
    else epercpae = 0;

  ehlftpae = htrgepa - eacthpae;

  ebwdpae = dtrgepa - e_cstpae;

/***     tottrvpa = perdepa + traveepa + mileeepa; ***/

/***     totdolpa = e_cstpa + tottrvpa; ***/

  /* SAE */
  eacthsae = sum(emphesa,ctrhesa);

  if dtrgesa >0 then epercsae = ((dtrgesa - e_cstsae) / dtrgesa);
    else epercsae = 0;

  ehlftsae = htrgesa - eacthsae;

  ebwdsae = dtrgesa - e_cstsae;

/***     tottrvsa = perdesa + traveesa + mileeesa; ***/

/***     totdolsa = e_cstsa + tottrvsa; ***/

  /* SDE */
  eacthsde = sum(emphesd,ctrhesd);

  if dtrgesd > 0 then epercsde = ((dtrgesd - e_cstsde) / dtrgesd);
    else epercsde = 0;

  ehlftsde = htrgesd - eacthsde;

  ebwdsde = dtrgesd - e_cstsde;

/***     tottrvsd = perdesd + traveesd + mileeesd; ***/

/***     totdolsd = e_cstsd + tottrvsd; ***/

  /* SSE */
  eacthsse = sum(emphess,ctrhess);

  if dtrgess > 0 then epercsse = ((dtrgess - e_cstsse) / dtrgess);
    else epercsse = 0;

  ehlftsse = htrgess - eacthsse;

  ebwdsse = dtrgess - e_cstsse;

/***     tottrvss = perdess + traveess + mileeess; ***/

/***     totdolss = e_cstss + tottrvss; ***/

  /* Category code */
  if prodcode    = 'BARCDE'
     then catgy  = '4BCD';
  else if class  = 'D'
    then catgy   = '5T&E';
  else if class  = 'E'
    then catgy   = '6W88';
  else if i_cost = 0
    then catgy   = '3NAC';
  else if i_cost > 0 and dolrtrgi < 1
    then catgy   = '2NTG';
  else catgy     = '1FPC';

  /* Source code */
  if (prodline ^= 'H' and source_i = 1)
    then csrce = 4;
  else
    csrce = source_i;

  /* Remap Product Line */
  /* TODO is this still necessary? */
  if prodcode in ('A/N','SA/N','ANODE') or prodline = 'Y'
    then nprdline = 'A';  /* Formerly Y */
  else
    nprdline = prodline;

   /* Reporting regions -- per ISS structure */
   /* Any changes made here must be replicated in FormatChopOpFi.xls */
  if distcode = 'OM25'
    then rptg_rgn = 'ALD';

  else if distcode in ('OM20','OM21','OM22','OM29','C202','CP02')
    then rptg_rgn = 'AMT';

/***  else if distcode in ('OM83','OM84','OM85','OM86','OM87','OM88','OM89',***/
/***                      'C208')***/
/***    then rptg_rgn = 'BAN';  ***/   /* Formerly named NE i.e. Nynex */

/***  else if distcode in ('OM80','OM81','OM90','C213')***/
/***    then rptg_rgn = 'BAS'; ***/  /* Formerly named BAT */

  /* CPxx OMs added 10/8/99. */
  else if distcode in ('OM80','OM84','OM87','OM88', 'OM89','OM90',
                       'C214','CP14')
    then rptg_rgn = 'BAT';

  else if distcode in ('OM10','OM11','OM13','OM94','C201', 'CP01')
    then rptg_rgn = 'BST';

  else if distcode in ('OM04','C204','CP04')
    then rptg_rgn = 'CTNR';

  else if distcode in ('OM40','OM41','OM42','OM43','OM44','OM45','OM46',
                       'OM96','OM97','C211','CP11')
    then rptg_rgn = 'GTE';

/***     else if distcode in ('OM14','OM33','OM38','OM63','OM70','OM71','OM77', ***/
/***                          'OM72','OM73','OM82','OM74','OM75','OM76','C203','FM33','CP03') ***/
/***       then rptg_rgn = 'IOC'; ***/
  else if distcode in ('OM82','OM01','OM02','OM03','OM05')
    then rptg_rgn = 'SPNE';

  else if distcode in ('OM76','OM08','OM09','OMC6','OMC7')
    then rptg_rgn = 'SPSE';

  else if distcode in ('OM74','OM73','OM27','OM28','OM39')
    then rptg_rgn = 'SPCE';

  else if distcode in ('OM70','OM77','OM48','OM78','OM79','OMC5')
    then rptg_rgn = 'SPWE';

  else if distcode in ('OM60','OM62','OM67','OM69','C206','CP06')
    then rptg_rgn = 'PAC';

  else if distcode in ('OM12','OM15','OM16','OM26','C210','CP10')
    then rptg_rgn = 'SPR';

  else if distcode in ('OM30','OM34','OM37','C212','CP12')
    then rptg_rgn = 'SBC';

  else if distcode in ('OM19','OM64','OM65','OM91','C209','CP09')
    then rptg_rgn = 'USW';

  else if distcode in ('OM59')
    then rptg_rgn = 'CLEC';   /* Work done for ILEC by CLEC. */

  /* Indicates new OM in ISS structure that we are not aware of,
   * inactive OM #, or OM68. 
   */
  else rptg_rgn = 'ZZZ'; 
                           
run;


/*----------------------------------------------------------------------------
 * Creates textfiles for each of the 12 region's Open jobs.
 *----------------------------------------------------------------------------
 */
data _null_;
  /* Create production week macro var 12 weeks i.e. 84 days in the future. */
  call symput('TWELVEWK', input(put(today() + 84, ntyyww.), 6.));
  /* Create prior wk to use in Open; captures as Open even though has FTSDT */
  /* No longer needed since synchronizing with Finance Close week since week 1
   * 2000. 
   */
/***   call symput('PRIORWKO', input(put(today() - 7, ntyyww.), 6.)); ***/
run;

proc sort data=work.costxtmp;
  by distcode class job_id;
run;

proc sort data=work.costxtmp (keep=rptg_rgn) out=work.regions nodupkey;
  by rptg_rgn;
run;

data _null_;
  set work.regions nobs=norgns end=eof;
  /* Get reporting regions */
  call symput('RGN' !! left(put(_n_, 3.)), rptg_rgn);
  /* Get max number of reporting regions */
  if (eof) then
    call symput('NORGNS', norgns);
run;

/* Create the individual textfiles. */
%openreg;

/* Copy costx.  It is used later in spending recon, archiving, etc. */
data custfin.costx;
  set work.costxtmp;
run;


/*----------------------------------------------------------------------------
 * Creates textfiles for each of the 12 region's FINAL jobs, using costx.ssd01
 * from the OPEN run.
 *----------------------------------------------------------------------------
 */
 /*  NO LONGER USING SINCE SYNCHED WITH NT CLOSE WK------Create production
  *  week macro var 7 days in the past 
  */
/* Used in FINAL criteria as 'ftsdt is less than CLOSEWK' */
data _null_;
/***   call symput('PRIORWKF', input(put(today() - 7, ntyyww.), 6.)); ***/
  call symput('CLOSEWK', input(put(today(), ntyyww.), 6.));
run;

proc sort data=work.costxtmp;
  /***by rgncode distcode catgy class job_id;***/ /* change 980714 */
  by distcode rgncode catgy class job_id; /* change 19990216 */
run;

proc sort data=work.costxtmp (keep=rptg_rgn) out=work.regions nodupkey;
  by rptg_rgn;
run;

data _null_;
  set work.regions nobs=norgns end=eof;
  /* Get reporting regions */
  call symput('RGN' !! left(put(_n_, 3.)), rptg_rgn);
  /* Get max number of reporting regions */
  if (eof)  then
    call symput('NORGNS', norgns);
run;

/* Create the individual textfiles. */
%finalreg;


/*----------------------------------------------------------------------------
 * Create 5 region-independent Final jobs files. TODO -- use array.
 *----------------------------------------------------------------------------
 */
/* Use temporary copy of costx for region-independent runs. */
data work.fincstx;
  set custfin.costx;
    /* Final jobs criteria */
    where ftsdate ^= . and
          ftsdate > &YYYYWW and
                distcode ne 'OM68' and  /* New for Aug98 close */
                ord_stat ne 'CAN' and   /* New for Aug98 close */
          prodline in ('H', 'T', 'A', 'Y', 'B', 'O') and
          /* H1X172 was an ITW problem job in 1998. */
          /* AQ260820 doesn't exist in Conled or ISS. */
          job_id not in ('H1X172', 'AQ260820') and
          /* NO LONGER USING------ PRIORWKF is current wk minus 1 */
          ftsdate < &CLOSEWK;
          /* Capture 199850 thru 199952 (inclusive). Assumes run on 1/4/00 */
/***           ftsdate < 200001; ***/
run;

/* Create totfi.xls - Final Product Cost only, misnamed "tot" by convention */
data work.tot;
  /* Common Final jobs*/
  attrib rgncode  label  = 'ISS Rgn'
         distcode label  = 'Ops Mgr'
                  length = $5
         catgy    label  = 'Catgy'
                  length = $4
         class    label  = 'Class'
                  length = $1
         job_id   label  = 'Job'
         job_loc  label  = 'Location'
         st       label  = 'State'
         holdco   label  = 'Holdco'
         supervsr label  = 'Supervisor'
         prodline label  = 'Product Line'
         prodcode label  = 'Product Code'
         d_date   label  = 'D-Date'
         k_date   label  = 'Committed K-Date'
         ftsdate  label  = 'FTS Dt'

        /* Inst source, source, hours, dollars, and pct complete */
        source_i label   = 'Inst Source'
        hrstrgi  label   = 'Inst Tgt Hrs'
        emphrsi  label   = 'Inst RFT Hrs'
        ctrhrsi  label   = 'Inst Contractor Hrs'
        iacthrs  label   = 'Inst Tot Hrs'
        ihrslft  label   = 'Inst Hrs Variance'
        dolrtrgi label   = 'Inst Tgt Cost'
        i_cost   label   = 'Inst Act Labor Cost'
        ibwdol   label   = 'Inst $ B/(W)'
        ipercom  label   = 'Inst Variance'
                 format  = percent10.0
        itottrav label   = 'Inst Travel Cost'
        itotdol  label   = 'Inst Labor+Trav Act Cost'

        source_e label   = 'Total Eng Source'
        hrstrge  label   = 'Total Eng Tgt Hrs'
        emphrse  label   = 'Total Eng RFT Hrs'
        ctrhrse  label   = 'Total Eng Contractor Hrs'
        eacthrs  label   = 'Total Eng Act Hrs'
        ehrslft  label   = 'Total Eng Hrs Variance'
        dolrtrge label   = 'Total Eng Tgt Cost'
        e_cost   label   = 'Total Eng Act Labor Cost'
        ebwdol   label   = 'Total Eng $ B/(W)'
        epercom  label   = 'Total Eng Variance'
                 format  = percent10.0
        etottrav label   = 'Total Eng Travel Cost'
        etotdol  label   = 'Total Eng Labor+Trav Act Cost'

        htrgeea  label  = 'EAE Tgt Hrs'
        eactheae label  = 'EAE Act Hrs'
        ehlfteae label  = 'EAE Hrs Variance'
        dtrgeea  label  = 'EAE Tgt Cost'
        e_csteae label  = 'EAE Act Cost'
        ebwdeae  label  = 'EAE $ B/(W)'
        eperceae label  = 'EAE Variance'
                 format = percent10.0

        htrgefe  label  = 'FE Tgt Hrs'
        eacthfe  label  = 'FE Act Hrs'
        ehlftfe  label  = 'FE Hrs Variance'
        dtrgefe  label  = 'FE Tgt Cost'
        e_cstfe  label  = 'FE Act Cost'
        ebwdfe   label  = 'FE $ B/(W)'
        epercfe  label  = 'FE Variance'
                 format = percent10.0

        htrgeot  label  = 'OTHR Tgt Hrs'
        eacthot  label  = 'OTHR Act Hrs'
        ehlftot  label  = 'OTHR Hrs Variance'
        dtrgeot  label  = 'OTHR Tgt Cost'
        e_cstot  label  = 'OTHR Act Cost'
        ebwdot   label  = 'OTHR $ B/(W)'
        epercot  label  = 'OTHR Variance'
                 format = percent10.0

        htrgepa  label  = 'PAE Tgt Hrs'
        eacthpae label  = 'PAE Act Hrs'
        ehlftpae label  = 'PAE Hrs Variance'
        dtrgepa  label  = 'PAE Tgt Cost'
        e_cstpae label  = 'PAE Act Cost'
        ebwdpae  label  = 'PAE $ B/(W)'
        epercpae label  = 'PAE Variance'
                 format = percent10.0

        htrgesa  label  = 'SAE Tgt Hrs'
        eacthsae label  = 'SAE Act Hrs'
        ehlftsae label  = 'SAE Hrs Variance'
        dtrgesa  label  = 'SAE Tgt Cost'
        e_cstsae label  = 'SAE Act Cost'
        ebwdsae  label  = 'SAE $ B/(W)'
        epercsae label  = 'SAE Variance'
                 format = percent10.0

        htrgesd  label  = 'SDE Tgt Hrs'
        eacthsde label  = 'SDE Act Hrs'
        ehlftsde label  = 'SDE Hrs Variance'
        dtrgesd  label  = 'SDE Tgt Cost'
        e_cstsde label  = 'SDE Act Cost'
        ebwdsde  label  = 'SDE $ B/(W)'
        epercsde label  = 'SDE Variance'
                 format = percent10.0

        htrgess  label  = 'SSE Tgt Hrs'
        eacthsse label  = 'SSE Act Hrs'
        ehlftsse label  = 'SSE Hrs Variance'
        dtrgess  label  = 'SSE Tgt Cost'
        e_cstsse label  = 'SSE Act Cost'
        ebwdsse  label  = 'SSE $ B/(W)'
        epercsse label  = 'SSE Variance'
                 format= percent10.0
                 ;
  set work.fincstx;
    where catgy = '1FPC';
      /* Common Final */
      keep rgncode
           distcode
           catgy
           class
           job_id
           job_loc
           st
           holdco
           supervsr
           prodline
           prodcode
           d_date
           k_date
           ftsdate

           /* Installation */
           source_i
           hrstrgi
           emphrsi
           ctrhrsi
           iacthrs
           ihrslft
           dolrtrgi
           i_cost
           ibwdol
           ipercom
           itottrav
           itotdol

           /* Engineering */
           source_e
           hrstrge
           emphrse
           ctrhrse
           eacthrs
           ehrslft
           dolrtrge
           e_cost
           ebwdol
           epercom
           etottrav
           etotdol

           /* EAE */
           htrgeea
           eactheae
           ehlfteae
           dtrgeea
           e_csteae
           ebwdeae
           eperceae

           /* FE */
           htrgefe
           eacthfe
           ehlftfe
           dtrgefe
           e_cstfe
           ebwdfe
           epercfe

           /* OTHR */
           htrgeot
           eacthot
           ehlftot
           dtrgeot
           e_cstot
           ebwdot
           epercot

           /* PAE */
           htrgepa
           eacthpae
           ehlftpae
           dtrgepa
           e_cstpae
           ebwdpae
           epercpae

           /* SAE */
           htrgesa
           eacthsae
           ehlftsae
           dtrgesa
           e_cstsae
           ebwdsae
           epercsae

           /* SDE */
           htrgesd
           eacthsde
           ehlftsde
           dtrgesd
           e_cstsde
           ebwdsde
           epercsde

           /* SSE */
           htrgess
           eacthsse
           ehlftsse
           dtrgess
           e_cstsse
           ebwdsse
           epercsse
           ;
run;

%dswrite(dsname=work.tot,
         file=&OUTPUTTO/totfi.xls,
         dlm='09'x);


/* Create problfi.xls -- Problem is no targets, no actuals */
data work.probl;
  /* Common Final Jobs*/
  attrib rgncode  label  = 'ISS Rgn'
         distcode label  = 'Ops Mgr'
                  length = $5
         catgy    label  = 'Catgy'
                  length = $4
         class    label  = 'Class'
                  length = $1
         job_id   label  = 'Job'
         job_loc  label  = 'Location'
         st       label  = 'State'
         holdco   label  = 'Holdco'
         supervsr label  = 'Supervisor'
         prodline label  = 'Product Line'
         prodcode label  = 'Product Code'
         d_date   label  = 'D-Date'
         k_date   label  = 'Committed K-Date'
         ftsdate  label  = 'FTS Dt'

         /* Inst source, source, hours, dollars, and pct complete */
         source_i label  = 'Inst Source'
         hrstrgi  label  = 'Inst Tgt Hrs'
         emphrsi  label  = 'Inst RFT Hrs'
         ctrhrsi  label  = 'Inst Contractor Hrs'
         iacthrs  label  = 'Inst Tot Hrs'
         ihrslft  label  = 'Inst Hrs Variance'
         dolrtrgi label  = 'Inst Tgt Cost'
         i_cost   label  = 'Inst Act Labor Cost'
         ibwdol   label  = 'Inst $ B/(W)'
         ipercom  label  = 'Inst Variance'
                  format = percent10.0
         itottrav label  = 'Inst Travel Cost'
         itotdol  label  = 'Inst Labor+Trav Act Cost'

         source_e label  = 'Total Eng Source'
         hrstrge  label  = 'Total Eng Tgt Hrs'
         emphrse  label  = 'Total Eng RFT Hrs'
         ctrhrse  label  = 'Total Eng Contractor Hrs'
         eacthrs  label  = 'Total Eng Act Hrs'
         ehrslft  label  = 'Total Eng Hrs Variance'
         dolrtrge label  = 'Total Eng Tgt Cost'
         e_cost   label  = 'Total Eng Act Labor Cost'
         ebwdol   label  = 'Total Eng $ B/(W)'
         epercom  label  = 'Total Eng Variance'
                  format = percent10.0
         etottrav label  = 'Total Eng Travel Cost'
         etotdol  label  = 'Total Eng Labor+Trav Act Cost'

         htrgeea  label  = 'EAE Tgt Hrs'
         eactheae label  = 'EAE Act Hrs'
         ehlfteae label  = 'EAE Hrs Variance'
         dtrgeea  label  = 'EAE Tgt Cost'
         e_csteae label  = 'EAE Act Cost'
         ebwdeae  label  = 'EAE $ B/(W)'
         eperceae label  = 'EAE Variance'
                  format = percent10.0

         htrgefe  label  = 'FE Tgt Hrs'
         eacthfe  label  = 'FE Act Hrs'
         ehlftfe  label  = 'FE Hrs Variance'
         dtrgefe  label  = 'FE Tgt Cost'
         e_cstfe  label  = 'FE Act Cost'
         ebwdfe   label  = 'FE $ B/(W)'
         epercfe  label  = 'FE Variance'
                  format = percent10.0

         htrgeot  label  = 'OTHR Tgt Hrs'
         eacthot  label  = 'OTHR Act Hrs'
         ehlftot  label  = 'OTHR Hrs Variance'
         dtrgeot  label  = 'OTHR Tgt Cost'
         e_cstot  label  = 'OTHR Act Cost'
         ebwdot   label  = 'OTHR $ B/(W)'
         epercot  label  = 'OTHR Variance'
                  format = percent10.0

         htrgepa  label  = 'PAE Tgt Hrs'
         eacthpae label  = 'PAE Act Hrs'
         ehlftpae label  = 'PAE Hrs Variance'
         dtrgepa  label  = 'PAE Tgt Cost'
         e_cstpae label  = 'PAE Act Cost'
         ebwdpae  label  = 'PAE $ B/(W)'
         epercpae label  = 'PAE Variance'
                  format = percent10.0

         htrgesa  label  = 'SAE Tgt Hrs'
         eacthsae label  = 'SAE Act Hrs'
         ehlftsae label  = 'SAE Hrs Variance'
         dtrgesa  label  = 'SAE Tgt Cost'
         e_cstsae label  = 'SAE Act Cost'
         ebwdsae  label  = 'SAE $ B/(W)'
         epercsae label  = 'SAE Variance'
                  format = percent10.0

         htrgesd  label  = 'SDE Tgt Hrs'
         eacthsde label  = 'SDE Act Hrs'
         ehlftsde label  = 'SDE Hrs Variance'
         dtrgesd  label  = 'SDE Tgt Cost'
         e_cstsde label  = 'SDE Act Cost'
         ebwdsde  label  = 'SDE $ B/(W)'
         epercsde label  = 'SDE Variance'
                  format = percent10.0

         htrgess  label  = 'SSE Tgt Hrs'
         eacthsse label  = 'SSE Act Hrs'
         ehlftsse label  = 'SSE Hrs Variance'
         dtrgess  label  = 'SSE Tgt Cost'
         e_cstsse label  = 'SSE Act Cost'
         ebwdsse  label  = 'SSE $ B/(W)'
         epercsse label  = 'SSE Variance'
                  format= percent10.0
                  ;
  set work.fincstx;
    where catgy in ('3NAC', '2NTG');
      keep rgncode
           distcode
           catgy
           class
           job_id
           job_loc
           st
           holdco
           supervsr
           prodline
           prodcode
           d_date
           k_date
           ftsdate

           /* Installation */
           source_i
           hrstrgi
           emphrsi
           ctrhrsi
           iacthrs
           ihrslft
           dolrtrgi
           i_cost
           ibwdol
           ipercom
           itottrav
           itotdol

           /* Engineering */
           source_e
           hrstrge
           emphrse
           ctrhrse
           eacthrs
           ehrslft
           dolrtrge
           e_cost
           ebwdol
           epercom
           etottrav
           etotdol

           /* EAE */
           htrgeea
           eactheae
           ehlfteae
           dtrgeea
           e_csteae
           ebwdeae
           eperceae

           /* FE */
           htrgefe
           eacthfe
           ehlftfe
           dtrgefe
           e_cstfe
           ebwdfe
           epercfe

           /* OTHR */
           htrgeot
           eacthot
           ehlftot
           dtrgeot
           e_cstot
           ebwdot
           epercot

           /* PAE */
           htrgepa
           eacthpae
           ehlftpae
           dtrgepa
           e_cstpae
           ebwdpae
           epercpae

           /* SAE */
           htrgesa
           eacthsae
           ehlftsae
           dtrgesa
           e_cstsae
           ebwdsae
           epercsae

           /* SDE */
           htrgesd
           eacthsde
           ehlftsde
           dtrgesd
           e_cstsde
           ebwdsde
           epercsde

           /* SSE */
           htrgess
           eacthsse
           ehlftsse
           dtrgess
           e_cstsse
           ebwdsse
           epercsse
           ;
run;

%dswrite(dsname=work.probl,
         file=&OUTPUTTO/problfi.xls,
         dlm='09'x);


/* Create brcdefi.xls Barcode jobs */
data work.brcde;
  /* Common Final jobs*/
  attrib rgncode  label  = 'ISS Rgn'
         distcode label  = 'Ops Mgr'
                  length = $5
         catgy    label  = 'Catgy'
                  length = $4
         class    label  = 'Class'
                  length = $1
         job_id   label  = 'Job'
         job_loc  label  = 'Location'
         st       label  = 'State'
         holdco   label  = 'Holdco'
         supervsr label  = 'Supervisor'
         prodline label  = 'Product Line'
         prodcode label  = 'Product Code'
         d_date   label  = 'D-Date'
         k_date   label  = 'Committed K-Date'
         ftsdate  label  = 'FTS Dt'

         /* Inst source, source, hours, dollars, and pct complete */
         source_i label  = 'Inst Source'
         hrstrgi  label  = 'Inst Tgt Hrs'
         emphrsi  label  = 'Inst RFT Hrs'
         ctrhrsi  label  = 'Inst Contractor Hrs'
         iacthrs  label  = 'Inst Tot Hrs'
         ihrslft  label  = 'Inst Hrs Variance'
         dolrtrgi label  = 'Inst Tgt Cost'
         i_cost   label  = 'Inst Act Labor Cost'
         ibwdol   label  = 'Inst $ B/(W)'
         ipercom  label  = 'Inst Variance'
                  format = percent10.0
         itottrav label  = 'Inst Travel Cost'
         itotdol  label  = 'Inst Labor+Trav Act Cost'

         source_e label  = 'Total Eng Source'
         hrstrge  label  = 'Total Eng Tgt Hrs'
         emphrse  label  = 'Total Eng RFT Hrs'
         ctrhrse  label  = 'Total Eng Contractor Hrs'
         eacthrs  label  = 'Total Eng Act Hrs'
         ehrslft  label  = 'Total Eng Hrs Variance'
         dolrtrge label  = 'Total Eng Tgt Cost'
         e_cost   label  = 'Total Eng Act Labor Cost'
         ebwdol   label  = 'Total Eng $ B/(W)'
         epercom  label  = 'Total Eng Variance'
                  format = percent10.0
         etottrav label  = 'Total Eng Travel Cost'
         etotdol  label  = 'Total Eng Labor+Trav Act Cost'

         htrgeea  label  = 'EAE Tgt Hrs'
         eactheae label  = 'EAE Act Hrs'
         ehlfteae label  = 'EAE Hrs Variance'
         dtrgeea  label  = 'EAE Tgt Cost'
         e_csteae label  = 'EAE Act Cost'
         ebwdeae  label  = 'EAE $ B/(W)'
         eperceae label  = 'EAE Variance'
                  format = percent10.0

         htrgefe  label  = 'FE Tgt Hrs'
         eacthfe  label  = 'FE Act Hrs'
         ehlftfe  label  = 'FE Hrs Variance'
         dtrgefe  label  = 'FE Tgt Cost'
         e_cstfe  label  = 'FE Act Cost'
         ebwdfe   label  = 'FE $ B/(W)'
         epercfe  label  = 'FE Variance'
                  format = percent10.0

         htrgeot  label  = 'OTHR Tgt Hrs'
         eacthot  label  = 'OTHR Act Hrs'
         ehlftot  label  = 'OTHR Hrs Variance'
         dtrgeot  label  = 'OTHR Tgt Cost'
         e_cstot  label  = 'OTHR Act Cost'
         ebwdot   label  = 'OTHR $ B/(W)'
         epercot  label  = 'OTHR Variance'
                  format = percent10.0

         htrgepa  label  = 'PAE Tgt Hrs'
         eacthpae label  = 'PAE Act Hrs'
         ehlftpae label  = 'PAE Hrs Variance'
         dtrgepa  label  = 'PAE Tgt Cost'
         e_cstpae label  = 'PAE Act Cost'
         ebwdpae  label  = 'PAE $ B/(W)'
         epercpae label  = 'PAE Variance'
                  format = percent10.0

         htrgesa  label  = 'SAE Tgt Hrs'
         eacthsae label  = 'SAE Act Hrs'
         ehlftsae label  = 'SAE Hrs Variance'
         dtrgesa  label  = 'SAE Tgt Cost'
         e_cstsae label  = 'SAE Act Cost'
         ebwdsae  label  = 'SAE $ B/(W)'
         epercsae label  = 'SAE Variance'
                  format = percent10.0

         htrgesd  label  = 'SDE Tgt Hrs'
         eacthsde label  = 'SDE Act Hrs'
         ehlftsde label  = 'SDE Hrs Variance'
         dtrgesd  label  = 'SDE Tgt Cost'
         e_cstsde label  = 'SDE Act Cost'
         ebwdsde  label  = 'SDE $ B/(W)'
         epercsde label  = 'SDE Variance'
                  format = percent10.0

         htrgess  label  = 'SSE Tgt Hrs'
         eacthsse label  = 'SSE Act Hrs'
         ehlftsse label  = 'SSE Hrs Variance'
         dtrgess  label  = 'SSE Tgt Cost'
         e_cstsse label  = 'SSE Act Cost'
         ebwdsse  label  = 'SSE $ B/(W)'
         epercsse label  = 'SSE Variance'
                  format= percent10.0
                  ;
  set work.fincstx;
    where catgy = '4BCD';
      keep rgncode
           distcode
           catgy
           class
           job_id
           job_loc
           st
           holdco
           supervsr
           prodline
           prodcode
           d_date
           k_date
           ftsdate

           /* Installation */
           source_i
           hrstrgi
           emphrsi
           ctrhrsi
           iacthrs
           ihrslft
           dolrtrgi
           i_cost
           ibwdol
           ipercom
           itottrav
           itotdol

           /* Engineering */
           source_e
           hrstrge
           emphrse
           ctrhrse
           eacthrs
           ehrslft
           dolrtrge
           e_cost
           ebwdol
           epercom
           etottrav
           etotdol

           /* EAE */
           htrgeea
           eactheae
           ehlfteae
           dtrgeea
           e_csteae
           ebwdeae
           eperceae

           /* FE */
           htrgefe
           eacthfe
           ehlftfe
           dtrgefe
           e_cstfe
           ebwdfe
           epercfe

           /* OTHR */
           htrgeot
           eacthot
           ehlftot
           dtrgeot
           e_cstot
           ebwdot
           epercot

           /* PAE */
           htrgepa
           eacthpae
           ehlftpae
           dtrgepa
           e_cstpae
           ebwdpae
           epercpae

           /* SAE */
           htrgesa
           eacthsae
           ehlftsae
           dtrgesa
           e_cstsae
           ebwdsae
           epercsae

           /* SDE */
           htrgesd
           eacthsde
           ehlftsde
           dtrgesd
           e_cstsde
           ebwdsde
           epercsde

           /* SSE */
           htrgess
           eacthsse
           ehlftsse
           dtrgess
           e_cstsse
           ebwdsse
           epercsse
           ;
run;

%dswrite(dsname=work.brcde,
         file=&OUTPUTTO/brcdefi.xls,
         dlm='09'x);


/* Create tefi.xls -- Time & Expense */
data work.te;
  /* Common Final Jobs*/
  attrib rgncode  label  = 'ISS Rgn'
         distcode label  = 'Ops Mgr'
                  length = $5
         catgy    label  = 'Catgy'
                  length = $4
         class    label  = 'Class'
                  length = $1
         job_id   label  = 'Job'
         job_loc  label  = 'Location'
         st       label  = 'State'
         holdco   label  = 'Holdco'
         supervsr label  = 'Supervisor'
         prodline label  = 'Product Line'
         prodcode label  = 'Product Code'
         d_date   label  = 'D-Date'
         k_date   label  = 'Committed K-Date'
         ftsdate  label  = 'FTS Dt'

         /* Inst source, source, hours, dollars, and pct complete */
         source_i label  = 'Inst Source'
         hrstrgi  label  = 'Inst Tgt Hrs'
         emphrsi  label  = 'Inst RFT Hrs'
         ctrhrsi  label  = 'Inst Contractor Hrs'
         iacthrs  label  = 'Inst Tot Hrs'
         ihrslft  label  = 'Inst Hrs Variance'
         dolrtrgi label  = 'Inst Tgt Cost'
         i_cost   label  = 'Inst Act Labor Cost'
         ibwdol   label  = 'Inst $ B/(W)'
         ipercom  label  = 'Inst Variance'
                  format = percent10.0
         itottrav label  = 'Inst Travel Cost'
         itotdol  label  = 'Inst Labor+Trav Act Cost'

         source_e label  = 'Total Eng Source'
         hrstrge  label  = 'Total Eng Tgt Hrs'
         emphrse  label  = 'Total Eng RFT Hrs'
         ctrhrse  label  = 'Total Eng Contractor Hrs'
         eacthrs  label  = 'Total Eng Act Hrs'
         ehrslft  label  = 'Total Eng Hrs Variance'
         dolrtrge label  = 'Total Eng Tgt Cost'
         e_cost   label  = 'Total Eng Act Labor Cost'
         ebwdol   label  = 'Total Eng $ B/(W)'
         epercom  label  = 'Total Eng Variance'
                  format = percent10.0
         etottrav label  = 'Total Eng Travel Cost'
         etotdol  label  = 'Total Eng Labor+Trav Act Cost'

         htrgeea  label  = 'EAE Tgt Hrs'
         eactheae label  = 'EAE Act Hrs'
         ehlfteae label  = 'EAE Hrs Variance'
         dtrgeea  label  = 'EAE Tgt Cost'
         e_csteae label  = 'EAE Act Cost'
         ebwdeae  label  = 'EAE $ B/(W)'
         eperceae label  = 'EAE Variance'
                  format = percent10.0

         htrgefe  label  = 'FE Tgt Hrs'
         eacthfe  label  = 'FE Act Hrs'
         ehlftfe  label  = 'FE Hrs Variance'
         dtrgefe  label  = 'FE Tgt Cost'
         e_cstfe  label  = 'FE Act Cost'
         ebwdfe   label  = 'FE $ B/(W)'
         epercfe  label  = 'FE Variance'
                  format = percent10.0

         htrgeot  label  = 'OTHR Tgt Hrs'
         eacthot  label  = 'OTHR Act Hrs'
         ehlftot  label  = 'OTHR Hrs Variance'
         dtrgeot  label  = 'OTHR Tgt Cost'
         e_cstot  label  = 'OTHR Act Cost'
         ebwdot   label  = 'OTHR $ B/(W)'
         epercot  label  = 'OTHR Variance'
                  format = percent10.0

         htrgepa  label  = 'PAE Tgt Hrs'
         eacthpae label  = 'PAE Act Hrs'
         ehlftpae label  = 'PAE Hrs Variance'
         dtrgepa  label  = 'PAE Tgt Cost'
         e_cstpae label  = 'PAE Act Cost'
         ebwdpae  label  = 'PAE $ B/(W)'
         epercpae label  = 'PAE Variance'
                  format = percent10.0

         htrgesa  label  = 'SAE Tgt Hrs'
         eacthsae label  = 'SAE Act Hrs'
         ehlftsae label  = 'SAE Hrs Variance'
         dtrgesa  label  = 'SAE Tgt Cost'
         e_cstsae label  = 'SAE Act Cost'
         ebwdsae  label  = 'SAE $ B/(W)'
         epercsae label  = 'SAE Variance'
                  format = percent10.0

         htrgesd  label  = 'SDE Tgt Hrs'
         eacthsde label  = 'SDE Act Hrs'
         ehlftsde label  = 'SDE Hrs Variance'
         dtrgesd  label  = 'SDE Tgt Cost'
         e_cstsde label  = 'SDE Act Cost'
         ebwdsde  label  = 'SDE $ B/(W)'
         epercsde label  = 'SDE Variance'
                  format = percent10.0

         htrgess  label  = 'SSE Tgt Hrs'
         eacthsse label  = 'SSE Act Hrs'
         ehlftsse label  = 'SSE Hrs Variance'
         dtrgess  label  = 'SSE Tgt Cost'
         e_cstsse label  = 'SSE Act Cost'
         ebwdsse  label  = 'SSE $ B/(W)'
         epercsse label  = 'SSE Variance'
                  format= percent10.0
                  ;
  set work.fincstx;
    where catgy = '5T&E';
      keep rgncode
           distcode
           catgy
           class
           job_id
           job_loc
           st
           holdco
           supervsr
           prodline
           prodcode
           d_date
           k_date
           ftsdate

           /* Installation */
           source_i
           hrstrgi
           emphrsi
           ctrhrsi
           iacthrs
           ihrslft
           dolrtrgi
           i_cost
           ibwdol
           ipercom
           itottrav
           itotdol

           /* Engineering */
           source_e
           hrstrge
           emphrse
           ctrhrse
           eacthrs
           ehrslft
           dolrtrge
           e_cost
           ebwdol
           epercom
           etottrav
           etotdol

           /* EAE */
           htrgeea
           eactheae
           ehlfteae
           dtrgeea
           e_csteae
           ebwdeae
           eperceae

           /* FE */
           htrgefe
           eacthfe
           ehlftfe
           dtrgefe
           e_cstfe
           ebwdfe
           epercfe

           /* OTHR */
           htrgeot
           eacthot
           ehlftot
           dtrgeot
           e_cstot
           ebwdot
           epercot

           /* PAE */
           htrgepa
           eacthpae
           ehlftpae
           dtrgepa
           e_cstpae
           ebwdpae
           epercpae

           /* SAE */
           htrgesa
           eacthsae
           ehlftsae
           dtrgesa
           e_cstsae
           ebwdsae
           epercsae

           /* SDE */
           htrgesd
           eacthsde
           ehlftsde
           dtrgesd
           e_cstsde
           ebwdsde
           epercsde

           /* SSE */
           htrgess
           eacthsse
           ehlftsse
           dtrgess
           e_cstsse
           ebwdsse
           epercsse
           ;
run;

%dswrite(dsname=work.te,
         file=&OUTPUTTO/tefi.xls,
         dlm='09'x);


/* Create w88kfi.xls -- Warranty jobs */
data work.w88k;
  /* Common Final Jobs*/
  attrib rgncode  label  = 'ISS Rgn'
         distcode label  = 'Ops Mgr'
                  length = $5
         catgy    label  = 'Catgy'
                  length = $4
         class    label  = 'Class'
                  length = $1
         job_id   label  = 'Job'
         job_loc  label  = 'Location'
         st       label  = 'State'
         holdco   label  = 'Holdco'
         supervsr label  = 'Supervisor'
         prodline label  = 'Product Line'
         prodcode label  = 'Product Code'
         d_date   label  = 'D-Date'
         k_date   label  = 'Committed K-Date'
         ftsdate  label  = 'FTS Dt'

         /* Inst source, source, hours, dollars, and pct complete */
         source_i label  = 'Inst Source'
         hrstrgi  label  = 'Inst Tgt Hrs'
         emphrsi  label  = 'Inst RFT Hrs'
         ctrhrsi  label  = 'Inst Contractor Hrs'
         iacthrs  label  = 'Inst Tot Hrs'
         ihrslft  label  = 'Inst Hrs Variance'
         dolrtrgi label  = 'Inst Tgt Cost'
         i_cost   label  = 'Inst Act Labor Cost'
         ibwdol   label  = 'Inst $ B/(W)'
         ipercom  label  = 'Inst Variance'
                  format = percent10.0
         itottrav label  = 'Inst Travel Cost'
         itotdol  label  = 'Inst Labor+Trav Act Cost'

         source_e label  = 'Total Eng Source'
         hrstrge  label  = 'Total Eng Tgt Hrs'
         emphrse  label  = 'Total Eng RFT Hrs'
         ctrhrse  label  = 'Total Eng Contractor Hrs'
         eacthrs  label  = 'Total Eng Act Hrs'
         ehrslft  label  = 'Total Eng Hrs Variance'
         dolrtrge label  = 'Total Eng Tgt Cost'
         e_cost   label  = 'Total Eng Act Labor Cost'
         ebwdol   label  = 'Total Eng $ B/(W)'
         epercom  label  = 'Total Eng Variance'
                  format = percent10.0
         etottrav label  = 'Total Eng Travel Cost'
         etotdol  label  = 'Total Eng Labor+Trav Act Cost'

         htrgeea  label  = 'EAE Tgt Hrs'
         eactheae label  = 'EAE Act Hrs'
         ehlfteae label  = 'EAE Hrs Variance'
         dtrgeea  label  = 'EAE Tgt Cost'
         e_csteae label  = 'EAE Act Cost'
         ebwdeae  label  = 'EAE $ B/(W)'
         eperceae label  = 'EAE Variance'
                  format = percent10.0

         htrgefe  label  = 'FE Tgt Hrs'
         eacthfe  label  = 'FE Act Hrs'
         ehlftfe  label  = 'FE Hrs Variance'
         dtrgefe  label  = 'FE Tgt Cost'
         e_cstfe  label  = 'FE Act Cost'
         ebwdfe   label  = 'FE $ B/(W)'
         epercfe  label  = 'FE Variance'
                  format = percent10.0

         htrgeot  label  = 'OTHR Tgt Hrs'
         eacthot  label  = 'OTHR Act Hrs'
         ehlftot  label  = 'OTHR Hrs Variance'
         dtrgeot  label  = 'OTHR Tgt Cost'
         e_cstot  label  = 'OTHR Act Cost'
         ebwdot   label  = 'OTHR $ B/(W)'
         epercot  label  = 'OTHR Variance'
                  format = percent10.0

         htrgepa  label  = 'PAE Tgt Hrs'
         eacthpae label  = 'PAE Act Hrs'
         ehlftpae label  = 'PAE Hrs Variance'
         dtrgepa  label  = 'PAE Tgt Cost'
         e_cstpae label  = 'PAE Act Cost'
         ebwdpae  label  = 'PAE $ B/(W)'
         epercpae label  = 'PAE Variance'
                  format = percent10.0

         htrgesa  label  = 'SAE Tgt Hrs'
         eacthsae label  = 'SAE Act Hrs'
         ehlftsae label  = 'SAE Hrs Variance'
         dtrgesa  label  = 'SAE Tgt Cost'
         e_cstsae label  = 'SAE Act Cost'
         ebwdsae  label  = 'SAE $ B/(W)'
         epercsae label  = 'SAE Variance'
                  format = percent10.0

         htrgesd  label  = 'SDE Tgt Hrs'
         eacthsde label  = 'SDE Act Hrs'
         ehlftsde label  = 'SDE Hrs Variance'
         dtrgesd  label  = 'SDE Tgt Cost'
         e_cstsde label  = 'SDE Act Cost'
         ebwdsde  label  = 'SDE $ B/(W)'
         epercsde label  = 'SDE Variance'
                  format = percent10.0

         htrgess  label  = 'SSE Tgt Hrs'
         eacthsse label  = 'SSE Act Hrs'
         ehlftsse label  = 'SSE Hrs Variance'
         dtrgess  label  = 'SSE Tgt Cost'
         e_cstsse label  = 'SSE Act Cost'
         ebwdsse  label  = 'SSE $ B/(W)'
         epercsse label  = 'SSE Variance'
                  format= percent10.0
                  ;
  set work.fincstx;
    where catgy = '6W88';
      keep rgncode
           distcode
           catgy
           class
           job_id
           job_loc
           st
           holdco
           supervsr
           prodline
           prodcode
           d_date
           k_date
           ftsdate

           /* Installation */
           source_i
           hrstrgi
           emphrsi
           ctrhrsi
           iacthrs
           ihrslft
           dolrtrgi
           i_cost
           ibwdol
           ipercom
           itottrav
           itotdol

           /* Engineering */
           source_e
           hrstrge
           emphrse
           ctrhrse
           eacthrs
           ehrslft
           dolrtrge
           e_cost
           ebwdol
           epercom
           etottrav
           etotdol

           /* EAE */
           htrgeea
           eactheae
           ehlfteae
           dtrgeea
           e_csteae
           ebwdeae
           eperceae

           /* FE */
           htrgefe
           eacthfe
           ehlftfe
           dtrgefe
           e_cstfe
           ebwdfe
           epercfe

           /* OTHR */
           htrgeot
           eacthot
           ehlftot
           dtrgeot
           e_cstot
           ebwdot
           epercot

           /* PAE */
           htrgepa
           eacthpae
           ehlftpae
           dtrgepa
           e_cstpae
           ebwdpae
           epercpae

           /* SAE */
           htrgesa
           eacthsae
           ehlftsae
           dtrgesa
           e_cstsae
           ebwdsae
           epercsae

           /* SDE */
           htrgesd
           eacthsde
           ehlftsde
           dtrgesd
           e_cstsde
           ebwdsde
           epercsde

           /* SSE */
           htrgess
           eacthsse
           ehlftsse
           dtrgess
           e_cstsse
           ebwdsse
           epercsse
           ;
run;

%dswrite(dsname=work.w88k,
         file=&OUTPUTTO/w88kfi.xls,
         dlm='09'x);

