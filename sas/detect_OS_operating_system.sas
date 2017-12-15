      if symget('SYSSCP')='WIN' then do;
        entry = trim(dir) || '\' || entry;
      end;
      else if symget('SYSSCP')='HP 64' or symget('SYSSCP')="LIN X64" or symget('SYSSCP')='LINUX' or symget('SYSSCP')='AIX 64' or symget('SYSSCP')='SUN 64' then do;
        entry = trim(dir) || '/' || entry;
      end;
      else do;
        put "ERROR: unsupported OS detected &SYSSCP";
      end;
