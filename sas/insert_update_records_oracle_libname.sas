options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: insert_update_records_oracle_libname.sas
  *
  *  Summary: Insert record based on user's domain.  No idea how to use UPDATE
  *           query in SQL to do this.
  *
  *           Limitation: requires a DROP and then ALTER of the Oracle table, 
  *           not done inplace.  See insert_update_records_oracle_libname2.sas
  *
  *  Created: Thu 12 Jul 2012 11:22:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let db=sdev581;
%let usr=ks;
%let pw=ev123dba;
%let tbl=ser_role2;

 /* Implicit pass-through */
libname ORA oracle user=&usr password=&pw path=&db;

 /* VARCHARS work automatically but must specify CHAR (and maybe others) */
data ORA.user_role3(DBTYPE=(user_status='CHAR(1)' prod_op_ind='CHAR(1)'));
  set ORA.&tbl;
  output;  /* keep original domain and updater */
  if user_domain in:('s1_auth','S1_AUTH') then do;
    user_domain = 'MSERVICE';
    updated_by_patron_id='sh86800';
    output;
  end;
run;

 /* Then rename in Oracle: ALTER TABLE user_role3 RENAME TO user_role2; */
