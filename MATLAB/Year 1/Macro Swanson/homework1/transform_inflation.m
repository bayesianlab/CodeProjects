function [ cast ] = transform_inflation( series, lcpi )

cast = zeros(length(series),1);
cast(1,1) = exp(lcpi);
for i = 1:length(series)
    cast(i+1,1) = exp(series(i,1) + log(cast(i,1)) );
end
cast = cast(2:length(cast));
end

