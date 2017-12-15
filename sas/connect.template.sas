 /* If not using sasrun -c (which autowraps this stuff around non-Connect 
  * code):
 */

%include 'c:/cygwin/home/bqh0/code/sas/connect_setup.sas';
signon cdcjes2;
rsubmit;

 /* code goes here to be executed on the mf */
 /* e.g.  libname L 'BQH0.SASLIB' DISP=SHR; */

endrsubmit;
signoff cdcjes2;
