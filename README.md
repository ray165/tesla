# Tesla
Text analysis of r/Investing comments and submissions mentioning Tesla/ Elon Musk from Jan 1, 2020 to Aug 23, 2020 with 17,042 observations.

Data was pulled using PushShift (Python API) and analysis following tidytext principles outlined by Julia Silge and David Robinson. The search criteria was: "Tesla, Elon Musk, and TSLA". 

## Findings 
If you have been reading r/Investing's comments and paying attention to Tesla news in 2020, the results agree with most of our impression on what users are discussing. Through the use of unigram and bigram words, we can see the most commonly used words and phrases. Unsurpringly, the data table mainly shows two main things: stock related terms like 'market cap' and common knowledge of what Tesla does i.e. they produce 'electric cars' and that they are a 'car company'. 

The second most common unigram word is 'dont'. Intially, I assumed users were going to be saying 'dont buy' Tesla, which was a common theme when I was reading r/Investing. Diving a bit further, users actually 'dont understand' Tesla likely due to the mismatch between valuation and market cap. 




## Intial Data Preprocessing 



![Unigram Words](https://github.com/ray165/tesla/blob/master/tesla_unigram.png)

![Bigram Words](https://github.com/ray165/tesla/blob/master/tesla_bigram.png)

![Dont Phrases](https://github.com/ray165/tesla/blob/master/tesla_dont_words.png?raw=true)

![Plot: tf-idf](https://github.com/ray165/tesla/blob/master/tesla_tf_idf.png)

![Plot: Stock Prices vs. Sentiment](https://github.com/ray165/tesla/blob/master/tesla_prices_sentiment.png)


