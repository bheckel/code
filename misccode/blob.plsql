
-- Adapted: 13-Apr-2020 (Bob Heckel--https://connor-mcdonald.com/2020/04/07/will-a-blob-eat-all-my-memory/)
declare
  l_raw blob := utl_raw.cast_to_raw(lpad('X',1000,'X'));
  c     blob;
begin
  c := l_raw;
  for i in 1 .. 10000 loop
    dbms_lob.writeappend (c, utl_raw.length(l_raw), l_raw);
  end loop;

  for i in (
    select 'pga '||value val
      from v$mystat
     where statistic# = 40  -- session pga memory max
    union all
    select 'blk '||blocks  -- temporary space
      from v$sort_usage
     where username = 'ADMIN'
    union all
    select 'len '||dbms_lob.getlength(c)
      from dual
  ) loop
    dbms_output.put_line(i.val);
  end loop;
end;
