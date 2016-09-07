# install.packages("txtplot")


d1500 <- read.table("document_similarity.acc.1500", header=FALSE, sep=" ")
a1500 <- read.table("average_term_similarity.acc.1500", header=FALSE, sep=" ")
f1500 <- read.table("average_tfidf_similarity.acc.1500", header=FALSE, sep=" ")
t1500 <- read.table("top_ten_term_similarity.acc.1500", header=FALSE, sep=" ")

d2000 <- read.table("document_similarity.acc.2000", header=FALSE, sep=" ")
a2000 <- read.table("average_term_similarity.acc.2000", header=FALSE, sep=" ")
f2000 <- read.table("average_tfidf_similarity.acc.2000", header=FALSE, sep=" ")
t2000 <- read.table("top_ten_term_similarity.acc.2000", header=FALSE, sep=" ")

d2500 <- read.table("document_similarity.acc.2500", header=FALSE, sep=" ")
a2500 <- read.table("average_term_similarity.acc.2500", header=FALSE, sep=" ")
f2500 <- read.table("average_tfidf_similarity.acc.2500", header=FALSE, sep=" ")
t2500 <- read.table("top_ten_term_similarity.acc.2500", header=FALSE, sep=" ")

d3000 <- read.table("document_similarity.acc.3000", header=FALSE, sep=" ")
a3000 <- read.table("average_term_similarity.acc.3000", header=FALSE, sep=" ")
f3000 <- read.table("average_tfidf_similarity.acc.3000", header=FALSE, sep=" ")
t3000 <- read.table("top_ten_term_similarity.acc.3000", header=FALSE, sep=" ")

d3500 <- read.table("document_similarity.acc.3500", header=FALSE, sep=" ")
a3500 <- read.table("average_term_similarity.acc.3500", header=FALSE, sep=" ")
f3500 <- read.table("average_tfidf_similarity.acc.3500", header=FALSE, sep=" ")
t3500 <- read.table("top_ten_term_similarity.acc.3500", header=FALSE, sep=" ")

d4000 <- read.table("document_similarity.acc.4000", header=FALSE, sep=" ")
a4000 <- read.table("average_term_similarity.acc.4000", header=FALSE, sep=" ")
f4000 <- read.table("average_tfidf_similarity.acc.4000", header=FALSE, sep=" ")
t4000 <- read.table("top_ten_term_similarity.acc.4000", header=FALSE, sep=" ")

png("accuracy.png")
plot(d1500$V7,d1500$V6, type="l", ylim=c(0,1), xlab="Threshold", ylab="Accuracy", main="Accuracy", col="blue")

lines(d2000$V7,d2000$V6, col="blue")
lines(d2500$V7,d2500$V6, col="blue")
lines(d3000$V7,d3000$V6, col="blue")
lines(d3500$V7,d3500$V6, col="blue")
lines(d4000$V7,d4000$V6, col="blue")

lines(a1500$V7,a1500$V6, col="green")
lines(a2000$V7,a2000$V6, col="green")
lines(a2500$V7,a2500$V6, col="green")
lines(a3000$V7,a3000$V6, col="green")
lines(a3500$V7,a3500$V6, col="green")
lines(a4000$V7,a4000$V6, col="green")

lines(t1500$V7,t1500$V6, col="red")
lines(t2000$V7,t2000$V6, col="red")
lines(t2500$V7,t2500$V6, col="red")
lines(t3000$V7,t3000$V6, col="red")
lines(t3500$V7,t3500$V6, col="red")
lines(t4000$V7,t4000$V6, col="red")

lines(f1500$V7,f1500$V6, col="yellow")
lines(f2000$V7,f2000$V6, col="yellow")
lines(f2500$V7,f2500$V6, col="yellow")
lines(f3000$V7,f3000$V6, col="yellow")
lines(f3500$V7,f3500$V6, col="yellow")
lines(f4000$V7,f4000$V6, col="yellow")

legend(0.2,0.4, c("Document Freqency", "Average Term Frequency", "Top Ten Terms", "Average TFIDF"), col=c("blue", "green", "red", "yellow"), pch=c(0,0,0))
q()
