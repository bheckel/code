#!/bin/ruby

require 'dbi'

# TODO not working
DBI.connect('DBI:ORACLE:usdev388', 'pks', 'dev123dba') do | dbh |
  sth = dbh.prepare("SELECT * FROM samp WHERE samp_id=187242;")
  sth.execute
  while row = sth.fetch do
    puts row
  end
end
