__author__ = 'dillonflannery-valadez'
import requests
import urllib2 as url2
import os
from bs4 import BeautifulSoup

path = "/Users/dillonflannery-valadez/UCI/Year_1/Fall_yr1"
poiriers_site = 'https://eee.uci.edu/15f/62620'
os.chdir(path)

def get_mp3_hrefs(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    soup = BeautifulSoup(text)
    hreflist = []
    site = "https://eee.uci.edu/15f/62620"
    for link in soup.findAll("a"):
        if link.get("href") != None:
            chapter =  link.get('href')
            if chapter.endswith("pdf"):
                fullUrl = site + "/" + chapter
                hreflist.append(fullUrl)
    return hreflist

def get_mp3_names(hrefs):
    file_names = []
    for ref in hrefs:
        ref = str(ref[65:])
        file_names.append(ref)
    return file_names

hrefs = get_mp3_hrefs(poiriers_site)
file_names = get_mp3_names(hrefs)
print file_names
names_refs = zip(file_names, hrefs)
for n,r in names_refs:
    print n, r
    req = url2.Request(r)
    res = url2.urlopen(req)
    mp3 = open(str(n), "wb")
    mp3.write(res.read())
    mp3.close()

