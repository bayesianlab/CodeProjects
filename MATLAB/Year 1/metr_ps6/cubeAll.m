function [ spline ] = cubeAll( aVec, knot )

spline = zeros(length(aVec),1);
for i=1:length(aVec)
    if (aVec(i,1) - knot) > 0
        spline(i,1) = (aVec(i,1)-knot);
    end
end
splineSqd =spline.*spline;
splineCubed = spline.*splineSqd;
spline = [spline splineSqd splineCubed];
end

