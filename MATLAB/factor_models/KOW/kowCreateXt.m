function [ Xt ] = kowCreateXt( yt, SeriesPerCountry, Countries)
[K, T] = size(yt);
NXcols = Countries*SeriesPerCountry*(SeriesPerCountry+1);
Xt = zeros(K*T, NXcols);
% Create Xt matrix for vectorized yt
s = 1:SeriesPerCountry;
s1 = 1:SeriesPerCountry*(SeriesPerCountry+1);
take = 1:K;

for t= 1:T
    tx = take + (t-1)*K;
    for c = 1:Countries
        rowsx = s + (c-1)*SeriesPerCountry;
        rowsx = tx(rowsx);
        getCountry = s + (c-1)*SeriesPerCountry;
        fillx = s1 + (c-1)*SeriesPerCountry*(SeriesPerCountry+1);
        Xt(rowsx, fillx) = kron(eye(SeriesPerCountry), [1,yt(getCountry,t)']);
    end
end
end

