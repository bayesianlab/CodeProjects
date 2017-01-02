def polyEval(coeffs, point):
    y = -1
    highestDeg = len(coeffs) - 1
    FofX = 0
    for i in coeffs[0:(len(coeffs) -1)]:
         y += 1
         FofX += i *(point**(highestDeg - y))
    FofX += coeffs[-1]
    return FofX
print polyEval([1,2,3], 2.1, -1)

def coeffs(highestDeg):
    x = 0
    while x <= highestDeg:
        check = raw_input("Coefficient of the x to the %i:" %
                          (highestDeg - x) )
        if check == '.':
            return '.'
        coeffs += [float(check)]
        x += 1
    return coeffs
        
