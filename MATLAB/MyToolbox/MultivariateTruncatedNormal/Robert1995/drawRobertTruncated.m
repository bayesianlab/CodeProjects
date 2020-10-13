function[x] = drawRobertTruncated(lowerTruncPoint)
c=0;
MAX = 100;
alphaOptimal=.5*(lowerTruncPoint + sqrt(lowerTruncPoint^2 + 4));
while c <= MAX
    z = shiftedExponentialDist(alphaOptimal, lowerTruncPoint,1);
    logrhoz=-.5*((z-alphaOptimal)^2);
    lu = log(unifrnd(0,1));
    if lu <= logrhoz
        x = z;
        return
    end
    c=c+1;
end
fprintf('Error in drawRobertTruncated\n')
end

