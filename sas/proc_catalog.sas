libname l '.';
proc catalog catalog=l.formats ; CONTENTS; run;
proc catalog cat=l.catalog; CONTENTS;run;
