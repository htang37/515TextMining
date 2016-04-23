setwd("~/Desktop/wellsFargo")
# load the packages
library(dplyr)
library(tm)
# load the file 
wf <- read.table("wellsfargocase.txt", head=T, sep="|",stringsAsFactors=FALSE, fileEncoding="latin1", comment.char="")
# check the period range
str(wf)
table(wf$Date) # 2014/08 - 2015/08
# format Date as date 
wf$Date <- as.Date(wf$Date, format="%m/%d/%Y")

# keep only banka, bankb, bankc, bankd, since other banks' performance not considered in this challenge
wf_banks <- filter(wf, grepl('BankA|BankB|BankC|BankD', wf$FullText))
dim(wf_banks)
dim(wf) # delete 28197 rows 

# filter out useless words like ADDRESS, Name, INTERNET, PHONE, twit_hndl (check the data description of the challenge)
wf_banks$FullText <- gsub("ADDRESS", " ", wf_banks$FullText, ignore.case=F)
wf_banks$FullText <- gsub("Name", " ", wf_banks$FullText, ignore.case=F)
wf_banks$FullText <- gsub("INTERNET", " ", wf_banks$FullText, ignore.case=F)
wf_banks$FullText <- gsub("PHONE", " ", wf_banks$FullText, ignore.case=F)
wf_banks$FullText <- gsub("twit_hndl_", " ", wf_banks$FullText, ignore.case=F)

# preprocessing the text 
# remove retweet entities 
wf_banks$FullText = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", wf_banks$FullText)
# remove "@people"
wf_banks$FullText = gsub("@\\w+", "", wf_banks$FullText)
# remove punctuation
wf_banks$FullText = gsub("[[:punct:]]", "", wf_banks$FullText)
# remove digits 
wf_banks$FullText = gsub("[[:digit:]]", "", wf_banks$FullText)
# remove links
wf_banks$FullText = gsub("http\\w+", "", wf_banks$FullText)
# remove white spaces
wf_banks$FullText <- gsub("^[[:space:]]+", "", wf_banks$FullText ) 
wf_banks$FullText <- gsub("[[:space:]]+$", "", wf_banks$FullText ) 
# lowercase 
wf_banks$FullText = tolower(wf_banks$FullText)
# remove stopwords 
wf_banks$FullText <- removeWords(wf_banks$FullText, stopwords("english"))

# check the data after cleaning 
head(wf_banks$FullText)

# output to a clean text 
saveRDS(wf_banks, "wells_banks.rds")





