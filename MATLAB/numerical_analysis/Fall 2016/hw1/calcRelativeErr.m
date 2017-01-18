function [ relErr] = calcRelativeErr( exact, approx )
relErr = abs( (exact - approx) )/ abs(exact);
end

