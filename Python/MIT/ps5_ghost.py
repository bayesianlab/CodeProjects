# Problem Set 5: Ghost
# Name: 
# Collaborators: 
# Time: 
#

import random

# -----------------------------------
# Helper code
# (you don't need to understand this helper code)
import string

WORDLIST_FILENAME = "words.txt"

def load_words():
    """
    Returns a list of valid words. Words are strings of lowercase letters.
    
    Depending on the size of the word list, this function may
    take a while to finish.
    """
    print "Loading word list from file..."
    # inFile: file
    inFile = open(WORDLIST_FILENAME, 'r', 0)
    # wordlist: list of strings
    wordlist = []
    for line in inFile:
        wordlist.append(line.strip().lower())
    print "  ", len(wordlist), "words loaded."
    return wordlist

def get_frequency_dict(sequence):
    """
    Returns a dictionary where the keys are elements of the sequence
    and the values are integer counts, for the number of times that
    an element is repeated in the sequence.

    sequence: string or list
    return: dictionary
    """
    # freqs: dictionary (element_type -> int)
    freq = {}
    for x in sequence:
        freq[x] = freq.get(x,0) + 1
    return freq


# (end of helper code)
# -----------------------------------

# Actually load the dictionary of words and point to it with 
# the wordlist variable so that it can be accessed from anywhere
# in the program.
wordlist = load_words()

# TO DO: your code begins here!

def exit_game(period):
    if period == '.':
        return True
    else:
        return False

def players_up(counter):
    if counter % 2== 1:
        print 
        print "Player 1's turn..."
    else:
        print 
        print "Player 2's turn..."

def ascii_test(letter):
    if letter in string.ascii_letters:
        return True
    else:
        return False

def current_word_displayer(word):
    print
    print word
    if len(word) <= 3:
        print "are the current game letters, you can make 3 letter words!"
    else:
        print "are the current game letters, try not to make a word now!"

def lost_game_statements():
    print "Oh no!"
    print "You have spelled a word, you have lost."
    return

def whitespace_cleaner(letterInput):
    letter = ''
    for i in letterInput:
        if i in string.ascii_letters:
            letter = i
    return letter

def welcome_statements():
    print 
    print "WELCOME TO GHOST!"
    return

def impossible_word_checker(word_frag):
    fragLength = len(word_frag)
    for word in wordlist:
        if word_frag == word[:fragLength]:
            return False
    else:
        print "Impossible word. " + word_frag + " can't spell a word."
        print "Sorry you have lost."
        return True
    
## Game code implementing above functions.
    
def ghost():
    welcome_statements()
    word = ''
    odd_even = 0
    lengthWord = 0
    while lengthWord < 3:
        odd_even += 1
        players_up(odd_even)
        letter = raw_input("Input a letter...")
        whitespace_cleaner(letter)
        if exit_game(letter):
            return
        elif ascii_test(letter):
            word += letter
            if impossible_word_checker(word):
                return
            current_word_displayer(word)
        else:
            while not ascii_test(letter):
                players_up(odd_even)
                letter = raw_input("Input a LETTER...")
                whitespace_cleaner(letter)
            word += letter
            if impossible_word_checker(word):
                return
            current_word_displayer(word)
        lengthWord = len(word)
    while lengthWord >= 3:
        odd_even += 1
        players_up(odd_even)
        letter = raw_input("Input a letter...")
        whitespace_cleaner(letter)
        if exit_game(letter):
            return
        word += letter
        if impossible_word_checker(word):
            return
        if word in wordlist:
            print word
            lost_game_statements()
            return
        else:
            current_word_displayer(word)
        lengthWord = len(word)

## Unit tests of above functions
        
def impossible_word_checker_Test():
    """
    Should return false for a possible word and true for an impossible
    word.
    """
    word_frag = "dog"
    counter = 1
    if not impossible_word_checker(word_frag):
        print "Returns True with impossible word fragment, False with possible."
        print "Impossible word test %i PASS." % (counter)
        print "Function returned:", impossible_word_checker(word_frag)
        print "Word fragment:", word_frag
    else:
        print "Impossible word test %i FAILED." % (counter)
        print impossible_word_checker(word_frag)
    print 
    word = 'qx'
    counter += 1
    if impossible_word_checker(word):
        print "Returns True with impossible word fragment False with possible."
        print 'Impossible word checker test %i PASS' % (counter)
        print "Function returned:", impossible_word_checker(word)
        print "Word fragment:", word
    else:
        print 'impossible word checker test %i FAILED' % (counter)
    print 
    word_frag = 'tot'
    counter += 1
    if not impossible_word_checker(word_frag):
        print "Returns True with impossible word fragment False with possible."
        print 'impossible word checker test %i PASS' % (counter)
        print "Function returned:", impossible_word_checker(word_frag)
        print "word_frag is: " + word_frag 
    else:
        print 'impossible word checker test %i FAILED' % (counter)
    print 
    word_frag = 'thr'
    counter += 1
    if impossible_word_checker(word_frag):
        print "Returns True with impossible word fragment False with possible."
        print "word_frag is: " + word_frag
        print 'impossible word checker test %i FAILED' % (counter)
        print "Function returned:", impossible_word_checker(word_frag), \
              " it is impossible which is incorrect."
        print 
    else:
        print "Returns True with impossible word fragment False with possible."
        print "Impossible word checker test %i PASS" % (counter)
        print "Function returned:", impossible_word_checker(word_frag)
        print "word_frag is: " + word_frag
    print 
    word_frag = "zzwm"
    counter += 1
    if impossible_word_checker(word_frag):
        print "Returns True with impossible word fragment, False with possible."
        print "Impossible word test %i PASS." % (counter)
        print "Function returned:", impossible_word_checker(word_frag)
        print "Word fragment:", word_frag
    else:
        print "Impossible word test %i FAILED." % (counter)
        print impossible_word_checker(word_frag)

def whitespace_cleaner_Test():
    letter = '   h'
    result = whitespace_cleaner(letter)
    counter = 1
    if result == 'h':
        print "whitespace cleaner test %i PASS" % (counter)
    else:
        print "whitespace cleaner test %i FAILED" % (counter)

def ascii_test_Test():
    letter = ' '
    counter = 1
    print 
    if ascii_test(letter):
        print 'ascii test %i FAILED' % (counter)
    else:
        print 'ascii test %i PASS' % (counter)
        print 'Whitespace inputed, ascii test returned', ascii_test(letter)
    print 
    letter = 'a'
    counter = counter + 1
    if ascii_test(letter):
        print 'ascii test %i PASS' % (counter)
        print letter, 'inputed, ascii test returned',  ascii_test(letter)
    else:
        print 'ascii test %i FAILED' % (counter)
    print 
    letter = '#'
    counter += 1
    if ascii_test(letter):
        print 'ascii test %i FAILED' % (counter)
    else:
        print 'ascii test %i PASS' % (counter)
        print letter, ' inputed, ascii test returned', ascii_test(letter)

## Tests below
##print 
##whitespace_cleaner_Test()
##print 
##ascii_test_Test()
##print
##impossible_word_checker_Test()
##print
        
## Runs Ghost Game when executed.
        
ghost()
