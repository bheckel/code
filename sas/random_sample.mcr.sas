/* Adapted: Mon, 13 Dec 1999 13:54:41 (Bob Heckel)
 * TODO allow calling via _random(sample, seed, data, output)
 * Sample call:
 *
 *   %include '/DART/users/bh1/random_burchill.sas';
 *   _random sample=10
 *           seed=5
 *           data=dart.jobcost
 *           output=work.output;
 *
 *  Call:
 *     _random options ;
 *
 *  Options:
 *      data=    Data set name.
 *      output=  Output dataste name (required).
 *      seed=    Seed value for SAS random number lookup, default system time.
 *      sample=  Size of the sample, total or within in each by group.
 *      percent= Size of sample based on % of dataset size, or by group size.
 *               One of Sample or Percent is required, if both are
 *               provided percent is used.
 *      by=      Varible(s) to sample by.
 *               Multiple variables must be enclosed in quotes
 *               (e.g. by="hosp agegrp").
 *      min=     Minimum size in a % sample by group.
 *      debug=   Turn on or off debuging (=debug, =nodebug).
 *
 *  Example Calls:
 *  Randomly sample claims within each hospital
 *   With at least 5 samples (if there are that many). ;
 * data test;
 *    set cpe.hsp9394(obs=5000 keep=los hosp) ;
 *    run;
 * _random percent=50  seed=5 min=5
 *      data=test by=hosp
 *      output=dump ;
 *
 *  Randomly select 100 claims from a dataset;
 * _random sample=100
 *         seed=5
 *         data=hosp
 *         output=sample ;
 *
 */

options implmac ;

%macro _random(sample=,data=,output=,percent=,seed=0,
               debug=nodebug,by=,min=) / stmt  /** store des='random sampler' **/ ;
  %local sample data output percent seed by min ;
  options notes;
  %put ;
  %put Macro for random sampling of datasets ;
  %put Version 1.31, Feburary 6, 1994 ;
  %put Charles Burchill, Manitoba Centre for Health Policy and Evaluation ;
  %put Input from: Randy Walld, Shelley Derksen, Ruth Bond ;
  %put ;

  %* Turn on debuging option for checking and testing program.;
  %if &debug=debug %then options mprint notes ;
  %else options nomprint nonotes ;;

  %* Pick up last dataset that was in use if data is not provided ;
  %if &data= %then %do ;
     %let data=%substr(&sysdsn,1,8).%substr(&sysdsn,9) ;
     %end ;

  %* Check if the minimum requirements of the program are provided. ;
  %if ( (&sample= & &percent= ) | &output= ) %then %goto error0 ; ;

    %* Seperate the libname and the dataset name for use in
      the proc sql dictionary ;
    %let data=%upcase(&data) ;
    %* test for a two level name ;
    %if %index(&data,.) %then %do;
       %let libname=%scan(&data,1);
       %let data=%scan(&data,2);
       %end;
    %else %do ;
       %let libname=WORK ;
       %end ;

  %* separate runs that use by group processing, which requires
     sorting the dataset, and non-bygroup which uses pointers (faster);
  %if &by= %then %do ;

    %* Retrieve information on the requested data set.
       Information includes the number of observations,
       if the dataset is SAS compressed, and if it is a view or data
       type ;
    proc sql;
          create view _rtemp as
       select nobs, compress, memtype from dictionary.tables
       where libname=upcase("&libname") and
             (memtype='DATA' or memtype='VIEW') and
             memname=upcase("&data");

    %* Pick up the created datset to transfer variables into
       macro format ;
    data _null_ ;
      set _rtemp ;
      call symput('_obs',trim(left(put(nobs,12.)))) ;
      call symput('_cps',compress) ;
      call symput('_typ',memtype) ;
      %* If the percent parameter is passed calculate the sample
         size for the dataset ;
      %if &percent ^= %then %do ;
         if nobs ^= . then sample=round(&percent/100*nobs) ;
         call symput('sample',trim(left(put(sample,12.)))) ;
         %end ;
      run;

    %* Since pointers can not be used in views or compressed datasets.
       Create a temporary dataset from these types of files. ;
    %if &_typ=VIEW | &_cps=YES %then %do ;
      data _rtemp2  ;
        set &libname..&data end=last ;
        if last then call symput('_obs',trim(left(put(_n_,12.)))) ;
        %if &percent ^= %then %do ;
           if last then do ;
             _sample_=round(&percent/100*_n_) ;
             call symput('sample',trim(left(put(_sample_,12.)))) ;
             end ;
           drop _sample_ ;
           %end ;
        run;

      %* reset the data set name and library to the temproary ones ;
      %let libname = WORK ;
      %let data = _RTEMP2 ;
      %end;

    %* check if the user has requested a sample that is larger than the
       dataset size ;
    %if &sample > &_obs %then %goto error2 ; ;

    %* Proc plan can only generate sample sizes of less than
       10000. The next loop captures larger datasizes ;
    %if &sample > 9999 %then %do ;
         data &output;
            retain _sample_ &sample _numb_ ;
            drop _sample_ _numb_ ;
            if _n_=1 then _numb_=_numobs_ ;
            set &libname..&data point=_n_ nobs=_numobs_;
            if ranuni(&seed) < _sample_/_numb_ then do ;
               output ;
               _sample_ = _sample_ - 1 ;
               end;
            _numb_ = _numb_ - 1 ;
            if _numb_ = 0 | _sample_ = 0 | _n_=_numobs_ then stop ;
            run;

         %end;

    %* For sample sizes smaller than 10000 use the faster proc plan
       method ;
    %else %if &sample < 10000 %then %do ;
       %* Create a dataset of size sample of random numbers
          within the size of the dataset ;
       proc plan %if &seed ^=0 %then seed=&seed ;;
         factors _s1_=&sample of &_obs / noprint;
         output out=_rsample ;
         run;

       %* Create the sample output datset using the random numbers
          from proc plan to point to observations in the raw data;
       data &output ;
         set  _rsample ;
         set &libname..&data 
           point=_s1_ ;
         run;
       %end ;

     %end ;

  %* If by variable(s) have been defined use this method.
     Attach a random number to each variable and sort by
     the by variables and the random number;
  %else %if &by ^=() %then %do ;

    %* Check if the by string is quoted, if it is strip the
      quotes and extract the last item for first. processing;
    %let byq=%qsubstr(&by,1,1);
    %if &byq = %str(%') | &byq = %str(%") %then %do ;
       %let rq=%length(&by);
       %let by = %substr(&by,2,%eval(&rq-2)) ;
       %let n=1 ;
       %let word=%qscan(&by,&n,%str( )) ;
       %do %while(&word^=) ;
           %let n=%eval(&n+1);
           %let word=%qscan(&by,&n,%str( )) ;
            %end ;
       %let l_item=%qscan(&by,%eval(&n-1),%str( ));
       %end ;
    %else %do ;
       %let l_item=&by ;
       %end ;

    %* Put the raw data into a temproary dataset.  Add a random number
       to each variable. ;
    data _rtemp2;
        set &libname..&data ;
        _rand_ =ranuni(&seed) ;
        run;

    %* Sort the data by the by variable(s) and random number ;
    proc sort data=_rtemp2 ;
      by &by  _rand_ ;
      run;

    %* Seperate the processing for a single sample size.
       Count the observations in each by group until
       the sample size has been reached. ;
    %if &percent = %then %do ;

    data &output(drop=_count_ _under_ ) ;
      set _rtemp2(drop=_rand_) end=last ;
      by &by ;
      retain _under_  0 ;
      if first.&l_item then _count_ = 1 ;
      if last.&l_item then do;
         if _count_ < &sample then _under_+1 ;
         end ;
      if _count_ <= &sample then output ;
      _count_ = _count_ + 1 ;
      retain _count_ _under_;
      if last then  call symput('und',trim(left(put(_under_,12.)))) ;
      run;

      %* Flag the number of by groups that had fewer values
         than requested by the user ;
      %if &und > 0 %then %do;
         %put NOTE: &und by groups had fewer values than the requested sample size.;
         %end ;
      %end;

    %* Process the data if a percent of data size has been requested.
       Count the number of observations in each by group level
       and add this variable to the dataset ;
    %else %if &percent ^= %then %do ;

    proc summary data=_rtemp2 nway ;
      class &by ;
      output out=_rsample(drop=_type_ rename=(_freq_=_tcount_));
      run;

    data &output (drop=_tcount_ _count_) ;
      merge _rtemp2(drop=_rand_ ) _rsample ;
      by &by ;
      if first.&l_item then _count_=1 ;
      if _count_/_tcount_ <= &percent/100
           %if &min ^= %then | _tcount_ <= &min ;
           then output ;
      _count_ = _count_+1 ;
      retain _count_ ;
      run;

      %end ;
    %end ;

  %* Delete temporary datasets created by this macro ;
  proc datasets nolist;
     delete _rtemp2 _rsample / memtype=DATA ;
     delete _rtemp / memtype=VIEW ;
      quit ;
      run;

  %goto exit ;

  %* Error checking ;
  %error0:
     options notes ;
     %put ;
     %put WARNING: One (or more) macro option(s) has not been defined. ;
     %put EXPECTING: sample= or percent=, and output= ;
     %put NOTE: Available options data=, sample=, percent=, output=, seed=, by= ;
     %put ;
     %goto exit2 ;

  %error2:
     options notes ;
     %put ;
     %put WARNING: The you have provided a sample size (&sample) that is larger ;
     %put than the total dataset size (&_obs).  The sample size must be smaller ;
     %put than the number of observations in the dataset. ;
     %put ;
     %goto exit2 ;

  %exit:
     options notes ;
     %put ;
     %put NOTE: Input dataset:  &libname..&data ;
     %put NOTE: Output dataset: %upcase(&output)  ;
     %put NOTE: Random seed:    &seed ;
                %if &sample ^= %then %put NOTE: Sample size:    &sample ;
                %if &by ^= %then %put     NOTE: By variable(s): %upcase(&by) ;
     %put ;
     ;
  %exit2:  ;
%mend _random ;
