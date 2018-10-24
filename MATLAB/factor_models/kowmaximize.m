function [  ] = kowmaximize( demeanedy, init, sigmaVector, Sworld,...
    Sregion, Scountry, regionIndices)
Countries = 60;
SeriesPerCountry = 3;
country = 0;
region = 1;
for i = 1:Countries*SeriesPerCountry
    if mod(i-1,3) == 0
        country = country + 1;
    end
    if country == regionIndices(region+1)
        region = region + 1;
    end
    Sr = Sregion(:,:,region);
    Sc = Scountry(:,:,country);
    dll = @(guess) kowll(demeanedy(:,i), 1, guess, Sworld, Sr, Sc, .1);
    [amean, ahess] = bhhh(init(i,:)', dll, 3, .1, .5);
    [~,p] = chol(ahess)
end



end

