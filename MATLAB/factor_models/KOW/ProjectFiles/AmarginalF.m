function [currobsmod] = AmarginalF(SeriesPerCountry, InfoMat, Factor, yt,...
    currobsmod,  ObsPriorMean, ObsPriorVar, lastMean, lastHessian )
options = optimoptions(@fminunc, 'Algorithm', 'quasi-newton',...
        'Display', 'iter', 'FiniteDifferenceType', 'central',...
         'MaxIterations', 100, 'MaxFunctionEvaluations', 600);
Countries = size(InfoMat,1);
Regions = length(unique(InfoMat(1,:)));
% May have to remove factor from y1 
t = 1:SeriesPerCountry;
[K,T] = size(yt);
changeRegion = InfoMat(1,1);
InfoMat = [1,1; 1,2; 1,3; 2,4;2,5; 3,6;4,7]
Countries = size(InfoMat,1);
for c = 1:Countries
    [InfoMat(c,1),c]
    if c == 1
        RestrictionLevel = 3
    elseif InfoMat(c,1) ~= changeRegion
        RestrictionLevel = 2
        changeRegion = InfoMat(c,1);
    else
        RestrictionLevel = 1
    end
    
%     subsetSelect = t + SeriesPerCountry*(c-1);
%     [subFt, subTrans]  = subsetFt(Factor, InfoMat(c,:), Regions);
%     factorPrecision = kowStatePrecision(diag(subTrans), 1, T);
%     yslice = yt(subsetSelect,:);
%     precisionSlice = obsPrecision(subsetSelect);
%     x0 = currobsmod(subsetSelect,:);
%     [xt, lastMean, lastHessian] = optimizeA(x0, yslice,...
%         ObsPriorMean, ObsPriorVar, precisionSlice, subFt,...
%         factorPrecision, lastMean, lastHessian, RestrictionLevel, options);
%     currobsmod(subsetSelect,:) = xt;
end

