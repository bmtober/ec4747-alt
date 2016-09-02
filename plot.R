# install.packages("txtplot")

library('txtplot')

d <- read.table("document_similarity.csv", header=TRUE, sep="\t")
a <- read.table("average_term_similarity.csv", header=TRUE, sep="\t")
t <- read.table("top_ten_term_similarity.csv", header=TRUE, sep="\t")

txtplot(d$spamminess, d$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
txtplot(a$spamminess, a$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
txtplot(t$spamminess, t$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))

png("document_similarity.png")
plot(d$spamminess, d$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Document Frequency")

png("average_term_frequency.png")
plot(a$spamminess, a$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Average Term Frequency")

png("top_ten_terms_frequency.png")
plot(t$spamminess, t$hamminess, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Top Ten Terms Frequency")

q()
