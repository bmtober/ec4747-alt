# install.packages("txtplot")

library('txtplot')

x <- read.table("document_similarity.csv", header=TRUE, sep="\t")
txtplot(x$spamminess, x$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))

x <- read.table("average_term_similarity.csv", header=TRUE, sep="\t")
txtplot(x$spamminess, x$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))

x <- read.table("top_ten_term_similarity.csv", header=TRUE, sep="\t")
txtplot(x$spamminess, x$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))

q()
