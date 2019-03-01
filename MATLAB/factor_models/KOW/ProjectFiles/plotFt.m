function [] = plotFt(Factor, sumFt, sumFt2, InfoCell, varargin)
[nFactors, T] = size(Factor);
variance = sumFt2 - sumFt.^2;
sig = sqrt(variance);
upper = sumFt + 2.*sig;
lower = sumFt - 2.*sig;
xaxis = 1:T;
fillX = [xaxis, fliplr(xaxis)];
fillY = [upper, fliplr(lower)];
facealpha = .3;



LW = .75;
COLOR = [1,0,0];
Regions = size(InfoCell{1,2},1);
Countries = size(InfoCell{1,3},1);
RowsWhenEven = Regions/2 + 1;
RowsWhenOdd  = 1 + (Regions-1)/2 + 1;
f1=figure(1);
if mod(Regions,2) == 0
    for k = 1:Regions+1

        % Even Regions
        if k == 1
            subplot(RowsWhenEven,2, 1:2)
            h = fill(fillX(1,:), fillY(1,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(1,:), 'Color', 'black', 'LineWidth', 1);
            title('World')
            hold off
        else
            subplot(RowsWhenEven, 2, k+1)
            h = fill(fillX(1,:), fillY(k,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(k,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Region %i', k-1))
            hold off
        end
    end
else
    for k = 1:Regions+1
        % Odd Regions
        if k == 1
            subplot(RowsWhenOdd, 2, 1:2)
            h = fill(fillX(1,:), fillY(1,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(1,:), 'Color', 'black', 'LineWidth', LW);
            title('World')
            hold off
        elseif k == Regions+1

            subplot(RowsWhenOdd, 2, k+1:k+2)
            h = fill(fillX(1,:), fillY(k,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(k,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Region %i', k-1))
            hold off
        else
            subplot(RowsWhenOdd, 2, k+1)
            h = fill(fillX(1,:), fillY(k,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(k,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Region %i', k-1))
            hold off
        end
    end
end

f2 = figure(2);
moveToCountry = 1 + Regions;
RowsWhenOdd = (Countries- 1)/2 + 1;
RowsWhenEven = Countries/2;

if Countries == 1
    h = fill(fillX(1,:), fillY(moveToCountry,:), COLOR);
    set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
    hold on
    p1 = plot(Factor( moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
    title(sprintf('Country %i', k))
    hold off
    
else
    if mod(Countries,2) == 0
        for k = 1:Countries
            % Even
            subplot(RowsWhenEven, 2, k)
            h = fill(fillX(1,:), fillY(k+moveToCountry,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(k + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Country %i', k))
            hold off
        end
    else
        for k = 1:Countries
            % Odd
            if k == 1
                subplot(RowsWhenOdd, 2, 1:2)
                h = fill(fillX(1,:), fillY(k + moveToCountry,:), COLOR);
                set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
                hold on
                p1 = plot(Factor(k+ moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
                title(sprintf('Country %i', k))
                hold off
            else
                subplot(RowsWhenOdd, 2, k+1)
                h = fill(fillX(1,:), fillY(k+moveToCountry,:), COLOR);
                set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
                hold on
                p1 = plot(Factor(k + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
                title(sprintf('Country %i', k))
                hold off
            end
            
        end
    end
end

if nargin > 4
    if nargin == 5
        error('Need two filenames')
    end
    fprintf('Saving to file:\n %s\n  %s\n', varargin{1}, varargin{2})
    
    saveas(f1, varargin{1})
    saveas(f2, varargin{2})
end

end


