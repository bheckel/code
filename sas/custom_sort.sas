options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: custom_sort.sas
  *
  *  Summary: Specify your own sorting order.
  *
  *  Created: Fri 10 May 2013 10:26:51 (Bob Heckel)
  * Modified: Wed 14 Jun 2017 10:42:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc sql;
  select monotonic() as debug, *
  from (select Region, Product, Subsidiary,
               case when (Region eq 'Canada') then 1
                    when (Region eq 'Asia')   then 2
                    when (Region eq 'Africa') then 3
                                              else 9
                    end as sortby
        from sashelp.shoes)
  where Product eq 'Sandal'
  order by sortby
  ;
quit;


endsas;
proc sql;
  create table totals as
  select *
  from (select *,
        case when (description like '%Original%') then 1
             when (description like '%Non-Pilot%') then 2
             when (description like '%18%') then 3
             when (description like '%Gender%') then 4
             when (description like '%State%') then 5
             end as sortby
        from totals)
  order by sortby;
quit;
