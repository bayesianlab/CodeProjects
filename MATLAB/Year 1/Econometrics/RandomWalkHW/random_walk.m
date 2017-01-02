clear;
clc;

smpSizes = [  
              10;  
              100;
              1000;
            ];
        

sims = 100;
numSamps = length(smpSizes);
percentSpurious = zeros(numSamps,1);
for size = 1:numSamps
    tic
    percentSpurious(size) = rWalkMC( smpSizes(size), sims );
    str = sprintf( 'Estimated time remaining: %.3f',...
        toc * 10^(numSamps - size) );
    disp(str)
end

disp( sprintf( '%.2f Percent Spurious Correlation \n', 100*percentSpurious) )








