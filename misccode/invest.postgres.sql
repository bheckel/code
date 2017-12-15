-- Create 3 tables - funds, transtypes and transacts

-- Assumes this has been completed prior to running:
-- $ createdb invest

-- To execute this code:
-- $ psql invest < invest.postgres.sql


--------------------------CLEANUP OLD TBLS-----------------------------------
-- If this is not the first run:
drop table funds, transtypes, transacts;


--------------------------FUNDS TBL------------------------------------------
create table funds (fundid smallint PRIMARY KEY, 
                    fundname text NOT NULL, 
                    objective text NOT NULL);
-- Export from Access tab-delimited, strip doublequotes, run nl to number 
-- fundid.
-- E.g.
--     1^IPuritan--Fidelity^IBalanced
--     2^IJanus^IGrowth
copy funds from '/home/bheckel/tmp/testing/FundNames3.dat';


--------------------------TRANSTYPE TBL--------------------------------------
create table transtypes (trantypeid smallint PRIMARY KEY, transtype text NOT 
                         NULL, descript text NOT NULL);
-- E.g.
-- 1^IDividend^INormal reinvested distribution.
-- 2^IOpening Bal^IUsed once per fund.
copy transtypes from '/home/bheckel/tmp/testing/TransactionTypes3.dat';


--------------------------TRANSACTS TBL--------------------------------------
create table transacts (fundid integer REFERENCES funds, 
                        trandt date NOT NULL, 
                        shares numeric NOT NULL, 
                        pricepershare numeric NOT NULL, 
                        transtype smallint REFERENCES transtypes NOT NULL);


-- Test data (sequence automatically added by postgresql)
-- insert into transacts (fundid, trandt, shares, pricepershare, transtype) 
       -- values (2, '10/30/95', 5.3, 3.5, 1);
-- insert into transacts (fundid, trandt, shares, pricepershare, transtype) 
       -- values (1, '10/30/01', 9.3, 9.5, 1);
-- insert into transacts (fundid, trandt, shares, pricepershare, transtype) 
       -- values (1, '10/30/00', 8.8, 9, 2);
-- If satisfied with testing, empty table
---delete from transacts;
-- If needed:
--- drop sequence transacts_transid_seq;
--- drop table transacts;

-- TODO not working (sequence confusion?)...
---copy transacts from '/home/bheckel/tmp/testing/TransactionDetails3.dat';
-- ...so instead wrap each line of TransactionDetails2.dat in 
-- an INSERT INTO then run invest=# \e and :r the lines in
