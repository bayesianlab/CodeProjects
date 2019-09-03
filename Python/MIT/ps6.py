# 6.00 Problem Set 6
#
# The 6.00 Word Game
#

import time
import itertools
from MIT.ps5 import *


VOWELS = 'aeiou'
CONSONANTS = 'bcdfghjklmnpqrstvwxyz'
HAND_SIZE = 7

SCRABBLE_LETTER_VALUES = {
    'a': 1, 'b': 3, 'c': 3, 'd': 2, 'e': 1, 'f': 4, 'g': 2, 'h': 4, 'i': 1, 'j': 8, 'k': 5, 'l': 1, 'm': 3, 'n': 1,
    'o': 1, 'p': 3, 'q': 10, 'r': 1, 's': 1, 't': 1, 'u': 1, 'v': 4, 'w': 4, 'x': 8, 'y': 4, 'z': 10
}

# -----------------------------------
# Helper code
# (you don't need to understand this helper code)

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
        freq[x] = freq.get(x, 0) + 1
    return freq


# (end of helper code)
# -----

# Problem #1: Scoring a word
#
def get_word_score(word, n):
    """
    Returns the score for a word. Assumes the word is a
    valid word.

    The score for a word is the sum of the points for letters
    in the word, plus 50 points if all n letters are used on
    the first go.

    Letters are scored as in Scrabble; A is worth 1, B is
    worth 3, C is worth 3, D is worth 2, E is worth 1, and so on.

    word: string (lowercase letters)
    returns: int >= 0
    """
    score = 0
    for letter in word:
        score += SCRABBLE_LETTER_VALUES[letter.lower()]
    if len(word) == n:
        score += 50
    return score


def get_word_score_nobonus(word):
    score = 0
    for letter in word:
        score += SCRABBLE_LETTER_VALUES[letter.lower()]
    return score


def display_hand(hand):
    """
    Displays the letters currently in the hand.

    For example:
       display_hand({'a':1, 'x':2, 'l':3, 'e':1})
    Should print out something like:
       a x x l l l e
    The order of the letters is unimportant.

    hand: dictionary (string -> int)
    """
    for letter in hand.keys():
        for j in range(hand[letter]):
            print letter,  # print all on the same line
    print  # print an empty line


#
# Make sure you understand how this function works and what it does!
#
def deal_hand(n):
    """
    Returns a random hand containing n lowercase letters.
    At least n/3 the letters in the hand should be VOWELS.

    Hands are represented as dictionaries. The keys are
    letters and the values are the number of times the
    particular letter is repeated in that hand.

    n: int >= 0
    returns: dictionary (string -> int)
    """
    hand = {}
    num_vowels = n / 3

    for i in range(num_vowels):
        x = VOWELS[random.randrange(0, len(VOWELS))]
        hand[x] = hand.get(x, 0) + 1

    for i in range(num_vowels, n):
        x = CONSONANTS[random.randrange(0, len(CONSONANTS))]
        hand[x] = hand.get(x, 0) + 1

    return hand


# Problem #2: Update a hand by removing letters
#
def update_hand(hand, word):
    """
    Assumes that 'hand' has all the letters in word.
    In other words, this assumes that however many times
    a letter appears in 'word', 'hand' has at least as
    many of that letter in it.

    Updates the hand: uses up the letters in the given word
    and returns the new hand, without those letters in it.

    word: string
    hand: dictionary (string -> int)
    returns: dictionary (string -> int)
    """
    freq = get_frequency_dict(word)
    newhand = {}
    for char in hand:
        newhand[char] = hand[char] - freq.get(char, 0)
    return newhand
    # return dict( ( c, hand[c] - freq.get(c,0) ) for c in hand )


#
# Problem #3: Test word validity
#
def is_valid_word(word, hand, word_list):
    """
    Returns True if word is in the word_list and is entirely
    composed of letters in the hand. Otherwise, returns False.
    Does not mutate hand or word_list.

    word: string
    hand: dictionary (string -> int)
    word_list: list of lowercase strings
    """
    freq = get_frequency_dict(word)
    for letter in word:
        if freq[letter] > hand.get(letter, 0):
            return False
    return word in word_list


def is_valid_word2(word, hand, points_dict):
    freq = get_frequency_dict(word)
    for letter in word:
        if freq[letter] > hand.get(letter, 0):
            return False
    return word in points_dict


def get_words_to_points(word_list):
    """
    Return a dictionary that maps every word to a point value.
    :param word_list:
    :return:
    """
    points_dict = {}
    for word in word_list:
        points_dict[word] = get_word_score_nobonus(word)
    return points_dict

####################################################################
# These functions cut the dictionary down to make it faster for the#
# computer player###################################################
####################################################################
def cut_by1st_letter(hand, points_dict):
    """
    The letters in the hand must begin at least one word. Cut out
    the rest.
    hand: Dictionary
    points_dict: global words -> points
    :return: reduced dictionary
    """
    reduced_dict = {}
    hand_len = sum(hand.values())
    x = 0
    for letter in hand:
        for word in points_dict:
            if letter == word[0]:
                reduced_dict[word] = points_dict[word]
            else:
                pass
    return reduced_dict


def word_too_long(hand, reduced_dict):
    """
    If the words in the list are too long to be formed by the hand, cut them out.
    :param hand: dicitonary
    :param reduced_dict:
    :return: really reduced dictionary
    """
    hand_len = sum(hand.values())
    really_reduced_dict = {}
    for word in reduced_dict:
        if len(word) <= hand_len:
            really_reduced_dict[word] = points_dict[word]
        else:
            pass
    return really_reduced_dict


def reduced_points_dict(hand, points_dict):
    """
    Implement the reducing dicitonary functions above.
    :param hand:
    :param points_dict:
    :return: the reduced dictionary
    """
    dict = cut_by1st_letter(hand, points_dict)
    dict = word_too_long(hand, dict)
    return dict


def valid_word(hand, word):
    """
    Determines if a word can be made from the hand.
    Iterates through the letters of a word if the letter of a word
    is in the hand (dictionary converted to string) then the function
    cuts that letter out of the hand. If a letter is ever in the word
    that is not in the hand it will return false.
    :param hand:
    :param word:
    :return:
    """
    test = 0
    hand_string = make_hand_string(hand)
    for letter_of_word in word:
        if letter_of_word in hand_string:
            indx_of_letter = hand_string.find(letter_of_word)
            hand_string = hand_string[:indx_of_letter] + hand_string[(indx_of_letter + 1):]
            test = 1
        else:
            return False
    if test == 1:
        return True
    else:
        return False


def get_comparison_dict(hand, points_dict):
    """
    Makes another dictionary that ensures that the word is valid and
    that it can be made with the letters of the hand.
    :param hand: dictionary
    :param points_dict:
    :return: small dictionary
    """
    dict_to_compare_points = {}
    cut_dict = reduced_points_dict(hand, points_dict)
    for word in cut_dict:
        if valid_word(hand, word):
            dict_to_compare_points[word] = points_dict[word]
        else:
            pass
    return dict_to_compare_points


def get_time_limit(points_dict, k):
    """
    Return the time limit for the computer player as a function of the
    multiplier k.

    points_dict should be the same dictionary that is created by
    get_words_to_points.
    """
    start_time = time.time()
    for word in points_dict:
        get_frequency_dict(word)
        get_word_score(word, HAND_SIZE)
    end_time = time.time()
    return round((end_time - start_time) * k, 4)


def pick_best_word(hand, points_dict):
    """
    Returns the highest scoring word from points_dict that can be
    made with the given hand.
    Return "." if no word can be made.
    :param hand_string:
    :param word:
    :return:
    """
    compare_dict = get_comparison_dict(hand, points_dict)
    words = compare_dict.keys()
    points = compare_dict.values()
    max = 0
    highest_scoring_word = ""
    if len(words) > 0:
        for i, j in zip(words, points):
            if j > max:
                max = j
                highest_scoring_word = i
            else:
                pass
        return highest_scoring_word
    else:
        return "."

########################
# end pick best word ###
#######################

###################################
# Code for better computer player##
###################################

def list_to_string(list):
    """
    Does exactly what it says.
    :param list:
    :return: a string, not alphabetically though.
    """
    alpha_string = ""
    for i in list:
        alpha_string += i
    return alpha_string


def get_word_rearrangements(word_list):
    """
    Returns a dictionary of alphabetically sored words linked to values
    that are the actual words unsorted.
    :param word_list:
    :return: dictionary -> words from wordlist
    """
    d = {}
    for word in word_list:
        d[list_to_string(sorted(word))] = word
    return d


def make_hand_string(hand):
    hand_string = ""
    for i in hand.keys():
        for j in range(hand[i]):
            hand_string += i
    return hand_string


def power_set_list(hand):
    """
    Converts hand into a list of strings representing every possible
    subset.
    :param hand: a dictionary
    :return: string
    """
    hand_string = sorted(make_hand_string(hand))
    length_hand_string = len(hand_string) + 1
    power_set = [] # less one (empty set not included) 2^n - 1
    for num_letters in range(1, length_hand_string ):
        power_set += list(itertools.combinations(hand_string, num_letters))
    return power_set

def make_list_strings_from_power_set(power_set):
    """
    The power set function above returns a list of tuples. This makes a
    list of strings because its easier to use.
    :param power_set:
    :return: list of strings
    """
    power_set_strings = []
    for tuple in power_set:
        power_set_strings.append(list_to_string(tuple))
    return power_set_strings

def acceptable_words(hand,  rearrange_dict):
    """
    Sees if all the words in the list of strings are anywhere in the dicitonary
    that is a  rearrangement of the words in the words list (alphabetical rearrangement)
    :param hand:
    :param rearrange_dict:
    :return: list of words that are found in the rearranged dictionary
    """
    power_set = power_set_list(hand)
    power_set_strings = make_list_strings_from_power_set(power_set)
    stored_acceptable_words = []
    for possibility in power_set_strings:
        if possibility in rearrange_dict:
            stored_acceptable_words.append(rearrange_dict[possibility])
    return stored_acceptable_words

def pick_best_word_faster(hand, rearrange_dict):
    """
    picks the highest scoring word in the list of stored acceptable word list
    :param hand:
    :param rearrange_dict:
    :return: string
    """
    stored_acceptable_words = acceptable_words(hand, rearrange_dict)
    max = 0
    highest_scorer = ""
    if len(stored_acceptable_words) > 0:
        for word in stored_acceptable_words:
            point_value = points_dict[word]
            if point_value > max:
                max = point_value
                highest_scorer = word
            else:
                pass
        return highest_scorer
    else:
        return "."


#######################
# end pick word faster#
#######################

##################
# Implementation #
##################

def play_hand0(hand, word_list):
    """
    Allows the user to play the given hand, as follows:

    * The hand is displayed.

    * The user may input a word.

    * An invalid word is rejected, and a message is displayed asking
      the user to choose another word.

    * When a valid word is entered, it uses up letters from the hand.

    * After every valid word: the score for that word is displayed,
      the remaining letters in the hand are displayed, and the user
      is asked to input another word.

    * The sum of the word scores is displayed when the hand finishes.

    * The hand finishes when there are no more unused letters.
      The user can also finish playing the hand by inputing a single
      period (the string '.') instead of a word.

      hand: dictionary (string -> int)
      word_list: list of lowercase strings
    """
    total = 0
    initial_handlen = sum(hand.values())
    epsilon = .0000001
    # time_limit = raw_input("Enter the time limit, in seconds for players: ") # For human players, uncomment
    # time_limit = float(time_limit)
    time_limit = time_limit_computer
    print "Computer time limit... ", time_limit_computer
    while 0 < time_limit:
        print 'Current Hand:',
        display_hand(hand)
        start_time = time.time()
        # userWord = raw_input('Enter word, or a . to indicate that you are finished: ') # For human players, uncomment
        userWord = pick_best_word(hand, points_dict)
        print userWord
        if userWord == '.':
            break
        else:
            isValid = is_valid_word(userWord, hand, word_list)
            if not isValid:
                end_time = time.time()
                total_time = end_time - start_time
                time_limit -= total_time
                if time_limit <= 0:
                    print " Game over. Time limit exceeded. "
                    print 'Total score: %d points.' % total
                    return
                else:
                    print 'Invalid word, please try again.'
                    print "You have %.2f seconds remaining. " % time_limit
                    print
            else:
                end_time = time.time()
                total_time = end_time - start_time
                if abs(total_time) < epsilon:
                    points = get_word_score(userWord, initial_handlen)
                    total += points
                    print '%s earned %.2f points. Total: %.2f points ' % (userWord, points, total)
                    print "You have %.2f remaining. " % (time_limit)
                    print
                    hand = update_hand(hand, userWord)
                else:
                    points = get_word_score(userWord, initial_handlen) / total_time
                    total += points
                    time_limit -= total_time
                    if time_limit < 0:
                        time_limit = 0
                    print '%s earned %.2f points. Total: %.2f points ' % (userWord, points, total)
                    print "You have %.2f seconds remaining. " % (time_limit)
                    print
                    hand = update_hand(hand, userWord)
    print 'Total score: %d points. Time remaining %.2f ' % (total, time_limit)

# def play_hand1(hand, word_list):
#     """
#     Allows the user to play the given hand, as follows:
#
#     * The hand is displayed.
#
#     * The user may input a word.
#
#     * An invalid word is rejected, and a message is displayed asking
#       the user to choose another word.
#
#     * When a valid word is entered, it uses up letters from the hand.
#
#     * After every valid word: the score for that word is displayed,
#       the remaining letters in the hand are displayed, and the user
#       is asked to input another word.
#
#     * The sum of the word scores is displayed when the hand finishes.
#
#     * The hand finishes when there are no more unused letters.
#       The user can also finish playing the hand by inputing a single
#       period (the string '.') instead of a word.
#
#       hand: dictionary (string -> int)
#       word_list: list of lowercase strings
#       """
#     # rearrange_dict = get_word_rearrangements(word_list)
#     total = 0
#     initial_handlen = sum(hand.values())
#     epsilon = .0000001
#     time_limit = raw_input("Enter the time limit, in seconds for players: ")
#     time_limit = float(time_limit)
#     while 0 < time_limit:
#         print 'Current Hand:'
#         display_hand(hand)
#         start_time = time.time()
#         userWord = pick_best_word_faster(hand, rearrange_dict)
#         if userWord == '.':
#              break
#         else:
#             isValid = is_valid_word(userWord, hand, word_list)
#             if not isValid:
#                 end_time = time.time()
#                 total_time = end_time - start_time
#                 time_limit -= total_time
#                 if time_limit <= 0:
#                     print " Game over. Time limit exceeded. "
#                     print 'Total score: %d points.' % total
#                     return
#                 else:
#                     print 'Invalid word, please try again.'
#                     print "You have %.2f seconds remaining. " % time_limit
#                     print
#             else:
#                 end_time = time.time()
#                 total_time = end_time - start_time
#                 if abs(total_time) < epsilon:
#                     points = get_word_score(userWord, initial_handlen)
#                     total += points
#                     print '%s earned %.2f points. Total: %.2f points ' % (userWord, points, total)
#                     print "You have %.2f remaining. " % (time_limit)
#                     print
#                     hand = update_hand(hand, userWord)
#                 else:
#                     points = get_word_score(userWord, initial_handlen) / total_time
#                     total += points
#                     time_limit -= total_time
#                     if time_limit < 0:
#                         time_limit = 0
#                     print '%s earned %.2f points. Total: %.2f points ' % (userWord, points, total)
#                     print "You have %.2f seconds remaining. " % (time_limit)
#                     print
#                     hand = update_hand(hand, userWord)
#     print 'Total score: %d points.' % total


def play_game(word_list):
    """
    Allow the user to play an arbitrary number of hands.

    * Asks the user to input 'n' or 'r' or 'e'.

    * If the user inputs 'n', let the user play a new (random) hand.
      When done playing the hand, ask the 'n' or 'e' question again.

    * If the user inputs 'r', let the user play the last hand again.

    * If the user inputs 'e', exit the game.

    * If the user inputs anything else, ask them again.
    """
    # TO DO ...

    ## uncomment the following block of code once you've completed Problem #4
    hand = deal_hand(HAND_SIZE) # random init
    while True:
        cmd = raw_input('Enter n to deal a new hand, r to replay the last hand, or e to end game: ')
        if cmd == 'n':
            hand = deal_hand(HAND_SIZE)
            play_hand(hand.copy(), word_list)
            print
        elif cmd == 'r':
            play_hand(hand.copy(), word_list)
            print
        elif cmd == 'e':
            break
        else:
            print "Invalid command."

# Needed globals

k = .75
word_list = load_words()
points_dict = get_words_to_points(word_list)

rearrange_dict = get_word_rearrangements(word_list)
time_limit_computer = get_time_limit(points_dict, k)

# Some tester code
word_list_test = word_list[100:110]

hand = deal_hand(HAND_SIZE)

play_hand0(hand, word_list)
print
print get_time_limit(points_dict, k)






# Code for visual test that the functions above work.

# print hand
# print
# pwrset = power_set_list(hand)
# print make_list_strings_from_power_set(pwrset)
# display_hand(hand)
#
#
# print acceptable_words(hand, rearrange_dict), "acceptable words"
# for i in acceptable_words(hand, rearrange_dict):
#     print i, points_dict[i]
# print
# print pick_best_word_faster(hand, rearrange_dict), get_word_score((pick_best_word_faster(hand, rearrange_dict)), 7)
#