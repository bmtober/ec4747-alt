x <- read.table("document_similarity.csv", header=FALSE, sep=",")
library('txtplot')
txtplot(x$V2,x$V3)
q()
