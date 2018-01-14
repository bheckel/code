#!/bin/bash

# Quick reference to either local files or websites

#  Created: Sun 22 Dec 2013 10:59:11 (Bob Heckel)
# Modified: Tue 22 Jul 2014 11:28:55 (Bob Heckel)

# S/b aliased, not symlinked, as qr

plat=`uname`

if [ ${plat:0:6} = CYGWIN ];then
  BROWSER=cygstart
  PDF=cygstart
else
  BROWSER=sensible-browser
  PDF=acroread
fi

function Html() {
  echo -n 'HTML doc detected, use w3m? [y/N] '; read yn
  if [ "$yn" = 'y' ];then
    echo looking for w3m...
    if [ -e /usr/bin/w3m ];then
      if [ "${1:0:4}" = 'http' ]; then
        F=$1
      else
        F=$HOME/$1
      fi
      echo $F
      w3m ${F}
      return
    else
      echo 'w3m not available'
      return
    fi
  fi

  if [ -e "$BROWSER" ];then
    ###if [ `uname` = CYGWIN_NT-5.1 ];then
    if [ ${plat:0:6} = CYGWIN ];then
      # We're on a Cygwin platform...
      if [ "${1:0:4}" != 'http' ]; then
        F=file:///u:/$1
        echo $F
        cygstart "$BROWSER" -new-tab "$F"
      else
        echo $1
        cygstart "$BROWSER" -new-tab "$1"
      fi
    else
      echo "we're on non-Cygwin platform..."
      echo "no browser ($BROWSER) available"
    fi
  else
    # Probably a Linux box...
    if [ "${1:0:4}" = 'http' ]; then
      echo Opening browser on remote file
      $BROWSER $1
    else
      echo Opening browser on local file
      $BROWSER file:///$HOME/$1
      return
    fi
  fi
}

if [ "$#" = 0 ]; then
  cat <<EOT
qr android
qr apache
qr asp
qr awk
qr bash
qr bash2
qr bat
qr bat2
qr c
qr css
qr css2
qr cvs
qr dom
qr git
qr git2
qr git3
qr graph sasgraph
qr html
qr javascript
qr javascript2
qr javascript3
qr jquery
qr markdown
qr mutt
qr oracle
qr perl
qr perl2
qr perl3
qr plsql
qr powershell
qr R
qr regex
qr regex2
qr rgb
qr ruby
qr sas
qr sas2
qr sed
qr sql
qr sql2
qr sqlplus
qr vba
qr vim
qr vimperator
qr w3
qr xslt

also see:
one
loc
rme -l
EOT
  exit 1
fi

if [ "$1" = 'sas' ]; then
  Html file:///C:/Bookshelf_SAS/main.htm
elif [ "$1" = 'sas2' ]; then
  ###$PDF $HOME/code/sas/quickref_SASFuncsFormatInformat.pdf
  Html http://support.sas.com/documentation/cdl/en/syntaxidx/65757/HTML/default/index.htm#/documentation/cdl/en/syntaxidx/65757/HTML/default/shared/start.htm
elif [ "$1" = 'html' ]; then
   Html http://www.w3schools.com/html5/html5_reference.asp
elif [ "$1" = 'sed' ]; then
  vim $HOME/code/misccode/sed_quickref.txt
elif [ "$1" = 'sql' ]; then
  Html $HOME/code/misccode/quickref_sql.htm
elif [ "$1" = 'sql2' ]; then
  Html $HOME/code/misccode/sql_quickref.htm
elif [ "$1" = 'regex' ]; then
  $PDF $HOME/code/perl/plregexquickref.pdf
elif [ "$1" = 'regex2' ]; then
  Html http://regexpal.com
elif [ "$1" = 'perl' ]; then
  Html code/perl/RexSwainPerl5RefGuide.html
elif [ "$1" = 'perl2' ]; then
  vim $HOME/code/perl/bluecamel_examples
elif [ "$1" = 'perl3' ]; then
  Html http://www.java2s.com/Code/Perl/CatalogPerl.htm
elif [ "$1" = 'asp' ]; then
  Html code/vb/quickref_asp.html
elif [ "$1" = 'css' ]; then
  Html https://developer.mozilla.org/en-US/docs/Web/CSS/Reference
elif [ "$1" = 'css2' ]; then
  ###Html $HOME/code/html CSSQuickReference.htm
  Html http://www.w3schools.com/css/css_examples.asp
elif [ "$1" = 'c' ]; then
  Html code/c/C++quick-reference.htm
elif [ "$1" = 'javascript' ]; then
  Html code/html/javascript_ref.html
elif [ "$1" = 'javascript2' ]; then
  Html http://www.javascriptkit.com/javatutors/
elif [ "$1" = 'javascript3' ]; then
  Html http://learn.jquery.com/javascript-101/
elif [ "$1" = 'jquery' ]; then
  Html http://api.jquery.com/
elif [ "$1" = 'awk' ]; then
  vim $HOME/code/misccode/awk_quickref.txt
elif [ "$1" = 'bash' ]; then
  rme bash
elif [ "$1" = 'bash2' ]; then  # more detail
  ###cygstart "$PROGRAMFILES/mozilla firefox/firefox" bashref2_05.html
  ###Html $HOME/code/misccode bashref2_05.html
  Html code/misccode/bashref2_05.html
elif [ "$1" = 'mutt' ]; then
  vim $HOME/code/misccode/mutt_search_quickref.txt
elif [ "$1" = 'cvs' ]; then
  vim $HOME/code/misccode/cvs_quickref.txt
elif [ "$1" = 'oracle' ]; then
  $PDF $HOME/code/misccode/Book.oracle8.pdf
elif [ "$1" = 'sqlplus' ]; then
  Html code/misccode/quickref_sqlplus.htm
elif [ "$1" = 'plsql' ]; then
  Html code/misccode/quickref_plsql.html
elif [ "$1" = 'ruby' ]; then
  Html code/misccode/quickref_ruby.html
elif [ "$1" = 'vba' ]; then
  Html code/vb/quickref_vba.htm
elif [ "$1" = 'vim' ]; then
  vim -c ':h quickref'
elif [ "$1" = 'xslt' ]; then
  ###Html $HOME/code/html quick_ref_XSLT.html
  ###Html file:///u:/code/html/quick_ref_XSLT.html
  # TODO local html links to web content, firewall fail, s/b cygstart??
  ###w3m $HOME/code/html/quick_ref_XSLT.html
  Html "http://www.w3schools.com/xsl/xsl_w3celementref.asp"
elif [ "$1" = 'graph' ]; then
  Html "http://support.sas.com/sassamples/graphgallery/"
elif [ "$1" = 'sasgraph' ]; then
  Html "http://support.sas.com/sassamples/graphgallery/"
elif [ "$1" = 'powershell' ]; then
  $PDF $HOME/code/misccode/powershell_reference.pdf
elif [ "$1" = 'powershell2' ]; then
  antiword $HOME/code/misccode/powershell_reference.doc | less
elif [ "$1" = 'bat' ]; then
  Html "http://technet.microsoft.com/en-us/library/cc772390(WS.10).aspx"
elif [ "$1" = 'w3' ]; then
  Html http://www.w3schools.com/sitemap/sitemap_references.asp
elif [ "$1" = 'bat2' ]; then
  vim $HOME/code/misccode/batchbook.txt
elif [ "$1" = 'vimperator' ]; then
  echo -n Use  :h index  inside Firefox.  Start Firefox [y/n]?
  ###cygstart firefox.exe -vimperator "+c ':h index'"
  read yesno
  if [ $yesno = 'y' ]; then 
    cygstart firefox.exe
  fi
elif [ "$1" = 'apache' ]; then
  $PDF $HOME/code/misccode/apache-refcard-letter.pdf
elif [ "$1" = 'dom' ]; then
  Html http://www.w3schools.com/jsref/default.asp
elif [ "$1" = 'rgb' ]; then
  cygstart $HOME/code/html/color_RGB_visualizer.html
elif [ "$1" = 'R' ]; then
  $PDF $HOME/code/sas/RQuickReference.pdf
elif [ "$1" = 'R2' ]; then
  $PDF $HOME/code/misccode/Short-refcard.R.pdf
elif [ "$1" = 'git' ]; then
  ###Html -s $HOME/code/misccode/GitQuickReference.htm
  Html code/misccode/GitQuickReference.htm
elif [ "$1" = 'git2' ]; then
  $PDF $HOME/code/misccode/git_cheat_sheet.pdf
elif [ "$1" = 'git3' ]; then
  Html http://help.github.com/git-cheat-sheets
elif [ "$1" = 'git4' ]; then
  Html http://gitref.org
elif [ "$1" = 'android' ]; then
  Html http://developer.android.com/guide/faq/commontasks.html
elif [ "$1" = 'markdown' ]; then
  Html https://guides.github.com/features/mastering-markdown/
else
  echo "error - quickref not implemented for $1"
  exit 1
fi
