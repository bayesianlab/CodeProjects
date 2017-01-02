__author__ = 'dillonflannery-valadez'


import requests
from bs4 import BeautifulSoup
import urllib2 as URL2
import os
import string

dirname = "Interlinear_Bible_pdfs"
new_direct = os.mkdir("Interlinear_Bible_pdfs")
print
print "Your files are stored in directory:", os.getcwd() + "/" + dirname

# url = "http://www.scripture4all.org/OnlineInterlinear/Hebrew_Index.htm"
url = "http://www.scripture4all.org/OnlineInterlinear/Greek_Index.htm"

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

def get_specific_pdfs(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    root = "http://www.scripture4all.org/OnlineInterlinear/"
    soup = BeautifulSoup(text)
    names_list = []
    stop = 0
    for i in soup.findAll("a"):
        stop += 1
        if str((i.get("href"))) == "OTpdf/hos1.pdf":
            return stop
    else:
        return "No match"

# Download stopped at hosea, needed to find what item of the list that was in the
# list of anchors.

def restart_download_names(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    root = "http://www.scripture4all.org/OnlineInterlinear/"
    soup = BeautifulSoup(text)
    names_list = []
    stop = 0
    for link in soup.findAll("a")[873:]:
        fullurl = root + link.get("href")
        if fullurl.endswith(".pdf"):
            # Value method returns list, select only element in list and
            # the slice to get only the applicable value for the name.
            names_list.append(link.attrs.values()[0][6:])
    return names_list

def restart_download_hrefs(site_name):
    url = site_name
    website = requests.get(url)
    text = website.text
    root = "http://www.scripture4all.org/OnlineInterlinear/"
    soup = BeautifulSoup(text)
    url_list = []
    stop = 0
    for link in soup.findAll("a")[873:]:
        fullurl = root + link.get("href")
        if fullurl.endswith(".pdf"):
            url_list.append(fullurl)
    return url_list

def make_soup(filename):
    text = open(filename)
    soup = BeautifulSoup(text)
    return soup


def make_xml(url, filename, path):
    """
    Input a url and the a name you would like to call your file. The url
    will be created into a xml file. Path is the directory to save the file.
    :param url:
    :param filename:
    :return: path of new file
    """
    sitereq = requests.get(url)
    text = sitereq.text
    myfile = open(filename, "w")
    myfile.write(text)
    myfile.close()
    return os.path.realpath(path + filename)



# Get the file names to save pdfs in an orgainized way and the hrefs for downloading
filenames = get_pdf_names(url)
hrefs = get_pdf_hrefs(url)
filenames_hrefs = zip(filenames, hrefs)

# Iterate through the filenames and hrefs downloading one by one
# saving into a directory.
for name, ref in filenames_hrefs:
    print ref
    req = URL2.Request(ref)
    resp = URL2.urlopen(req)
    pdf = open(dirname + "/" + name, "w")
    pdf.write(resp.read())
    pdf.close()


