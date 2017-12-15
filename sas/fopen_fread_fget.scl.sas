
rc=filename('filrf', 'c:\cygwin\home\bheckel\projects\datapost\tmp\FreeWeigh\CODE\t.sql');
put rc=;
fid=fopen('filrf','i', 0,'d');
put fid=;
rc2=fread(fid);
put rc2=;
rc3=fget(fid, mystr, 992);
put rc3=;
put mystr=;
