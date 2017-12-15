options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_positional.sas
  *
  *  Summary: Demo of using file contents to determine where to position the
  *           cursor.  S/b symlinked as ipaddress.sas
  *
  *  Adapted: Thu 09 Oct 2003 10:21:50 (Bob Heckel -- Phil Mason Tip72)
  *---------------------------------------------------------------------------
  */
options source;

 /* W2K specific. */
filename cmd pipe 'ipconfig' ;

 /*
  
  Windows 2000 IP Configuration
  
  Ethernet adapter Local Area Connection:
  
    Connection-specific DNS Suffix  . : NCHS.CDC.GOV
    IP Address. . . . . . . . . . . . : 158.111.250.170
    Subnet Mask . . . . . . . . . . . : 255.255.255.0
    Default Gateway . . . . . . . . . : 158.111.250.1
  */
data _NULL_ ;
  infile cmd dlm='.: ' ;
  list;
  input @'IP Address' n1 n2 n3 n4 3. ;
  put _ALL_;
  ip_address=compress(put(n1,3.)||'.' ||put(n2,3.)||'.'
                      ||put(n3,3.)||'.' ||put(n4,3.));
  call symput('ip',ip_address) ;
run ;
%put My IP address is &ip ;
