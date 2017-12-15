
%macro m;
  options mlogic;
  libname data '/Drugs/TMMEligibility/MarathonPhar/Imports/20170606/Data';
	proc contents 	
		data=data.rxfilldata
		out=cont_entity(keep=name)
		noprint;
	run;
title "&SYSDSN";proc print data=cont_entity(obs=10) width=minimum heading=H;run;title;  

	proc sql noprint;
		select count(*) into:NOBS
			from cont_entity
		;
	quit;

	proc sql noprint;
		select count(*) into: nobs2
			from data.rxfilldata;
	quit;

	%let dsId = %Sysfunc(open(cont_entity));
	%let N_NOME_CAMPO = %Sysfunc(varnum(&dsId.,name));
	%let I=1;

	proc sql;
		create table stat_missing as
			select

			%do %while (%Sysfunc(fetch(&dsId.)) = 0);
				%let NOME_CAMPO = %Sysfunc(getvarc(&dsId.,&N_NOME_CAMPO));

				%if &I ne &NOBS %then
					%do;
						coalesce(sum(missing(&NOME_CAMPO.)),0) as &NOME_CAMPO. ,
					%end;
				%else
					%do;
						coalesce(sum(missing(&NOME_CAMPO.)),0) as &NOME_CAMPO.
					%end;

				%let I= %eval(&I + 1);
			%end;

		from data.rxfilldata
		;
	quit;
title "&SYSDSN";proc print data=stat_missing(obs=10) width=minimum heading=H;run;title;  

	%let RC= %sysfunc(close(&DsId));

	proc transpose data=stat_missing out=stat_missing2;
	run;

	title 'Number of Missing Values Summary';

	proc sql;
		select _NAME_ as Column_Name,
			Col1 as N_Missing,
			&nobs2 as Total_Records,
			Col1/&nobs2 as Perc_Missing format percent8.2
		from stat_missing2
		;
	quit;
%mend; %m;
