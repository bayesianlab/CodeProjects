import ps10; reload(ps10)
from ps10 import *

def isClose(float1, float2):
    """
    Helper function - are two floating point values close?
    """
    return abs(float1 - float2) < .01

def testResult(boolean):
    """
    Helper function - print 'Test Failed' if boolean is false, 'Test
    Succeeded' otherwise.
    """
    if boolean:
        print 'Test Succeeded'
    else:
        print 'Test Failed'


def equalityTest(value1, value2, should_fail_or_pass = True):

    if (value1 == value2) == should_fail_or_pass:
        print "Test Succeeded"
    else:
        print "Test Failed"

def comparisonOfPlayersTest(p1,p2):
    print
    print "Comparison of players. p1 greater than p2."
    if p1 > p2:
        print "Test Succeeded"
    else:
        print "Test Failed"

def testHand():
    """
    Test the hand class. Add your own test cases
    """
    print "Tests on updating of hand method."
    test_dict = {'a': 3, 'b': 2, 'd': 3}
    h = Hand(8, test_dict)
    h.update('bad')
    testResult(h.containsLetters('aabdd') and not h.isEmpty())
    h.update('dad')
    testResult(h.containsLetters('ab') or not h.isEmpty())
    h.update('ab')
    testResult(h.isEmpty())
    print "Tests on equality method"
    h = Hand(8, test_dict)
    otherhand = Hand(8, test_dict)
    equalityTest(h, otherhand)
    otherhand = Hand(8, {"a": 3, "b": 2, "d" : 1, "e": 2})
    equalityTest(h, otherhand, False)

def testPlayer():
    """
    Test the Player class. Add your own test cases.
    """

    print "Player tests"
    hand1 = Hand(6, {'c': 1, 'a': 1, 'b': 1, 'd': 1, 'o': 1, 'e': 1})
    hand2 = Hand(6, {"g":2, "a": 1,"i": 1, "r":1, "t":1})
    p1 = Player(1, hand1)
    print p1.getHand()
    testResult(type(p1.getHand()) == Hand)
    p1.addPoints(5.)
    p1.addPoints(12.)
    testResult(isClose(p1.getPoints(), 17))
    p2 = Player(2, hand2)
    p2.addPoints(5.0)
    p2.addPoints(1.0)
    comparisonOfPlayersTest(p1.getPoints(),p2.getPoints())
    print "Player score equality test"
    p2.addPoints(11.0)
    print p1.getPoints(), p2.getPoints()
    testResult(isClose(p1.getPoints(),p2.getPoints()))
    print
    print "String rep test"
    print p1
    print p2



def testComputerPlayer():
    """
    Test the ComputerPlayer class. Add your own test cases.
    """
    wordlist = Wordlist()
    p = ComputerPlayer(1, Hand(6, {'c':1, 'a':1, 'b':1 ,'d':1, 'o':1, 'e':1}))
    testResult(getWordScore(p.pickBestWord(wordlist)) == getWordScore('abode'))

def testAll():
    """
    Run all Tests
    """

    print "Uncomment the tests in this file as you complete each problem."

    print 'PROBLEM 2 -----------------------------------------'
    # testHand()

    print 'PROBLEM 3 -----------------------------------------'
    # testPlayer()

    print 'PROBLEM 4 -----------------------------------------'
    testComputerPlayer()

testAll()
wl = Wordlist()

# print word_list[0:100]
hand = Hand(6, {'c': 1, 'a': 1, 'b': 1, 'd': 1, 'o': 1, 'e': 1})
comp1 = ComputerPlayer(1, hand)
# print comp1.pickBestWord(wl)
