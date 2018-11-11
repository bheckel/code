-- create tables
create table departments (
    name                           varchar2(255) not null,
    location                       varchar2(4000),
    country                        varchar2(4000)
)
;

create table employees (
    department_id                  number
                                   constraint employees_department_id_fk
                                   references departments on delete cascade,
    name                           varchar2(50) not null,
    email                          varchar2(255),
    cost_center                    number,
    date_hired                     date,
    job                            varchar2(255)
)
;


-- triggers
create or replace trigger departments_biu
    before insert or update 
    on departments
    for each row
begin
    null;
end departments_biu;
/

create or replace trigger employees_biu
    before insert or update 
    on employees
    for each row
begin
    :new.email := lower(:new.email);
end employees_biu;
/


-- indexes
create index employees_i1 on employees (department_id);

-- create views
create or replace view emp_v as 
select 
    departments.name                                   department_name,
    departments.location                               location,
    departments.country                                country,
    employees.name                                     employee_name,
    employees.email                                    email,
    employees.cost_center                              cost_center,
    employees.date_hired                               date_hired,
    employees.job                                      job
from 
    departments,
    employees
where
    employees.department_id(+) = departments.id
/

-- load data
 
insert into departments (
    name,
    location,
    country
) values (
    'Systems Architecture',
    'Tanquecitos',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Customer Support',
    'Sugarloaf',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Systems Development',
    'Dale City',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Customer Support',
    'Grosvenor',
    'United States'
);

commit;
-- load data
 
insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Gricelda Luebbers',
    'gricelda.luebbers@aaab.com',
    26,
    sysdate - 59,
    'Receptionist'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Dean Bollich',
    'dean.bollich@aaac.com',
    38,
    sysdate - 74,
    'Facilities Manager'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Milo Manoni',
    'milo.manoni@aaad.com',
    76,
    sysdate - 98,
    'Systems Designer'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Laurice Karl',
    'laurice.karl@aaae.com',
    17,
    sysdate - 57,
    'Facilities Manager'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'August Rupel',
    'august.rupel@aaaf.com',
    34,
    sysdate - 41,
    'Executive Engineer'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Salome Guisti',
    'salome.guisti@aaag.com',
    70,
    sysdate - 9,
    'Programmer'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Lovie Ritacco',
    'lovie.ritacco@aaah.com',
    4,
    sysdate - 49,
    'Facilities Manager'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Chaya Greczkowski',
    'chaya.greczkowski@aaai.com',
    54,
    sysdate - 99,
    'Finance Analyst'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Twila Coolbeth',
    'twila.coolbeth@aaaj.com',
    100,
    sysdate - 86,
    'Software Engineer'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Carlotta Achenbach',
    'carlotta.achenbach@aaak.com',
    100,
    sysdate - 60,
    'System Operations'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Jeraldine Audet',
    'jeraldine.audet@aaal.com',
    32,
    sysdate - 13,
    'Data Architect'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'August Arouri',
    'august.arouri@aaam.com',
    41,
    sysdate - 55,
    'Sustaining Engineering'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Ward Stepney',
    'ward.stepney@aaan.com',
    76,
    sysdate - 56,
    'Sales Representative'
);

insert into employees (
    department_id,
    name,
    email,
    cost_center,
    date_hired,
    job
) values (
    1,
    'Ayana Barkhurst',
    'ayana.barkhurst@aaao.com',
    95,
    sysdate - 27,
    'Network Architect'
);

commit;

