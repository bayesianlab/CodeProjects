function [ forecasts, variables  ] = fcastvar_perturbed( periods_out, impulse, X, p )
[row,col] = size(X);
forecasts = zeros(periods_out, col);
[coeffs] = vreg(X, p);
variables = zeros(periods_out, col*p + 1);

for period =  1:periods_out
    if period == 1
        cur_t = updateObservations(X, p) ;
        variables(period, :) = cur_t;
        t_plus_one = cur_t*coeffs + impulse;
        forecasts(period, :) = t_plus_one;
        X = vertcat(X, t_plus_one);
    else
        cur_t = updateObservations(X, p) ;
        variables(period, :) = cur_t;
        t_plus_one = cur_t*coeffs;
        forecasts(period, :) = t_plus_one;
        X = vertcat(X, t_plus_one);
    end

end




end

