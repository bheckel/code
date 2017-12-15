#!/bin/sh
# For security on daeb.  Run as root.
/etc/init.d/lpd stop
/etc/init.d/exim stop
/etc/init.d/portmap stop
