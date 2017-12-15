heisenberg <- read.csv(file="readfile.csv.r.txt",head=TRUE,sep=",")

names(heisenberg)

attributes(heisenberg)

#heisenberg
# or better just first few rows
head(heisenberg)

summary(heisenberg)

heisenberg$mass

cor(heisenberg$mass, heisenberg$velocity)
