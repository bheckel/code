-- create tables
create table departments (
    name                           varchar2(255),
    location                       varchar2(255),
    country                        varchar2(255)
)
;

create table employees (
    department_id                  number
                                   constraint employees_department_id_fk
                                   references departments on delete cascade,
    name                           varchar2(255),
    email                          varchar2(255),
    job                            varchar2(255),
    hiredate                       date
)
;

create table skills (
    employee_id                    number
                                   constraint skills_employee_id_fk
                                   references employees on delete cascade,
    skill                          varchar2(255),
    proficiency                    number constraint skills_proficiency_cc
                                   check (proficiency in (1,2,3,4,5))
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
    null;
end employees_biu;
/

create or replace trigger skills_biu
    before insert or update 
    on skills
    for each row
begin
    null;
end skills_biu;
/


-- indexes
create index employees_i1 on employees (department_id);
create index skills_i1 on skills (employee_id);

-- comments
comment on column skills.proficiency is 'with 1 being a novice and 5 being a guru';
-- load data
 
insert into departments (
    name,
    location,
    country
) values (
    'Consulting',
    'Tanquecitos',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Governance and Acountability',
    'Sugarloaf',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Enteprise Resource Planning',
    'Dale City',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Logistics',
    'Grosvenor',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Analyst Relations',
    'Riverside',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Future Products',
    'Ridgeley',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Customer Relationship',
    'Ashley Heights',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Delivery',
    'Monfort Heights',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Real World Testing',
    'Point Marion',
    'United States'
);

insert into departments (
    name,
    location,
    country
) values (
    'Shipping and Receiving',
    'Eldon',
    'United States'
);

commit;
-- load data
 
insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Gricelda Luebbers',
    'gricelda.luebbers@aaab.com',
    'Analyst',
    sysdate - 13
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Dean Bollich',
    'dean.bollich@aaac.com',
    'Receptionist',
    sysdate - 60
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Milo Manoni',
    'milo.manoni@aaad.com',
    'Network Architect',
    sysdate - 6
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Laurice Karl',
    'laurice.karl@aaae.com',
    'Sustaining Engineering',
    sysdate - 48
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'August Rupel',
    'august.rupel@aaaf.com',
    'Sales Representative',
    sysdate - 37
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Salome Guisti',
    'salome.guisti@aaag.com',
    'Network Architect',
    sysdate - 39
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Lovie Ritacco',
    'lovie.ritacco@aaah.com',
    'Vice President',
    sysdate - 78
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Chaya Greczkowski',
    'chaya.greczkowski@aaai.com',
    'Engineer',
    sysdate - 54
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Twila Coolbeth',
    'twila.coolbeth@aaaj.com',
    'Accounting Analyst',
    sysdate - 20
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Carlotta Achenbach',
    'carlotta.achenbach@aaak.com',
    'Business Operations',
    sysdate - 22
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Jeraldine Audet',
    'jeraldine.audet@aaal.com',
    'Manufacturing and Distribution',
    sysdate - 49
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'August Arouri',
    'august.arouri@aaam.com',
    'Usability Engineer',
    sysdate - 8
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Ward Stepney',
    'ward.stepney@aaan.com',
    'Sustaining Engineering',
    sysdate - 3
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Ayana Barkhurst',
    'ayana.barkhurst@aaao.com',
    'Consultant',
    sysdate - 84
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Luana Berends',
    'luana.berends@aaap.com',
    'Receptionist',
    sysdate - 91
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Lecia Alvino',
    'lecia.alvino@aaaq.com',
    'Security Specialist',
    sysdate - 52
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Joleen Himmelmann',
    'joleen.himmelmann@aaar.com',
    'Programmer',
    sysdate - 68
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Monty Kinnamon',
    'monty.kinnamon@aaas.com',
    'Engineer',
    sysdate - 93
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Dania Grizzard',
    'dania.grizzard@aaat.com',
    'Usability Engineer',
    sysdate - 6
);

insert into employees (
    department_id,
    name,
    email,
    job,
    hiredate
) values (
    1,
    'Inez Yamnitz',
    'inez.yamnitz@aaau.com',
    'Webmaster',
    sysdate - 79
);

commit;
-- load data
 
insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'PYTHON',
    5
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'C++',
    5
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'JAVASCRIPT',
    1
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'CSS',
    4
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'JAVASCRIPT',
    5
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'APEX',
    2
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'JSON',
    2
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'JAVA',
    3
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'C++',
    5
);

insert into skills (
    employee_id,
    skill,
    proficiency
) values (
    1,
    'C++',
    5
);

commit;

