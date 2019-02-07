function [ backupcell ] = setBackups( InfoCell, SeriesPerCountry, worldBlockNumber, idrestrict)
InfoMat = InfoCell{1,1};
InfoRegion = InfoCell{1,2};
regions = size(InfoCell{1,2},1);
countries = size(InfoMat,1);

detectChange = InfoMat(1);
K = countries*SeriesPerCountry;

worldBlockSize= K/worldBlockNumber;
if floor(worldBlockSize) ~= worldBlockSize
    error('Number of blocks must divide K with remainder zero.')
end
backupcell = cell(worldBlockNumber+regions+countries,2);
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
        backupcell{worldBlockNumber+regions+c,1} = zeros(1,SeriesPerCountry);
        backupcell{worldBlockNumber+regions+ c,2} = eye(SeriesPerCountry);
    end
    for r = 1:regions
        sizeR = length(InfoRegion(r,1):InfoRegion(r,2));
        backupcell{worldBlockNumber+r,1} = zeros(1, sizeR);
        backupcell{worldBlockNumber+r,2} = eye(sizeR);
    end
    for w = 1:worldBlockNumber

        backupcell{w,1} = zeros(1, worldBlockSize);
        backupcell{w,2} = eye(worldBlockSize);
    end
    
    
end

end