EXPLAIN select * from foo

https://explain.depesz.com

---

Sample .pgpass:

ajsperdb1.dep.taeb.com:5432:TAEBMART:bheckel:mypass
bd-02.twa.taeb.com:5432:taeb:bheckel:mypass

---

select current_query from pg_stat_activity where usename='bheckel'
select * from pg_stat_activity where usename='bheckel'
select pg_cancel_backend(procpid);   --kill query

TRUNCATE bigtable, fattable;

TAEBMART=> select * from analytics.haelthplanpatients where lastname like 'PAT%' limit 3;

---

-- Password prompted:
psql -h bd5.dep.atbe.com -U bheckel -d reporting
psql -h jasperdb1.dep.atbe.com ATBEMART

\l  list dbs
\dn list schemas
\c  show db you're connected to and who you are
\d  describe list tables in db
\d  [schema.table] describe list fields in table in a specific schema (or \d analytics. [TAB] to see all)
\e  edit query in $EDITOR
\x  horizontal display, one field per line
\s history
\o saveoutput.txt  (\o to quit)  then run query
\? help on psql commands
\h help on SQL commands


\pset pager  (toggle pager)

To save formatted output to file:
Instead of ';' at end of query use '\g foo.out'

To save output to csv file:
psql> \f ','
psql> \a
psql> \o '/tmp/output.csv'
psql> SELECT * from users;
psql> \q

-- Write a pipe-delimited textfile
psql> \f '|' \a \t \o /Drugs/HealthPlans/U/Medicare/Tasks/20160815/Output/UHC_del_20160815_deceased.csv
psql> SELECT * from users;
psql> \q

---

2005-05-22 some of this is obsolete

---------------------

Is PostgreSQL running?
ps ax | grep postmaster

---------------------

2002-12-12

Normal startup of backend server on Cygwin:

(May want to install as Windows Service)
$ ipc-daemon&
$ pg_ctl -D /usr/share/postgresql/data start
 or for a sandbox database
$ pg_ctl -D /home/bheckel/pg/data start

 or better (avoids STDOUT/STDERR mess on your terminals)
$ postmaster -D /usr/share/postgresql/data >| \
/usr/share/postgresql/data/pg.log 2>&1 &
 or 
$ postmaster -D ~/pg/data >| ~/pg/data/pg.log 2>&1 &

$ pg_ctl -D /usr/share/postgresql/data status
or
$ pg_ctl -D ~/pg/data status

$ pg_ctl -D /usr/share/postgresql/data stop
or
$ pg_ctl -D ~/pg/data stop


I'm not using the NT Service method b/c of the trouble I've had with FAT vs
NTFS and I don't need it to always be running.  

---------------------

2002-12-09 Installation on cdc

The following is the basic Cygwin PostgreSQL installation procedure after
unpacking the tarball (or in parsifal's case, no tarball was needed):

1. Start the cygipc ipc-daemon (assumes cygipc has been installed):

    $ ipc-daemon &

2. Initialize a new PostgreSQL database cluster:

    $ initdb -D /usr/share/postgresql/data

3. Start the PostgreSQL postmaster:

    $ postmaster -D /usr/share/postgresql/data >| ~/tmp/pg.log 2>&1 &

4. Connect to PostgreSQL with the psql client:

    $ psql template1


$ psql -l                   <---list available databases on local machine
$ psql template1            <---template1 is a default db from the install
                                but appears to be empty

template1=# \h              <---SQL command help
template1=# \?              <---slash command help

template1=# \l              <---list databases
template1=# \d tblname      <---describe / list sequence, table, view or index
template1=# \dt             <---list all tables
template1=# \dv             <---list all views
template1=# \e              <---to use vi to edit previous query
template1=# \h alter table  <---specific help
template1=# CREATE DATABASE foo;  <---have to leave template1 to use it
# or do a  \q  then
$ createdb foo && psql foo
foo=# CREATE TABLE shipments (customer_id integer, isbn text);
foo=# INSERT INTO shipments (customer_id, isbn) VALUES (42, 'foo');
-- or populate a db with a tab delimited textfile that contains those 2 items:
foo=# COPY shipments from '/home/bqh0/tabdelimited_data.txt';


5.  Shutdown postmaster:
    
    $ pg_ctl -D /usr/share/postgresql/data stop

---------------------

PL/pgSQL installation on cdc:

testbobh=# CREATE FUNCTION plpgsql_call_handler ()
testbobh-# RETURNS OPAQUE
testbobh-# as '/usr/lib/postgresql/plpgsql.dll'
testbobh-# language 'c';

---------------------

2003-03-23 Perl DBD driver installation (parsifal):

Assumes postgresql version 7.2.1 (parsifal) has been installed.  It doesn't
need to be running until specifically mentioned below.

Assumes DBI-1.14.tar.gz has been installed (newer versions of DBI/DBI Bundle
fail on parsifal Cygwin for some reason) so have to use the lower 1.14
version.  Due to this, must use version 1.01 Pg DBD since the newer Pg DBD
requires a higher DBI version.  But I don't seem to be missing anything by
using the lower versions.

$ tar xvfz DBD-Pg-1.01.tar.gz
$ export POSTGRES_LIB=/usr/lib/postgresql
$ export POSTGRES_INCLUDE=/usr/include/postgresql
$ perl Makefile.PL
$ make 
$ ipc-daemon&
$ /bin/pg_ctl -D /usr/share/postgresql/data start
$ make test
$ make install
Test via:
$ ~/code/perl/dbi_dbd_postgresql_helloworld.pl

Perl doesn't care where (i.e. -D /foo) the database's data is located.

---------------------

Backup (single db, not a cluster):
With production db invest running:
$ pg_dump invest > investdump.sql

Restore the whole invest db to the sandbox:
Shutdown production db:
$ pg_ctl -D /usr/share/postgresql/data stop
$ postmaster -D ~/pg/data >| ~/pg/data/pg.log 2>&1 &
With production db invest running:
$ createdb invest
psql invest < investdump.sql
