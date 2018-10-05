QuickRef
========
$ /opt/mysql/bin/mysql    <---as root initially
show databases;
use indocc
show tables;
desc mytable;
select * from mytable where literal like 'police%';
\q (or quit or quit;)


Installation -- Cygwin:
======================
mysql-3.23.51.tar.gz compiles OOTB for Cygwin 06/17/02
Before starting, add to /etc/passwd:
mysql::1003:514:MySQL::/bin/false
Add to /etc/group:
mysql:514:555:

$ ./configure --prefix=/usr/local/mysql
$ make
$ make test   <---not sure if this is worth it; it can't kill test daemons
$ make install
$ cd scripts
$ ./mysql_install_db
$ /usr/local/mysql/bin/safe_mysqld &

At this point the daemon cannot be killed, it keeps respawning (as it is
supposed to).  Think I should be using something other than safe_mysqld
(mysql.server start ?) for Cygwin use.


Start MySQL daemon (assumes installation succeeded) -- Cygwin:
=============================================================
$ /usr/local/mysql/bin/safe_mysqld &
$ /usr/local/mysql/bin/mysql



Installation -- Debian (per INSTALL-SOURCE file in the tarball):
===============================================================
As root:
$ groupadd mysql
$ useradd -g mysql mysql  <---no home dir created, may want to change
                              /bin/bash to /bin/false
As bqh0:
Untar and cd to the mysql src dir
$ CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors -fno-exceptions \
          -fno-rtti" ./configure --prefix=/usr/local/mysql --enable-assembler \
          --with-mysqld-ldflags=-all-static
or
$ CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" ./configure --prefix=/usr/local/mysql --enable-assembler --with-mysqld-ldflags=-all-static
$ make
$ su -
$ make install
$ cd scripts
$ ./mysql_install_db
$ chown -R root  /usr/local/mysql
$ chown -R mysql /usr/local/mysql/var
$ chgrp -R mysql /usr/local/mysql
$ /usr/local/mysql/bin/safe_mysqld --user=mysql &

I have not set any passwords, despite the urging of the installations.


Start MySQL daemon (assumes installation succeeded) -- Debian:
=============================================================
$ cd /etc/init.d
$ ln -s /usr/local/mysql/share/mysql/mysql.server mysql.server
$ cd /etc/rc0.d
$ ln -s ../init.d/mysql.server K20mysql.server
$ cd /etc/rc2.d
$ ln -s ../init.d/mysql.server S20mysql.server
...do for 3, 4, 5
ln -s ../init.d/mysql.server K20mysql.server

$ ps auxw | grep mysql  <---to find data dir, user running daemon, etc.



Installation -- Solaris (per INSTALL-SOURCE file in the tarball):
================================================================
2004-05-25
As root:
# groupadd mysql
# useradd -g mysql mysql  <---no home dir created, may want to change
                              /bin/bash to /bin/false

As bheckel:
$ cd ~/src
$ gunzip < mysql-4.0.20.tar.gz | tar -xvf -
Don't think 'export' is needed, just the variable declaration.
$ export LD_LIBRARY_PATH=/opt/sfw/lib
$ CC=gcc CFLAGS="-O3 -fomit-frame-pointer -DHAVE_CURSES_H" \
CXX=gcc \
CXXFLAGS="-O3 -fomit-frame-pointer -felide-constructors \
   -fno-exceptions -fno-rtti -DHAVE_CURSES_H"
$ cd mysql-4.0.20
$ ./configure --prefix=/opt/mysql
$ make

As root:
# make install
# cp support-files/my-medium.cnf /etc/my.cnf
# cd /opt/mysql
# export LD_LIBRARY_PATH=/opt/sfw/lib
Don't think this is needed, just the LD_LIBRARY_PATH above.
# CC=gcc CFLAGS="-O3 -fomit-frame-pointer -DHAVE_CURSES_H" \
CXX=gcc \
CXXFLAGS="-O3 -fomit-frame-pointer -felide-constructors \
   -fno-exceptions -fno-rtti -DHAVE_CURSES_H"
# bin/mysql_install_db --user=mysql
# chown -R root  .
# chown -R mysql var
# chgrp -R mysql .
# bin/mysqld_safe --user=mysql &

Edited /etc/group -- add bheckel to mysql group (to allow /opt/mysql/bin/mysql
to work).

Probably want to # perl -MCPAN -e 'install Bundle::DBD::mysql' as root.

Autorun/stop
------------
# cp -i ~bheckel/src/mysql-4.0.20/support-files/mysql.server /etc/init.d/
See ~/code/misccode/runlevel.solaris.txt

Solaris
# cp /opt/sfw/mysql/share/mysql/mysql.server /etc/init.d/mysql.server
# ln /etc/init.d/mysql.server /etc/rc3.d/S99mysql
# ln /etc/init.d/mysql.server /etc/rc0.d/K00mysql
# ln /etc/init.d/mysql.server /etc/rc1.d/K00mysql
# ln /etc/init.d/mysql.server /etc/rc2.d/K00mysql
# ln /etc/init.d/mysql.server /etc/rcS.d/K00mysql

Edit /etc/my.cnf to uncomment the /tmp/ line.

For Solaris i86 at least, make sure  
LD_LIBRARY_PATH=/opt/sfw/lib
export LD_LIBRARY_PATH
is visible (in /etc/init.d/mysql.server script for the SysV runlevel stuff).



Running the client a.k.a. Monitor: 
=================================
$ /usr/local/mysql/bin/mysql     <---non-MySQL-root implied here (no -u root)
You'll see 'mysql> '
Test it:
SELECT user();
SELECT now();
SELECT version();    <---MySQL version
use test     <---assuming test is one of the default (but empty) db's.
# Which database am I using currently?  Whereami?  Whatthehellisgoingone?
SELECT database();
# or
show databases;
show tables
show index from myfootbl;
show table status;
# Number of records in table:
SELECT COUNT(*) FROM footbl;
quit

Use /c instead of ';' to cancel a query being typed.


Run the Monitor on the 'test' database:
$ /usr/local/mysql/bin/mysql test

# See ~/code/perl/load_mysql_db.pl for another approach.
# Create an instant table in db 'test' -- just copy 'n' paste this raw at the
# 'mysql>' prompt:
  CREATE TABLE shop (
    article INT(4) UNSIGNED ZEROFILL DEFAULT '0000' NOT NULL,
    dealer  CHAR(20)                 DEFAULT ''     NOT NULL,
    price   DOUBLE(16,2)             DEFAULT '0.00' NOT NULL,
    PRIMARY KEY(article, dealer)
  );
  INSERT INTO shop VALUES
  (1,'A',3.45),(1,'B',3.99),(2,'A',10.99),(3,'B',1.45),(3,'C',1.69),
  (3,'D',1.25),(4,'D',19.95);

  DELETE FROM shop WHERE article = 1;

# No commit; required, takes effect immediately.  TODO how does a non-graceful
# exit handle rollback?

# Verify
show tables;
# Elminate
drop table shop;

# Create new db (no longer use db 'test'):
$ /usr/local/mysql/bin/mysql -u root   <---ok to be bqh0 or bheckel here
                                           since we didn't give MySQL's
                                           root a password
create database menagerie;
grant all on menagerie.* to bheckel@localhost;    <---permissions
# Verify:
show grants for bqh0@localhost;
quit

$ /usr/local/mysql/bin/mysql
use menagerie;
show tables;   <---s/b "Empty set (0.00 secs)
# You can use ALTER TABLE later if your assumptions are wrong.
create table pet (name VARCHAR(20), owner VARCHAR(20), species VARCHAR(20), sex CHAR(1), birth DATE, death DATE);
show tables;
describe pet;  <---show field's info

# Create pets.txt using this tab-delimited data (use /N for nulls):
  Fluffy	Harold	cat	f	1993-02-04   
  Claws	Gwen	cat	m	1994-03-17   
  Buffy	Harold	dog	f	1989-05-13   
  Fang	Benny	dog	m	1990-08-27   
  Bowser	Diane	dog	m	1998-08-31  1995-07-29  
  Chirpy	Gwen	bird	f	1998-09-11   
  Whistler	Gwen	bird	1997-12-09   
  Slim	Benny	snake	m	1996-04-29  

# Now exit and restart mysql to allow importing (some kind of security issue).
$ /usr/local/mysql/bin/mysql --local-infile=1
load data local infile "pets.txt" into table pet;
# Then you realize you missed a record:
insert into pet values ('puffball','diane','hamster','f','1999-03-30',null);
select * from pet;
# You notice an error (string comparisons are case sensitive):
update pet set birth = "1989-08-31" WHERE name = "Bowser";
# F' around with single table queries:
SELECT * FROM pet WHERE birth >= "1998-1-1";
SELECT name, birth FROM pet;
SELECT DISTINCT owner FROM pet;
mysql> SELECT * FROM pet WHERE (species = "cat" AND sex = "m")
    -> OR (species = "dog" AND sex = "f");
mysql> SELECT name, birth, CURRENT_DATE,
    -> (YEAR(CURRENT_DATE)-YEAR(birth))
    -> - (RIGHT(CURRENT_DATE,5)<RIGHT(birth,5))
    -> AS age
    -> FROM pet;
mysql> SELECT name, birth, CURRENT_DATE,
    -> (YEAR(CURRENT_DATE)-YEAR(birth))
    -> - (RIGHT(CURRENT_DATE,5)<RIGHT(birth,5))
    -> AS age
    -> FROM pet ORDER BY name;
SELECT * FROM pet WHERE name LIKE "%fy";
SELECT * FROM pet WHERE name LIKE "_____";
# Much better:
SELECT * FROM pet WHERE name REGEXP "^b";
SELECT COUNT(*) FROM pet;
SELECT owner, COUNT(*) FROM pet GROUP BY owner;
mysql> SELECT species, sex, COUNT(*) FROM pet
    -> WHERE sex IS NOT NULL
    -> GROUP BY species, sex;

Create second table:
CREATE TABLE event (name VARCHAR(20), date DATE, type VARCHAR(15), remark VARCHAR(255));
More sample data (to be saved as event.txt):
  Fluffy	1995-05-15	litter	4 kittens, 3 female, 1 male	
  Buffy	1993-06-23	litter	5 puppies, 2 female, 3 male	
  Buffy	1994-06-19	litter	3 puppies, 3 female	
  Chirpy	1999-03-21	vet	needed beak straightened	
  Slim	1997-08-03	vet	broken rib	
  Bowser	1991-10-12	kennel	
  Fang	1991-10-12	kennel	
  Fang	1998-08-28	birthday	Gave him a new chew toy	
  Claws	1998-03-17	birthday	Gave him a new flea collar	
  Whistler	1998-12-09	birthday	First birthday	
LOAD DATA LOCAL INFILE "event.txt" INTO TABLE event;
# F' around with single table queries:
# Find out the ages of each pet when they had their litters.
mysql> SELECT pet.name, (TO_DAYS(date) - TO_DAYS(birth))/365 AS age, remark
    -> FROM pet, event
    -> WHERE pet.name = event.name AND type = "litter";
quit


Using MySQL's Full-text Feature:
===============================
Load:
CREATE TABLE tblname
          (trash INTEGER, trash2 INTEGER, trash3 INTEGER,
            indliteral VARCHAR(50), 
            occliteral VARCHAR(50),
            indnum INTEGER, 
            occnum INTEGER,
            INDEX ioliteral (indliteral,occliteral),
            FULLTEXT (indliteral,occliteral)
          );
Query:
SELECT indliteral, MATCH (indliteral) AGAINST ('boise cascade') AS foo FROM
iandoft WHERE MATCH (indliteral) AGAINST ('boise cascade');


Command line without mysql client interface:
===========================================
Comments are # or --   <---must be a space after 2nd dash!!
Create indocc.sql with this line:
SHOW TABLES;
SELECT * FROM occxls LIMIT 10;

Then run it:
$ mysql -t indocc < indocc.sql


Misc:
====
--                                  required!
ALTER TABLE occxls CHANGE soic soc VARCHAR(20);


If you have no idea how the databases are set up:
================================================
$ mysql
show databases;
use indocc
show tables;
desc occxls;
select * from occxls where literal like "police%";
quit


If you know how the databases are set up:
========================================
Use a textfile named mysql.sql containing the line:
select * from occxls where literal like "police%";
then
$ mysql -t indocc < mysql.sql


Privileges
==========
As root:
$ /usr/local/mysql/bin/mysql
mysql> grant all privileges on *.* to bheckel@localhost;


2004-06-29
For Perl DBI/DBD, had to adjust certain dirs to 755 for execute privilege by
user nobody group other
