function [ spline ] = selectivelyCube( aVector, knot )

aVector = cleanData(aVector, knot );
spline = zeros(length(aVector),1);
for i=1:length(aVector)
    if aVector(i,1) > 0
        spline(i,1) = (aVector(i,1)-knot);
    end
end

spline = spline.*spline.*spline;

end

