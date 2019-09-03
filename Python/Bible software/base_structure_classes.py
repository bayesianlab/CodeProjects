__author__ = 'dillonflannery-valadez'

from bs4 import BeautifulSoup
import string
import os

workingD = "/Users/dillonflannery-valadez/Google Drive/PycharmProjects/Bible software/bibles/kjvxml"
os.chdir(workingD)
soup = BeautifulSoup(open('testXml.xml'), "xml")
x = 0
naviStr = soup.find('w').next_element
NAVIGABLE_STRING = type(naviStr)


class Display1Verse():

    def cutWhiteSpace(self, input):
        index = -1
        while index < len(input)-1:
            index += 1
            try:
                if input[index] == ' ':
                    input = input[:index] + input[index + 1:]
                    index -= 1
            except:
                IndexError
                break
        return input

    def insertPeriod(self, input):
        index = -1
        for i in input:
            index += 1
            if i in string.digits:
                input = input[:index] + "." + input[index:]
                break
        return input

    def replaceColon(self, input):
        input = input.replace(':', '.')
        return input

    def frmtInput(self, input):
        """
        So searches dont break. sID in the attributes of the tag 'verse'
        must match the user input, so it is difficult to make a function that will
        not break with unforeseen character inputs and extra whitespace.

        The function needs to remove all white space and replace it with only one period,
        the colons need to be replaced with a period as well.
        :param input:
        :return:
        """
        input = self.replaceColon(self.insertPeriod(self.cutWhiteSpace(input)))
        return input

    def removePuncWhiteSpaces(self, verseToDisplay, currElem):
        if str(currElem).replace(' ', '') in string.punctuation:
            verseToDisplay += str(currElem).replace(' ', '')
        return verseToDisplay

    def getVerseText(self, input):
        input = self.frmtInput(input)
        currElem = soup.find(sID = str(input))
        verseToDisplay = ""
        index = -1
        while True:
            index += 1
            currElem = currElem.next_sibling
            if str(currElem).replace(' ', '') in string.punctuation:
                verseToDisplay += str(currElem).replace(' ', '')
                currElem = currElem.next_sibling
            try:
                if index == 0:
                    verseToDisplay += currElem.get_text()
                else:
                    verseToDisplay += ' ' + currElem.get_text()
            except:
                AttributeError
            try:
                if currElem['eID'] == str(input):
                    verseToDisplay = verseToDisplay.rstrip()
                    break
            except:
                AttributeError
        return verseToDisplay

class Display1Chapter(Display1Verse):

    def getVerseText2(self, verse):
        v_sID = str(verse['sID'])
        verseToDisplay = ''
        index = -1
        while True:
            index += 1
            verse = verse.next_sibling
            # print currElem
            if str(verse).replace(' ', '') in string.punctuation:
                verseToDisplay += str(verse).replace(' ', '')
                verse = verse.next_sibling
            try:
                if index == 0:
                    verseToDisplay+= verse.get_text()
                else:
                    verseToDisplay += ' ' + verse.get_text()
            except:
                AttributeError
            try:
                if verse['eID'] == v_sID:
                    verseToDisplay = verseToDisplay.rstrip()
                    break
            except:
                AttributeError
        return verseToDisplay

    def book_chapter_search(self,  query):
        query = self.frmtInput(query)
        chap = soup.find(osisID = query)
        chapterToDisplay = ''
        count = 0
        for v in chap.findAll('verse'):
            count += 1
            if count%2 != 0:
                chapterToDisplay += self.getVerseText2(v)
        return chapterToDisplay

class DisplayStrongsRefs():
    pass










