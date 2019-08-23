function [obsupdate, backup, f, vdecomp] = ...
    AmarginalF(Info, Factor, yt, currobsmod,  stateTransitions, factorVariance,...
    obsPrecision, backup, options, identification, vy, varargin)
if nargin > 11
    [K,T] = size(yt);
    Regions = size(Info,1);
    f = zeros(Regions,T);
    obsupdate = zeros(K,1);
    u = 0;
    vdecomp = zeros(K,1);
    breakUp = varargin{1};
    if breakUp == 0
        for r = 1:Regions
            subsetSelect = Info(r,1):Info(r,2);
            ySlice = yt(subsetSelect,:);
            vytemp = vy(subsetSelect);
            precisionSlice = obsPrecision(subsetSelect);
            x0 = currobsmod(subsetSelect);
            factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
            lastMean = backup{r,1};
            lastCovar = backup{r,2};
            [xt, lastMean, lastCovar] = optimizeA(x0, ySlice,precisionSlice,...
                Factor(r,:), factorPrecision, lastMean,...
                lastCovar, options, identification, breakUp);
            obsupdate(subsetSelect) = xt;
            backup{r,1} = lastMean;
            backup{r,2} = lastCovar;
            f(r,:) =  kowUpdateLatent(ySlice(:) , xt, factorPrecision, precisionSlice);
            obsmodSquared = xt.^2;         
            for m = 1:size(ySlice,1)
                u = u + 1;
                vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
            end
        end
    else
        %% Break up over blocks
        blocks = varargin{2};
        for r = 1:Regions
            subsetSelect = Info(r,1):Info(r,2);
            factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
            vytemp = vy(subsetSelect);
            lastMean = backup{r,1};
            lastCovar = backup{r,2};
            N = length(subsetSelect);
            storeTheMean = zeros(1,N-1);
            storeLastMean = zeros(1,N-1);
            % Blocks divide evenly
            if N < blocks
                subsetSelect = Info(r,1):Info(r,2);
                ySlice = yt(subsetSelect,:);
                vytemp = vy(subsetSelect);
                precisionSlice = obsPrecision(subsetSelect);
                x0 = currobsmod(subsetSelect);
                factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
                lastMean = backup{r,1};
                lastCovar = backup{r,2};
                [xt, lastMean, lastCovar] = optimizeA(x0, ySlice,precisionSlice,...
                    Factor(r,:), factorPrecision, lastMean,...
                    lastCovar, options, identification);
                obsupdate(subsetSelect) = xt;
                backup{r,1} = lastMean;
                backup{r,2} = lastCovar;
                f(r,:) =  kowUpdateLatent(ySlice(:), xt, factorPrecision, precisionSlice);
                obsmodSquared = xt.^2;
                for m = 1:size(ySlice,1)
                    u = u + 1;
                    vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
                end
            elseif mod(N, blocks) == 0
                floorNblocks = floor(N/blocks);
                CovarCell = cell(1,floorNblocks+1);
                storeLastCovar = cell(1,floorNblocks +1 );
                g = blocks;
                p = 1;
                for h = 1:floorNblocks
%                     fprintf('Block number %i \n', h)
                    if h == 1
                        isRestricted = 1;
                    else
                        isRestricted = 0;
                    end
                    subSelect = p:g;
                    p = g+1;
                    g = blocks*(h+1);
                    ySlice = yt(subSelect,:);
                    precisionSlice = obsPrecision(subSelect);
                    if h == 1
                        x0 = currobsmod(subSelect(2:end));
                        [themean, V, ~, ~] = ...
                            MaximizeA(x0, ySlice, precisionSlice, Factor(r,:), factorPrecision,...
                            storeLastMean(subSelect:end-1), lastCovar(subSelect:end-1), options, isRestricted);
                        storeTheMean(subSelect(1:end-1)) = themean;
                        storeLastMean(subSelect(1:end-1)) = themean;
                        storeLastCovar{1,h} = V;
                    else
                        x0 = currobsmod(subSelect);
                        [themean, V, ~, ~] = ...
                            MaximizeA(x0, ySlice, precisionSlice, Factor(r,:), factorPrecision,...
                            lastMean(subSelect - 1), lastCovar(subSelect-1, subSelect-1), options, isRestricted);
                        storeTheMean(subSelect-1) = themean;
                        storeLastMean(subSelect-1) = themean;
                        storeLastCovar{1,h} = V;
                    end
                    CovarCell{1,h} = V;
                end
                backup{r,1} = storeLastMean;
                backup{r,2} = blkdiag(storeLastCovar{:});
                ySlice = yt(subsetSelect,:);
                precisionSlice = obsPrecision(subsetSelect);
                V = blkdiag(CovarCell{:});
                obsupdate(subsetSelect) =MHstepA(currobsmod(subsetSelect),...
                    storeTheMean, V, ySlice, precisionSlice, Factor(r,:), factorPrecision);
                f(r,:) =  kowUpdateLatent(ySlice(:) , obsupdate(subsetSelect), factorPrecision, obsPrecision);
                obsmodSquared = obsupdate.^2;
                for m = 1:size(ySlice,1)
                    u = u + 1;
                    vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
                end
                
            else
                % Blocks have remainder
                floorNblocks = floor(N/blocks);
                CovarCell = cell(1,floorNblocks+1);
                storeLastCovar = cell(1,floorNblocks +1 );
                g = blocks;
                p = 1;
                for h = 1:floorNblocks
%                     fprintf('Block number %i \n', h)
                    if h == 1
                        isRestricted = 1;
                    else
                        isRestricted = 0;
                    end
                    subSelect = p:g;
                    p = g+1;
                    g = blocks*(h+1);
                    ySlice = yt(subSelect,:);
                    precisionSlice = obsPrecision(subSelect);
                    if h == 1
                        x0 = currobsmod(subSelect(2:end));
                        [themean, V, ~, ~] = ...
                            MaximizeA(x0, ySlice, precisionSlice, Factor(r,:), factorPrecision,...
                            storeLastMean(subSelect:end-1), lastCovar(subSelect:end-1), options, isRestricted);
                        storeTheMean(subSelect(1:end-1)) = themean;
                        storeLastMean(subSelect(1:end-1)) = themean;
                        storeLastCovar{1,h} = V;
                    else
                        x0 = currobsmod(subSelect);
                        [themean, V, ~, ~] = ...
                            MaximizeA(x0, ySlice, precisionSlice, Factor(r,:), factorPrecision,...
                            lastMean(subSelect - 1), lastCovar(subSelect-1, subSelect-1), options, isRestricted);
                        storeTheMean(subSelect-1) = themean;
                        storeLastMean(subSelect-1) = themean;
                        storeLastCovar{1,h} = V;
                    end
                    CovarCell{1,h} = V;
                end
                pm1 = p-1;
                [themean, V, ~, ~] = ...
                    MaximizeA(currobsmod(p:N), yt(p:N,:),  obsPrecision(p:N), Factor(r,:), factorPrecision,...
                    lastMean(p:end), lastCovar(p:end, p:end), options, isRestricted);

                storeTheMean(pm1:end) = reshape(themean, 1, N-p+1) ;
                storeLastMean(pm1:end) = themean;
                storeLastCovar{1, N+1} = V;
                CovarCell{1, floorNblocks + 1} = V;
                V = blkdiag(CovarCell{:});
                backup{r,1} = storeLastMean;
                backup{r,2} = blkdiag(storeLastCovar{:});
                ySlice = yt(subsetSelect,:);
                precisionSlice = obsPrecision(subsetSelect);
                obsupdate(subsetSelect) = MHstepA(currobsmod(subsetSelect), ...
                    storeTheMean, V, ySlice, precisionSlice, Factor(r,:), factorPrecision);
                f(r,:) =  kowUpdateLatent(ySlice(:) , obsupdate(subsetSelect),...
                    factorPrecision, precisionSlice);
                obsmodSquared = obsupdate.^2;
                for m = 1:size(ySlice,1)
                    u = u + 1;
                    vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
                end
            end
        end
    end
else
    [K,T] = size(yt);
    Regions = size(Info,1);
    f = zeros(Regions,T);
    obsupdate = zeros(K,1);
    u = 0;
    vdecomp = zeros(K,1);
    for r = 1:Regions
        subsetSelect = Info(r,1):Info(r,2);
        ySlice = yt(subsetSelect,:);
        vytemp = vy(subsetSelect);
        precisionSlice = obsPrecision(subsetSelect);
        x0 = currobsmod(subsetSelect);
        factorPrecision = kowStatePrecision(stateTransitions(r), factorVariance(r), T);
        lastMean = backup{r,1};
        lastCovar = backup{r,2};
        [xt, lastMean, lastCovar] = optimizeA(x0, ySlice,precisionSlice,...
            Factor(r,:), factorPrecision, lastMean,...
            lastCovar, options, identification);
        obsupdate(subsetSelect) = xt;
        backup{r,1} = lastMean;
        backup{r,2} = lastCovar;
        
        f(r,:) =  kowUpdateLatent(ySlice(:), xt, factorPrecision, precisionSlice);
        
        obsmodSquared = xt.^2;
        
        for m = 1:size(ySlice,1)
            u = u + 1;
            vdecomp(u) = (obsmodSquared(m) .* var(f(r,:))) ./ vytemp(m);
        end
    end
end