# install.packages("txtplot")

library('txtplot')

d <- read.table("document_similarity.csv", header=TRUE, sep="\t")
a <- read.table("average_term_similarity.csv", header=TRUE, sep="\t")
t <- read.table("top_ten_term_similarity.csv", header=TRUE, sep="\t")
f <- read.table("average_tfidf_similarity.csv", header=TRUE, sep="\t")

txtplot(d$spamminess, d$hamminess, pch=d$class, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
txtplot(a$spamminess, a$hamminess, pch=a$class, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
txtplot(t$spamminess, t$hamminess, pch=t$class, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))
txtplot(f$spamminess, f$hamminess, pch=f$class, xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1))

png("document_similarity.png")
plot(d$spamminess, d$hamminess, pch=d$class, col=ifelse(d$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Document Frequency")

png("average_term_frequency.png")
plot(a$spamminess, a$hamminess, pch=a$class, col=ifelse(a$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Average Term Frequency")

png("top_ten_term_frequency.png")
plot(t$spamminess, t$hamminess, pch=t$class, col=ifelse(t$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Top Ten Terms Frequency")

png("average_tfidf_frequency.png")
plot(f$spamminess, f$hamminess, pch=f$class, col=ifelse(f$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Average TFIDF Frequency")


q()
