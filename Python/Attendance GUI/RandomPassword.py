__author__ = 'dillonflannery-valadez'

import string
import random
import time

VOWELS = 'aeiou'
CONSONANTS = 'bcdfghjklmnpqrstvwxyz'
NUMBERS = "1234567890"
EXTRA = "!@#$%^&*"
char = VOWELS + CONSONANTS + EXTRA


# Seed for Chambers Bank password: 4
# Seed for Charles Schwab 10
# Seed for ebay 27
# Seed for PayPal 7
vow = []
class RandomPassword():

    def genPassword(n, seed):
        random.seed(seed)
        password = ""
        passordLength = n
        numLetters = len(string.ascii_lowercase)
        numNumbers = len(string.digits)
        for i in range(passordLength):
            if i <= 3:
                password += string.ascii_lowercase[random.randrange(0, numLetters)]
            elif 3 < i <= 10:
                password += string.digits[random.randrange(0, (numNumbers))]
            elif 10 < i <= 13:
                password += EXTRA[random.randrange(0, len(EXTRA))]
            elif i > 12:
                password += string.ascii_uppercase[random.randrange(0, (numLetters))]
        return password

    def strongerPassword(numCapLets , numLowLets , numDigs, numChars, seed):
        random.seed(seed)
        password = ""
        chars = "!@#$%&*"
        lowLets = list(string.ascii_lowercase)
        bigLets = list(string.ascii_uppercase)
        digs = list(string.digits)
        chars =  list(chars)
        passwordList = []
        for i in range(0, numCapLets):
            passwordList.append(random.choice(bigLets))
        for i in range(0, numLowLets):
            passwordList.append(random.choice(lowLets))
        for i in range(0, numDigs):
            passwordList.append(random.choice(digs))
        for i in range(0, numChars):
            passwordList.append(random.choice(chars))
        random.shuffle(passwordList)
        str(passwordList)
        for i in passwordList:
            password += i
        return password


class GenerateThreeDigitCodes(RandomPassword):

    def __init__(self):
        self.numChars= 0
        self.numLow = 0
        self.numHigh = 0
        self.numDigs = 3
        self.seed = 1

    def CreateCodes(self, numStudents):
        storage = []
        for i in numStudents:
            storage.append(RandomPassword.strongerPassword())
        print storage

# Chambers
# print "Chambers"
# print genPassword(18, 4)
# Schwab
# print
# print "Schwab"
# print "4" + genPassword(7, 10)
# eBay
# print
# print "eBay"
# print genPassword(27, 15)
# PayPal
# print
# print "PayPal"
# print genPassword(20, 7)
# """ CHASE Sapphire Preferred. Seed = 99 """
# print
# print "CHASE"
# print strongerPassword(2, 3,3,2, 99)
# print
# print "Dropbox"
# print strongerPassword(5,20, 8, 5, 13)
# print
# schoolFirst_systemTime = 1442964801.96
# print "School First bank account"
# print strongerPassword(3, 10, 7,0, schoolFirst_systemTime)
# print
# gmailSeed = 1445824807.54
# print "New Gmail password"
# print strongerPassword(5,5,5,5,gmailSeed)
#
#
#
#
#
