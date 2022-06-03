#!/bin/bash

cat<<HEREDOC
perl -e '\$x=q{"\\\\sashq\root\dept\kmc\rion\prod\src\batch\jobs\Strategic_Accounts_Rpt.sas"}; \$x=~s:\\\\:/:g; \$x=~s|sashq|/sashq|; \$x=~s:"::g; print "\$x";' | clip.exe
HEREDOC
