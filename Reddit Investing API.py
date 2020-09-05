import requests

query = "Tesla"
url = "https://api.pushshift.io/reddit/comment/search?html_decode=true&subreddit=investing&q=Tesla&size=10000"

from psaw import PushshiftAPI

api = PushshiftAPI()

import pandas as pd
import datetime as dt

start_epoch = int(dt.datetime(2020, 1,1).timestamp())



#########################################

gen = api.search_comments(q='Tesla|tesla|Elon|elon|Musk|musk|TSLA|tsla',
                          subreddit='investing',
                          after = start_epoch,
                          )

#unspecified limit leads to output in csv

max_response_cache = 1
cache = []

for c in gen:
    cache.append(c)
    # Omit this test to actually return all results. Wouldn't recommend it though: could take a while, but you do you.
    if len(cache) >= max_response_cache:
        break


df = pd.DataFrame([thing.d_ for thing in gen])

df.to_csv('reddit_tesla4.csv')
