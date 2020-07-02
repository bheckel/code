#!/usr/bin/perl -w
##############################################################################
#    Name: csv.pl
#
# Summary: Demo of regex that separates CSV comma separated value fields.
#          From Mastering Regular Expressions. Jeffrey Friedl.
#
# Adapted: Sat, 29 Jan 2000 23:07:24 (Bob Heckel)
##############################################################################

@fields = ();
# Normally this would come from a standalone file.
$text = '"one","two","",3,4,,5';


while ($text =~ m/         # A field is one of three things.
                           # 1) DOUBLEQUOTED STRING
 "([^"\\]*(\\.[^"\\]*)*)"  #    - Standard doublequoted string (capture to $1).
 ,?                        #    - Eat any trailing comma.
           |               # Or
                           # 2) NORMAL FIELD
 ([^,]+)                   #    - Capture (to $3) up to next comma. 
 ,?                        #    - And including comma if there is one.
           |               # Or
                           # 3) EMPTY FIELD
 ,                         #    - Just match the comma.
 /gx
) {
  push(@fields, defined($1) ? $1 : $3);
}

print "@fields\n";
print @fields;

