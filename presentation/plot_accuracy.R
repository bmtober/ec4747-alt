# install.packages("txtplot")


a1500 <- read.table("average_term_similarity_example.acc", header=FALSE, sep=" ")


png("accuracy-example.png", width=400, height=400)
plot(a1500$V7,a1500$V6, type="l", cex.lab=1.5, cex.main=2, ylim=c(0,1), xlab="Threshold", ylab="Accuracy", main="Accuracy", col="blue")

dev.off()
