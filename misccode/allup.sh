#!/bin/bash
##############################################################################
#     Name: allup.sh
#
#  Summary: Transfer system config files to systems where we use bash(1) and
#           all its Unixy goodness.
#
#  Created: Tue 27 Dec 2004 18:30:08 (Bob Heckel)
# Modified: Fri 17 Jul 2009 17:27:56 (Bob Heckel)
##############################################################################

if [ -e $HOME/bin/getpw ];then
  pw=`getpw`
else
  pw=
fi

# TODO allow passing on command line for when Windows freaks out and skips F:
normalUsr=bheckel

if [ "$#" -lt 1 ]; then
  echo 'usage: allup [-][A|b|s|j|a]|u'
  echo '       Archtarball | sverige | anicca | ubuntu'
  echo '       Copies core files to remote boxes'
  exit 1
fi


# TODO parse a combined string like bdsm
case "$1" in
  archtarball|A|-A)
    now=`date +%Y%m%d`  # e.g. 20040922
    echo -n 'starting sverige arch.tar.gz transfers... '
    scp $HOME/tmp/arch.tar.gz $normalUsr@sverige.freeshell.org:arches/arch${now}.tar.gz
    ;;
  sverige|s|-s)
    echo 'starting transfers TO sverige (/arpa/af/b/bheckel)... '
    # Want this file visible via the web
    scp $HOME/.bashrc $normalUsr@sverige.freeshell.org:html/.bashrc
    # Want this file visible via the web
    scp $HOME/.vimrc $normalUsr@sverige.freeshell.org:html/.vimrc
    # Want this file visible via the web
    scp $HOME/.inputrc $normalUsr@sverige.freeshell.org:html/.inputrc
    # Want this file visible via the web
    scp $HOME/code/misccode/oneliners $normalUsr@sverige.freeshell.org:html/oneliners
    # Want this file visible via the web
    scp $HOME/code/misccode/_vimperatorrc $normalUsr@sverige.freeshell.org:html/.vimperatorrc
    # Want this file visible via the web
    scp $HOME/code/misccode/.Xdefaults $normalUsr@sverige.freeshell.org:html/.Xdefaults
    echo 'done'
    echo 'starting transfers FROM sverige (/arpa/af/b/bheckel/html/x)... '
    # Backup
    scp bheckel@sverige.freeshell.org:/arpa/af/b/bheckel/html/x/index.html $HOME/code/html/equanimity.html
    echo 'done'
    echo 'starting code execution on sverige... '
    echo -n 'running dots... '
    # Because freeshell's "cron" is fsck'd
    ssh bheckel@sverige.freeshell.org /arpa/af/b/bheckel/bin/dots
    echo 'done'
    ;;
  rdrtp|r|-r)
    echo 'starting bftp to rdrtp transfers...'
    bftp -p $HOME/.bashrc .bashrc $normalUsr rdrtp $pw &&
    bftp -p $HOME/.vimrc .vimrc $normalUsr rdrtp $pw &&
    bftp -p $HOME/.inputrc .inputrc $normalUsr rdrtp $pw
    ;;
  anicca|a|-a)
    echo "starting scp to anicca transfers (root's home in /)..."
    normalUsr=root
    hstname=anicca
    scp $HOME/.bashrc $normalUsr@$hstname:.bashrc &&
    scp $HOME/.vimrc $normalUsr@$hstname:.vimrc &&
    scp $HOME/.inputrc $normalUsr@$hstname:.inputrc
    scp $HOME/.w3m/keymap $normalUsr@$hstname:.w3m/keymap
    ;;
  ubuntu|u|-U)
    echo "starting scp to Ubuntu transfers (ubuntu's home in /home/ubuntu)..."
    normalUsr=ubuntu
    hstname=ubuntu
    scp $HOME/.bashrc $normalUsr@$hstname:.bashrc &&
    scp $HOME/.vimrc $normalUsr@$hstname:.vimrc &&
    scp $HOME/.inputrc $normalUsr@$hstname:.inputrc
    scp $HOME/code/misccode/keymap.w3m $normalUsr@$hstname:.w3m/keymap
    ;;
  *)
    echo "error: unknown parameter $1"
    ;;
esac
