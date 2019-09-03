__author__ = 'dillonflannery-valadez'

from termcolor import colored

class TestStructure():

    def __init__(self):
        pass

    def assertEqual(self, str1, str2):
        if str1 != str2:
            msg = 'Test Failed: Not Equivalent. \n'  + str(str1) + " != " + str(str2)
            print colored(msg, 'red', attrs=['bold'])
            print
            return
        else:
            print colored('Test passed.', 'green', attrs=['bold'])
            print colored(str(str1) + ' == ' + str(str2), 'green')
            print
            return


