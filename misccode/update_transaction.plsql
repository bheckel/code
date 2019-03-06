
create table toys (
  toy_name varchar2(30),
  price    number
);

insert into toys values ( 
  'Baby Turtle' ,  5 
);
insert into toys values ( 
  'Purple Ninja',  9 
);
insert into toys values ( 
  'Cuteasaurus' , 20 
);
commit;


-- Without PLSQL the first 2 UPDATEs will happen despite the 3rd failing
begin
	update toys  
	set    price = 7 
	where  toy_name = 'Baby Turtle';

	update toys  
	set    price = 10 
	where  toy_name = 'Purple Ninja';

	update toys  
	set    xprice = 'fails!' 
	where  toy_name = 'Cuteasaurus';

	commit;

exception
  when others then
    -- We want all 3 updated in a transaction else undo everything
    rollback;
    dbms_output.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK );  
end;

select * from toys;
