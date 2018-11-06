
insert into lu_dea_states ([plan]) values ('MI')



insert into links_material (MATL_DESC, matl_mfg_dt, matl_exp_dt, matl_nbr, batch_nbr, matl_typ) values ('Waiting for update from SAP', '01-JAN-1960', '01-JAN-1960', '0737003', '6ZP8404', 'MANL')



insert into mailing_list (name, email)
values ('Philip Greenspun','philg@mit.edu');
insert into mailing_list (name, email)
values ('Michael O''Grady','ogrady@fastbuck.com');

-- Evil shortcut without specifying phone_numbers fields but instead assuming their order
insert into phone_numbers values ('ogrady@fastbuck.com','work','(800) 555-1212');
insert into phone_numbers values ('ogrady@fastbuck.com','home','(617) 495-6000');
insert into phone_numbers values ('philg@mit.edu','work','(617) 253-8574'); 
insert into phone_numbers values ('ogrady@fastbuck.com','beper','(617) 222-3456');



INSERT INTO retain.fnsh_prod (fnsh_prod_id_nbr, matl_nbr, lot_nbr, retn_cont_cnt,         retn_dt,             retn_loc, prod_exp_dt,              prod_act_ind, prod_sel, locked_by_patron_id, perf_by_patron_id, prod_sel_dt, annivsry_dt, deleted_ind) 
VALUES                       ( 11111,          '0682004', '1ZP9999',     8,       to_date('03AUG11','DDMONYY') ,null ,  to_date('31DEC13','DDMONYY'),   'Y' ,        'N' ,        null,              'rsh86800'        ,null ,       null,         'N')



-- Insert 5-star ratings by James Cameron (207) for all movies in the database.
-- Leave the review date as NULL.
insert into rating
select 207, mid, 5, NULL
from movie
where mid in(select distinct mid from movie)



insert into target_table ( col1, col2, ...)
  select col1, col2, ...
  from   source_table;



insert all  
  into teddies values ('Dinosaur King', 'red')  
  into bricks values ('sphere', 'green', 100)  
  select * from dual;



insert all
  into people values (full_name)
  when hire_date is not null then 
    into staff values (hire_date)
  when nhs_number is not null then 
    into patients values (nhs_number)
  select * from people_details;
