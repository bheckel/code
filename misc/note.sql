
select distinct r.sampid, s.specname 
from result r, spec s 
where rescomment like 'NOTE:%' 
and r.sampname like 'SC%' 
and r.specrevid=s.specrevid
and r.sampid not in(188400,189367,189762,190299,191968,192004,198164,199580,202182,204455,208279,208358,208430,210255,210257,216442,224995,225318,234725,240831,244243)
  ;

exit;
