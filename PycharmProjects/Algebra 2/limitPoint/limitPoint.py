__author__ = 'dillonflannery-valadez'


def period(x):
    if x == '.':
        return True
    else:
        return False


def evalNewPoint(string):
    if string == 'Y' or string == 'y':
        return True
    else:
        return False


def polyEval(coeffs, point):
    y = -1
    highestDeg = len(coeffs) - 1
    FofX = 0
    for i in coeffs[0:(len(coeffs) - 1)]:
        y += 1
        FofX += i * (point ** (highestDeg - y))
    FofX += coeffs[-1]
    return FofX


def coeffsN():
    x = 0
    print
    highestdeg = raw_input("What is the highest degree of the polynomial in the numerator?  ")
    highestdeg = int(highestdeg)
    coeffs = []
    while x <= highestdeg:
        coefprompt = "Coefficient of the x to the %i:  "
        numb = raw_input(coefprompt %
                         (highestdeg - x))
        if numb == '.':
            return '.'
        coeffs += [float(numb)]
        x += 1
    print "The Numerator Coefficients are ", coeffs
    print "Making the equation in the numerator: " + str(rationalformat(coeffs, highestdeg))
    print
    return coeffs


def coeffsD():
    x = 0
    coeffs = []
    print
    degreepoly = "What is the highest degree of the polynomial in the denominator?  "
    highestdeg = raw_input(degreepoly)
    highestdeg = int(highestdeg)
    while x <= highestdeg:
        coefprompt = "Coefficient of the x to the %i:  "
        numb = raw_input(coefprompt % (highestdeg - x))
        if numb == '.':
            return '.'
        coeffs += [float(numb)]
        x += 1
    dcoeffs = "Denominator cofficients "
    print "The Denominator Coefficients are: ", coeffs
    print "Making the equation in the denominator: " + str(rationalformat(coeffs, highestdeg))
    print
    return coeffs


def coeffsRedo(coeffs, numORden):
    coeffs = coeffs
    if numORden == "N":
        coeffsprompt = "Numerator coefficients  "
    else:
        coeffsprompt = "Denominator cofficients "
    correction = "Is this correct? Y/N  "
    correct = raw_input(correction)
    if correct == "N" or correct == "n":
        notcorrect = True
        while notcorrect == True:
            if numORden == "N":
                coeffs = coeffsN()
                if coeffs == ".":
                    return
                print
                correct = raw_input(correction)
                if correct == ".":
                    return
                if correct == "Y" or correct == "y":
                    return coeffs
                else:
                    notcorrect = True
            else:
                coeffs = coeffsD()
                correct = raw_input(correction)
                if correct == ".":
                    return
                if correct == "Y" or correct == "y":
                    return coeffs
                else:
                    notcorrect = True
    else:
        return coeffs


def numeratorhandling(coeffs, apoint):
    fofx = polyEval(coeffs, apoint)
    return fofx


def denominatorhandling(coeffs, apoint):
    gofx = polyEval(coeffs, apoint)
    return gofx


def aPoint():
    somepoint = raw_input("What point would you like to evaluate?  ")
    somepoint = float(somepoint)
    return somepoint


def welcomePrintout():
    print
    print "\t Finding Asymptotes: Input degree of polynomial and a point."
    print "\t Return value is the y value at the inputed point."
    print
    print "\t Enter the value of the coefficients on each term."
    print "\t If a term does not exist put in 0."
    print
    print "\t ENTER PERIOD '.' TO EXIT AT ANY TIME!"
    print
    return


def rationalredonewpoint(coefficientsNum, coefficientsDen):
    highestDegN = len(coefficientsNum) - 1
    highestDegD = len(coefficientsDen) - 1
    redo = True
    while redo == True:
        print
        question = "Would you like to evaluate the same rational function at another point? Y/N  "
        answer = raw_input(question)
        if answer == "Y" or answer == "y":
            point = aPoint()
            num = numeratorhandling(coefficientsNum, point)
            den = denominatorhandling(coefficientsDen, point)
            pofx = num/den
            print "(" + str(rationalformat(coefficientsNum, highestDegN)) + ")/" + \
                  "(" +  str(rationalformat(coefficientsDen, highestDegD)) + ") at point %f is: " % (point)
            print "\t", pofx
            print
        else:
            return False

def indexofnegs(coeffs):
    x = []
    y = -1
    for i in coeffs:
        y += 1
        if i < 0:
            x += [y]
    return x

def rationalformat(coeffs,  highestDegN):
    numerator = ""
    degreecount = -1
    indxofnegs = indexofnegs(coeffs)
    for i in coeffs:
        degreecount += 1
        if degreecount == highestDegN:
            if degreecount in indxofnegs:
                i = abs(i)
                numerator = numerator[:len(numerator) - 2]
                numerator += "- " + str(i)
            else:
                numerator = numerator[:len(numerator) - 1]
                numerator += " " + str(coeffs[-1])
            return numerator
        else:
            if degreecount in indxofnegs and degreecount != 0:
                i = abs(i)
                numerator = numerator[:len(numerator ) - 2]
                numerator += "- " + str(i) + "x^%i + " %(highestDegN - degreecount)
            else:
                numerator += str(i) + "x^%i + " % (highestDegN - degreecount)


def terminator():
    print "\n\n\t Program Terminated"


def restart_statement():
    print "Restarting..."


def limitPoints():
    welcomePrintout()
    while True:
        numcoeffs = coeffsN()
        if numcoeffs == ".":
            return
        coefficientsNum = coeffsRedo(numcoeffs, "N")
        highestDegN = len(coefficientsNum) - 1
        if coefficientsNum == ".":
            return
        dencoeffs = coeffsD()
        coefficientsDen = coeffsRedo(dencoeffs, "D")
        highestDegD = len(coefficientsDen) - 1
        if coefficientsDen == ".":
            return
        point = aPoint()
        if point == ".":
            return
        pofx = numeratorhandling(coefficientsNum, point) / denominatorhandling(coefficientsDen, point)
        print "(" + str(rationalformat(coefficientsNum, highestDegN)) + ")/" + \
                  "(" +  str(rationalformat(coefficientsDen, highestDegD)) + ") at point %f is: " % (point)
        print "\t", pofx
        redoatnewpoint = rationalredonewpoint(coefficientsNum, coefficientsDen)
        if redoatnewpoint == False:
            terminate = raw_input("Would you like to quit the program or start over with a new function?"
                                  " Enter Q for Quit or R for restart: Q/R  ")
            if terminate == "Q" or terminate == "q":
                terminator()
                return
            elif terminate != "R" or terminate != "r":
                restart_statement()
            else:
                terminator()
                return


limitPoints()
