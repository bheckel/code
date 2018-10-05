> R.home()
[1] "C:/PROGRA~1/R/R-33~1.1"

Error: could not find function "libpaths"
> .libPaths()
[1] "C:/Program Files/R/R-3.3.1/library"

---

R for Data Science book 2017:
----------------------------

apropos('myregex')

library(stringi)
apropos('str_|stri_')
?str_sub

?`if`

package?tibble  # man
vignette('tibble')  # info


> getwd()
# [1] "C:/Users/bob.heckel/Documents"


install.packages('tidyverse')
library(tidyverse)
setwd("~/projects")
?mpg
# reference http://www.cookbook-r.com/Graphs
ggplot(data=mpg) + geom_point(mapping=aes(x=displ,y=hwy,color=class))
ggplot(data=mpg) + geom_point(mapping=aes(x=displ,y=hwy, color=class)) + facet_wrap(~ class,nrow=2)
ggplot(data=mpg) + geom_smooth(mapping=aes(x=displ,y=hwy)) + geom_point(mapping=aes(x=displ,y=hwy))


# Categorical, e.g. cut quality variation:
# Y-axis "count" isn't in the ds, auto calculated!
ggplot(data=diamonds)+geom_bar(mapping=aes(x=cut,fill=cut))
# Continuous variation:
ggplot(data=diamonds)+geom_histogram(mapping=aes(x=carat,fill=carat),binwidth=0.5)
ggplot(data=diamonds)+geom_freqpoly(mapping=aes(x=carat,color=cut),binwidth = 0.5)
# zoom in to see outliers:
ggplot(data=diamonds)+geom_histogram(mapping=aes(x=carat,fill=carat),binwidth = 0.01) + coord_cartesian(ylim=c(0,50))
# or hide outliers:
diamonds2 <- diamonds %>% mutate(y=ifelse(y<3 | y>20, NA, y))

ggplot(data=diamonds2)+geom_boxplot(mapping=aes(x=cut,y=price))


install.packages('nycflights13')
library(nycflights13)
View(flights)  # in RStudio GUI
library(dplyr)
x <- filter(flights, month %in% c(1,2))
select(flights, dest, dep_time, everything())
summarize(flights, delay=mean(dep_delay,na.rm=TRUE))

gbd <- group_by(flights,year,month,day)
summarize(gbd, delay=mean(dep_delay,na.rm=TRUE))

gbd <- group_by(flights,year)
summarize(gbd, delay=mean(dep_delay,na.rm=TRUE),count=n())

# think "then" when see %>%
delays <- flights +
  %>% group_by(dest) +
  %>% summarize(count=n(),dist=mean(distance,na.rm=TRUE),delay=mean(arr_delay,na.rm=TRUE)) +
  %>% filter(count>20,dest!='HNL')

not_canc <- flights %>% filter(!is.na(dep_delay),!is.na(arr_delay))
delays <- not_canc %>% group_by(tailnum) %>% summarize(delay=mean(arr_delay),n=n())
ggplot(data=delays,mapping=aes(x=delay)) + geom_freqpoly(binwidth=10)
ggplot(data=delays,mapping=aes(x=n,y=delay)) + geom_point(alpha=1/10)  # 1/5 opacity is less "blurry"
# 3 hour delays are misleading, we want to use larger sample sizes to decrease variation:
lessvariation <- delays %>% filter(n>25)
ggplot(data=lessvariation,mapping=aes(x=n,y=delay)) + geom_point()


install.packages('Lahman')
library("tibble", lib.loc="~/R/win-library/3.3")
library(Lahman)
library(dplyr)
batting <- as_tibble(Lahman::Batting)
master <- select(tbl_df(Lahman::Master), playerID, birthYear, birthMonth, nameLast, nameFirst, bats)
batting2 <- batting %>% +
  left_join(master) %>% +
  mutate(age = yearID - birthYear - ifelse(birthMonth < 10, 0, 1)) %>% +
  select(-(birthYear:birthMonth))
select(batting2, nameFirst, nameLast) %>% filter(nameFirst=='Mookie') %>% arrange(desc(nameLast))
summarize(batting2,sd(G),min(G),max(G),median(G))
batting %>% count(G) %>% arrange(desc(G))


mytbl <- tribble(
  ~x, ~y, ~z,
  "a", 2, 3.6,
  "b", 1, 8.5
)

# print(mytbl, n=1)

df <- tibble(
  x=runif(5),
  y=rnorm(5)
)

df$x

# Convert to real df
class(as.data.frame(df))

x <- read_csv("# skip me
  x,y,z
  1,2,3",
  comment='#')

library(hms)
d <- parse_date('04/17/17', '%m/%d/%y')

# challenge.csv is a hard to auto-detect correct data types, library provided example
challenge <- read_csv(readr_example('challenge.csv'), col_types = cols(x=col_double(), y=col_date()))
# the guessing stops at obs 1000, we can extend it
challenge <- read_csv(readr_example('challenge.csv'), guess_max = 1001)
# or just use all character
challenge <- read_csv(readr_example('challenge.csv'), col_types = cols(.default = col_character()))


library(haven)
read_sas('t:/personnel/bob/tmm_targeted_list_refresh.sas7bdat')


stocks <- tibble(
  year = c(2015, 2015, 2016),
  qtr  = c(1, 2, 1),
  ret  = c(1.88, NA, 0.35)
)
locf <- stocks %>% fill(ret)

# Rename a variable
who2 <- who1 %>%
  mutate(key=stringr::str_replace(key, 'newrel', 'new_rel'))

# Drop a variable (opposite of keep)
who3 <- who2 %>% select(-iso3)

splitup <- who2 %>% separate(sexage, c('sex','age'), sep=1)

# Tidy - One variable per column. One observation per row. Each type of observational unit forms a table.
who2 <- who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm=TRUE) %>%
  mutate(code=stringr::str_replace(code,'newrel','new_rel')) %>%
  separate(code, c('new','var', 'sexage')) %>%
  select(-new,-iso2,-iso3) %>%
  separate(sexage, c('sex','age'), sep=1)


# Are tailnums unique - HAVING in SQL
library(nycflights13)
emptydf <- planes %>% count(tailnum) %>% filter(n>1)

# Find airline name
f2 <- flights %>% 
  select(-origin,-dest,-sched_arr_time) %>%
  left_join(airlines, by='carrier')


library(stringr)
head(sentences)


library(lubridate)

myage <- today() - ymd(19651030)
as.duration(myage)

---

# Matrix algebra
m1 <- matrix(c(0, 2, 1, 0), nrow = 2, ncol = 2, byrow = TRUE)
m2 <- matrix(c(0, 3, 1, 0), nrow = 2, ncol = 2, byrow = TRUE)
m1
m2
m1+m2
m1*m2

---

03-Oct-12 yoniso install

1480  2012-10-03 18:15:59 sudo vi  /etc/apt/sources.list
deb http://lib.stat.cmu.edu/R/CRAN//bin/linux/ubuntu oneiric/
1482  2012-10-03 18:19:09 sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
1483  2012-10-03 18:19:27 sudo apt-get update
1484  2012-10-03 18:20:26 sudo apt-get install r-base

install.packages("psych")  # need internet
library(psych)
# now describe() is available
describe(impact)

# If stuck behind firewall and can't use normal CRAN installation:
# Cygwin requires Xinit, gfortran, libiconv to be able to install packages from source:
# Download tgz by hand http://cran.r-project.org/web/packages/available_packages_by_name.html
$ R CMD INSTALL Hmisc_3.9-3.tar.gz 

---

http://watson.nci.nih.gov/cran_mirror/src/contrib/

---

$ R  # Rterm or Rgui on Windows sometimes
# quit:
q()
# help:
?lm
??lm  # fuzzy verbose
help(lm)
# html help:
options(browser="/cygdrive/c/Program\\ Files/Mozilla\\ Firefox/firefox.exe")
help.start()
# What are a function's arguments parms:
args(lm)
# fuzzy terse partial word search
apropos("nova")  # either quote style works
example('ls')
history()
??getcd  # guess the command to list pwd, R gives suggestion getcwd()
getcwd()
setwd("c:/temp")
# List installed & loaded packages:
search()
# List installed packages:
installed.packages()
# Load a builtin package:
library(MASS)
detach(package:MASS)  # find fully qual name via search()
ls()  # print R objects
ls(pattern = 'mysearchregex')  # wildcarding
dir()  # filesystem files
# Like OS' ls
list.files()
# Describe builtin sample example datasets:
data()
# Make copy:
mydp2<-mydp
# Delete cleanup all objects (only works on whole objects, not variables etc)
rm(list=ls())
rm(list=ls(pattern='^b'))  # only objects starting with letter b
# Drop vars:
myjunk$score1<-myjunk$score2<-NULL
getwd()
setwd("/home/bheckel")
head(mydata)
# same
mydata[c(1:6), ]
# What is object type?:
class(ratings)  # assumes dataframe 'rating's exist - returns "data.frame"

# Run execute an external program:
setwd('/home/bheckel/code/sas')
source("t.R", echo=T)  # or from commandline $ Rscript readfile.csv.R


# A scalar is actually a vector of length 1

# Create vector (a one dimensional data structure):
myvectorofone<-c('a')
mych<-c(1,'b','c')
class(mych)
print(mych)  # or just  mych


# Build hash from vectors:
mykeys = c("Bob","Carol","Ted","Alice")
myvalues = c("Robert Culp","Natalie Wood","Elliott Gould","Dyan Cannon")
# Names of the MYVALUES are the MYKEYS.
names(myvalues) = mykeys
myvalues['Carol']


# Limit to one variable
summary(mydp["source"])
summary(mydp$source)
names(mydp)
summary(mydp[c(28,29)])


# Limit observations:
mydp[2:4, ]
mydp[mydp$short_test_name_level1=='Assay', ]


# Manually or from clipboard, enter a list (vector) of numbers (2 CR to end, don't use commas):
x <- scan()
# or
x <- scan(sep=',')
x <- scan(sep='\t')
# Manually or from clipboard, enter a list (vector) of chars (2 CR to end, don't use commas):
x <- scan(what='character')
# or
x <- scan(what='char')


# Read CSV t.csv into a data frame (a collection of columns of data):
 a,b,c,d
 1,2,3,foo
 3,4,5,bar
 6,7,8,baz
myd<-read.table('/home/rsh86800/t.csv',header=TRUE,sep=',')
# or
setwd("/home/rsh86800")
getwd
myd<-read.table('t.csv',header=TRUE,sep=',')
# Or from clipboard:  myd<-scan(what='char',sep=',')  then paste rows & CR but it's not a data frame, it's a list of vectors (I think).
# Read but skip var c
myd<-read.table('t.csv',header=TRUE,sep=',',colClasses=c('integer','NULL','integer','character'))
write.table(myd, file='tR.csv', row.names=FALSE, sep=',', col.names=TRUE)  # e.g. to give to coworker


foo <- c(1,2,3)
cat(foo,file='list.txt')


# Subset:
ass<-mydp[mydp$short_test_name_level1=='Assay', ]
diss<-mydp[mydp$short_test_name_level1=='Dissolution', ]
# Stack (row bind):
both<-rbind(ass,diss)
# Add column (col bind):
mydp<-cbind(mydp,score1=0)

# read SAS (varnames must be 8 char or less)
mysas<-read.ssd('c:/cygwin/home/rsh86800/rtest','t', sascmd='c:/PROGRA~1/SASINS~1/SAS/V8/sas.exe')

# No pre-sorting needed
merged<-merge(myleft,myright,by=c("id","workshop"))

# Sort by gender ascending ...(-mydata$q1)... for descending)
attach(mydata)  # convenience feature to avoid prefixing vars e.g. ds$Density
mydata[order(gender), ]
# or without attach()
mydata[order(mydata$gender), ]

# Vectors using concatenation function (caution-clobbers any existing x y z objects):
x <- c("Bob","Carol","Ted","Alice")
y <- c("Bob","foo","bar","baz")
z <- unique(c(x,y))


# Workspace management:
save.image()  # save all objects to ./.RData - and it autoloads at next invocation of R, verify via ls() - good for snapshots
save.image(file='/home/rsh86800/rtest/mydata.Rdata')  # save everything
load(file='/home/rsh86800/rtest/mydata.Rdata')
load("Beginning.RData")  # in pwd
# ./.RData and ./.Rhistory are saved if you chose 'y' at q() or > savehistory() saves to pwd (loadhistory() is then available but .Rhistory is autoloaded if in pwd)
save(bf, bf.lm, bf.beta, file=/home/rsh86800/butterfly.RData  # save only specific objects to disk
save(list = ls(pattern='^bf'), file=/home/rsh86800/butterfly.RData  # save only specific objects to disk


Sys.setenv('R_HISTSIZE' = 512)  # modify max history size (not persistent! so mostly useless)
Sys.getenv('R_HISTSIZE')  # verify


> data(islands)  # copy to your workspace
> km_islands <- islands*2.59  # convert

> .Last.value  # like bc(1)'s . (dot)

> is.integer(k)  # is k an integer? 

> z = 1 + 2i     # create a complex number

> sprintf("%s has %d dollars", "Sam", 100) 


# R List objects (a series of other objects bundled together to form a single object):
# E.g. if a pepper shaker is your list x, then x[1] is the pepper shaker containing a single pepper packet.  x[2] would
# look the same but contain the second packet.  x[1:2] would be the pepper shaker containing two pepper packets.  The 
# actual pepper would be x[[1]][[1]]
> n = c(2, 3, 5) 
> class(n)  # confirm it's a List (or Matrix or Data Frame)
> s = c("aa", "bb", "cc", "dd", "ee") 
> b = c(TRUE, FALSE, TRUE, FALSE, FALSE) 
> m = matrix(1:12, nrow=3)
> x = list(n, s, b, m, 42)   # x contains copies of n, s, b, m 
> x
[[1]]
[1] 2 3 5

[[2]]
[1] "aa" "bb" "cc" "dd" "ee"

[[3]]
[1]  TRUE FALSE  TRUE FALSE FALSE

[[4]]
     [,1] [,2] [,3] [,4]
[1,]    1    4    7   10
[2,]    2    5    8   11
[3,]    3    6    9   12

[[5]]
[1] 42
> x[[3]]
[1]  TRUE FALSE  TRUE FALSE FALSE
> x[[4]][3,4]
[1] 12


# Matrix Matrices (2 dimensional block of one kind of object - i.e. must be all numeric or all character, it's essentially a single data item that has been displayed in rows and columns):
> neo=matrix(c(1,2,3,4,5,6), nrow=2, ncol=3)  # 2x3 grid
> neo

     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6

> neo[2,3]  # 6
> neo[2,]   # 2 4 6

> morpheus <- matrix(1:30, 5,6)
> morpheus

     [,1] [,2] [,3] [,4] [,5] [,6]
[1,]    1    6   11   16   21   26
[2,]    2    7   12   17   22   27
[3,]    3    8   13   18   23   28
[4,]    4    9   14   19   24   29
[5,]    5   10   15   20   25   30

> t(morpheus)  # transpose

     [,1] [,2] [,3] [,4] [,5]
[1,]    1    2    3    4    5
[2,]    6    7    8    9   10
[3,]   11   12   13   14   15
[4,]   16   17   18   19   20
[5,]   21   22   23   24   25
[6,]   26   27   28   29   30

> c(morpheus)  # collapse to vector

> bird
              Garden Hedgerow Parkland Pasture Woodland
Blackbird         47       10       40       2        2
Chaffinch         19        3        5       0        2
Great Tit         50        0       10       7        0
House Sparrow     46       16        8       4        0
Robin              9        3        0       0        2
Song Thrush        4        0        6       0        0

> species = c('Bbird', 'C.Finch', 'Gt.Tit', 'Sparrow', 'Robin', 'Thrush')
> habitats = c('Gdn', 'Hedge', 'Park', 'Field', 'Wood')
> dimnames(birdmatrix) = list(species, habitats)

        Gdn Hedge Park Field Wood
Bbird    47    10   40     2    2
C.Finch  19     3    5     0    2
Gt.Tit   50     0   10     7    0
Sparrow  46    16    8     4    0
Robin     9     3    0     0    2
Thrush    4     0    6     0    0


# Arrays:
> a = array(1:16, dim=c(4,2,2)); a
, , 1

     [,1] [,2]
[1,]    1    5
[2,]    2    6
[3,]    3    7
[4,]    4    8

, , 2

     [,1] [,2]
[1,]    9   13
[2,]   10   14
[3,]   11   15
[4,]   12   16
> a[,,2][4,2]
[1] 16


# Data Frames
> n = c(2, 3, 5) 
> s = c("aa", "bb", NA) 
> b = c(TRUE, FALSE, TRUE) 
> df = data.frame(n, s, b)  # must be exactly 3 vars in each (or pad with NAs), unlike lists
> df
  n  s     b
1 2 aa  TRUE
2 3 bb FALSE
3 5 cc  TRUE

> df[2,3]
[1] FALSE
> df[2,'b']
[1] FALSE


> head(mtcars)
> tail(mtcars)  # better, see record count
> names(mtcars) # just fieldnames
> dimnames(mtcars) # both row and fieldnames, almost always used for matrices only
# Standard deviation (stddev)
> sd(mtcars[,4])  # 68.56287
> sd(mtcars[[4]]) # 68.56287
> sd(mtcars$hp)   # 68.56287
# Query data frames like SQL:
# SELECT * FROM mtcars WHERE am = 0
> isautotranny = mtcars$am==0  # the logical index vector (FALSE FALSE TRUE...)
> mtcars[isautotranny,]  # print everything with auto transmission
# SELECT mpg FROM mtcars WHERE am = 0
> mtcars[isautotranny,]$mpg  # print vector (21.4 18.7 18.1...) for stats like:
> mean(mtcars[autotranny,]$mpg)
# SELECT * FROM mtcars ORDER BY mpg DESC, hp
> mtcars[order(-mtcars[,1], mtcars[,4]),]
# SELECT V1 FROM lims WHERE V1 is > 10000
> lims$V1>10000  # returns vector TRUE TRUE FALSE...
> lims$V1[lims$V1>10000]
# SELECT max(mpg)
> max(mtcars$mpg)
# ORDER BY ...
> sort(nottem)


> cyl=mtcars$cyl
> cyl.freq=table(cyl)
> cyl.freq  # horizontal print
> cbind(cyl.freq)  # vertical print
> cyl.relfreq = cyl.freq/nrow(mtcars)
> cyl.relfreq
> barplot(cyl.relfreq)
#  barplot(d.freq, main='Recent ChemLMS Logins', ylab='Count', col='#FFA500', border='gray', col.lab=gray(.8))
> pie(cyl.relfreq)


> lims <-read.table('limslogins.parsed.txt', header=F, sep=',')
> ts <-strptime(lims$V2, format='%d-%b-%Y')
> limssrtd <-data.frame(lims, ts)  # sort by timestamp var
> d <-limssrtd$ts
> d.freq <-table(d)
> barplot(d.freq, main='ChemLMS Logins', ylab='Login Count', col='#FFA500', border='gray', cex.axis=0.8, cex=0.8, col.lab=gray(.8), density=50)


> circle.area <- function(r) { pi * r ^ 2 }
> circle.area(5)

> randomnumbers = rnorm(100)
> notsorandomnumbers = rnorm(100, mean=100, sd=15)

> set.seed(1)  # reproduce the results again at a later date
> rnorm(5)
> rnorm(6)
# Get same 5 & 6 random numbers again:
> set.seed(1)
# A simulation would reset the seed each time it runs to get a new series

> rbinom(50,1,0.5)  # 50 binary numbers 0,1,0,1,1,0 ...

> sample(1:10, 4)  # 3 4 5 7

##############
# Standard deviation
> x<-c(455.05, 459.3, 462.04, 448.26) 
> sd(x)  # or sd(x, na.rm=TRUE) if any NA nulls exist in the sample
6.002113
##############
# Or same via manual standard deviation calculation:
$ bc
455.05 + 459.3 + 462.04 + 448.26
1824.65
./4
456.16250000000000000000

455.05-456.16
-1.11
459.3-456.16
3.14
462.04-456.16
5.88
448.26-456.16
-7.90

-1.11^2
1.2321
3.14^2
9.8596
5.88^2
34.5744
-7.90^2
62.4100

1.2321+9.8596+34.5744+62.4100
108.0761

# Calculate Variance
108.0761/(4-1)
36.02536666666666666666  # confirm via var(x)

sqrt(36.025)
6.00208297176905077812
##############

# List all available preinstalled sample R datasets:
data() #  or data(package = .packages(all.available = TRUE))


mean(bird[2,])  # mean of the 2nd row of a matrix
mean(bird[,2])  # mean of the 2nd column of a matrix

sample(bird, size=4)  # random sample of 4 items (without replacement)


x <- as.Date("1970-01-01")  # store as a Date class
unclass(x)  # days since the Jan 1, 1970 epoch (i.e. 0 here)

x <- Sys.time()  # now
y <- as.POSIXlt(x)  # a list
names(unclass(y))  # show available, find 'sec'
y$sec

x <-c("January 10, 2012 10:40", "December 9, 2011 9:10")
y <-strptime(x, "%B %d, %Y %H:%M")  # reformat datetime to POSIXlt


# Loop list (creates 4 lists, e.g. 0.2675082 then 0.218463 0.5137968 then 0.238909 0.3113233 0.5239157 then 0.5325233 0.123439 0.253234 0.793233):
# Best for loops on command line
x <- 1:5
lapply(x, mean)  # better: sapply(x, mean) to get a single vector rather than 3 lists of 1 element each

x <- 1:4
lapply(x, runif)  # (r)andom (unif)orm


# Loop matrix:
x <- matrix(rnorm(200), 20, 10)
apply(x, 2, mean)  # creates list of 10 column means
apply(x, 1, mean)  # creates list of 20 row means

# Split data frame:
s<-split(airquality,airquality$Month)


# proc transform - use  library(reshape2)


# For loop:
library(tidyverse)

# 3C x 10R
mydf <- tibble(
  a=rnorm(10),
  b=rnorm(10),
  c=rnorm(10)
)

mymedianvec <- vector('double', ncol(mydf))

for ( i in seq_along(mydf)) {
  mymedianvec[[i]] <- median(mydf[[i]])
}
