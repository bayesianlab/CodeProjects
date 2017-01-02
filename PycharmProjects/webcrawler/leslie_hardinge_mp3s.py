__author__ = 'dillonflannery-valadez'
__author__ = 'dillonflannery-valadez'

import requests
from bs4 import BeautifulSoup
import urllib2 as URL2
from urllib import FancyURLopener
import os

site = "http://www.maranathamedia.com"
path = "/Users/dillonflannery-valadez/Media/Hardinge"
os.chdir(path)

def get_mp3_hrefs(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    soup = BeautifulSoup(text)
    hreflist = []
    print soup
    for link in soup.findAll("a"):
        print link
        section =  link.get('href')
        print section
    # return hreflist
get_mp3_hrefs(site)
# def get_mp3_names(hrefs):
#     file_names = []
#     for ref in hrefs:
#         ref = str(ref[66:])
#         file_names.append(ref)
#     return file_names
#
#
# hrefs = get_mp3_hrefs(site)
# file_names = get_mp3_names(hrefs)
# print file_names
# names_refs = zip(file_names, hrefs)
# for n,r in names_refs:
#     print n, r
#     req = URL2.Request(r)
#     res = URL2.urlopen(req)
#     mp3 = open(str(n), "wb")
#     mp3.write(res.read())
#     mp3.close()