setwd("~/Desktop/wellsFargo/")
wf <- read.table("wellsfargocase.txt", head=T, sep="|",stringsAsFactors=FALSE, fileEncoding="latin1", comment.char="")

## load the comments
comment <- wf[,6]
head(comment)
library(tm)
corp <- Corpus(VectorSource(comment))
# dtm <- DocumentTermMatrix(corp)
## preprocess the comments
# remove punctuation
corp <- tm_map(corp, removePunctuation)
# remove special characters
#for(j in seq(corp))   
#{   
#        corp[[j]] <- gsub("/", " ", corp[[j]])   
#        corp[[j]] <- gsub("@", " ", corp[[j]])   
#        corp[[j]] <- gsub("\\|", " ", corp[[j]])   
#}  
# remove numbers 
corp <- tm_map(corp, removeNumbers)
# convert to lowercase
corp <- tm_map(corp, tolower)
# remove stopwords
corp <- tm_map(corp, removeWords, stopwords("english"))

# stem words 
library(SnowballC)
corp <- tm_map(corp, stemDocument)


# strip whitespace
corp <- tm_map(corp, stripWhitespace)
# to finish 
corp <- tm_map(corp, PlainTextDocument)


inspect(corp[1:50])





