x<-read.csv("report/uniqwords.csv",header=T)
png()
h=hist(x$word.count, main="Unique Words Per Document", xlab="Number of Unique Words", breaks=100)
q()
