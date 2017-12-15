data sup_sub;
  length myvar $200;
  myvar = "Pythagorean Theorem: a^{super 2} + b^{super 2} = c^{super 2}";
  output;
  myvar = "This is something that needs a footnote. ^{super 1}";
  output;
  myvar = "Macbeth: 'Is this a dagger I see before me?' ^{dagger}";
  output;
  myvar = "The Caffeine molecule is an alkaloid of the methylxanthine family: " || "C^{sub 8}H^{sub 10}N^{sub 4}O^{sub 2}";
  output;
run;

ods html file='/Drugs/Personnel/bob/junk.html' style=sasweb;
ods rtf file='/Drugs/Personnel/bob/junk.rtf' notoc_data;
ods pdf file='/Drugs/Personnel/bob/junk.pdf';
ods escapechar='^';

proc print data=sup_sub;
  title j=r 'PDF & RTF: Page ^{thispage} of ^{lastpage}';
  title2 j=c 'RTF only: ^{pageof}';
  footnote '^{super 1}If this were a real footnote, there would be something very academic here.';
  footnote2 '^{dagger} Macbeth talked to himself a lot. This quote is from Macbeth: Act 2, Scene 1, Lines 33-39.';
run;
ods _all_ close;
