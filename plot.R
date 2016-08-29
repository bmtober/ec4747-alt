x <- read.table("document_similarity.csv", header=FALSE, sep=",")
library('txtplot')
txtplot(x$V2, x$V3, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
q()
