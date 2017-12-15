
 /* see ~/code/sas/proc_presenv.save.sas */

%include '~/bob/tmp/proc_presenv.sas';
%put _ALL_;
proc print data=t(obs=10) width=minimum heading=H;run;title;
