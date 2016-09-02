library('txtplot')
d <- read.table("document_similarity.acc", header=FALSE, sep=" ")
a <- read.table("average_term_similarity.acc", header=FALSE, sep=" ")
t <- read.table("top_ten_term_similarity.acc", header=FALSE, sep=" ")
txtplot(d$V7,d$V6, ylim=c(0,1), xlab="Threshold", ylab="Accuracy")
txtplot(a$V7,a$V6, ylim=c(0,1), xlab="Threshold", ylab="Accuracy")
txtplot(t$V7,t$V6, ylim=c(0,1), xlab="Threshold", ylab="Accuracy")

plot(d$V7,d$V6, ylim=c(0,1), xlab="Threshold", ylab="Accuracy", main="Document Frequency")
plot(a$V7,a$V6, ylim=c(0,1), xlab="Threshold", ylab="Accuracy", main="Average Term Frequency")
plot(t$V7,t$V6, ylim=c(0,1), xlab="Threshold", ylab="Accuracy", main="Top Ten Terms Frequency")

q()
