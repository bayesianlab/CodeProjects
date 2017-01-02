__author__ = 'dillonflannery-valadez'

import urllib
import urllib2
import os


url = "http://www.crummy.com/software/BeautifulSoup/bs4/download/4.0/beautifulsoup4-4.0.0b3.tar.gz"
resp = urllib2.urlopen(url)
urllib.urlretrieve(url, "bs1")
push_return = "Then press RETURN."
print
print
print "INSTRUCTIONS: Do these three steps"
print
print "Click on bs1 in ", os.getcwd() + "/bs1"
print push_return
raw_input()
print
print "1. First read all of these insturctions" \
      "Then follow these steps. " \
      "You will need to change the directory by typing \"cd\" into the command prompt"
print "and typing in the name of the directory of the file you downloaded. It is above you" \
      "printed out."
print push_return
raw_input()
print
print "2. Type \"python setup.py install\" in the command prompt"
print push_return
raw_input()
print "3. Type \"mkdir pdfs\" in the command prompt"
print push_return
raw_input()
print "4. Save the next file in the same directory that you are currently in and type in"
print " \"python pdf_graber.py\" into the command prompt."
print
print









