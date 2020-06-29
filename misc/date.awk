#!/bin/awk -f

BEGIN { print gettimeofday() };

function gettimeofday(time,    ret, now, i){
  # get time once, avoids unnecessary system calls    now = systime()
  # return date(1)-style output
  ret = strftime("%a %b %d %H:%M:%S %Z %Y", now)    # clear out target array
  for (i in time)        delete time[i]
  # fill in values, force numeric values to be    # numeric by adding 0
  time["second"]       = strftime("%S", now) + 0
  time["minute"]       = strftime("%M", now) + 0
  time["hour"]         = strftime("%H", now) + 0
  time["althour"]      = strftime("%I", now) + 0
  time["monthday"]     = strftime("%d", now) + 0
  time["month"]        = strftime("%m", now) + 0
  time["monthname"]    = strftime("%B", now)
  time["shortmonth"]   = strftime("%b", now)
  time["year"]         = strftime("%y", now) + 0
  time["fullyear"]     = strftime("%Y", now) + 0
  time["weekday"]      = strftime("%w", now) + 0
  time["altweekday"]   = strftime("%u", now) + 0
  time["dayname"]      = strftime("%A", now)
  time["shortdayname"] = strftime("%a", now)
  time["yearday"]      = strftime("%j", now) + 0
  time["timezone"]     = strftime("%Z", now)
  time["ampm"]         = strftime("%p", now)
  time["weeknum"]      = strftime("%U", now) + 0
  time["altweeknum"]   = strftime("%W", now) + 0    

  return ret
}
