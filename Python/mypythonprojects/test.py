import os 
import sys
from PyQt4.QtCore import *
from PyQt4.QtGui import*
from bs4 import BeautifulSoup
import string
import csv
import profile
import gc

class BibleStat:
    os.chdir("/Users/dillonflannery-valadez/Coding/PycharmProjects/mypythonprojects/")

    def __init__(self):
        self.soup = BeautifulSoup(open('nt.xml'), 'xml')
        self.punctuation = string.punctuation
        self.punc = ',.;:?!'
        self.bookTitles = self.findOsisIDs()

    def numVersesPerChapter(self, bookName, chapNum):
        chapNum = bookName + '.' + str(chapNum)
        count = 0
        for tag in self.soup.find(osisID=chapNum):
            try:
                if tag.name == 'verse':
                    count += 1
            except AttributeError:
                pass
        return count / 2

    def numChaptersPerBook(self, bookName):
        count = 0
        division = self.soup.find('div', osisID=bookName)
        for tag in division.children:
            try:
                if tag.name == 'chapter':
                    count += 1
            except AttributeError:
                pass
        return count

    def findOsisIDs(self):
        osisIDs = []
        osisIDs.append(self.soup.div.attrs['osisID'])
        gc.disable()
        print self.soup.div.attrs['osisID']
        for tag in self.soup.div.next_siblings:
            try:
                tagAttributes = tag.attrs
                title = tagAttributes['osisID']
                print title
                osisIDs.append(title)
            except AttributeError:
                pass
        osisIDs = map(str, osisIDs)
        gc.enable()
        return osisIDs

    def getChaptersPerBook(self):
        chaptersPerBook = []
        gc.disable()
        for bookTitle in self.bookTitles:
            titleNumChap = (bookTitle, self.numChaptersPerBook(bookTitle))
            print titleNumChap
            chaptersPerBook.append(titleNumChap)
        gc.enable()
        return chaptersPerBook

    def createVersePerChapterCSV(self, title, versesPerChapter):
        filename = str(title)
        print filename
        with open(filename, 'w') as csvfile:
            writer = csv.writer(csvfile, delimiter=',')
            for i in versesPerChapter:
                writer.writerow(i)

    def createNumChapCSV(self):
        self.chapPerBook = self.getChaptersPerBook()
        with open('bibleChapPerBook', 'w') as csvfile:
            writer = csv.writer(csvfile, delimiter=',')
            for i in self.chapPerBook:
                writer.writerow(i)


    def getVersesPerChapter(self):
        for book in self.chapPerBook:
            versesPerChapter = []
            title = book[0]
            numChaps = book[1]
            count = 0
            for chap in range(1, numChaps + 1):
                count += 1
                verses = self.numVersesPerChapter(title, chap)
                chapterNumber = (title + '.' + str(count))
                chapVerses = (chapterNumber, verses)
                print chapVerses
                versesPerChapter.append( chapVerses )
            self.createCSV(title, versesPerChapter)


class RenderText(BibleStat):

    def isTag(self, check):
        if '<' in check:
            return True
        else:
            return False

    def notBlankIsTagIsWOrSupplied(self, tag, check):
        if self.isNotBlank(check):
            if self.isTag(check):
                if tag.name != 'note':
                    return True
        else:
            return False

    def isNotBlank(self, check):
        if check != '':
            return True
        else:
            return False

    def isPunctuationAndVerseNonempty(self, check):
        if check in self.punc:
            return True
        else:
            return False

    def isWordOutsideTag(self, check):
        if not self.isTag(check):
            for letter in string.letters:
                if letter in check:
                    return True
            else:
                return False
        else:
            return False

    def tagIsWOrSupplied(self, tag):
        if (tag.name == 'w' or tag.name == 'transChange'):
            return True
        else:
            return False

    def firstElementPunctuation(self, check):
        if check[0] in self.punc:
            return True
        else:
            return False

    def getVerse(self, chapVerse):
        verseTag = self.soup.find(osisID=chapVerse)
        displayVerse = ''
        for tag in verseTag.next_siblings:
            check = str(tag).strip()
            if self.notBlankIsTagIsWOrSupplied(tag, check):
                tempDict = tag.attrs
                try:
                    if tempDict['eID'] == chapVerse:
                        return displayVerse
                except:
                    KeyError
                displayVerse += tag.get_text() + ' '
            elif self.isWordOutsideTag(check):
                if self.firstElementPunctuation(check):
                    displayVerse = displayVerse.strip()
                    displayVerse += check + ' '
                else:
                    displayVerse += check + ' '
            elif self.isPunctuationAndVerseNonempty(check):
                displayVerse = displayVerse.strip()
                displayVerse += check + ' '
        return displayVerse

    def getChapter(self, chapName, num):
        searchStr = chapName + '.' + str(num)
        chap = self.soup.find(osisID=searchStr)
        displayVerse = ''
        verseCount = 0
        for tag in chap.children:
            check = str(tag).strip()
            if self.isNotBlank(check):
                try:
                    tempDict = tag.attrs
                    if self.tagIsWOrSupplied(tag):
                        displayVerse += tag.get_text() + ' '
                    if tempDict['sID']:
                        verseCount += 1
                        displayVerse += str(verseCount) + ' '
                except:
                    AttributeError
                if self.isWordOutsideTag(check):
                    if self.firstElementPunctuation(check):
                        displayVerse = displayVerse.strip()
                        displayVerse += check + ' '
                    else:
                        displayVerse += check + ' '
                elif self.isPunctuationAndVerseNonempty(check):
                    displayVerse = displayVerse.strip()
                    displayVerse += check + ' '
        return str(displayVerse)




# x = BibleStat()
# x.createNumChapCSV()
# for t in x.soup.div.next_siblings:
#     try:
#         print t.attrs
#     except AttributeError:
#         pass
# profile.run("x.numVersesPerChapter('Gen', 1)")
# print x.numVersesPerChapter('Gen', 1)
# print x.bookTitles
# print x.getChaptersPerBook()
# vpc =  x.getVersesPerChapter()



class MainWindow(QMainWindow, RenderText):

    nextId = 1
    geoms = [50,50]
    instances = set()

    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)
        soupText = RenderText()
        MainWindow.instances.add(self)
        self.setGeometry(50, 50, 800, 500) 
        self.setWindowTitle("BibleApp")
        self.editor = QTextEdit()
        self.editor.setReadOnly(True)
        self.editor.setText(str(soupText.soup))
        self.setCentralWidget(self.editor)
        self.loadFileMenuActions()
        mm = self.menuBar()
        fileMenu = mm.addMenu("&File")
        fileMenu.addAction(self.addNewAct)
        fileMenu.addAction(self.endAct)

        self.statusBar()

    def addEndSessionAction(self):
        self.endAct = QAction("&End Session", self)
        self.endAct.setShortcut("Ctrl+Q")
        self.endAct.setStatusTip("Ends Current Session")
        self.connect(self.endAct, SIGNAL("triggered()"), self, SLOT("close()"))
    
    def addNewWindowAction(self):
        self.addNewAct = QAction("New", self)
        self.addNewAct.triggered.connect(self.addNewSubWin)

    def loadFileMenuActions(self):
        self.addNewWindowAction()
        self.addEndSessionAction()
        
    def updateGeoms(self):
        self.geoms[0] += 25
        self.geoms[1] += 25

    def addNewSubWin(self):
        print("triggered")
        newWin = MainWindow()
        newWin.updateGeoms()
        newWin.setGeometry(newWin.geoms[0], newWin.geoms[1], 800, 500)
        newWin.show()


def runGUI():
     app = QApplication(sys.argv)
     app.setApplicationName("Bible Search App")
     mw = MainWindow()
     mw.show()
     sys.exit(app.exec_())

runGUI()
