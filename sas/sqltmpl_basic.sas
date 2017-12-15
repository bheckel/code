/*---------------------------------------------------------------------------
 *   Program Name:  sqltmpl.sas
 *
 *        Summary:  Template for adhoc ds queries.
 *
 *                  Mnemonic: So Few Workers Go Home On Time
 *                            SELECT var1, var2
 *                            FROM work.foo
 *                            WHERE (condition)
 *                            GROUP by var1
 *                            HAVING (condition)
 *                            ORDER by var1 ;
 *
 *      Generated:  Wed Oct  7 08:38:06 1998 (Bob Heckel)
 * Modified: Sun 25 May 2003 10:48:56 (Bob Heckel)
 *---------------------------------------------------------------------------
 */

libname master '/disc/data/master/';

proc sql;
  select job_id, class, customer, custname, distcode,
         rgncode, respcode, source_e, source_i
  from master.jobcost
  where job_id in ('H2D122','H1X332','H1W553')
  order by job_id
  ;
quit;
