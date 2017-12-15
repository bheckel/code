
select * from #bobtmp
where DATEDIFF(YEAR, dob, GETDATE()) > 1
