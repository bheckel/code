#!/bin/sh

# This code must be separate from install.sh because 0_ and excel_ are hand
# edited after install to adapt to prod environment.

PTHPRDCODE=//rtpsawnv0312/pucc/VALTREX_Caplets/CODE

# Must be same as datapost_check.sh
FILES=$(find $PTHPRDCODE -type f -not -name baseline.md5 -a -not -name '*.log' -a -not -name '*.lst' -a -not -name '*.txt')
md5sum $FILES >| $PTHPRDCODE/util/baseline.md5

