function [ output_args ] = kowmaximize( demeanedy, init, sigmaVector, Sworld,...
    Sregion, Scountry)

newCountry = 0;
region = 1;
for i = 1:Eqns
    if mod(i-1,3) == 0
        newCountry = newCountry + 1;
    end
    if newCountry == regionIndices(region+1)
        region = region + 1;
    end
    Sr = Sregion(:,:,region);
    Sc = Scountry(:,:,country);
    dll = @(guess) kowml(demeanedy(:,i), sigmaVetor, guess, Sworld, Sregion, Scountry);
    [amean, ahess] = bhhh(init, dll, 5, .1, .5)
end



end

