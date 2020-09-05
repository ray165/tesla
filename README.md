# Tesla
Text analysis of r/Investing comments and submissions mentioning Tesla/ Elon Musk from Jan 1, 2020 to Aug 23, 2020 with 17,042 observations.

Data was pulled using PushShift (Python API) and analysis following tidytext principles outlined by Julia Silge and David Robinson. The search criteria was: "Tesla, Elon Musk, and TSLA". 

## Findings 
This project aims to understand what users are saying about Tesla on r/ Investing.

If you have been reading r/Investing's comments and paying attention to Tesla news in 2020, the results agree with most of our impressions on what users are discussing. Through the use of unigram and bigram words, we can see the most commonly used words and phrases. Unsurprisingly, the data table mainly shows two main things: stock related terms like 'market cap' and common knowledge of what Tesla does i.e. they produce 'electric cars' and that they are a 'car company'.

The second most common unigram word is 'dont'. Initially, I assumed users were going to be saying 'dont buy' Tesla, which was a common theme when I was reading r/Investing. Diving a bit further, users actually 'dont understand' Tesla likely due to the mismatch between valuation and market cap.
Using tf-idf, we find the most important words for each month. The result essentially shows the theme or topic of the month.

Lastly, the comparison between sentiment and stock prices shows that users are not following Tesla hype proportionally to share prices rocketing.

## Intial Data Preprocessing 
* Used PowerQuery for some quick fixes to white space for each comment
* Used R to filter stop words, created new date/time columns, removed html tags and all non ASCII words 
* Example: 

```R
rt = rt %>% 
  mutate( date =  (as.POSIXct(rt$created_utc, origin="1970-01-01"))) %>% 
  mutate( year = format(date, "%Y"),
          month = format(date, "%m"),
          month_name = format(date, "%B"),
          day  = format(date, "%d"),
          date_ = format(date, "%Y-%m-%d"))
 ```         

## Unigram and Bigram words
The tidytext package has a neat function called `unnest_tokens()` which quickly strips blocks of text into single words or multi-worded phrases AKA n-gram. 

Unigrams show the most commonly used words. 'Dont' seems to be the most interesting word amongst the list. 
![Unigram Words](https://github.com/ray165/tesla/blob/master/tesla_unigram.png)

Comparing the unigrams to the bigrams, I created a list of the top 15 bigrams. The results are more informative than the unigrams for what the users are talking about. 
![Bigram Words](https://github.com/ray165/tesla/blob/master/tesla_bigram.png)

Since 'dont' seems to be so popular, a list of the top 15 `dont+(word)` pairs is created. 'Dont understand' is the most common phrase in this list. Users seem to be recommending others to not buy or invest in Tesla either. From this, I expect the train of thought is: users don't understand why Tesla prices keep soaring while its fundamentals don't reflect the market cap therefore they recommend others to not invest in the company.
![Dont Phrases](https://github.com/ray165/tesla/blob/master/tesla_dont_words.png?raw=true)

## Term Frequency and Topics Across The Months
The tf-idf shows the top words in a given month that best describe the theme. February seemed to have been more of a r/WallStreetBets theme perhaps users were excited by the options they were trading. From March till May the COVID-19 theme seems to be more prevalent. For instance, May focuses on Tesla's Alameda county factory which was on the news. While March and April mention pharmaceutical companies. In more recent months, Tesla has been compared to Nikola, a competing EV company.
![Plot: tf-idf](https://github.com/ray165/tesla/blob/master/tesla_tf_idf.png)

## Time Series: Sentiment Analysis vs Stock Prices 
User sentiment towards Tesla does not seem to correlate with the large increases in stock prices. I initially thought the sentiment scores would increase as stock prices increases. This doesn't seem to be the case. Perhaps, retail investors aren't powering Tesla's stock rally. ![Plot: Stock Prices vs. Sentiment](https://github.com/ray165/tesla/blob/master/tesla_prices_sentiment.png)



