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

png("document_similarity.png", width=400, height=400)
plot(d$spamminess, d$hamminess, cex.lab=1.5, cex.main=2, pch=d$class, col=ifelse(d$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Document Frequency")

png("average_term_frequency.png", width=400, height=400)
plot(a$spamminess, a$hamminess, cex.lab=1.5, cex.main=2, pch=a$class, col=ifelse(a$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Average Term Frequency")

png("top_ten_term_frequency.png", width=400, height=400)
plot(t$spamminess, t$hamminess, cex.lab=1.5, cex.main=2, pch=t$class, col=ifelse(t$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Top Ten Terms Frequency")

png("average_tfidf_frequency.png", width=400, height=400)
plot(f$spamminess, f$hamminess, cex.lab=1.5, cex.main=2, pch=f$class, col=ifelse(f$class==1,"green", "red"), xlab="Spamminess", ylab="Hamminess", xlim=c(0,1), ylim=c(0,1), main="Average TFIDF Frequency")


q()
