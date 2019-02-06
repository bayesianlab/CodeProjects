function [ backupcell ] = setBackups( InfoMat, SeriesPerCountry, idrestrict)
countries = size(InfoMat,1);
backupMeanAndHessian = cell(countries,6);
detectChange = InfoMat(1);

if idrestrict == 1
    for c = 1:countries
        if c == 1
            backupcell{c,1} = zeros(1,SeriesPerCountry-1);
            backupcell{c,2} = eye(SeriesPerCountry- 1);
            backupcell{c,3} = backupcell{c,1};
            backupcell{c,4} = backupcell{c,2};
            backupcell{c,5} = backupcell{c,1};
            backupcell{c,6} = backupcell{c,2};
        else
            if InfoMat(c) ~= detectChange
                detectChange = InfoMat(c);
                backupcell{c,1} = zeros(1,SeriesPerCountry);
                backupcell{c,2} = eye(SeriesPerCountry);
                backupcell{c,5} = zeros(1, SeriesPerCountry-1);
                backupcell{c,6} = eye(SeriesPerCountry-1);
                backupcell{c,3} = backupcell{c,5};
                backupcell{c,4} = backupcell{c,6};
                
                
            else
                
                backupcell{c,1} = zeros(1,SeriesPerCountry);
                backupcell{c,2} = eye(SeriesPerCountry);
                backupcell{c,3} = backupcell{c,1};
                backupcell{c,4} = backupcell{c,2};
                backupcell{c,5} = zeros(1, SeriesPerCountry-1);
                backupcell{c,6} = eye(SeriesPerCountry-1);
                
                
            end
            
            
        end
    end
    
else
    for c = 1:countries
        if c == 1
            backupcell{c,1} = zeros(1,SeriesPerCountry);
            backupcell{c,2} = eye(SeriesPerCountry);
            backupcell{c,3} = backupcell{c,1};
            backupcell{c,4} = backupcell{c,2};
            backupcell{c,5} = backupcell{c,1};
            backupcell{c,6} = backupcell{c,2};
        else
            if InfoMat(c) ~= detectChange
                detectChange = InfoMat(c);
                backupcell{c,1} = zeros(1,SeriesPerCountry);
                backupcell{c,2} = eye(SeriesPerCountry);
                backupcell{c,5} = zeros(1, SeriesPerCountry);
                backupcell{c,6} = eye(SeriesPerCountry);
                backupcell{c,3} = backupcell{c,5};
                backupcell{c,4} = backupcell{c,6};
                
                
            else
                
                backupcell{c,1} = zeros(1,SeriesPerCountry);
                backupcell{c,2} = eye(SeriesPerCountry);
                backupcell{c,3} = backupcell{c,1};
                backupcell{c,4} = backupcell{c,2};
                backupcell{c,5} = zeros(1, SeriesPerCountry);
                backupcell{c,6} = eye(SeriesPerCountry);
                
                
            end
            
            
        end
    end
    
end





end

