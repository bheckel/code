
f <-function() {
  lims <-read.table('limslogins.parsed.txt', header=F, sep=',')
  ts <-strptime(lims$V2, format='%d-%b-%Y')
  lims2 <-data.frame(lims, ts)
  d <-lims2$ts
  d.freq <-table(d)
  barplot(d.freq, sub='ChemLMS Logins', ylab='Login Count', col='#FFA500', border='NA')
}

f()

# > source('~/code/misccode/function.R')
