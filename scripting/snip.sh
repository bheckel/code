
snip() {
  D=$HOME/onedrive/misc/bkup/
  if [ $# -eq 0 ];then
    ls -l 'C:\Users\bheck\AppData\Roaming\SQL Developer\UserSnippets.xml'
    #cp -v 'C:\Documents and Settings\bheck\Application Data\SQL Developer\UserSnippets.xml' $D
    cp -v 'C:\Users\bheck\AppData\Roaming\SQL Developer\UserSnippets.xml' $D
    #cp -v 'C:\Documents and Settings\bheck\Application Data\SQL Developer\CodeTemplate.xml' $D
    cp -v 'C:\Users\bheck\AppData\Roaming\SQL Developer\CodeTemplate.xml' $D
    #cp -v 'C:\Documents and Settings\bheck\Application Data\SQL Developer\CodeTemplate.xml' $HOME/code/database/
    cp -v 'C:\Users\bheck\AppData\Roaming\SQL Developer\CodeTemplate.xml' $HOME/code/database/
    #cp -v "C:\Users\bheck\AppData\Roaming\SQL Developer\system21.4.1.349.1822\o.sqldeveloper\preferences.xml" $D
    #cp -v "C:\Users\bheck\AppData\Roaming\SQL Developer\system21.4.1.349.1822\o.sqldeveloper\product-preferences.xml" $D
  else
    #vim -R 'C:\Documents and Settings\bheck\Application Data\SQL Developer\UserSnippets.xml'
    vim -R 'C:\Users\bheck\AppData\Roaming\SQL Developer\UserSnippets.xml'
  fi
}
