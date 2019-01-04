Port 110 is POP3 mail.  

E.g. telnet mail.mindspring.com 110

user bheckel

pass foopass

list      <---show all and sizes of mail

top 42 5  <---show top 5 lines of message #42

retr 42   <---prints email to screen

reset     <---undelete what you've deleted by hand

quit      <---if you get logged off, the deletes are lost
