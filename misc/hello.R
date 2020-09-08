# R Statistical System
# $ Rscript hello.R
# Parts adapted from tutorialspoint.com
# help:
# ?lm
# ??lm  # fuzzy verbose
# help(lm)
# Created: Mon 18 Apr 2016 10:46:02 (Bob Heckel) 

s <- 'hello world'; print(s)

s <- 'hello world'
s

# Colon operator creates sequence
s2 <- 0:9
s2

s3 <- seq(0, 9, by=0.5)
s3


mynumeric <- 12.34
mynumeric

myinteger <- 1234L
myinteger


myvector <- c('red', 'yellow', 'blue')
myvector
# yellow & blue
myvector2 <- myvector[c(2,3)]
myvector2


mylist <- list(1234L, 'algae')
print('mylist is')
mylist
soylentlist <- list(mylist, 'soy','people', TRUE)
print('my soylent list is')
soylentlist


myarray <- array(c('green','yellow'),dim = c(3,3, 4))
myarray


# Like Excel with R1C1 notation, no field names (like frames have)
mymatrix <- matrix(c('r1c1','r1c2','r1c3', 'r2c2','r2c2','r2c3'), nrow=2, ncol=3, byrow=TRUE)
mymatrix
cat('\n')
print('r2c2:')
mymatrix[2,2]
cat('\n')
print('r2:')
mymatrix[2,]


vapple_colors <- c('green','green','yellow','red','red','red','green')
# De-dup
myfactor <- factor(vapple_colors)
myfactor
print(nlevels(myfactor))

# Frame is list of vectors of equal length
myframe <- data.frame(
             gender = c('Male', 'Male', 'Female'),
             height = c(152, 171.5, 165),
             age = c(42, 44, 69),
             mydt = as.Date(c('2016-01-01', '2016-02-01', '2016-04-16'))
           )
# Add a column
myframe$dept <- c('IT', 'Ops', 'HR')
# To add a row make a new frame then  newframe <- rbind(myframe, myframe2)
# Whole frame
myframe
# Details of frame
str(myframe)
# proc means
summary(myframe)
# Partial frame
print(data.frame(myframe$age, myframe$mydt))
cat('\n')


v1 <- c(2,5.5,6,9)
v2 <- c(8,2.5,14,9)
# Vector arithmetic
print(v1+v2)
print(v1<v2)
print(v1 != v2)


v <- c("what","is","foo","bar","foo")

if ( "Foo" %in% v ) {
   print("one foo is found")
} else if ( "foo" %in% v ) {
   print("a 2nd foo is found")
} else {
   print("foo is not found")
}


v <- c("Hello","do loop")
cnt <- 2

repeat {
  print(v)
  cnt <- cnt+1
   
  if (cnt > 5) {
    break
  }
}


v <- c("Hello","while loop")
cnt <- 2

while (cnt < 7) {
   print(v)
   cnt = cnt + 1
}


v <- LETTERS[1:4]
for ( i in v) {
   print(i)
}


# Standard deviation
print(sd(25:30))


new.function <- function(a, c=42) {
  for(i in 1:a) {
    b <- i^2
    print(b)
    print(c)
  }
}

###new.function(3)
new.function(a=3, c=43)


# Concatenation
a <- 'foo'
b <- 'bar'
c <- 'baz'
print(paste(a,b,c, sep = "-"))
cat('\n')


# Total number of digits displayed. Last digit rounded off
result <- format(23.123456789, digits = 9)
print(result)

# Display numbers in scientific notation
result <- format(c(6, 13.14521), scientific = TRUE)
print(result)

# The minimum number of digits to the right of the decimal point
result <- format(23.47, nsmall = 5)
print(result)

# Format treats everything as a string
result <- format(42)
print(result)

# Left justify strings
result <- format("Hello", width=8, justify="l")
print(result)
cat('\n')


result <- substring("Extract", 5, 7)
print(result)
cat('\n')


print('ok')
cat('ok\n')
print(charToRaw("ABCabc"))
cat('\n')


v1 <- c(1, 2, 3, 4)
###v2 <- c(4, 5, 6, 7)
# Same as 4, 5, 4, 5 due to recycling
v2 <- c(4, 5)
vectoraddition <- v1 + v2
vectoraddition

vs <- sort(v1, decreasing=TRUE)
vs
cat('\n')

print
###help(print)


# Get library locations containing R packages
.libPaths()
# Get installed packages
library()

