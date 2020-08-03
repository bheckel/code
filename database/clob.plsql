
create table count_test(
	id      number,
	val     varchar2(40),
	clb     clob);

begin
	for z in 1..1000000 loop
		 insert into count_test
		 values(z, 'Record '||z, 'Clob value '||z);
	end loop;

	commit;
end;
/
