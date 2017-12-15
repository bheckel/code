options fullstimer;

 /* OS Memory represents the amount of memory SAS allocates from the operating
  * system that is to be used by the threaded kernel and by SAS DATA steps and
  * procedures. In the FULLSTIMER summary at the end of the SAS log, the value
  * for OS Memory reflects the peak memory usage for the entire process. 
  *
  * Page Faults indicates the number of memory pages that SAS tries
  * to access, but that are not in the main memory and that require I/O
  * activity. A consistently high number of page faults that occur across
  * multiple steps might indicate that not enough memory is available to the
  * process. It can also mean that the application is reading a very large
  * sequential file without doing any serious processing, causing high (but
  * normal) values for Page Faults
  *
  * Page Reclaims indicates the number of page faults that are
  * serviced without any I/O activity. I/O activity is avoided by the process
  * of reclaiming a page frame from the list of memory pages that are awaiting
  * reallocation.
  *
  * The Page Swaps indicates the number of times a process is swapped out of
  * main memory. 
  *
  * Values for the Voluntary Context Switches and Involuntary Context Switches
  * reflect the number of times the process switches from an active to inactive
  * state, and vice versa. A voluntary context switch indicates that the
  * process relinquished the CPU. This usually occurs when the process is
  * waiting for the availability of a resource. For example, suppose you have a
  * process that needs to read a large data set. When SAS recognizes that this
  * process will not use a CPU during a lengthy reading, the software
  * efficiently (and voluntarily) releases the CPU to serve another process
  * until the reading is complete.  An involuntary context switch indicates
  * that the kernel forces the process into an inactive state. For example, if
  * you have a higher-priority process starting on the system, the kernel
  * forces your lower-priority process into an inactive state while it runs the
  * one with the higher priority.  If the number of involuntary context
  * switches is consistently high, it might be an indication that the step or
  * process is experiencing a computer-resource constraint. At this point, you
  * should use vendor-supplied tools to monitor the CPU to determine whether a
  * resource constraint is the cause. 
  *
  * 1-For nominally good SAS I/O performance, you should see job steps in your
  * SAS logs with combined CPU + User CPU time within 10% of the Real Time.
  *
  * 2-As a general rule, the User CPU Time value added to the System CPU Time
  * value should be fairly close to the Real Time value. If the Real Time value
  * is much higher, as it is in this example, then you have a problem that
  * needs to be corrected. 
  */

proc options group=(performance memory); run; 

options ls=180 ps=max; libname l '.';

data l.random;
  array x(100);
  do i=1 to 100;
    x(i)=ranuni(i);
  end;
  do i=1 to 7500000;
    output;
   end;
run; 
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


proc sort in=l.random out=l.random2;  by x1; run;
