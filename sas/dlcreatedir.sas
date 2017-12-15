options dlcreatedir;

 /* see also  %let newdir=%sysfunc(dcreate(images, &outdir./results/));  but it requires 2 passes */

%let outdir=~/tmp;

libname res ("&outdir./results", "&outdir./results/images");
libname res clear;
