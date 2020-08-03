/* Using Analytic functions group by date range start and date range end. https://livesql.oracle.com/apex/livesql/file/content_C35KKE5TX8H1O3M2Z5TLAGAON.html */

/* 1. */
select date_taken,
  case
    when nvl(lag(date_taken) over (order by date_taken),date_taken) != date_taken-1 then date_taken
  end loval
from lab_samples
order by 1
/*
DATE_TAKEN	LOVAL
01-DEC-15	01-DEC-15
02-DEC-15	-
03-DEC-15	-
04-DEC-15	-
07-DEC-15	07-DEC-15
08-DEC-15	-
09-DEC-15	-
10-DEC-15	-
14-DEC-15	14-DEC-15
15-DEC-15	-
16-DEC-15	-
19-DEC-15	19-DEC-15
20-DEC-15	-
*/

/* 2. */
select date_taken, max(loval) over (order by date_taken) loval
from (
	select date_taken,
		case
			when nvl(lag(date_taken) over (order by date_taken),date_taken) != date_taken-1 then date_taken
		end loval
	from lab_samples )
order by 1
/*
DATE_TAKEN	LOVAL
01-DEC-15	01-DEC-15
02-DEC-15	01-DEC-15
03-DEC-15	01-DEC-15
04-DEC-15	01-DEC-15
07-DEC-15	07-DEC-15
08-DEC-15	07-DEC-15
09-DEC-15	07-DEC-15
10-DEC-15	07-DEC-15
14-DEC-15	14-DEC-15
15-DEC-15	14-DEC-15
16-DEC-15	14-DEC-15
19-DEC-15	19-DEC-15
20-DEC-15	19-DEC-15
*/

/* 3. */
select min(date_taken) range_start, max(date_taken) range_end
from (
  select date_taken,max(loval) over (order by date_taken) loval
  from (
    select date_taken,
      case
        when nvl(lag(date_taken) over (order by date_taken),date_taken) != date_taken-1 then date_taken
      end loval
    from lab_samples))
group by loval
order by 1
/*
RANGE_START	RANGE_END
01-DEC-15	04-DEC-15
07-DEC-15	10-DEC-15
14-DEC-15	16-DEC-15
19-DEC-15	20-DEC-15
*/
