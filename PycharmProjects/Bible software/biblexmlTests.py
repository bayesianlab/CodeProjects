__author__ = 'dillonflannery-valadez'

from biblexml import *


global p
global f
p = "TEST PASS."
f = "TEST FAILED."


def switch_punctuation_btwn_tags_Test():
    x = "</w>abcd</w>.<w>abcd</w>;<w>abcdefg</w>"
    y = "</w>;<w>somesstring and info </w>,<w> and some more info" \
        "</w>:<w> some interesting facts </w>!<w> This is a question </w>?<w>"
    test1 = switch_punctuation_btwn_tags(x)
    test2 = switch_punctuation_btwn_tags(y)
    if test1 == "</w>abcd.</w><w>abcd;</w><w>abcdefg</w>":
        print "Remove punctuation between tags 1: " + p
    else:
        print "Remove punctuation between tags 1 " + f
    if test2 == ";</w><w>somesstring and info ,</w><w> and some more info" \
                ":</w><w> some interesting facts !</w><w> This is a question ?</w><w>":
        print "Remove punctuation between tags 2: " + p
    else:
        print "Remove punctuation between tags 2 " + f
    print switch_punctuation_btwn_tags(bigstring)


def count_of_grammarTest():
    x = bigstring[:325]
    testval = count_of_grammar(x)
    if testval == 1:
        print "Count of grammar 1: " + p, testval
    else:
        print "Count of grammar 1 " + f, testval
    x = bigstring
    testval = count_of_grammar(x)
    if testval == 5:
        print "Count of grammar 2: " + p, testval
    else:
        print "Count of grammar 2 " + f, testval


# count_of_grammarTest()
# switch_punctuation_btwn_tags_Test()

newkjv = switch_punctuation_btwn_tags(bigstring)
newkjv = ET.fromstring(newkjv)
gen11 = ""
