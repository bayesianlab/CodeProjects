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

MAXPERFIGURE = 5;
MAXROWS = 5;
MAXCOLS = 1;

LW = .75;
COLOR = [1,0,0];
Regions = size(InfoCell{1,2},1);
Countries = size(InfoCell{1,3},1);
RowsWhenEven = Regions/2 + 1;
RowsWhenOdd  = 1 + (Regions-1)/2 + 1;
figure
ploti = 1:MAXPERFIGURE;
c = 0;
if Regions + 1 < MAXROWS
    regionWorldPagesRows = 1+Regions;
else
    regionWorldPagesRows = MAXROWS;
end
RemainingPlots = length(1:Regions+1);
for k = 1:Regions+1
    c = c + 1;
    if k == 1
        subplot(regionWorldPagesRows,MAXCOLS, 1:MAXCOLS)
        length(fillX(1,:))
        length(fillY(1,:))
        h = fill(fillX(1,:), fillY(1,:), COLOR);
        set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
        hold on
        p1 = plot(Factor(1,:), 'Color', 'black', 'LineWidth', 1);
        title('World')
        hold off
    else
        subplot(regionWorldPagesRows,MAXCOLS, ploti(c))
        h = fill(fillX(1,:), fillY(k,:), COLOR);
        set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
        hold on
        p1 = plot(Factor(k,:), 'Color', 'black', 'LineWidth', 1);
        title(sprintf('Region %i', k-1))
        hold off
        if c == MAXPERFIGURE
            RemainingPlots = RemainingPlots - MAXPERFIGURE;
            if RemainingPlots < MAXPERFIGURE
                regionWorldPagesRows = RemainingPlots;
            end
            figure
            c=0;
        end
    end
end

figure
ploti = 1:MAXPERFIGURE;
c=0;
moveToCountry = 1 + Regions;
cindex = moveToCountry + 1:(1+Regions+Countries);

if length(cindex) < MAXROWS
    countryRows = Countries;
else
    countryRows = MAXROWS;
end
RemainingPlots = length(cindex);
for k = cindex
    if c == MAXPERFIGURE
        RemainingPlots = RemainingPlots - MAXPERFIGURE;
        if RemainingPlots < MAXPERFIGURE
            countryRows = RemainingPlots;
        end
        figure
        c=0;
    end
    c = c + 1;

    subplot(countryRows,MAXCOLS, ploti(c))
   
    h = fill(fillX(1,:), fillY(k,:), COLOR);
    set(h, 'FaceAlpha', facealpha, 'LineStyle', 'none')
    hold on
    p1 = plot(Factor(k,:), 'Color', 'black', 'LineWidth', 1);
    title(sprintf('Country %i', k-Regions-1))
    hold off
    
end

if nargin > 4
    SaveFig(varargin{1},varargin{2})
end
end


