function [StateObsModel] = makeStateObsModel(obsModel, IRegion,ICountry)
StateObsModel = [obsModel(:,1), IRegion.*obsModel(:,2), ICountry.*obsModel(:,3)];
end

