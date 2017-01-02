import cmath
import math


def quadRoots():
    print "The quadratic root solver."
    print "Assume: ax^2 + b x + c = 0"
    print "Enter \'.\' to exit at any time."
    print 
    print "Enter..."
    while True:
        answers = []
        a = raw_input("Coefficient on quadratic term...")
        if a == '.':
            return
        b = raw_input("Coefficient on linear term...")
        if a == '.':
            return
        c = (raw_input("Constant..."))
        if a == '.':
            return
        a = float(a)
        b = float(b)
        c = float(c)
        if b**2 - 4*a*c < 0:
            ans = (-b + cmath.sqrt((b**2 - 4*a*c))/(2*a))
            answers += [(ans)]
            ans = (-b - cmath.sqrt(b**2 - 4*a*c)/(2*a))
            answers += [ans ]
        else:
            num = (-b + math.sqrt(b**2 - 4*a*c))
            answers += [round(num / (2.0*a), 3)]
            num = (-b - math.sqrt(b**2 - 4*a*c))
            answers += [round(num / (2*a), 3)]
        print 
        print "The roots are:", answers
        print 
        print "Next quadratic or press \'.\' to exit."
        

print quadRoots()


