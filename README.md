#Executive Summary
This project is a competition from MindSumo sponsored by Wells Fargo. The project aims to find the insight that indicates customers’ behaviors, desires, pains and thought from financial comments and conversations on social media. To realize the text mining of the social media data, we applied topic modeling algorithm with R and in the end got 20 different topics with around 200k twitters and Facebook comments. We also used sentiment analysis to compare different topics to see whether they are good indicators of these customers’ comments. In the end of the report, we suggested some recommendations for the financial agencies to better utilize social media to improve customers’ experience and loyalty. 

#Background 
Social media has the proven power for business to develop a loyal community and reach new audience in a marketing strategy. As for finance industry, social media monitoring is also effectively used to improve customer service, generate lead, react to a crisis, track brand awareness and create social media buzz [1]. Wells Fargo alone, has seven official Twitter accounts, including @WellsFargo, @Ask_WellsFargo for answering customer questions, @WellsFargoJobs for job opportunity, @WellsFargoB2B for wholesale customers, @WellsFargoNews for latest company news, @WellsFargoWorks for small business customers and @WFAssetMgmt for market insights [2]. Wells Fargo also has a Facebook page providing updates, financial tips and other information [3]. Wells Fargo and other banking agencies can understand their customers and competitors better by analyzing the first-hand feedbacks from the social media.

#Problem Description 
Wells Fargo hosted the competition as a campus analytics challenge on MindSumo. As a part of the challenge, Wells Fargo wants to know what financial topics do customers discuss on social media and what caused the consumers to post about the topic. To be specific, if a customer posted “I will never bank again with BankA. Today, I simply wanted to close the savings account at the Bank Location on Address. Personal banker Name gave me such a hard time. Because of this, I will never bank at BankA and will tell everyone I know of the poor customer service”, we should try to build a model to automatically analyze these lines and then cluster the similar comments into a topic telling these comments are complaints of the poor customer service [4]. 


#Data
The original dataset is a text file with 220,377 records, each has six metrics: AutoID, Date, Year, Month, MediaType and FullText. It contains Twitter data in August of 2015 and Facebook data from 2014 August to 2015 August with query of 4 banks. The real name of the 4 banks have been replaced by “BankA”, “BankB”, “BankC” and “BankD”. While other banks are replaced by “Banke”. Meanwhile, all scrubbed addresses are replaced by uppercase “ADDRESS”, but a lowercase “address” is part of the text and is not a scrubbed replacement. Similarly, all internet references are replaced by “INTERNET”, a lower case of “internet” is just part of the text. 
All names are replaced by “Name”, phone numbers as “PHONE”. All actual twitter handles “@” are replaced by “twit_hndl”, so “twit_hndl_BankA” should actually be “@BankA”.
 
#Methodology
After checking the data description, we first did a data preprocessing to remove all the meaningless expressions.  After we got our clean file, we applied a topic model algorithm from “stm” package of R to come up with 20 topics from all the comments. 

As a matter of fact, if we hire 100 human experts to analyze 200k comments and classify them in 20 topics, we may get 100 totally different answers. One expert could do the classification based on geographic locations of the comments. Another could do based on the contents, sort out the news from the complaints, or thanks. One of them may classify based on the events of hashtags of the social media, since hashtags are commonly used on Twitters.

It seems there is no standard answer for the topic assignment, but we can still know whether it makes sense to us. As for us, it the content and sentiment is alike in the same topic, but dissimilar in different topics, we can say that the topic model is effective. So we checked the 20 topics’ top-ranked comments to see whether the basic contents of them are consistent in the same topic but different from others. Meanwhile, we also applied sentiment analysis to check whether the emotion is different from different topics, but consistent among the same one.  

This is process structure of the project. Let’s check each step one by one. 

#Step 1: Pre-processing
In the previous part, we have mentioned that there are many meaningless words in the text, like “ADDRESS”, “Name”, “INTERNET”, “PHONE” and “twit_hndl” (case sensitive), so we first removed them with the code: 
	*wf_banks$FullText <- gsub("ADDRESS", " ", wf_banks$FullText, ignore.case=F)*
	*wf_banks$FullText <- gsub("Name", " ", wf_banks$FullText, ignore.case=F)*
	*wf_banks$FullText <- gsub("INTERNET", " ", wf_banks$FullText, ignore.case=F)*
	*wf_banks$FullText <- gsub("PHONE", " ", wf_banks$FullText, ignore.case=F)*
	*wf_banks$FullText <- gsub("twit_hndl_", " ", wf_banks$FullText, ignore.case=F)*

Next, we want to remove the retweet entities (RT), mentions (@account), punctuation, digits, links (URLs), white spaces. We also want to lowercase all the text and remove the stop words. We used the code below: 

	*wf_banks$FullText = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", wf_banks$FullText)*
	*wf_banks$FullText = gsub("@\\w+", "", wf_banks$FullText)*
	*wf_banks$FullText = gsub("[[:punct:]]", "", wf_banks$FullText)*
	*wf_banks$FullText = gsub("[[:digit:]]", "", wf_banks$FullText)*
	*wf_banks$FullText = gsub("http\\w+", "", wf_banks$FullText)*
	*wf_banks$FullText <- gsub("^[[:space:]]+", "", wf_banks$FullText)* 
	*wf_banks$FullText <- gsub("[[:space:]]+$", "", wf_banks$FullText)* 
	*wf_banks$FullText = tolower(wf_banks$FullText)*
	*wf_banks$FullText <- removeWords(wf_banks$FullText, stopwords("english"))* 

Also, we only want to keep the text with the four banks, since other banks’ performance are not considered in this project. We used the code: (deleted 28197 records)
	*wf_banks <- filter(wf, grepl('BankA|BankB|BankC|BankD', wf$FullText))*

In the “stm” package, there is a function “textProcessor” that can build corpus, convert to lower case, remove stopwords, remove numbers, remove punctuation, and stem words automatically. The code is:
	*processed <- textProcessor(wf_banks$FullText, metadata=wf_banks)*

Last but not least, we only keep the words that appeared more than 15 times in the whole file to do the topic model, to make our model more efficient. We used the code: (removed 86858 of 93077 terms)
	*out<-prepDocuments(processed$documents, processed$vocab, processed$meta, lower.thresh=15)*

So far, we finished our pre-processing.

#Step 2: Topic model with STM package
Structural Topic Model stm R package is developed by Robert, Stewart, Tingley. The Structural Topic Model allows researchers to flexibly estimate a topic model that includes document-level meta-data. The meta-data comes from a data generating process for each document and then use the data to find the most likely values for the parameters within the model. The generative process for each document can be summarized as: 

First, for each topic in each document (record), it generalizes a linear model based on document covariates;

Next, for each topic, it generates the document distribution over words with the baseline word distribution, the topic specific deviation, the covariate group deviation and the interaction between the two. 

In the end, for each document, STM assigns it to a specific topic. Therefore, for each word in the document, STM can draw the word’s topic assignment. Besides, conditional on the topic chosen, STM can draw an observed word from that topic. 

This package also provides many other features, including topic exploration, extensive plotting and visualization options [5].  

We used the following code to build our STM model:
	*PrevFit <- stm(out$documents, vocabs, K = 20,  prevalence =~ MediaType, max.em.its = 75, data = meta, init.type = "Spectral")*
The model is set to run for a maximum of 75 EM iterations. We used the MediaType (Facebook/Twitter) as a covariate in the topic prevalence. And we used the spectral initialization, which guarantees the same result to generate regardless of the seed we chose. The graph of 20 topics is generated with the code: (longer lines, larger proportion)
plot.STM(PrevFit, type="summary")

We will talk about the analysis and interpretation of the model in the next two steps. 
#Step 3: Topic Interpretations
As we mentioned before, we don't have a standard answer to the topic selection. But we can check each topic to see whether the documents in it is highly related to each other. We first checked the topic 4, since it has the largest proportion among 20 topics. We can see that “waiting line”, “wait”, and “waiting” appeared frequently in the documents, so we can assume this topic is about the poor customer service. 


Then we generated the top-related documents in topic 11. This time, “bankbhelp” appeared frequently. And the documents are mainly about customer issue with accounts, credit cards, phone scams and so on.


We used this way to check all 20 topics and here is our summary:
1	BankC news 
6	Mission Main Street Grants
11	@BankBhelp
16	Security News
2	Job opportunities
7	Hard to tell…
12	Shit, Hate, Fuck..
17	Loan & Mortagage
3	LIBOR news
8	Photos
13	Thank, Love…
18	Stock Market News
4	Poor Customer Service
9	Twitter handles
14	Sport Games 
19	getcollegeready
5	Banks Feedback
10	Hard to tell…
15	Asset Mgmt
20	Hard to tell…
There are three topics which are hard to tell their contents apart from others. Other topics seem to perform well to collect similar documents and we can assign the content summary to each of them.
 
#Step 4: Topic Sentiment Analysis 
As to better understand our generated projects, we applied a sentiment analysis with qdap package, Here is the code we used:
 *	sentscore <- rep(0,200)
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
		sentmean[i,1] <- mean(sentscore, na.rm=T)
	}*

1	0.1341 
6	0.0273
11	-0.1077
16	-0.3388
2	-0.1598
7	-0.2953
12	-0.3378
17	-0.0048
3	-0.0172
8	0.0304
13	0.8086
18	-0.1217
4	0.0787
9	0.0737
14	0.0794
19	0.2157
5	0.0618
10	0.0072
15	-0.1016
20	-0.0404

We can see that our topic model actually did a good job to sort out the most positive comments. In topic 13, the most frequent words appeared are “thank”, “love” and “bless”. That is why it has the highest sentiment score. While in topic 12, a lot of “hate”, “shit”, and “fuck” appeared in the documents, making the sentiment score really low. This indicates that our topic model really made sense when trying to separate users’ comments based on their sentiment. 

#Managerial Implications 
1. Attract Millennials
Millennials, as the main users of social media, are a demographic that’s rapidly maturing in terms of their economic strength, social influence and political power. However, according to the FICO report, traditional banks are not so attractive to Millennials when compared to non-traditional payments and peer-to-peer lenders. Meanwhile, 43% of Millennials don’t think that their bank communicates to them through their preferred communication channels, like social media and apps [6].  
As a matter of fact, financial agencies should pay more attention to attract their interest. According to our topic model, Topic 19 is the collection of the documents with the hashtag #getcollegeready of Wells Fargo (BankA). This topic ranked 7th in the overall topic proportions, meaning this topic has relatively large influence on the social. Wells Fargo uses this hashtag to promote its private student loan and it indeed builds the close relationship between students and the agency on social network [7]. 

2. Pay attention to customer feedbacks 
In our model, Topic 11 is a collection of documents that contains @BankBhelp (real account @BofA_Help), which is official BofA Twitter reps. Topic 11 ranked 2nd in proportions, meaning that this help account actually did a good job in communication with customers and solve their problems. Indeed, @BofA_Help account has the largest influence in the four banks. It has posted 555k Twitters, following 65.6k people and having 95.2k followers [8]. 

3. Quicker and more efficient replies to customer needs 
Topic 5 is all about banks’ replies to customer feedbacks. After checking the replies, we found that banks usually can’t solve customers’ problems immediately, instead, they told customers to make phone calls to banks or visit local bank stores. Although this kind of communication is great to build a connection with customers, it is not efficient enough to best solve their problems. 

#Summary
This project involves building a text mining topic model STM that can give us 20 trending topics among 220k social media conversations. We checked the most related documents under each topic and figure out the summary to each of it. Meanwhile, we applied a sentiment analysis between different topics to see whether our topic model made sense. In the end, we provided some recommendations for finance agencies to improve customer service with the help of social media. 


#Reference
[1] http://oursocialtimes.com/event/socialmediafinance/
[2] https://twitter.com/search?f=users&q=wells%20fargo
[3] https://www.facebook.com/wellsfargo/info/?tab=page_info
[4] https://www.mindsumo.com/contests/wells-fargo
[5] https://cran.r-project.org/web/packages/stm/vignettes/stmVignette.pdf
[6] http://www.fico.com/millennial-quiz/pdf/fico-millennial-insight-report.pdf
[7] https://welcome.wf.com/getcollegeready/
[8] https://twitter.com/BofA_Help




