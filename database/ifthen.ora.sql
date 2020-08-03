
-- Oracle CASE or IF-THEN-ELSE shortcut, replacement
--                                IF  THEN     IF       THEN  ELSE
select prod_nm, decode(prod_grp,'MDPI','m','Solid Dose','sd','unk') from samp;

-- If numeric field holds a 1 then flag a new column
select decode(r.proccancelflag,1,'RETEST') as pcf from resultall
