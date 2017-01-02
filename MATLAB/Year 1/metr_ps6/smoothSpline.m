function [ alteredVector ] = smoothSpline( aVector, paramsForKnots)
% paramsForKnots a vector of three signifying 
% [startVal, endVal, number of Knots] 
knots = linspace(0,2,5);
numbKnots = length(knots);
alteredVector = zeros(length(aVector), 7);
for knot = 1:numbKnots
    if knot == 1    
        bgnIndx = 3*knot - 2;
        endIndx = 3*knot;
        alteredVector(:,bgnIndx:endIndx) = cubeAll(aVector, knots(knot));
    else
        alteredVector(:,2+knot) = selectivelyCube(aVector, knots(knot));
    end      
end

end

