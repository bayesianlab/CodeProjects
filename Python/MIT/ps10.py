# Backend code for PS10

import random
import string
import wx

# Global Constants
VOWELS = 'aeiou'
CONSONANTS = 'bcdfghjklmnpqrstvwxyz'
HAND_SIZE = 30
SCRABBLE_LETTER_VALUES = {
    'a': 1, 'b': 3, 'c': 3, 'd': 2, 'e': 1, 'f': 4, 'g': 2, 'h': 4, 'i': 1,
    'j': 8, 'k': 5, 'l': 1, 'm': 3, 'n': 1, 'o': 1, 'p': 3, 'q': 10, 'r': 1,
    's': 1, 't': 1, 'u': 1, 'v': 4, 'w': 4, 'x': 8, 'y': 4, 'z': 10
}
HUMAN_SOLO = 0
HUMAN_VS_HUMAN = 1
HUMAN_VS_COMP = 2

WORDLIST_FILENAME = "words.txt"

def getFrequencyDict(sequence):
    """
    Given a sequence of letters, convert the sequence to a dictionary of
    letters -> frequencies. Used by containsLetters().

    returns: dictionary of letters -> frequencies
    """
    freq = {}
    for x in sequence:
        freq[x] = freq.get(x,0) + 1
    return freq

def getWordScore(word):
    """
    Computes the score of a word (no bingo bonus is added).

    word: The word to score (a string).

    returns: score of the word.
    """
    score = 0
    for ch in word:
        score += SCRABBLE_LETTER_VALUES[ch]
    if len(word) == HAND_SIZE:
        score += 50
    return score

#
# Problem 2: Representing a Hand
#

class Hand(object):
    def __init__(self, handSize, initialHandDict = None):
        """
        Initialize a hand.

        handSize: The size of the hand

        postcondition: initializes a hand with random set of initial letters.
        """
        num_vowels = handSize / 3
        if initialHandDict is None:
            initialHandDict = {}
            for i in range(num_vowels):
                x = VOWELS[random.randrange(0,len(VOWELS))]
                initialHandDict[x] = initialHandDict.get(x, 0) + 1
            for i in range(num_vowels, handSize):
                x = CONSONANTS[random.randrange(0,len(CONSONANTS))]
                initialHandDict[x] = initialHandDict.get(x, 0) + 1
        self.initialSize = handSize
        self.handDict = initialHandDict

    def update(self, word):
        """
        Remove letters in word from this hand.

        word: The word (a string) to remove from the hand
        postcondition: Letters in word are removed from this hand
        """
        for i in word:
            if self.handDict[i] - 1 > -1:
                self.handDict[i] = self.handDict[i] - 1
            elif self.handDict[i] - 1 <= -1:
                print "Error. Class Hand, update method."
        return self.handDict

    def containsLetters(self, letters):
        """
        Test if this hand contains the characters required to make the input
        string (letters)

        returns: True if the hand contains the characters to make up letters,
        False otherwise
        """
        handString = ""
        for i in self.handDict:
            handString += i * self.handDict[i]
        if letters in handString:
            return True
        else:
            return False

    def isEmpty(self):
        """
        Test if there are any more letters left in this hand.

        returns: True if there are no letters remaining, False otherwise.
        """
        for key in self.handDict:
            if self.handDict[key] != 0:
                return False
        return True

    def __eq__(self, other):
        """
        Equality test, for testing purposes

        returns: True if this Hand contains the same number of each letter as
        the other Hand, False otherwise
        """
        for item_i, item_j in zip(self.handDict, other.handDict):
            if item_i != item_j:
                return False
        return True

    def __str__(self):
        """
        Represent this hand as a string

        returns: a string representation of this hand
        """
        string = ''
        for letter in self.handDict.keys():
            for j in range(self.handDict[letter]):
                string = string + letter + ' '
        return string

#
# Problem 3: Representing a Player
#

class Player(object):
    """
    General class describing a player.
    Stores the player's ID number, hand, and score.
    """
    def __init__(self, idNum, hand):
        """
        Initialize a player instance.

        idNum: integer: 1 for player 1, 2 for player 2.  Used in informational
        displays in the GUI.

        hand: An object of type Hand.

        postcondition: This player object is initialized
        """
        self.points = 0.
        self.idNum = idNum
        self.hand = hand

    def getHand(self):
        """
        Return this player's hand.

        returns: the Hand object associated with this player.
        """
        return self.hand

    def addPoints(self, points):
        """
        Add points to this player's total score.

        points: the number of points to add to this player's score

        postcondition: this player's total score is increased by points
        """
        self.points += points
        return self.points
    def getPoints(self):
        """
        Return this player's total score.

        returns: A float specifying this player's score
        """
        return self.points
    def getIdNum(self):
        """
        Return this player's ID number (either 1 for player 1 or
        2 for player 2).

        returns: An integer specifying this player's ID number.
        """
        return self.idNum
    def __cmp__(self, other):
        """
        Compare players by their scores.

        returns: 1 if this player's score is greater than other player's score,
        -1 if this player's score is less than other player's score, and 0 if
        they're equal.
        """
        totalPointsPlayer1 = self.getPoints()
        totalPointsPlayer2 = self.getPoints()
        if totalPointsPlayer1 > totalPointsPlayer2:
            return 1
        elif totalPointsPlayer1 == totalPointsPlayer2:
            return 0
        else:
            return -1
    def __str__(self):
        """
        Represent this player as a string

        returns: a string representation of this player
        """
        return 'Player %d\n\nScore: %.2f\n' % \
               (self.getIdNum(), self.getPoints())

#
# Problem 4: Representing a Computer Player

class Wordlist(object):
    """
    A word list.
    """
    def __init__(self):
        """
        Initializes a Wordlist object.

        postcondition: words are read in from a file (WORDLIST_FILENAME, a
        global constant) and stored as a list.
        """
        inputFile = open(WORDLIST_FILENAME)
        try:
            self.wordlist = []
            for line in inputFile:
                self.wordlist.append(line.strip().lower())
        finally:
            inputFile.close()

    def containsWord(self, word):
        """
        Test whether this wordlist includes word

        word: The word to check (a string)

        returns: True if word is in this Wordlist, False if word is not in
        Wordlist
        """
        return word in self.wordlist

    def getList(self):
        return self.wordlist

class ComputerPlayer(Player):
    """
    A computer player class.
    Does everything a Player does, but can also pick a word using the
    PickBestWord method.
    """

    def cut_by1st_letter(self, hand, points_dict):
        """
        The letters in the hand must begin at least one word. Cut out
        the rest.
        hand: Dictionary
        points_dict: global words -> points
        :return: reduced dictionary
        """
        reduced_dict = {}
        hand = hand.handDict
        for letter in hand:
            for word in points_dict:
                if letter == word[0]:
                    reduced_dict[word] = points_dict[word]
                else:
                    pass
        return reduced_dict

    def word_too_long(self, hand, reduced_dict, points_dict):
        """
        If the words in the list are too long to be formed by the hand, cut them out.
        :param hand: dicitonary
        :param reduced_dict:
        :return: really reduced dictionary
        """
        hand = hand.handDict
        hand_len = sum(hand.values())
        really_reduced_dict = {}
        for word in reduced_dict:
            if len(word) <= hand_len:
                really_reduced_dict[word] = points_dict[word]
            else:
                pass
        return really_reduced_dict

    def reduced_points_dict(self, hand, points_dict):
        """
        Implement the reducing dicitonary functions above.
        :param hand:
        :return: the reduced dictionary
        """
        dict = self.cut_by1st_letter(hand, points_dict)
        dict = self.word_too_long(hand, dict, points_dict)
        return dict

    def make_hand_string(self,hand):
        hand = hand.handDict
        hand_string = ""
        for i in hand.keys():
            for j in range(hand[i]):
                hand_string += i
        return hand_string

    def valid_word(self, hand, word):
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
        hand_string = self.make_hand_string(hand)
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

    def get_comparison_dict(self, hand, points_dict):
        """
        Makes another dictionary that ensures that the word is valid and
        that it can be made with the letters of the hand.
        :param hand: dictionary
        :param points_dict:
        :return: small dictionary
        """
        dict_to_compare_points = {}
        cut_dict = self.reduced_points_dict(hand, points_dict)
        for word in cut_dict:
            if self.valid_word(hand, word):
                dict_to_compare_points[word] = points_dict[word]
            else:
                pass
        return dict_to_compare_points

    def get_word_score_nobonus(self, word):
        score = 0
        for letter in word:
            score += SCRABBLE_LETTER_VALUES[letter.lower()]
        return score

    def getPointsDict(self, wordlist):
        """
        Return a dictionary that maps every word to a point value.
        :param word_list:
        :return:
        """
        wordlist = wordlist.getList()
        points_dict = {}
        for word in wordlist:
            points_dict[word] = self.get_word_score_nobonus(word)
        return points_dict

    def pickBestWord(self, word_list):
        """
        Pick the best word available to the computer player.

        returns: The best word (a string), given the computer player's hand and
        the wordlist
        """
        points_dict = self.getPointsDict(word_list)
        compare_dict = self.get_comparison_dict(self.hand, points_dict)
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

    def playHand(self, callback, wordlist):
        """
        Play a hand completely by passing chosen words to the callback
        function.
        """
        while callback(self.pickBestWord(wordlist)): pass

class HumanPlayer(Player):
    """
    A Human player class.
    No methods are needed because everything is taken care of by the GUI.
    """



class EndHand(Exception): pass

class Game(object):
    """
    Stores the state needed to play a round of the word game.
    """
    def __init__(self, mode, wordlist):
        """
        Initializes a game.

        mode: Can be one of three constant values - HUMAN_SOLO, HUMAN_VS_COMP,
        and HUMAN_VS_HUMAN

        postcondition: Initializes the players nd their hands.
        """
        hand = Hand(HAND_SIZE)
        hand2 = Hand(HAND_SIZE, hand.handDict.copy())
        if mode == HUMAN_SOLO:
            self.players = [HumanPlayer(1, hand)]
        elif mode == HUMAN_VS_COMP:
            self.players = [HumanPlayer(1, hand),
                            ComputerPlayer(2, hand2)]
        elif mode == HUMAN_VS_HUMAN:
            self.players = [HumanPlayer(1, hand),
                            HumanPlayer(2, hand2)]
        self.playerIndex = 0
        self.wordlist = wordlist
    def getCurrentPlayer(self):
        """
        Gets the Player object corresponding to the active player.

        returns: The active Player object.
        """
        return self.players[self.playerIndex]
    def nextPlayer(self):
        """
        Changes the game state so that the next player is the active player.

        postcondition: playerIndex is incremented
        """
        if self.playerIndex + 1 < len(self.players):
            self.playerIndex = self.playerIndex + 1
            return True
        else:
            return False
    def gameOver(self):
        """
        Determines if the game is over

        returns: True if the playerIndex >= the number of players, False
        otherwise
        """
        return self.playerIndex >= len(self.players)
    def tryWord(self, word):
        if word == '.':
            raise EndHand()
        player = self.getCurrentPlayer()
        hand = player.getHand()
        if self.wordlist.containsWord(word) and hand.containsLetters(word):
            points = getWordScore(word)
            player.addPoints(points)
            hand.update(word)
            if hand.isEmpty():
                raise EndHand()
            return points
        else:
            return None
    def getWinner(self):
        return max(self.players)
    def getNumPlayers(self):
        return len(self.players)
    def isTie(self):
        return len(self.players) > 1 and \
               self.players[0].getPoints() == self.players[1].getPoints()
    def __str__(self):
        """
        Convert this game object to a string

        returns: the concatenation of the string representation of the players
        """
        string = ''
        for player in self.players:
            string = string + str(player)
        return string










