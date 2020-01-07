from bs4 import BeautifulSoup as bs
import urllib3
import os
from zipfile import ZipFile

# os.chdir('/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/webcrawler/audiobible')

http = urllib3.PoolManager()
audioLink = 'http://www.earnestlycontendingforthefaith.com/'
booklink='http://www.earnestlycontendingforthefaith.com/ListenToTheKingJamesBible.html#COMPLETE_BOOKS_IN_ZIP_FORMAT'
req = http.request('GET', booklink)
soup = bs(req.data, 'html.parser')
tables=soup.find_all('table')
table5=tables[5]
for a in table5.find_all('a'):
    bookref = a['href']
    books=bookref.split('/')[1]
    savedir = books[0:books.find('.')]    #os.mkdir(books)
    if not os.path.exists(savedir):
        os.mkdir( savedir )
    print books
    audioReq=http.request('GET', audioLink+bookref)
    with open(books, 'wb') as f:
        print f
        f.write(audioReq.data)
    with ZipFile(books, 'r') as zz:
        print zz
        zz.extractall(savedir)

