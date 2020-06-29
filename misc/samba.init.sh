#!/bin/sh

# Created: Wed Jun 30 14:03:23 2004 (Bob Heckel)

samba_start() {
  echo "Starting Samba"
  /opt/samba/sbin/smbd -D
  ###/opt/samba/sbin/nmbd -D
}

samba_stop() {
  echo "Stopping Samba"
  ###killall smbd nmbd
  for p in `pgrep smbd`; do kill -9 $p; done
  ###for q in `pgrep nmbd`; do kill -9 $q; done
}

samba_restart() {
  samba_stop
  sleep 1
  samba_start
}

case "$1" in
  'start')
        samba_start
        ;;
  'stop')
        samba_stop
        ;;
  'restart')
        samba_restart
        ;;
  *)
        echo "Usage: $0 start|stop|restart"
esac

