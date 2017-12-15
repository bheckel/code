#########The Form Handler##########
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
       @pairs = split(/&/, $buffer);
       foreach $pair (@pairs)
       {
           ($name, $value) = split(/=/, $pair);

           # Un-Webify plus signs and %-encoding
           $value =~ tr/+/ /;
           $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

           # Stop people from using subshells to execute commands
           # Not a big deal when using sendmail, but very important
           # when using UCB mail (aka mailx).
           $value =~ s/~!/ ~!/g;

           $FORM{$name} = $value;
       }
#########End Form Handler#########
