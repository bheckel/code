
select NAME, TYPE, LINE, TEXT, 'esd' from SYS.USER_SOURCE@sed t WHERE t.TYPE='PACKAGE BODY' and t.name like 'RION%' AND (upper(t.TEXT) LIKE '%BHECK%')
union all
select NAME, TYPE, LINE, TEXT, 'est' from SYS.USER_SOURCE@set t WHERE t.TYPE='PACKAGE BODY' and t.name like 'RION%' AND (upper(t.TEXT) LIKE '%BHECK%')
union all
select NAME, TYPE, LINE, TEXT, 'esuat' from SYS.USER_SOURCE@seuat t WHERE t.TYPE='PACKAGE BODY' and t.name like 'RION%' AND (upper(t.TEXT) LIKE '%BHECK%')
union all
select NAME, TYPE, LINE, TEXT, 'esps' from SYS.USER_SOURCE@seps t WHERE t.TYPE='PACKAGE BODY' and t.name like 'RION%' AND (upper(t.TEXT) LIKE '%BHECK%')
union all
select NAME, TYPE, LINE, TEXT, 'esp' from SYS.USER_SOURCE@sep t WHERE t.TYPE='PACKAGE BODY' and t.name like 'RION%' AND (upper(t.TEXT) LIKE '%BHECK%')
;
