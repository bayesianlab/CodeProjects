function [ ObsModel ] = kowmaximize( demeanedy, init, sigmaVector, Sworld,...
    Sregion, Scountry, regionIndices)
Countries = 60;
SeriesPerCountry = 3;
country = 0;
region = 1;
Sr = Sregion(:,:,region);
Sc = Scountry(:,:,1);
ObsModel = zeros(3,Countries*SeriesPerCountry);
% USA GDP has three restrictions
ObsModel(:,1) = mhForUSAGDP(demeanedy(:,1), init(1,:)', sigmaVector(1), Sworld, Sr, Sc);
for i = 2:Countries*SeriesPerCountry
    if mod(i-1,3) == 0
        country = country + 1;
        if country == regionIndices(region+1)
            region = region + 1;
            % gdp and region restricted
            Sr = Sregion(:,:,region);
            Sc = Scountry(:,:,country);
            ObsModel(:,i) = mhStepTwoRestrictions(demeanedy(:,i), init(i,:)', sigmaVector(i), Sworld, Sr,Sc);
        else
            % gdp only restricted
            Sc = Scountry(:,:,country);
            ObsModel(:,i) = mhStepOneRestriction(demeanedy(:,i), init(i,:)', sigmaVector(i), Sworld, Sr,Sc);
        end
    else
        % unrestricted
        ObsModel(:,i) = mhStepUnRestricted(demeanedy(:,i), init(i,:)', sigmaVector(i), Sworld, Sr,Sc);
    end

    
end
end

