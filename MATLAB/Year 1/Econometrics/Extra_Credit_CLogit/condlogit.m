function [ stoLogLike ] = condlogit( b, Y, X, subsetBool, subX)
% b = initial guess of parameters (1D), Y = choice dataset (1D, 
% X = alternative specific attributes (3D), W = individual attributes (2D), .
% D is dimension
% subsetBool is boolean value indicating subset taken

if subsetBool == 0 
    lY = length(Y);
    
    stoLogLike = 0;

    for obs = 1:lY
        zij_times_b = (X(Y(obs), :, obs)) * b;
        den = log(sum(exp( X(:,:,obs)*b) ) );
        stoLogLike = stoLogLike + (den - zij_times_b);
    end
else
    [~, ~, observations] = size(X);
    
    stoLogLike = 0;
    for obs = 1:observations
        xij = X(:, Y(obs), obs);
        xij_times_b  = xij' * b;
        subsampleX = horzcat(xij, subX(:, :, obs));
        den = log( sum( exp( subsampleX' * b ) ) );
        negLL = den - xij_times_b;
        stoLogLike = stoLogLike + negLL;
    end
    
end


