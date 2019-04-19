function [] = SpatialMLFdata(SeriesPerY, Nsquares, drawsFromCube, ploton, T)


x = 0:1/Nsquares:1;
y = x;

if ploton == 1
    hold on
    plot(x(1), y(3))
    for k = 1:Nsquares + 1
        for m = 1:Nsquares + 1
            X = [x(m), x(m)];
            Y = [y(1), y(end)];
            plot( X,Y, 'black')
            plot(Y,X, 'black');
        end
    end
end


[D,cuts] = EuclideanNeighbor(Nsquares, ploton)


% D = nearest_neighbor(Nsquares);

rng(4)
yassignment = sort(randi([1,20], drawsFromCube,1));
uni = unique(yassignment);
Nuni = length(uni);
K = SeriesPerY*drawsFromCube;
yassignment = kron(yassignment, ones(SeriesPerY,1));
yassignment

b=1;
nFactors = Nuni;
regionInfo = zeros(Nuni,2);
for q = 1:Nuni
    n = sum(yassignment==uni(q));
    e = b+n-1;
    regionInfo(q,:) = [b,e];
    b= e+1;
end
regionInfo

gammas = unifrnd(.01,.3, nFactors,1);
stateTransitionsAll = gammas'.*eye(nFactors);
speyet = speye(T);
S = kowStatePrecision(stateTransitionsAll, 1, T)\speye(nFactors*T);
Factor = mvnrnd(zeros(nFactors*T,1), S);
Factor = reshape(Factor,nFactors,T);


[Identities, sectorInfo] = MakeObsModelIdentity(InfoCell);
% I1 = Identities{1,2};
% I2 = Identities{1,3};
% Z0 = zeros(K,1);
% Z1 = zeros(size(I1,1), size(I1,2));
% Z2 = zeros(size(I2,1), size(I2,2));
% Gt = unifrnd(.5,1,K,3);
% WorldOnly = Gt(:,1);
% RegionsOnly = Gt(:,2).*I1;
% CountriesOnly = Gt(:,3).*I2;
% Gt = [WorldOnly, RegionsOnly,CountriesOnly];
%
%
% mu = Gt*Factor;
% yt = mu + normrnd(0,1,K,T);
%
% Gt = [Gt(:,1), sum(Gt(:,2:Regions+1),2), sum(Gt(:,Regions+2:end),2)];
% Xt =0;
% DataCell = cell(1,7);
% DataCell{1,1} = yt;
% DataCell{1,2} = Xt;
% DataCell{1,3} = InfoCell;
% DataCell{1,4} = Factor;
% DataCell{1,5} = beta;
% DataCell{1,6} = gam;
% DataCell{1,7} = Gt;
%

end
