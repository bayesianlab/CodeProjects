# Evaluate polynomials

def period(x):
    if x == '.':
        return True
    else:
        return False

def evalNewPoint(string):
    if string == Y:
        return True
    else:
        return False
def limitPoints():
    print 
    print "\t Finding Asymptotes: Input degree of polynomial and a point."
    print "\t Return value is the y value at the inputed point."
    print
    print "\t Enter the value of the coefficients on each term."
    print "\t If a term does not exist put in 0."
    print 
    while True:
        
        FofX = 0
        GofX = 0
        x = 0
        y = -1
        coeffs1 = []
        coeffs2 = []
        check = ""

        point = raw_input("Enter the point you want to want the funtion"
                            "to evaluate: ")
        if period(point) == True:
            return
        point = float(point)
        
        ########################
        # Numerator Evaluation #
        ########################
        
        highestDeg1 =(raw_input("Enter highest degree of polynomial"
                                " in numerator: "))
        if period(highestDeg1) == True:
            return
        highestDeg1 = int(highestDeg1) 
        while x <= highestDeg1:
            check = raw_input("Coefficient of x to the %i: " %
            (highestDeg1 - x) )
            if period(check) == True:
                return
            
            coeffs1 += [float(check)]
            x+=1
        print coeffs1, "Numerator coefficients"
        for i in coeffs1[0:(len(coeffs1) -1)]:
            y += 1
            FofX += i *(point**(highestDeg1 - y))
        FofX += coeffs1[-1]
        print FofX, "Value of numerator"
