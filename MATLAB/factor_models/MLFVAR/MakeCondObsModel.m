function [com] = MakeCondObsModel(obsmodel, iden, index)
levels = size(iden,2);
K = size(obsmodel(:,1),1);
obsmodel(:,index:end) = zeros(K, length(index:levels));
com = makeStateObsModel(obsmodel, iden, 0);
end

