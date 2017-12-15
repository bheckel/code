options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_ds2_threads.sas
  *
  *  Summary: Demo of ds2 threading
  *
  *  Adapted: Thu 24 Aug 2017 15:14:56 (Bob Heckel--http://www.notecolon.info/2013/02/note-ds2-threaded-processing.html)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

/*****************************/
/* Create a chunky data set. */
/* Then read it:             */
/* a. With one thread        */
/* b. With eight threads     */
/* c. Using "old" DATA step  */
/*****************************/

/* In our simple case, the code was compute-bound. If your task is more I/O-bound then the benefits may be less predictable */

options msglevel=n;
options cpucount=actual;  /* CPU hog mode on */
options fullstimer;

proc options option=threads;run;
/****************************/
/* Create a chunky data set */
/****************************/
data work.jmaster;
  do i = 1 to 10e7;
    output;
  end;
run;


/**************************/
/* Now read it three ways */
/**************************/

/* But first define the threaded code thread */
proc ds2;
  thread r /overwrite=yes;
    dcl double count;
    method run();
      set work.jmaster;
      count+1;
      do k=1 to 100;/* Add some gratuitous computation! */
        x=k/count + k/count + k/count;
      end;
    end;
    method term();
      OUTPUT;
    end;
  endthread;
run; quit;


/* One thread */
proc ds2;
  data j1(overwrite=yes);
    dcl thread r r_instance;
    dcl double count;
    method run();
      set from r_instance threads=1;
      total+count;
    end;
  enddata;
run; quit;


/* Eight threads */
proc ds2;
  data j8(overwrite=yes);
    dcl thread r r_instance;
    dcl double count;
    method run();
      set from r_instance threads=8;
      total+count;
    end;
  enddata;
run; quit;


/* Old DATA step */
data jold;
  set work.jmaster end=finish;
  count+1;
  do k=1 to 100;/* Add some gratuitous computation! */
    x=k/count + k/count + k/count;
  end;
  if finish then output;
run;
