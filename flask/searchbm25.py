#!/usr/bin/env python
# coding: utf-8

# In[5]:


import numpy as numpy
import pandas as pd
import json
from rank_bm25 import BM25Okapi
import nltk
from nltk.tokenize import word_tokenize


# In[6]:


df = pd.read_csv('../scrape/supermarkets.csv')
df


# In[7]:


items = df['name'].astype(str).tolist()
items


# In[8]:


nltk.download("punkt")

# Tokenize documents
tokenized_corpus = [word_tokenize(doc.lower()) for doc in items]

# Initialize BM25
bm25 = BM25Okapi(tokenized_corpus)


# In[11]:


def search(query):
    top_n = 5
    tokenized_query = word_tokenize(query.lower())
    scores = bm25.get_scores(tokenized_query)
    top_indices = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)[:top_n]
    results = [
        {"rank": rank + 1, "text": items[idx]}
        for rank, idx in enumerate(top_indices)
    ]
    return results


# In[12]:


search('white bread')

