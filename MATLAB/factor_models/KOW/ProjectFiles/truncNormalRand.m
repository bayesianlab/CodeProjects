function [rn] = truncNormalRand(a,b,mu,sigma)
standardizedA = (a - mu) / sigma;
standardizedB = (b - mu) / sigma;
stdLimit = 8;
if (mu>a) && (mu < b)
    rn = tnormrnd(a,b,mu,sigma);
elseif 1e3 < b
    if  stdLimit < standardizedA 
        rn = mu + sigma*leftTruncation(standardizedA);
        return
    else
        rn = tnormrnd(a,b,mu,sigma);
        return
    end
elseif a<-1e3
    if standardizedB < -stdLimit
        rn = mu - sigma*leftTruncation(-standardizedB);
        return
    else
        rn = tnormrnd(a,b,mu,sigma);
        return
    end
else
    if standardizedA > stdLimit
        rn = mu + sigma*twoSided(standardizedA, standardizedB);
        return
    elseif standardizedB < -stdLimit
        rn = mu + sigma*twoSided(standardizedA, standardizedB);
        return
    else
        rn = tnormrnd(a,b,mu,sigma);
    end
end
end

