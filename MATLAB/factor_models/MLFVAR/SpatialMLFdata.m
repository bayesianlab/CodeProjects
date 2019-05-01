function [DataCell] = SpatialMLFdata(SeriesPerY, gridX,...
    samplesFromGrid, ploton, levels, T, corrType)


DataCell = cell(1,levels);

if corrType == 1
    [D, cuts] = nearest_neighbor(gridX);
    [~,~, Middles] = EuclideanNeighbor(gridX, 0);
    midpoint = mean(cuts);
else
    [D,cuts, Middles] = EuclideanNeighbor(gridX, ploton);
    midpoint = mean(cuts);
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
K = length(yassignment);
[I1,I2] = SpatialMakeIdentities(K,SeriesPerY, length(uniqueSquares));
InfoCell{1,1} = [1,K];

[InfoCell{1,2}, regionFactors] = setRegionalIndices(I2, SeriesPerY);

if levels > 2
%     seriesFactors = samplesFromGrid*yPerSquare;
else
    seriesFactors = 0;
end
nFactors = seriesFactors + regionFactors + 1;

gammas = unifrnd(.01,.3, nFactors,1);
stateTransitionsAll = gammas'.*eye(nFactors);
speyet = speye(T);
S = kowStatePrecision(stateTransitionsAll, 1, T)\speye(nFactors*T);
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);

levels = length(DataCell);
Gt = unifrnd(0.01,.5,K,nFactors);
G = [I1, I2];

Gt = Gt .* G;
mu = Gt*Factor;

smallD = selectCorrElems(D, uniqueSquares);
if corrType == 1
    ImA =  eye(size(smallD,1)) - (midpoint.*smallD);
    t = diag(diag(ImA).^(-.5));
    R = t*ImA*t;
else
    R = exp(-1.*smallD);
end

LR = chol(R,'lower');
BigLR = kron(eye(SeriesPerY), LR);

yt = BigLR*normrnd(mu,1,K,T);

Xt =0;

DataCell = cell(1,7);
DataCell{1,1} = yt;
DataCell{1,2} = Xt;
DataCell{1,3} = InfoCell;
DataCell{1,4} = smallD;
DataCell{1,5} = Factor;
DataCell{1,6} = gammas;
DataCell{1,7} = Gt;
end
