#!/bin/sh

gco() {
  if [ -z "$1" ];then
    git checkout develop;
  else
    git checkout feature/RION-${1};
  fi
}

---

[ $# -lt 2 ] && echo "Usage: $0 sum 177468AD [/home/bheckel/foo]" && exit 1

# Take path from command line
fqpath=$3
# If there is no path from command line, use this path as default:
test "x$3" = "x" && fqpath=/home/bheckel/projects/harnessSitewide

cp -i $fqpath/lelims${1}res01a${2}.sas7bdat $fqpath/lelims${1}res01a.sas7bdat
