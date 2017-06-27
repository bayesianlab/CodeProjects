from bs4 import BeautifulSoup as bs
import urllib3
import os

# os.chdir('/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/webcrawler/audiobible')

j=0
http = urllib3.PoolManager()
site = 'http://www.earnestlycontendingforthefaith.com/ListenToTheKingJamesBible.html'
audioLink = 'http://www.earnestlycontendingforthefaith.com/'
req = http.request('GET', site)
soup = bs(req.data, 'html.parser')
anchorTags = soup.find_all('a')
for link in anchorTags:
    linkhref = link['href']
    if linkhref.find('.mp3') != -1:
        nameStart = linkhref.find('/')
        j += 1
        numZeros = 4 - len(str(j))
        filename = numZeros*'0' + str(j) + ' - ' + linkhref[nameStart + 1:]
        print(site + linkhref)
        print(filename)
        audioReq = http.request('GET', audioLink + linkhref)
        with open(filename, 'wb') as file:
            file.write(audioReq.data)

