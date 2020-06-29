
@echo on

set npw=mypw

pause
net use X: \\sawn321\e$ /persistent:no /user:wmservice\rsh8680n %npw%

pause
net use Y: \\sawn557\e$ /persistent:no /user:wmservice\rsh8680n %npw%

pause
net use Z: \\sawn323\e$ /persistent:no /user:wmservice\rsh8680n %npw%

pause

---

@echo on

pause 
net use \\sawn321\D$ /delete
net use \\sawn321\E$ /delete
net use X: /delete /yes

pause
net use \\sawn557\d$ /delete
net use \\sawn557\E$ /delete
net use Y: /delete /yes

pause
net use \\sawn323\D$ /delete
net use \\sawn323\E$ /delete
net use Z: /delete /yes

pause
