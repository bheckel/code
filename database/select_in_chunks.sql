
-- Select records from a control table by chunk pieces
select distinct account_id
  from (select account_id, row_number() OVER (order by account_id) rn from ria_sg_acct_chk_del_02052020@sep ) v
 --where v.rn between 101 and 200
 --where v.rn between 201 and 300
 --where v.rn between 301 and 400
 --where v.rn between 401 and 500
 --where v.rn > 500
;

SELECT account_id
	FROM ( select account_id, row_number() OVER (order by account_id) rn from rion_44166@sed )
 WHERE rn between 85 and 125
	 AND account_id not in (999,888);
