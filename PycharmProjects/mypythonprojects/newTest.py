import sqlite3
import os
import sys
from bs4 import BeautifulSoup
from bs4 import NavigableString
import string

filename = 'ot.xml'
path ='/Users/dillonflannery-valadez/Coding/PycharmProjects/mypythonprojects/'

punctuation = ',.;:?!'


class CreateMyDatabase:

    def __init__(self, name):
        print 'Opening connection to database'
        self.con = sqlite3.connect(name + '.sqlite')
        with self.con:
            print 'Successfully opened connection'
            self.csr = self.con.cursor()
            self.tableName = 'Bible'
            self.field1 = 'Book'
            self.type1 = 'TEXT NOT NULL'
            self.field2 = 'Chapter'
            self.type2 = 'INTEGER NOT NULL'
            self.field3 = 'Verse'
            self.type3 = 'INTEGER NOT NULL'
            self.field4 = 'Markup'
            self.type4 = 'TEXT'
            self.field5 = 'Strongs'
            self.type5 = 'INTEGER'
            self.field6 = 'Text'
            self.type6 = 'TEXT NOT NULL'
            self.csr.execute("DROP TABLE IF EXISTS Bible")
            self.csr.execute('CREATE VIRTUAL TABLE {tn} USING fts3({f1} {t1}, {f2} {t2}, {f3} {t3}, '
                        '{f4} {t4}, {f5} {t5}, {f6} {t6})'.format(tn=self.tableName,
                                                                  f1=self.field1, t1=self.type1,
                                                                  f2=self.field2, t2=self.type2,
                                                                  f3=self.field3, t3=self.type3,
                                                                  f4=self.field4, t4=self.type4,
                                                                  f5=self.field5, t5=self.type5,
                                                                  f6=self.field6,t6=self.type6))

class BreakdownVerse:

    def __init__(self, filename):
        self.punctuation = ',.;:?!'
        print 'Opening file %s' % filename
        self.soup = BeautifulSoup(open(filename), 'xml')
        self.goodTags = ['w', 'transChange']

    def isAcceptableTag(self, tagName):
        if tagName in self.goodTags:
            return True
        else:
            return False

    def isBlank(self, tagText):
        if tagText == '':
            return True
        else:
            return False

    def getChapter(self, chapVerse):
        verse = []
        vTag = self.soup.find(osisID=chapVerse)
        for tag in vTag.next_siblings:
            tagText = str(tag).strip()
            if self.isBlank(tagText):
                continue
            else:
                try:
                    if self.isAcceptableTag(tag.name):
                            verse.append(str(tag.text + ' '))
                except:
                    verse[-1] = verse[-1].strip()
                    verse.append(tagText + ' ')
                    AttributeError
        return ''.join(verse)

    def isVerse(self,tag):
        if tag.name == 'verse':

            return True
        else:
            return False

    def isStrongsNumber(self, char):
        if char == ' ':
            return ' '
        elif char == 'H' or char in string.digits:
            return str(char)
        else:
            return ''

    def isPunctuation(self, canidatePunc):
        if len(canidatePunc) == 1 and canidatePunc in string.punctuation:
            return True
        else:
            return False

    def strongNumberFinder(self, varchar):
        strongsNumbers = [self.isStrongsNumber(c) for c in varchar]
        counter = -1
        for i in strongsNumbers:
            counter += 1
            if i == '0' and strongsNumbers[counter-1] == 'H':
                del strongsNumbers[counter]
        return ''.join(strongsNumbers)

    def isTag(self, check):
        if '<' in check:
            return True
        else:
            return False

    def isWordOutsideTag(self, tag):
        if not self.isTag(tag):
            for letter in string.letters + string.punctuation:
                if letter in tag:
                    return True
            else:
                return False
        else:
            return False

    def removeProblemHyphens(self, aTagsText):
        newWord = ''
        for i in aTagsText:
            if i == u'\u2013' or i == u'\u2015':
                newWord += '-'
            else:
                newWord += str(i)
        return newWord

    def capitalizeGodAndLord(self, godLordText):
        if godLordText == 'God' or godLordText == 'Lord':
            return string.upper(godLordText)
        elif godLordText == 'God\'s':
            return string.upper(godLordText[0:3]) + '\'s'
        elif godLordText == 'Lord\'s':
            return string.upper(godLordText[0:4]) + '\'s'
        else:
            return 'ERROR, something unexpected occured in capitalzation process'


    def wTagHasDivineName(self, wTag):
        if wTag.seg:
            return True
        else:
            return False

    def handleDivineNames(self, wTag):
        strList = []
        for i in wTag.contents:
            if not isinstance(i, NavigableString):
                strList.append(self.capitalizeGodAndLord(i.divineName.text))
            else:
                strList.append(i)
        return ''.join(strList)

    def handleInscriptions(self, inscriptionTag):
        pass

    def hasStrongsNumber(self, tagAttrs):
        try:
            if tagAttrs['lemma']:
                return True
        except KeyError:
            return False

    def buildDatabase(self, initChapter, chapNum, bookID):
        con = sqlite3.connect('mydb.sqlite')
        csr = con.cursor()
        tag = initChapter
        verseCounter = 1
        for t in tag.next_siblings:
            if not isinstance(t, NavigableString):
                if t.has_attr('sID'):
                    verseCounter +=1
                elif t.has_attr('eID'):
                    pass
                elif t.name == 'note':
                    pass
                elif t.name == 'milestone':
                    pass
                elif t.name == 'w':
                    wAttributes = t.attrs
                    try:
                        textInTag = str(t.text)
                        if self.wTagHasDivineName(t):
                            if self.hasStrongsNumber(wAttributes):
                                textInTag = self.handleDivineNames(t)
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                            (bookID, chapNum, verseCounter, '',
                                             self.strongNumberFinder(wAttributes['lemma']), textInTag))
                            else:
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',(bookID, chapNum,
                                                                                     verseCounter, '', '', textInTag))
                        else:
                            if self.hasStrongsNumber(wAttributes):
                                self.keepTrackOfLocation(t, bookID, chapNum, verseCounter)
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                            (bookID, chapNum, verseCounter, '',
                                             self.strongNumberFinder(wAttributes['lemma']), textInTag))
                            else:
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',(bookID, chapNum,
                                                                                     verseCounter, '','', textInTag))
                    except UnicodeEncodeError:
                        if self.wTagHasDivineName(t):
                            if self.hasStrongsNumber(wAttributes):
                                textInTag = t.text
                                textInTag = self.handleDivineNames(t)
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                            (bookID, chapNum, verseCounter, '',
                                             self.strongNumberFinder(wAttributes['lemma']),
                                             self.removeProblemHyphens(textInTag)))
                            else:
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                            (bookID, chapNum, verseCounter, '','',self.removeProblemHyphens(textInTag)))

                        else:
                            if self.hasStrongsNumber(wAttributes):
                                textInTag = t.text
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                            (bookID, chapNum, verseCounter, '',
                                             self.strongNumberFinder(wAttributes['lemma']),
                                             self.removeProblemHyphens(textInTag)))
                            else:
                                csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                            (bookID, chapNum, verseCounter, '','',
                                             self.removeProblemHyphens(textInTag)))

                elif t.name == 'transChange':
                    textInSuppliedTag = self.removeProblemHyphens(t.text)
                    csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                (bookID, chapNum, verseCounter, 'supplied',
                                 '', textInSuppliedTag))
                elif t.name == 'inscription':
                    str(t.text)
                    inscripAttributes = t.attrs
                    for i in t.contents:
                        if not isinstance(i, NavigableString):
                            if self.wTagHasDivineName(t):
                                if self.hasStrongsNumber(inscripAttributes):
                                    textInTag = self.handleDivineNames(i)
                                    csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                                (bookID, chapNum, verseCounter, '',
                                                 self.strongNumberFinder(wAttributes['lemma']), textInTag))
                                else:
                                    csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                                (bookID, chapNum, verseCounter, '','', textInTag))

                            else:
                                textInTag = i.text
                                if self.hasStrongsNumber(inscripAttributes):
                                    csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                                (bookID, chapNum, verseCounter, '',
                                                 self.strongNumberFinder(wAttributes['lemma']), textInTag))
                                else:
                                    csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                                (bookID,chapNum, verseCounter, '', '', textInTag))

                        elif len(i) > 1:
                            self.somethingUnexpectedOccuredWarning(i, bookID, chapNum, verseCounter)
                        else:
                            pass
                else:
                    self.somethingUnexpectedOccuredWarning(t, bookID, chapNum, verseCounter)
                    pass
            else:
                textOutOfTags = self.removeProblemHyphens(t).strip()
                if not self.isBlank(textOutOfTags):
                    if self.isPunctuation(textOutOfTags):
                        csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                    (bookID, chapNum, verseCounter, '', '', textOutOfTags))
                    elif self.isWordOutsideTag(t):
                        csr.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                    (bookID, chapNum, verseCounter, '', '', textOutOfTags))
                    else:
                        self.somethingUnexpectedOccuredWarning(t, bookID, chapNum, verseCounter)
                        pass
        con.commit()
        con.close()

    def somethingUnexpectedOccuredWarning(self, t, bookId, chapNum, verseCounter):
        print 'SOMETHING UNEXPECTED OCCURED'
        print t
        print (bookId, chapNum, verseCounter)

    def keepTrackOfLocation(self, t, bookId, chapNum, verseCounter):
        print t
        print (bookId, chapNum, verseCounter)

    def iterateOverChapters(self, bookXml, bookID):
        chapters = bookXml.children
        chapterCounter = 0
        for c in chapters:
            try:
                if c.verse:
                    chapterCounter += 1
                    self.buildDatabase(c.verse, chapterCounter, bookID)
            except AttributeError:
                pass

    def iterateOverBooks(self):
        print 'Creating Database now'
        CreateMyDatabase('mydb')
        books = self.soup.find_all('div')
        bookCounter = 0
        for b in books:
            if b.has_attr('osisID'):
                bookCounter += 1
                bookName = b.attrs['osisID']
                print bookName
                self.iterateOverChapters(b, bookCounter)


bv = BreakdownVerse(filename)

bv.iterateOverBooks()




