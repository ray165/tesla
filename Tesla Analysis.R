library(tidyverse)
library(readxl)
library(tm)
library(textclean)
library(tidytext)
library(lubridate)
library(forcats)
library(widyr)
library(sentimentr)
library(quantmod)
library(gridExtra)

setwd("~/Kaggle Competitions/Automating Boring Stuff")
rt <- read_excel("reddit_tesla4pq.xlsx", sheet = "tesla_r")


#Data pre processing#############################
# Remove all non ASCII words
rt$body = iconv(rt$body, "latin1", "ASCII", sub = "")
# Remove all html tags e.g. &gt and extra white space
rt$body = rt$body %>% 
  replace_html(., FALSE) %>%
  str_replace_all("[[:punct:]]", "") %>%
  replace_white()

# put the text into a tibble, create a column 'row' to track where it originally
  #came from in rt$body
# Remove stop Words
data("stop_words")



redundant = c("elon", "musk", "tesla", "tsla", "cock", "remindditbot", "ia", "ias",
              "71157", "sgmo")


# Mutate new time columns (Year, Month, Day) and day of week

rt = rt %>% 
  mutate( date =  (as.POSIXct(rt$created_utc, origin="1970-01-01"))) %>% 
  mutate( year = format(date, "%Y"),
          month = format(date, "%m"),
          month_name = format(date, "%B"),
          day  = format(date, "%d"),
          date_ = format(date, "%Y-%m-%d"))

#########################
#########################

# Mono and bigram code ------
tidy_df = tibble(row = 1:length(rt$body), text = rt$body) 

tesla_monogram = tidy_df %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words)

#tokenize the words, auto remove punctuations
# Current error  Line 1:  'Promised:to" --> "Promisedto" not sure how to remove punct and 
# conditionally place a space depending on the word. E.g. I'm doesnt need a space




tidy_df %>%
  count(word, sort = TRUE)


tesla_bigram  = tidy_df %>%
  unnest_tokens(bigram, text, token ="ngrams", n=2) %>%
  count(bigram, sort = TRUE)

# Remove stop words from bigram via word1 word2 comparison

bigrams_separated = tesla_bigram %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered = bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word1 %in% redundant) %>%
  filter(!word2 %in% redundant)

#new bigram counts
bigram_counts = bigrams_filtered %>%
  count(word1, word2, sort = TRUE)

bigram_counts


bigram_month = bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ") %>% 
  inner_join(rt)


#trigram

trigram = tidy_df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !word3 %in% stop_words$word) %>%
  filter(!word1 %in% redundant,
         !word2 %in% redundant,
         !word3 %in% redundant) %>% 
  filter(!is.na(word1),
         !is.na(word2),
         !is.na(word3)) %>%
  count(word1, word2, word3, sort = TRUE)










# Remake dataframe ------------------------
tesla_tidy = rt %>%
  unnest_tokens(word, body) %>%
  filter(!word %in% redundant) %>% 
  anti_join(stop_words)

# grouped by month
# specifying levels and turning month_name into a factor reorders the months
g_month = tesla_tidy %>%
  count(month_name, word, sort = TRUE) %>%
  mutate(word = fct_reorder(word, n)) %>%
  mutate(month_name = factor(month_name, levels = c("January", "February", "March",
                                                    "April", "May", "June",
                                                    "July", "August", "September",
                                                    "October", "November", "December"))) %>%
  bind_tf_idf(word, month_name, n)


g_month %>%
  arrange(desc(n)) %>%
  mutate(word = factor(word, levels = rev(unique(word)))) %>% 
  group_by(month_name) %>% 
  top_n(5) %>% 
  ungroup() %>%
  ggplot(aes(word, n, fill = month_name)) +
  geom_col(show.legend = FALSE) +
  labs(x = NULL, y = "tf-idf") +
  facet_wrap(~month_name, ncol = 2, scales = "free") +
  coord_flip()


# Pair wise with 'dont' ----------


bigram_tidy = rt %>%
  unnest_tokens(bigram, body, token ="ngrams", n=2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  filter(!word1 %in% redundant) %>%
  filter(!word2 %in% redundant) %>%
  filter(word1 == "dont") %>%
  count(word1, word2, sort = TRUE) %>%
  top_n(15)

bigram_tidy
# Remove stop words from bigram via word1 word2 comparison

# Time series Sentiment -------

sentiment_df = with(rt, sentiment_by(body, list(date_) )) %>%
  arrange(date_) %>%
  mutate(rn = row_number() )

# Geom smooth helps aid the eye of the patterns in the chart. Accordingly,  the blue line shows that the daily sentiment typically hovers around 0.1. Although there are extremes that deviate from 0.1, there doesnt seem to be much change since January despite stock prices going up and up. 
plot_senti = sentiment_df %>% 
  ggplot(aes(x = as.Date(date_), y = ave_sentiment, group = 1)) +
  geom_line() +
  geom_smooth() +
  labs( x = "Day", y = "Daily Sentiment", 
        title = "Time Series: r/Investing's Sentiment Towards Tesla",
        subtitle =  "Jan 1, 2020 - Aug 23, 2020")

# Quantmod Tesla Prices ----------------------------------------
## Adjusted prices after stock split

qm_tsla = getSymbols("TSLA", src = "yahoo", from = "2020-01-01", to = "2020-08-23", auto.assign =  FALSE)

plot_prices = ggplot(data = qm_tsla, 
                     aes( x = Index, y = TSLA.Adjusted)) +
  geom_line( size = 1) +
  geom_smooth() + 
  labs( x = "Day", y = "Price (USD)",
        title = "Tesla Adjusted Closing Prices",
        subtitle = "Jan 1, 2020 - Aug 23, 2020 (After Stock Split)")

grid.arrange(plot_prices, plot_senti, nrow = 2)


# Citation ------------
# This dataset was published in Saif M. Mohammad and Peter Turney. (2013), ``Crowdsourcing a Word-Emotion Association Lexicon.'' Computational Intelligence, 29(3): 436-465.
