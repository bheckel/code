

title1 'PowerPoint with Template Layout - Twocontent: Odstext/Graph';
footnote "The ODS Output Destination for PowerPoint";

ods listing close;
ods powerpoint file="~/bob/t.pptx" nogtitle nogfootnot layout=twocontent;

  proc odslist;
    item 'Pre-defined template';
    item 'Side-by-side output';
    item;
      p 'Use:';
      list / style=[bullet=check];
       item 'Tables';
       item 'Graphs';
       item 'Lists';
       item 'Text';
      end;
  run;

  goptions hsize=4.5in vsize=4.5in;
  proc gmap map=maps.us data=maps.us all;
    id state;
    choro statecode/statistic=frequency discrete nolegend;
  run; quit;
ods _all_ close;

