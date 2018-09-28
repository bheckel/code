-- Insert if we don't have a record to update

create table foo (
  name varchar2(10) primary key,
  age  number
);

merge into foo a
	using (select 'johnny' name, null age from dual) b
		on (a.name = b.name)
	when not matched then
		insert(name, age) values(b.name, b.age);
