BEGIN
	dbms_output.put_line('Do all commands = &doAll');

	if ('&doAll' in ('y','Y','yes','YES')) then
		 dbms_output.put_line('****Saving Object Grants****');
		 -- ...
   end if;
END;
/

