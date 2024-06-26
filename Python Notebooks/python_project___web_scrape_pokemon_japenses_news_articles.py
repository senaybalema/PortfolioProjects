# -*- coding: utf-8 -*-
"""Python Project | Web SCRAPE POKEMON JAPENSES NEWS Articles

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1fLfTxgrv0TMfpNJ4v4oVrvMJa2bQnC59
"""

#pip install setuptools==58

#!pip install pygooglenews

#pip install feedparser --force

#pip install beautifulsoup4 --force

#pip install  dateparse --force

#pip install requests --force

from pygooglenews import GoogleNews
import pandas as pd

#create the google news API from Japan and UK
#gn = GoogleNews(lang='en',country='UK')
gn = GoogleNews(lang='jp',country='JP')

#lets create search for UK and Japan for the word games
# Google translate games from enligh to japense gives ゲーム
#search = gn.search('Games')
search = gn.search('ゲーム')

#lets look at the entries
for i in search['entries']:
  print(i)

#lets loop through the actual titles
articles = search['entries']
for i in articles:
  print(i.title)

#lets create a function that will allows us to enter any keyword we want to search
def get_titles(search):
  gn = GoogleNews(lang='jp',country='JP')
  search = gn.search(search)
  articles = search['entries']
  for i in articles:
    print(i.title )
  return

#lets try to search casino in japense which is カジノ

get_titles('カジノ')

#lets create a dictionary so that we can get the date of publish , link and title

def get_titles(keyword):
  news=[]
  gn = GoogleNews(lang='jp',country='JP')
  search = gn.search(keyword)
  articles = search['entries']
  for i in articles:
    article = {'title': i.title, 'link': i.link, 'published': i.published}
    news.append(article)
  return news

#lets test our get_titles function with the search word pokemon in japanese  which is ポケットモン or ポケットモンスター



data = get_titles('ポケットモン')

data

#lets save a datframe so that we can start translating what we have
df = pd.DataFrame(data)
df.head()

#here is textblob our natural language processing library
from textblob import TextBlob

#we feed the function the term that we are interested in , here we enter the japenese word for pokemon ポケットモン
blob = TextBlob('ポケットモン')

# we use translate to with a from language to language, in our case, from japense to english

blob.translate(from_lang='ja', to='en')

#lets create a function that bring back sentiment and translation

def translation(text):
  blob = TextBlob(text)
  return str(blob.translate(from_lang='ja', to='en'))


def sentiment(text):
  blob = TextBlob(text)
  return blob.sentiment.polarity

#we feed the functions the term that we are interested in , here we enter the japenese word for pokemon ポケットモン

translation('ポケットモン')

sentiment('ポケットモン')

# lets try with the word game in japonese from earlier ゲーム
translation('ゲーム')

#lets apply our 2 function that bring back sentiment and translation for our dataframe, where we create 2 new columns of translation and sentiment
def translation(text):
  blob = TextBlob(text)
  return str(blob.translate(from_lang='ja', to='en'))


def sentiment(text):
  blob = TextBlob(text)
  return blob.sentiment.polarity

# we use df['title] and apply the translation function to create the translation column folr our dataframe
#we then use our new translation column and apply our sentiment function to create the a sentiment column to our dataframe


df['translation'] = df['title'].apply(translation)
df['sentiment'] = df['translation'].apply(sentiment)

df.head()

#lets create an actual class to our sentiment column to indicate if sentiment is positive, negative, neutral  and store that in a new column, sentiment class


import numpy as np

df['sentiment Class'] = np.where(df['sentiment']<0, "negative",
                                 np.where(df['sentiment']>0 , 'positive', 'neutral'))

df.head()

#export our dataframe to excel
#then from google colab download it
df.to_excel('web_scrape_output_file.xlsx')
from google.colab import files
files.download('web_scrape_output_file.xlsx')

