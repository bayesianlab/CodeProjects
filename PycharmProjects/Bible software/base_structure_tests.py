__author__ = 'dillonflannery-valadez'

from base_structure_classes import *
from TestStructure import *


class BaseStructure_cutWhiteSpace(Display1Verse, TestStructure):

    def __init__(self):
        self.tString1 = "foo bar"
        self.tString2 = "Gen 1:1"
        self.tString3 = " Gen 1 : 1 "
        self.tString4 = '  Gen 1: 2'
    def test_cutWhiteSpace(self):
        self.assertEqual(self.cutWhiteSpace(self.tString1), 'foobar')
        self.assertEqual(self.cutWhiteSpace(self.tString2), 'Gen1:1')
        self.assertEqual(self.cutWhiteSpace(self.tString3), 'Gen1:1')
        self.assertEqual(self.cutWhiteSpace(self.tString4), 'Gen1:2')


class BaseStructure_insertPeriod(Display1Verse, TestStructure):

    def __init__(self):
        self.tString1 = 'hungryhippos123'
        self.tString2 = "Gen1:1"
        self.tString3 = "John1:1"
        self.tString4 = 'Romans6:2'

    def test_insertPeriod(self):
        self.assertEqual(self.insertPeriod(self.tString1), 'hungryhippos.123')
        self.assertEqual(self.insertPeriod(self.tString2), 'Gen.1:1')
        self.assertEqual(self.insertPeriod(self.tString3), 'John.1:1')
        self.assertEqual(self.insertPeriod(self.tString4), 'Romans.6:2')


class BaseStructure_frmtInput(Display1Verse, TestStructure):

    def __init__(self):
        self.tString1 = "Romans 6:23"
        self.tString2 = "Gen 1:1"
        self.tString3 = " Gen 1 : 1 "
        self.tString4 = '  Gen 1: 2'

    def test_frmtInput(self):
        self.assertEqual(self.frmtInput(self.tString1), 'Romans.6.23')
        self.assertEqual(self.frmtInput(self.tString2), 'Gen.1.1')
        self.assertEqual(self.frmtInput(self.tString3), 'Gen.1.1')
        self.assertEqual(self.frmtInput(self.tString4), 'Gen.1.2')


class BaseStructure_search(Display1Verse,TestStructure):
    def __init__(self):
        pass

    def test_searchVerse(self):
        self.assertEqual(self.findVerse("Gen 3:23"), (soup.find(sID = 'Gen.3.23'), soup.find(eID = 'Gen.3.23')))
        print
        pass

class BaseStructure_getVerseText(Display1Verse,TestStructure):

    def __init__(self):
        self.tString1 = "Gen 1:1"
        self.tString2 = " Gen 1 : 1 "
        self.tString3 = '  Gen 1: 2'
        self.tString4 = 'Gen 3:1'
        self.tString5 = 'Gen 2:7'
        self.gen1_1 = 'In the beginning God created the heaven and the earth.'
        self.gen1_2 = 'And the earth was without form, and void; and darkness was upon the face of the deep. And the ' \
                      'Spirit of God moved upon the face of the waters.'
    def test_getVerseText(self):
        self.assertEqual(self.getVerseText(self.tString1), self.gen1_1)
        self.assertEqual(self.getVerseText(self.tString2), self.gen1_1)
        self.assertEqual((self.getVerseText(self.tString3)), (self.gen1_2))
        print self.getVerseText(self.tString4)
        print self.getVerseText(self.tString5)


class Tests_Display1Chater(Display1Chapter, TestStructure):
    def __init__(self):
        self.chapter_test = ''

    def test_book_chapter_search(self):
        v = soup.verse
        print self.book_chapter_search('Gen 3')

    def test_displayAChapter(self):
        pass





# run_cutWhiteSpaceTests = BaseStructure_cutWhiteSpace()
# run_cutWhiteSpaceTests.test_cutWhiteSpace()
#
# run_insertPeriodTests = BaseStructure_insertPeriod()
# run_insertPeriodTests.test_insertPeriod()
#
# runTests = BaseStructure_frmtInput()
# runTests.test_frmtInput()

# run_frmtInputTests = BaseStructure_frmtInput()
# run_frmtInputTests.test_frmtInput()
#
# run_search = BaseStructure_search()
# run_search.test_searchVerse()

# run_getVerseTextTest = BaseStructure_getVerseText()
# print run_getVerseTextTest.test_getVerseText()

# run_displayChapterTest = Tests_Display1Chater()
# run_displayChapterTest.test_book_chapter_search()

# be = soup.find('w')
# print type(be.next_element.next_element.next_element)

