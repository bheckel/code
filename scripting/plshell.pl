#!/usr/bin/perl
##############################################################################
#     Name: plshell
#
#  Summary: Perl shell has most features of perl -de 0
#           Can't do command history but can use mouse to cut'n'paste
#           TODO Ctr-D to exit.
#
#  Adapted: Fri, 19 Nov 1999 13:19:58 (from Univ of Missouri)
# Modified: Tue, 08 Aug 2000 13:11:47 (Bob Heckel)
##############################################################################

print "Perl Shell v1.3\n",
      "   p = print\n",
      "quit = exit\n",
      " bye = exit\n",
      "Return value of eval() is stored between parens\n";

# Init @result to give user indication of what parens are used for.
@result = ('retval');
$history = undef;

for (;;) {
  ###$history ? prompt($history) : prompt();
  prompt();
  chomp($input = <STDIN>);
  ###$history = $input;
  ###$input =~ /\033/ ? $input=$history : $input;
  ###$input =~ /z/ ? prompt($history) && next : $input;
  # Save input for history.
  ###$input =~ /z/ ? $history=$input : $input;
  $input =~ /quit|bye/ ? $input = 'exit' : $input;
  # Minimize keystrokes.
  $input =~ /^p (.*)/ ? $input = "print $1" : $input;

  $? = $@ = $! = undef;
  @result = eval $input;
  if ( $? ) { print "\nStatusFromLastAction is:\n", $? };
  if ( $@ ) { print "\nErrMsgFromLastEvalOrDo is:\n", $@, };
  if ( $! ) { print "\nCurrValOfErrNo is:\n", $!+0,': ', $!, "\n" };
  print "\n";     # Force good output to its own line.
}

sub prompt {
  my $x = $_[0];

  # Avoid 0 on commandline.
  $x ? $x : undef $x;
  print '(', join(', ', @result), ") pl\$ $x";
}
