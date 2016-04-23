setwd("~/Desktop/wellsFargo/")
library(stm)
library(tm)
library(qdap)
wf_banks <- readRDS("wells_banks.rds")
PrevFit <- readRDS("PrevFit.rds")
thought4 <- findThoughts(PrevFit, texts=out$meta$FullText, topics=4, n=200)$docs[[1]]

corpus4 <- Corpus(VectorSource(thought4))

sentscore <- rep(0,200)
sentmean <- data.frame(rep(0,20))
for (i in 1:20){
        thought <- findThoughts(PrevFit, text=out$meta$FullText, topics=i, n=200)$docs[[1]]
        corpus <- Corpus(VectorSource(thought))
        sentscore <- rep(0,200)
        for (j in 1:200){
                text <- corpus[[j]]$content
                sentiment <- polarity(text)
                sentscore[j] <- sentiment$all$polarity
        }
        plot(sentscore, main=i)
        sentmean[i,1] <- mean(sentscore, na.rm=T)
}




