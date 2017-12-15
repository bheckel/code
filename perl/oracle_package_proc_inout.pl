#!/usr/bin/perl -w

# Spec:
# CREATE OR REPLACE PACKAGE department
# AS
#    TYPE cursor_type IS REF CURSOR;
# 
#    PROCEDURE get_emps (i_deptno IN NUMBER, o_result_set OUT cursor_type);
# END;
# /
#
#
# Body:
# CREATE OR REPLACE PACKAGE BODY department
# AS
#    PROCEDURE get_emps (i_deptno IN NUMBER, o_result_set OUT cursor_type)
#    AS
#    BEGIN
#       OPEN o_result_set FOR
#          SELECT empno, ename
#            FROM emp
#           WHERE deptno = i_deptno;
#    END;
# END;
# /

use DBI;
use DBD::Oracle qw(:ora_types);

my $dbh = DBI->connect('dbi:Oracle:usprd188','crcarch','temppw') or 
                                                           die $DBI::errstr;

my $emp_num = 30;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      CRCARCH.DEPARTMENT.get_emps( :emp_num, :sth2 );
  END;
} );

$sth->bind_param(":emp_num", $emp_num);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

# The execute will automagically update the value of $sth2
$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;
