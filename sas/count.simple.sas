libname l 'U:\_go\tmp';
proc sql;
select count(*) from l.old;
select count(*) from l.new;
quit;
