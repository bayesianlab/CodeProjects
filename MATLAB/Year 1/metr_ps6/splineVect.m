function [ alteredVector ] = splineVect( aVector, paramsForKnots)
% paramsForKnots a vector of three signifying 
% [startVal, endVal, number of Knots] 
knots = linspace(0,2,5);
numbKnots = length(knots);
alteredVector = zeros(length(aVector), 15);
for knot = 1:numbKnots
    bgnIndx = 3*knot - 2;
    endIndx = 3*knot;
    alteredVector(:,bgnIndx:endIndx) = cubeAll(aVector, knots(knot));
end


end

