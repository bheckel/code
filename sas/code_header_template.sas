
options nosymbolgen nosource;
%put NOTE - **************************************************************;
%put NOTE - Program &_CLIENTTASKLABEL..sas started at %sysfunc(datetime(), datetime.);
%put NOTE - Run by: &sysuserid;
%put NOTE - SAS Version: &sysvlong;
%put NOTE - OS: &sysscp&sysscpl;
%put NOTE - Computer: &systcpiphostname;
%put NOTE - ****************************************************************;
options symbolgen source;
%put _all_;
