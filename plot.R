# install.packages("txtplot")

library('txtplot')

x <- read.table("document_similarity.csv", header=TRUE, sep="\t")
txtplot(x$hamminess, x$spamminess, xlab="Hamminess", ylab="Spamminess", xlim=c(0,1), ylim=c(0,1))

x <- read.table("average_term_similarity.csv", header=TRUE, sep="\t")
txtplot(x$hamminess, x$spamminess, xlab="Hamminess", ylab="Spamminess", xlim=c(0,1), ylim=c(0,1))

x <- read.table("top_ten_term_similarity.csv", header=TRUE, sep="\t")
txtplot(x$hamminess, x$spamminess, xlab="Hamminess", ylab="Spamminess", xlim=c(0,1), ylim=c(0,1))

q()
