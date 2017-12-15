#!/bin/sh

# Call this pgm from crontab -e
# 06 * * * * /home/bheckel/bin/cron_rotate.sh >> ~bheckel/cron_log 2>&1

find /home/bheckel/ -name foo.txt -size +10c -exec /home/bheckel/bin/rotate {} \;
