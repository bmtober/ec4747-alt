# install.packages("txtplot")


davg <- read.table("document_similarity.acc.avg", header=FALSE, sep=" ")
aavg <- read.table("average_term_similarity.acc.avg", header=FALSE, sep=" ")
favg <- read.table("average_tfidf_similarity.acc.avg", header=FALSE, sep=" ")
tavg <- read.table("top_ten_term_similarity.acc.avg", header=FALSE, sep=" ")


png("avg_accuracy.png", width=400, height=400)
plot(davg$V2,davg$V1, type="l", cex.lab=1.5, cex.main=2, ylim=c(0,1), xlab="Threshold", ylab="Accuracy", main="Average Accuracy", col="blue")

lines(aavg$V2,aavg$V1, col="green")

lines(tavg$V2,tavg$V1, col="red")

lines(favg$V2,favg$V1, col="yellow")

legend(0.2,0.4, c("Document Freqency", "Average Term Frequency", "Top Ten Terms", "Average TFIDF"), col=c("blue", "green", "red", "yellow"), pch=c(0,0,0))
dev.off()
q()
