-- Increase number by multiplying by 4
update goodclm
set stren = cast(stren as decimal(3,0)) *4
where source = 'o' and brand like '%add%'
