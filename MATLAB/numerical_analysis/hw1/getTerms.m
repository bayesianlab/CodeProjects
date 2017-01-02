function [ terms ] = getTerms( x, errTolerance, maxIt )
if checkX(x) == 0
    disp('Error in input, must be greater than 0, \nless than 1')
    return
else
    terms = 0;
    approx = x;
    warning = 0;
    exact = sin(x);
    while terms <= maxIt
        terms = terms + 1;
        if mod(terms, 2) == 0
            approx = approx + sinSeries(terms, x);
        else
            approx = approx - sinSeries(terms, x);
        end
        
        err = calcRelativeErr(exact, approx);
        if  err < errTolerance
            disp(sprintf('Approximation satisfactory...x set to %.4f', x))
            disp(sprintf('Absolute error %.18f', abs(exact - approx)))
            str = sprintf('\t%i terms necessary', terms);
            disp(str)
            disp(sprintf('\tRelative Error: %.18f', err))
            disp(sprintf('\tValue of approximation  %.18f', (approx/x)-1))
            disp(sprintf('\tValue of exact function %.18f\n', (exact/x)-1))
            warning = 1;
            return
        end
    end
    if warning == 0
        disp(sprintf('\nWARNING: Approximation never less than err. tol.'))
        disp(sprintf('Absolute Error %.18f', abs(exact - approx)))
        disp(sprintf('Approximation %.18f', approx))
        disp(sprintf('Exact         %.18f', exact))
        disp(sprintf('x= %.4f, terms= %i\n', x, terms))
    end
end

