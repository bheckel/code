Ctr-Alt-Enter exit fullscreen

---

#!/bin/bash

pw=mypw

myip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

printf "y\nbob.heckel\n${pw}\npush\n" | /opt/cisco/anyconnect/bin/vpn -s connect portal.ateb.com

sleep 5

echo '/opt/cisco/anyconnect/bin/vpn disconnect'

xfreerdp /v:twavws-05-bheckel.ateb.com /u:bob.heckel /f /bitmap-cache /smart-sizing /smooth /heartbeat /sound:sys:pulse /sound:latency:400 /p:${pw} /bpp:16 /network:modem /compression /auto-reconnect -themes -wallpaper +clipboard -u bheckel $myip

---

sudo apt-get install libfreerdp-plugins-standard

