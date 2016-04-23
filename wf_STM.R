# load packages 
library(stm)
# load the data created from "preprocessing.R"
setwd("~/Desktop/wellsFargo/")
wf_banks <- readRDS("wells_banks.rds")
# read and process text data automatically 
processed <- textProcessor(wf_banks$FullText, metadata=wf_banks)
# associate text with metadata
out<-prepDocuments(processed$documents, processed$vocab, processed$meta, lower.thresh=15)
saveRDS(out,"out.rds")
# variables setting for convenience
docs <- out$documents
vocabs <- out$vocab
meta <-out$meta
# estimate the structural topic model 
PrevFit <- stm(docs, vocabs, K = 20,  prevalence =~ MediaType, max.em.its = 75, data = meta, init.type = "Spectral")
# save it before moving to the next step 
saveRDS(PrevFit, "PrevFit.rds")
# interpret the stm by plotting and inspecting results 
# check 20 topics 
labelTopics(PrevFit)
# plot the topics
plot.STM(PrevFit, type="labels", n=10, text.cex=.7)
plot.STM(PrevFit, type="summary")
# according to the proportions, Topic 4 is most pervasive, followed by 11,12,18,13,14,19,9,2,5,15,16,3,1,6,17,10,8,20,7
# check topic 4 and 11 first 
thought4 <- findThoughts(PrevFit, texts=out$meta$FullText, topics=4, n=10)$docs[[1]]
thought11 <- findThoughts(PrevFit, texts=out$meta$FullText, topics=11, n=2)$docs[[1]]
thought12 <- findThoughts(PrevFit, texts=out$meta$FullText, topics=12, n=5)$docs[[1]]
thought18 <- findThoughts(PrevFit, texts=out$meta$FullText, topics=18, n=2)$docs[[1]]
thought2 <- findThoughts(PrevFit, texts=out$meta$FullText, topics=2, n=20)$docs[[1]]
par(mfrow = c(1, 2),mar = c(.5, .5, 1, .5))
plotQuote(thought4, width = 30, main = "Topic 4")
plotQuote(thought11, width = 30, main = "Topic 11") # 
plotQuote(thought12, width = 30, main = "Topic 12") # all related to fuck
plotQuote(thought18, width = 30, main = "Topic 18")
plotQuote(thought13, width = 30, main = "Topic 13")
# word cloud 
library(stm)
cloud(PrevFit, topic=4)




table(wf_banks$MediaType)


