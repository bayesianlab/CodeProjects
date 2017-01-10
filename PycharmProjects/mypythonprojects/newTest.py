import sqlite3
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

class HandleSoup:
    def isAcceptableTag(self, tagName):
        if tagName in self.goodTags:
            return True
        else:
            return False

    def isBlank(self, tagText):
        if not tagText.strip():
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
            if i == '0' and strongsNumbers[counter - 1] == 'H':
                del strongsNumbers[counter]
        return ''.join(strongsNumbers).decode()

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
        return newWord.decode()

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
        return ''.join(strList).decode()

    def hasStrongsNumber(self, tagAttrs):
        try:
            if tagAttrs['lemma']:
                return True
        except KeyError:
            return False

    def putWTagInSqlTable(self, wTag, bookID, chapNum, verseCounter, cursor):
        try:
            str(wTag.text)
            self.putEncodableWtagIntoSql(wTag, bookID, chapNum, verseCounter, cursor)
        except UnicodeEncodeError:
            self.putNonEncodableWtagIntoSql(wTag, bookID, chapNum, verseCounter, cursor)

    def putEncodableWtagIntoSql(self, wTag, bookID, chapNum, verseCounter, cursor):
        wAttributes = wTag.attrs
        if self.wTagHasDivineName(wTag):
            textInTag = self.handleDivineNames(wTag).decode()
            if self.hasStrongsNumber(wAttributes):
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '',
                                self.strongNumberFinder(wAttributes['lemma']), wTag.text))
            else:
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)', (bookID, chapNum,
                                                                         verseCounter, '', '', textInTag))
        else:
            if self.hasStrongsNumber(wAttributes):
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '',
                                self.strongNumberFinder(wAttributes['lemma']), wTag.text))
            else:
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)', (bookID, chapNum,
                                                                         verseCounter, '', '', wTag.text))

    def putNonEncodableWtagIntoSql(self, wTag, bookID, chapNum, verseCounter, cursor):
        wAttributes = wTag.attrs
        if self.wTagHasDivineName(wTag):
            if self.hasStrongsNumber(wAttributes):
                textInTag = self.handleDivineNames(wTag)
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '', self.strongNumberFinder(wAttributes['lemma']),
                                self.removeProblemHyphens(textInTag)))
            else:
                print "Verse has text but no strongs number?"
                self.keepTrackOfLocation(wTag, bookID, chapNum, verseCounter)
                textInTag = str(wTag.text)
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '', '', self.removeProblemHyphens(textInTag)))
        else:
            if self.hasStrongsNumber(wAttributes):
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '', self.strongNumberFinder(wAttributes['lemma']),
                                self.removeProblemHyphens(wTag.text)))
            else:
                print "Verse has text but no strongs number??"
                self.keepTrackOfLocation(wTag, bookID, chapNum, verseCounter)
                textInTag = str(wTag.text)
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '', '',
                                self.removeProblemHyphens(textInTag)))

    def handleInscriptions(self, inscriptionTag, bookID, chapNum, verseCounter, cursor):
        for i in inscriptionTag.contents:
            if not isinstance(i, NavigableString):
                inscripAttrs = i.attrs
                if self.wTagHasDivineName(inscriptionTag):
                    if self.hasStrongsNumber(inscripAttrs):
                        textInTag = self.handleDivineNames(i)
                        cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                       (bookID, chapNum, verseCounter, '',
                                        self.strongNumberFinder(inscripAttrs['lemma']),
                                        textInTag))
                    else:
                        cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                       (bookID, chapNum, verseCounter, '', '', textInTag))

                else:
                    textInTag = i.text
                    if self.hasStrongsNumber(inscripAttrs):
                        cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                       (bookID, chapNum, verseCounter, '',
                                        self.strongNumberFinder(inscripAttrs['lemma']),
                                        textInTag))
                    else:
                        cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                                       (bookID, chapNum, verseCounter, '', '', textInTag))
            elif len(i) > 1:
                self.somethingUnexpectedOccuredWarning(i, bookID, chapNum, verseCounter)
            else:
                pass

    def handleTextOutOfTags(self, tag, bookID, chapNum, verseCounter, cursor):
        textOutOfTags = str(self.removeProblemHyphens(tag)).strip()
        if not self.isBlank(textOutOfTags):
            if self.isWordOutsideTag(tag):
                cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                               (bookID, chapNum, verseCounter, '', '', textOutOfTags.decode()))
            else:
                self.somethingUnexpectedOccuredWarning(tag, bookID, chapNum, verseCounter)
                pass

    def handleSuppliedWordTags(self, tag, bookID, chapNum, verseCounter, cursor):
        textInSuppliedTag = self.removeProblemHyphens(tag.text)
        cursor.execute('INSERT INTO Bible VALUES(?,?,?,?,?,?)',
                       (bookID, chapNum, verseCounter, 'supplied',
                        '', textInSuppliedTag))


    def somethingUnexpectedOccuredWarning(self, t, bookId, chapNum, verseCounter):
        print 'SOMETHING UNEXPECTED OCCURED'
        print t
        print (bookId, chapNum, verseCounter)

    def keepTrackOfLocation(self, t, bookId, chapNum, verseCounter):
        print t
        print (bookId, chapNum, verseCounter)

class BuildSQL(HandleSoup):

    def __init__(self, filename):
        self.punctuation = ',.;:?!'
        print 'Opening file %s' % filename
        self.soup = BeautifulSoup(open(filename), 'xml')
        self.goodTags = ['w', 'transChange']

    def buildDatabase(self,initChapter, chapNum, bookID):
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
                    self.putWTagInSqlTable(t, bookID, chapNum, verseCounter, csr)
                elif t.name == 'transChange':
                    self.handleSuppliedWordTags(t, bookID,chapNum, verseCounter, csr)
                elif t.name == 'inscription':
                    self.handleInscriptions(t, bookID, chapNum, verseCounter, csr)
            else:
                self.handleTextOutOfTags(t, bookID, chapNum, verseCounter, csr)
        con.commit()
        con.close()


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



bv = BuildSQL(filename)
bv.iterateOverBooks()








