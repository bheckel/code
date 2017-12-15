
 /* Carriage return / linefeed garbage removal */
data t; set l.eformsds;
  AtypicalOccurrenceQuickSumma1158=compress(AtypicalOccurrenceQuickSumma1158, byte(13));
  AtypicalOccurrenceQuickSumma1158=compress(AtypicalOccurrenceQuickSumma1158, byte(10));
  comments1159=compress(comments1159, byte(13));
  comments1159=compress(comments1159, byte(10));
run;
