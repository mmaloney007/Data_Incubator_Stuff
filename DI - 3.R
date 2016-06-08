

devtools::install_github("Rexamine/stringi")
devtools::install_github("hadley/stringr")

#connect all libraries
library(twitteR)
library(ROAuth)
library(plyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(Hmisc)

download.file(url='http://curl.haxx.se/ca/cacert.pem&#8221', destfile='cacert.pem')

requestURL <- ???https://api.twitter.com/oauth/request_token&#8221;       
  
  # Set constant access URL
  accessURL = ???https://api.twitter.com/oauth/access_token&#8221;
  
  # Set constant auth URL
  authURL = ???https://api.twitter.com/oauth/authorize&#8221;
  
  require(twitteR)
require(plyr)

consumerKey <- '9bNPhVXJcGlUXT3xmecuJkqNl' #put the Consumer Key from Twitter Application
consumerSecret <- 'ttI2Q2eEkRrZX9sAlCHvmFSCtsKqYRusbWtBcvNCEamkJ3abAY'  #put the Consumer Secret from Twitter Application
oauth_token            <- '36936178-HgzlCRl0G6W8GqHylgc4s9THly55TzNoj42bV4N2x'
oauth_token_secret     = 'tzzNeqp7PUSZfW6MweRDCYBzxqzWLD8SVTmOanXEECD4s'

setup_twitter_oauth(consumerKey, consumerSecret, oauth_token, oauth_token_secret)

searchResults <- searchTwitter("#LibertyMutual", n=15000, since = as.character(Sys.Date()-1), until = as.character(Sys.Date()))
head(searchResults)

#the function of tweets accessing and analyzing

  #access tweets and create cumulative file
  #  list <- searchTwitter("#LibertyMutual", cainfo='cacert.pem', n=1500)
  list <- searchTwitter("#LibertyMutual", n=1500)
  #  list <- searchTwitter("#LibertyMutual", n=15000)
  df <- twListToDF(list)
  df <- df[, order(names(df))]
  df$created <- strftime(df$created, '%Y-%m-%d')
  #  str(df)
  if (file.exists('#LibertyMutual_stack_val.csv')==FALSE) write.csv(df, file='#LibertyMutual_stack_val.csv', row.names=F)
  #merge last access with cumulative file and remove duplicates
  stack <- read.csv('#LibertyMutual_stack_val.csv')
  stack <- rbind(stack, df)
  stack <- subset(stack, !duplicated(stack$text))
  write.csv(stack, file='#LibertyMutual_stack_val.csv', row.names=F)
  #evaluation tweets function
  valence <- read.csv('dictionary.csv', sep=',' , header=TRUE) #load dictionary from .csv file
  require(plyr)
  require(stringr)
  ### HERE
  score.sentiment <- function(sentences, valence, .progress='none')
  {
    
    scores <- laply(sentences, function(sentence, valence){
      sentence <- gsub('[[:punct:]]', '', sentence) #cleaning tweets
      sentence <- gsub('[[:cntrl:]]', '', sentence) #cleaning tweets
      sentence <- gsub("[^[:alnum:]///' ]", "", sentence) #cleaning tweets
      ###gsub("[^[:alnum:]///' ]", "", x)
      sentence <- gsub('\\d+', '', sentence) #cleaning tweets
      sentence <- tolower(sentence) #cleaning tweets
      word.list <- str_split(sentence, '\\s+') #separating words
      words <- unlist(word.list)
      val.matches <- match(words, valence$Word) #find words from tweet in "Word" column of dictionary
      val.match <- valence$Rating[val.matches] #evaluating words which were found (suppose rating is in "Rating" column of dictionary).
      val.match <- na.omit(val.match)
      val.match <- as.numeric(val.match)
      score <- sum(val.match)/length(val.match) #rating of tweet (average value of evaluated words)
      return(score)
    }, valence, .progress=.progress)
    scores.df <- data.frame(score=scores, text=sentences) #save results to the data frame
    return(scores.df)
  }
  #  valence <- read.csv('dictionary.csv', sep=',' , header=TRUE) #load dictionary from .csv file
  Dataset <- stack
  Dataset$text <- as.factor(Dataset$text)
  scores <- score.sentiment(Dataset$text, valence, .progress='text') #start score function
  write.csv(scores, file='#LibertyMutual_scores_val.csv', row.names=TRUE) #save evaluation results into the file
  #modify evaluation
  stat <- scores
  stat$created <- stack$created
  stat$created <- as.Date(stat$created)
  stat <- na.omit(stat) #delete unvalued tweets
  write.csv(stat, file='#LibertyMutual_opin_val.csv', row.names=TRUE)
  #create chart
  ggplot(stat, aes(created, score)) + geom_point(size=1) +
    stat_summary(fun.data = 'mean_cl_normal', mult = 1, geom = 'smooth') +
    ggtitle("#LibertyMutual")
  ggsave(file='#LibertyMutual_plot_val.jpeg')

library(RXKCD)
library(tm)
library(wordcloud)
library(RColorBrewer)

library("tm")
library("SnowballC")
posts<- read.csv("#LibertyMutual_opin_val.csv", header = TRUE,  fileEncoding="latin1")
corpus <- Corpus(VectorSource(posts$text)) # create corpus object
corpus <- tm_map(corpus, content_transformer(tolower)) # convert all text to lower case
#txt.corpus <- tm_map(txt.corpus, content_transformer(tolower))
corpus <- tm_map(corpus, mc.cores=1, removePunctuation)
corpus <- tm_map(corpus, removeNumbers, mc.cores=1)
corpus <- tm_map(corpus, removeWords, stopwords("english"), mc.cores=1)

tdm <- TermDocumentMatrix(corpus)
#tdm <- TermDocumentMatrix(corpus, control = list(weighting = weightTfIdf))

mydata.df <- as.data.frame(inspect(tdm))
count<- as.data.frame(rowSums(mydata.df))
count$word = rownames(count)
colnames(count) <- c("count","word" )
count<-count[order(count$count, decreasing=TRUE), ]

count$count

wordcloud(count$word,count$count,c(8,.5),2,,FALSE,.1)

wordcloud(count$word,count$count, scale=c(8,.3),min.freq=2,max.words=50, random.order=T, rot.per=.15, colors=pal, vfont=c("sans serif","plain"))

write.csv(count, file='#LibertyMutual_count.csv', row.names=TRUE)

