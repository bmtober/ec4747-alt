# install.packages("txtplot")

library('txtplot')
x <- read.table("document_similarity.csv", header=FALSE, sep="\t")
txtplot(x$V2, x$V3, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))

x <- read.table("average_term_similarity.csv", header=FALSE, sep="\t")
txtplot(x$V2, x$V3, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
q()
