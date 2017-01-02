function [ forecasts ] = fcastlevel( periods_out, X, p )
[row,col] = size(X);
forecasts = zeros(periods_out, col);
[coeffs] = vreg(X, p);
variables = zeros(periods_out, col*p + 1);

for period =  1:periods_out
    cur_t = updateObservations(X, p) ;
    variables(period, :) = cur_t;
    t_plus_one = cur_t*coeffs;
    forecasts(period, :) = t_plus_one;
    X = vertcat(X, t_plus_one);

end
[r, c] = size(X);
vec_to_make_level = X(1:(r-1),1);
vec_to_make_level = updateObservations( vec_to_make_level, periods_out );
vec_to_make_level(1) = [];
vec_to_make_level = flip(vec_to_make_level)' ;
level_fore = exp(forecasts(:,1) + vec_to_make_level);
forecasts(:,1) = level_fore;




end

