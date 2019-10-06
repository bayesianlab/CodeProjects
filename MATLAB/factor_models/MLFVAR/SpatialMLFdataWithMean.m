function [DataCell] = SpatialMLFdataWithMean(SeriesPerY, gridX,...
    samplesFromGrid, GroupingInfo, ploton,  T, parama, corrType)
K = samplesFromGrid*SeriesPerY;
factorI = MakeObsModelIdentity(GroupingInfo);
nFactors = sum(cellfun(@(x)size(x,1), GroupingInfo));
levels = size(GroupingInfo,2);


factorI = MakeObsModelIdentity(GroupingInfo);
nFactors = sum(cellfun(@(x)size(x,1), GroupingInfo));

if corrType == 1
    [D, cuts] = nearest_neighbor(gridX);
    [~,~, Middles] = EuclideanNeighbor(gridX, 0);
    midpoint = min(cuts) + .1
%     midpoint = mean(cuts);
else
    [D,~, Middles] = EuclideanNeighbor(gridX, ploton);
end

uniqueSquares = sort(datasample( [1:gridX^2], samplesFromGrid, 'Replace', false))';
x = 0:1/gridX:1;
y = x;
if ploton == 1
    hold on
    plot(x(1), y(3))
    for k = 1:gridX + 1
        for m = 1:gridX + 1
            X = [x(m), x(m)];
            Y = [y(1), y(end)];
            plot( X,Y, 'black')
            plot(Y,X, 'black');
        end
    end
    for k = 1:length(uniqueSquares)
        
        xy = Middles(uniqueSquares(k),:);
        plot(xy(1), xy(2), '.', 'MarkerSize', 18, 'Color', 'black')
    end
end
yassignment = kron(uniqueSquares, ones(SeriesPerY,1));
[I1,I2] = SpatialMakeIdentities(K,SeriesPerY, length(uniqueSquares));
InfoCell{1,1} = [1,K];



if levels > 2
    %     seriesFactors = samplesFromGrid*yPerSquare;
else
    seriesFactors = 0;
end


gammas = unifrnd(.01,.3, nFactors,1);
stateTransitionsAll = gammas'.*eye(nFactors);
speyet = speye(T);
S = kowStatePrecision(stateTransitionsAll, ones(nFactors,1), T)\speye(nFactors*T);
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);


smallD = selectCorrElems(D, uniqueSquares);
if corrType == 1
    parama = midpoint
    ImA =  eye(size(smallD,1)) - (parama.*smallD);
    t = diag(diag(ImA).^(-.5));
    R = t*ImA*t;
else
    R = exp(-parama.*smallD);
end

Gt = unifrnd(0.01,.5,K,levels);
G = makeStateObsModel(Gt, factorI, 0);
mu2 = G*Factor;

LR = chol(R,'lower');
xcols = 3;
Xt = normrnd(0,1, K*T, xcols);
Xt(:,1) = ones(K*T,1);
beta = .4.*ones(xcols, 1);
mu1 = reshape(Xt*beta, K,T);
yt = LR*normrnd(mu1 + mu2,1,K,T);
R
corr(yt')
SpatialInfo = {[1,zeros(1,nFactors-1)]};

DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = GroupingInfo;
DataCell{1,4} = SpatialInfo;
DataCell{1,5} = smallD;
DataCell{1,6} = Factor;
DataCell{1,7} = gammas;
DataCell{1,8} = Gt;

end
