__author__ = 'dillonflannery-valadez'

import requests
from bs4 import BeautifulSoup
import urllib2 as URL2
import os

path = raw_input("Input path for Interlinear Bible Files: ")
"""
/Users/dillonflannery-valadez/Books/Hebrew Interlinear
"""
url = raw_input("Input URL for download: ")
# url = "http://www.scripture4all.org/OnlineInterlinear/Hebrew_Index.htm"
# url = "http://www.scripture4all.org/OnlineInterlinear/Greek_Index.htm"
os.chdir(path)

"""
You will need to get the hyperrefs and the pdf names to save them in the file.
These two functions accomplish that. They put them in a list.
"""

def get_pdf_hrefs(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    root = "http://www.scripture4all.org/OnlineInterlinear/"
    soup = BeautifulSoup(text)
    url_list = []
    stop = 0
    for link in soup.findAll("a"):
        fullurl = root + link.get("href")
        if fullurl.endswith(".pdf"):
            url_list.append(fullurl)
    return url_list


def get_pdf_names(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    root = "http://www.scripture4all.org/OnlineInterlinear/"
    soup = BeautifulSoup(text)
    names_list = []
    stop = 0
    for link in soup.findAll("a"):
        fullurl = root + link.get("href")
        if fullurl.endswith(".pdf"):
            # Value method returns list, select only element in list and
            # the slice to get only the applicable value for the name.
            names_list.append(link.attrs.values()[0][6:])
    return names_list

"""
Get the file names to save pdfs in an orgainized way and the hrefs for downloading
"""
filenames = get_pdf_names(url)
hrefs = get_pdf_hrefs(url)
filenames_hrefs = zip(filenames, hrefs) # Zipped them together to iter through.

"""
Iterate through the filenames and hrefs downloading one by one
saving into a directory.
"""
run_crawler = raw_input("Run download? Input Y/N. ")
num_files = raw_input("How many files? Input Integer or \'a\' for all in link. ")
x = 0
if run_crawler == "Y":
    x = -1
    for name, ref in filenames_hrefs:
        x += 1
        print ref
        print str(name)
        req = URL2.Request(ref)
        resp = URL2.urlopen(req)
        pdf = open(str(name), "w")
        pdf.write(resp.read())
        pdf.close()
        if num_files == num_files:
            break

