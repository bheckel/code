http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/gpg-cs.html

---

Cygwin setup verify - only need download .sig from cygwin.com, not the pubring.asc, we
get it from a 3rd party below:

0 bheckel@sas-01.twa.ateb.com ~/ Wed Nov 23 11:22:00
$ gpg --verify ~/bob/setup-x86_64.exe.sig ~/bob/setup-x86_64.exe
gpg: Signature made Fri 09 Sep 2016 05:20:05 AM EDT using DSA key ID 676041BA
gpg: Can't check signature: No public key

0 bheckel@sas-01.twa.ateb.com ~/ Wed Nov 23 11:22:42
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 676041BA
gpg: requesting key 676041BA from hkp server keys.gnupg.net
gpg: key 676041BA: public key "Cygwin <cygwin@cygwin.com>" imported
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
gpg: Total number processed: 1
gpg:               imported: 1

0 bheckel@sas-01.twa.ateb.com ~/ Wed Nov 23 11:23:33
$ gpg --verify ~/bob/setup-x86_64.exe.sig ~/bob/setup-x86_64.exe
gpg: Signature made Fri 09 Sep 2016 05:20:05 AM EDT using DSA key ID 676041BA
gpg: Good signature from "Cygwin <cygwin@cygwin.com>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 1169 DF9F 2273 4F74 3AA5  9232 A9A2 62FF 6760 41BA

0 bheckel@sas-01.twa.ateb.com ~/ Wed Nov 23 11:25:01
$ gpg --list-keys
/mnt/nfs/home/bheckel/.gnupg/pubring.gpg
----------------------------------------
pub   2048R/E1522312 2016-02-08
uid                  Bob Heckel <bob.heckel@ateb.com>
sub   2048R/A4E5041A 2016-02-08

pub   2048R/5A368B06 2015-07-27
uid                  SMP, LLC <pgp@rxsmp.com>
sub   2048R/EA57203C 2015-07-27

pub   1024D/676041BA 2008-06-13
uid                  Cygwin <cygwin@cygwin.com>
sub   1024g/A1DB7B5C 2008-06-13

0 bheckel@sas-01.twa.ateb.com ~/ Wed Nov 23 15:34:36
$ gpg --fingerprint 676041BA
pub   1024D/676041BA 2008-06-13
      Key fingerprint = 1169 DF9F 2273 4F74 3AA5  9232 A9A2 62FF 6760 41BA
      uid                  Cygwin <cygwin@cygwin.com>
      sub   1024g/A1DB7B5C 2008-06-13


---

$ gpg --gen-key

Take defaults until
Real name: Bob Heckel
Email: sdfsd@taeb.com

gpg: key X1522312 marked as ultimately trusted                                 
public and secret key created and signed.                                      
                                                                               
gpg: checking the trustdb                                                      
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model               
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u          
pub   2048R/X1522312 2016-02-08                                                
      Key fingerprint = X991 EFC3 2E47 0B8B 87EE  5BF0 3E04 7676 X152 2312     
uid                  Bob Heckel <bob.heckel@taeb.com>                          
sub   2048R/X4E5041A 2016-02-08                                                


gpg --output ~/revoke.asc --gen-revoke X1522312

gpg --import SMP.asc


# Set the trust level
$ gpg --edit-key pgp@xrsmp.com                                                        
gpg (GnuPG) 2.0.14; Copyright (C) 2009 Free Software Foundation, Inc.                 
This is free software: you are free to change and redistribute it.                    
There is NO WARRANTY, to the extent permitted by law.                                 
                                                                                      
                                                                                      
pub  2048R/5A368B06  created: 2015-07-27  expires: never       usage: SC              
                     trust: unknown       validity: unknown                           
sub  2048R/EA57203C  created: 2015-07-27  expires: never       usage: E               
[ unknown] (1). SMP, LLC <pgp@rxsmp.com>                                              
                                                                                      
Command> trust                                                                        
pub  2048R/5A368B06  created: 2015-07-27  expires: never       usage: SC              
                     trust: unknown       validity: unknown                           
sub  2048R/EA57203C  created: 2015-07-27  expires: never       usage: E               
[ unknown] (1). SMP, LLC <pgp@rxsmp.com>                                              
                                                                                      
Please decide how far you trust this user to correctly verify other users' keys       
(by looking at passports, checking fingerprints from different sources, etc.)         
                                                                                      
  1 = I don't know or won't say                                                       
  2 = I do NOT trust                                                                  
  3 = I trust marginally                                                              
  4 = I trust fully                                                                   
  5 = I trust ultimately                                                              
  m = back to the main menu                                                           
                                                                                      
Your decision? 5                                                                      
Do you really want to set this key to ultimate trust? (y/N) y                         


$ gpg --list-keys


$ gpg --output Freds_Imm_PHI_08FEB16.csv.gpg --encrypt --recipient pgp@rx.com Freds_Imm_PHI_08FEB16.csv

---

$ gpg --armor --export bob.heckel@ateb.com >~/pub.asc

---

$ gpg -e -r bob.heckel@ateb.com encr.txt && rm encr.txt
$ gpg -d encr.txt.gpg > encr.txt  # encr.txt.gpg stays intact
# or
$ gpg encr.txt.gpg  # encr.txt.gpg stays intact

---

# Display the content of an armored file within the terminal window itself
$ gpg --decrypt filename.txt.gpg
