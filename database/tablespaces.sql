
SELECT a.file_name,
       substr(A.tablespace_name,1,14) tablespace_name,
       trunc(decode(A.autoextensible,'YES',A.MAXSIZE-A.bytes+b.free,'NO',b.free)/1024/1024) free_mb,
       trunc(a.bytes/1024/1024) allocated_mb,
       trunc(A.MAXSIZE/1024/1024) capacity,
       a.autoextensible ae
FROM (
     SELECT file_id, file_name,
            tablespace_name,
            autoextensible,
            bytes,
            decode(autoextensible,'YES',maxbytes,bytes) maxsize
     FROM   dba_data_files
     GROUP BY file_id, file_name,
              tablespace_name,
              autoextensible,
              bytes,
              decode(autoextensible,'YES',maxbytes,bytes)
     ) a,
     (SELECT file_id,
             tablespace_name,
             sum(bytes) free
      FROM   dba_free_space
      GROUP BY file_id,
               tablespace_name
      ) b
WHERE a.file_id=b.file_id(+)
AND A.tablespace_name=b.tablespace_name(+)
ORDER BY A.tablespace_name ASC; 
