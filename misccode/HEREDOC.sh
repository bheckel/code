
##############################################################
cat <<EOT
Usage: myfoo
  Recursively delete temp files like a.out *.bak, etc. in given dir 
  (prompts first)'
EOT



##############################################################
if [ "$#" -lt 1 ]; then 
  cat <<EOT2
Usage: $0 mydir
  Recursively delete temp files like a.out *.bak, etc. in given dir 
  (prompts first)'
  E.g. $0 .
EOT2
  exit 1
fi



##############################################################
# Use doublequotes or no quotes to get variable interpolation.
cat <<'HEREDOC'
Try:
$ perl -de 0
DB<1> $x='test string'
DB<2> $x =~ /^(test).*/; $y=$1;       <---must be on same line or lose $1
DB<3> p $y                            <---produces 'test'

or simply:
perl -e '$x=a11332; print "match" if $x =~ /113*/'

HEREDOC
