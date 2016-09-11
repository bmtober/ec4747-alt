
d1500 <- read.table("document_similarity.roc.1500", header=FALSE, sep=" ")
a1500 <- read.table("average_term_similarity.roc.1500", header=FALSE, sep=" ")
f1500 <- read.table("average_tfidf_similarity.roc.1500", header=FALSE, sep=" ")
t1500 <- read.table("top_ten_term_similarity.roc.1500", header=FALSE, sep=" ")

d2000 <- read.table("document_similarity.roc.2000", header=FALSE, sep=" ")
a2000 <- read.table("average_term_similarity.roc.2000", header=FALSE, sep=" ")
f2000 <- read.table("average_tfidf_similarity.roc.2000", header=FALSE, sep=" ")
t2000 <- read.table("top_ten_term_similarity.roc.2000", header=FALSE, sep=" ")

d2500 <- read.table("document_similarity.roc.2500", header=FALSE, sep=" ")
a2500 <- read.table("average_term_similarity.roc.2500", header=FALSE, sep=" ")
f2500 <- read.table("average_tfidf_similarity.roc.2500", header=FALSE, sep=" ")
t2500 <- read.table("top_ten_term_similarity.roc.2500", header=FALSE, sep=" ")

d3000 <- read.table("document_similarity.roc.3000", header=FALSE, sep=" ")
a3000 <- read.table("average_term_similarity.roc.3000", header=FALSE, sep=" ")
f3000 <- read.table("average_tfidf_similarity.roc.3000", header=FALSE, sep=" ")
t3000 <- read.table("top_ten_term_similarity.roc.3000", header=FALSE, sep=" ")

d3500 <- read.table("document_similarity.roc.3500", header=FALSE, sep=" ")
a3500 <- read.table("average_term_similarity.roc.3500", header=FALSE, sep=" ")
f3500 <- read.table("average_tfidf_similarity.roc.3500", header=FALSE, sep=" ")
t3500 <- read.table("top_ten_term_similarity.roc.3500", header=FALSE, sep=" ")

d4000 <- read.table("document_similarity.roc.4000", header=FALSE, sep=" ")
a4000 <- read.table("average_term_similarity.roc.4000", header=FALSE, sep=" ")
f4000 <- read.table("average_tfidf_similarity.roc.4000", header=FALSE, sep=" ")
t4000 <- read.table("top_ten_term_similarity.roc.4000", header=FALSE, sep=" ")

png("roc.png", width=400, height=400)
plot(d1500$V6,d1500$V7, type="l", cex.lab=1.5, cex.main=2, xlim=c(0,1), ylim=c(0,1), xlab="Prob. False Alarm", ylab="Prob. Detection", main="Receiver Operating\nCharacteristic", col="blue")

lines(d2000$V6,d2000$V7, col="blue")
lines(d2500$V6,d2500$V7, col="blue")
lines(d3000$V6,d3000$V7, col="blue")
lines(d3500$V6,d3500$V7, col="blue")
lines(d4000$V6,d4000$V7, col="blue")

lines(a1500$V6,a1500$V7, col="green")
lines(a2000$V6,a2000$V7, col="green")
lines(a2500$V6,a2500$V7, col="green")
lines(a3000$V6,a3000$V7, col="green")
lines(a3500$V6,a3500$V7, col="green")
lines(a4000$V6,a4000$V7, col="green")

lines(t1500$V6,t1500$V7, col="red")
lines(t2000$V6,t2000$V7, col="red")
lines(t2500$V6,t2500$V7, col="red")
lines(t3000$V6,t3000$V7, col="red")
lines(t3500$V6,t3500$V7, col="red")
lines(t4000$V6,t4000$V7, col="red")

lines(f1500$V6,f1500$V7, col="yellow")
lines(f2000$V6,f2000$V7, col="yellow")
lines(f2500$V6,f2500$V7, col="yellow")
lines(f3000$V6,f3000$V7, col="yellow")
lines(f3500$V6,f3500$V7, col="yellow")
lines(f4000$V6,f4000$V7, col="yellow")

legend(0.2,0.4, c("Document Freqency", "Average Term Frequency", "Top Ten Terms", "Average TFIDF"), col=c("blue", "green", "red", "yellow"), pch=c(0,0,0))
dev.off()
q()
