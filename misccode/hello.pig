-- git clone git://github.com/alanfgates/programmingpig.git

-- [maria_dev@sandbox ch2]$ head ../../data/NYSE_dividends
-- NYSE    CPO     2009-12-30      0.14
-- NYSE    CPO     2009-09-28      0.14
-- NYSE    CPO     2009-06-26      0.14
-- NYSE    CPO     2009-03-27      0.14
-- NYSE    CPO     2009-01-06      0.14
-- NYSE    CCS     2009-10-28      0.414
-- NYSE    CCS     2009-07-29      0.414
-- NYSE    CCS     2009-04-29      0.414
-- NYSE    CCS     2009-01-28      0.414
-- NYSE    CIF     2009-12-09      0.029

-- pig -x local average_dividend.pig
-- pig -dryrun average_dividend.pig
-- pig -x tez_local average_dividend.pig


dividends = load '../../data/NYSE_dividends' as (exchange, symbol, date, dividend);
grouped   = group dividends by symbol;
avg       = foreach grouped generate group, AVG(dividends.dividend);
store avg into 'average_dividend';

describe avg;

-- head average_dividend/part-r-00000
-- average_dividend/part-v001-o000-r-00000
-- CA      0.04
-- CB      0.35
-- CE      0.04
-- CF      0.1
-- CI      0.04

