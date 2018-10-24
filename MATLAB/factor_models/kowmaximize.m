function [  ] = kowmaximize( demeanedy, init, sigmaVector, Sworld,...
    Sregion, Scountry, regionIndices)
Countries = 60;
SeriesPerCountry = 3;
country = 0;
region = 1;
for i = 1:Countries*SeriesPerCountry
%    Maximize depending on whether it is new country or first in region

    if mod(i-1,3) == 0
        country = country + 1;
        if country == regionIndices(region+1)
            region = region + 1;
            % gdp and region restricted
            Sr = Sregion(:,:,region);
            Sc = Scountry(:,:,country);
            mhStepTwoRestrictioins(demeanedy(:,i), init(i,:)', sigmaVector(i), Sworld, Sr,Sc)

%             [~,p] = chol(ahess)
        else
            % gdp only restricted
            Sc = Scountry(:,:,country);
            1;
        end
    else
        % unrestricted
    end

    
end



end

