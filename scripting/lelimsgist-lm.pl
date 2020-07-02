#!/usr/bin/perl -w
##############################################################################
#     Name: lelimsgist-lm.pl
#
#  Summary: Convert a file into SQL statements to insert data into Oracle.  
#           When conversion is too complicated to just use Vim.
#
#           Paste in LELimsGist-LM.log below _DATA_
#           ./lelimsgist-lm.pl | putclip
#           Open ushpbc in SQL*Plus and paste
#
#  Created: Fri 07 Jul 2006 10:45:46 (Bob Heckel)
##############################################################################
use strict;
use warnings;


my ($mon, $day, $year, $today);

my %months = (
   "0"  => "JAN",
   "1"  => "FEB",
   "2"  => "MAR",
   "3"  => "APR",
   "4"  => "MAY",
   "5"  => "JUN",
   "6"  => "JUL",
   "7"  => "AUG",
   "8"  => "SEP",
   "9"  => "OCT",
   "10" => "NOV",
   "11" => "DEC",
);

($mon, $day, $year) = (localtime())[4,3,5];
# Keep Oracle happy by using its single quoted date format.
$today = "'" . $day . '-' . $months{$mon} . '-' . eval($year+1900) . "'";

while ( <DATA> ){
  next unless /^TP/;
  # Wrap SQL around the material and batch numbers
  $_ =~ s/TP- (\S+)\s+(\S+)/INSERT INTO links_material \(matl_desc,matl_mfg_dt,matl_exp_dt,matl_nbr,batch_nbr,matl_typ\) VALUES \('Waiting for update from SAP',$today,'01-JAN-1960','$1','$2','MANL'\)\;/;
  next if ! defined $2;
  print;
}


__DATA__
LM- Material #          Batch#
TP-                                 
TP- 4117344             6ZM1031     
TP- 4117344             6ZM1032     
TP- 4117344             6ZM1033     
TP- 4137019             6ZM0849     
TP- 4137019             6ZM0850     
TP- 4137019             6ZM0851     
TP- 4147901             6ZM2266     
