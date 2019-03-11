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

MAXPERFIGURE = 4;
MAXROWS = 2;
MAXCOLS = 2;
if MAXPERFIGURE ~= MAXROWS + MAXCOLS
    error('Incorrect dimensions of subplots')
end
LW = .75;
COLOR = [1,0,0];
Regions = size(InfoCell{1,2},1);
Countries = size(InfoCell{1,3},1);
RowsWhenEven = Regions/2 + 1;
RowsWhenOdd  = 1 + (Regions-1)/2 + 1;
figure
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

moveToCountry = 1 + Regions;
divrem = [fix(Countries/MAXPERFIGURE), mod(Countries,MAXPERFIGURE)];

% Check if the number of countries is small, less than the max per page
if divrem(1,1) == 0
    % Check if the remainder is even
    if mod(divrem(1,2),2)== 0
        % Even
        figure
        remcols = divrem(1,2)/2;
        for p = 1:divrem(1,2)
            subplot(MAXROWS, remcols, p)
            h = fill(fillX(1,:), fillY(p+moveToCountry,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(p + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Country %i', p))
            hold off
        end
    else
        % The remainder is odd
        % Odd
        figure
        % Special case for one country
        if Countries == 1
            h = fill(fillX(1,:), fillY( 1+moveToCountry,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(1 + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Country %i', 1))
            hold off
            % The usual case, odd number of countries
        else
            remrem = mod(divrem(1,2),2);
            remrows = fix(divrem(1,2)/2) + 1;
            for p = 1:divrem(1,2)
                % Last plot gets plot over the whole span of columns
                if p == divrem(1,2)
                    subplot(remrows, MAXCOLS, p:p+1)
                    h = fill(fillX(1,:), fillY(p+moveToCountry,:), COLOR);
                    set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
                    hold on
                    p1 = plot(Factor(p + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
                    title(sprintf('Country %i', p))
                    hold off
                else
                    subplot(remrows, MAXCOLS, p)
                    h = fill(fillX(1,:), fillY(p+moveToCountry,:), COLOR);
                    set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
                    hold on
                    p1 = plot(Factor(p + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
                    title(sprintf('Country %i', p))
                    hold off
                end
            end
        end
    end
    
    % Number of countries is larger than the per page max
else
    t = 1:MAXPERFIGURE;
    for k = 1:divrem(1,1)
        select = t + (k-1)*MAXPERFIGURE;
        figure
        for p = 1:MAXPERFIGURE
            subplot(MAXROWS, MAXCOLS, p)
            h = fill(fillX(1,:), fillY(p+moveToCountry,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(select(p) + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Country %i', select(p)))
            hold off
        end
    end
    lastplots = (1+divrem(1,1)*MAXPERFIGURE):Countries;
    if (mod(divrem(1,2),2)== 0) & (divrem(1,2) ~= 0)
        % Even
        figure
        remcols = divrem(1,2)/2;
        for p = 1:divrem(1,2)
            subplot(MAXROWS, remcols, p)
            h = fill(fillX(1,:), fillY(lastplots(p)+moveToCountry,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(lastplots(p) + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Country %i', lastplots(p)))
            hold off
        end
    elseif divrem(1,2) ~= 0
        % Odd
        figure
        if length(lastplots) == 1
            h = fill(fillX(1,:), fillY(lastplots+moveToCountry,:), COLOR);
            set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
            hold on
            p1 = plot(Factor(lastplots + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
            title(sprintf('Country %i', lastplots))
            hold off
        else
            remrem = mod(divrem(1,2),2);
            remrows = fix(divrem(1,2)/2);
            for p = 1:divrem(1,2)
                subplot(remrows, remcols, p)
                h = fill(fillX(1,:), fillY(lastplots(p)+moveToCountry,:), COLOR);
                set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
                hold on
                p1 = plot(Factor(lastplots(p) + moveToCountry,:), 'Color', 'black', 'LineWidth', LW);
                title(sprintf('Country %i', lastplots(p)))
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


