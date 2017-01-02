function [ ols_ests, tStats, tCrit, residuals, covar ] = vreg(  data_mat,...
    ar_terms, nullHypothesis, ci, altEnum, dBool )
X_t = vectorized_lags(data_mat, ar_terms);

[row_y, columns_y] = size(data_mat);
data_mat = data_mat(ar_terms + 1:row_y, :);
[row_x, columns_x] = size(X_t);

ols_ests = zeros(columns_x, columns_y);
residuals = zeros(row_x, columns_y);
tStats = zeros(1 + columns_y*ar_terms, columns_y);
tCrit = zeros(columns_y,1);

for col = 1:columns_y
    [ols_ests(:,col),~, tStats(:, col), tCrit(col), residuals(:,col)] =...
        betaLS(X_t, data_mat(:, col), nullHypothesis, ci, altEnum, 0);
end
covar = residuals'*residuals/((row_y - ar_terms)-(columns_y*ar_terms + 1)) ;   

if nargin > 5
    if dBool == 1
        charArray = {};
        for i = 1 : ar_terms
            str = sprintf( 'Lag %i ', i);
            charArray{i} = str;
        end
        columnTitleAr = {'Lags'};
        for j = 2 : columns_y + 1
            str = sprintf( 'X_%i', j-1);
            columnTitleAr{j} = str;
        end
        testStrs = {};
        for k = 1 : columns_y
            str = sprintf( 'T-Stat X_%i', k);
            testStrs{k} = str;
        end
        tstats_labeled = vertcat(testStrs, num2cell(tStats));
        est_cells = num2cell(ols_ests);
        lagLabels = [{'Constant'}, charArray, charArray]'; 
        ests_results = [cellstr(lagLabels), est_cells];        
        results = vertcat(columnTitleAr, ests_results);
        ests_w_stats = [results, tstats_labeled];
        ests_w_stats{1,1} = ' ';
        disp(ests_w_stats)
        str = sprintf('T-Critical Value %.4f \n', abs(tCrit(1)));
        disp( str )
      
    end
end

   

end



