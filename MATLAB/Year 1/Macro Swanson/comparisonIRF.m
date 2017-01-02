function [ output_and_percentiles, inflation_and_percentiles,...
    interest_and_percentiles ] = comparisonIRF( threeD, X, lags, periods)
[height, width, depth] = size(threeD);
[rows, columns] = size(X);
lowB = round(2.5*depth/100);
if lowB == 0
    lowB = 1;
end
upB = round(97.5*depth/100);
med = round(0.5*depth);
store_results = zeros(periods, columns, depth);
for d = 1:depth
    m_shock = calculate_shock( threeD(:,:,d) );
    store_results(:, :,  d) = IRF_var(periods, X, lags, m_shock);
end
sorted_along3D = sort(store_results, 3);
lower_percentile = zeros(periods, columns);
upper_percentile = zeros(periods, columns);
median = zeros(periods, columns);
for p = 1:periods
    lower_percentile(p,:) = sorted_along3D(p, :, lowB);
    upper_percentile(p,:) = sorted_along3D(p, :, upB);
    median(p,:) = sorted_along3D(p, :, med);
end
output_and_percentiles = [lower_percentile(:,1), upper_percentile(:,1),...
    median(:,1)];
inflation_and_percentiles = [lower_percentile(:,2), upper_percentile(:,2)...
    median(:,2)];
interest_and_percentiles = [lower_percentile(:,3), upper_percentile(:,3)...
    median(:,3)];
end

