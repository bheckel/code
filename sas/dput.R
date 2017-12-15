
y<-data.frame(a=1,b="a")
dput(y)  # debug
dput(y,file="t.R")  # write the frozen frame to file

new.y<-dget("t.R")
new.y

# See also ?dump
