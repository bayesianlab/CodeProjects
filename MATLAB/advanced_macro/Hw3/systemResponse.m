function [ response ] = systemResponse(varCoefs, shock, periods, show )

[r,c] = size(varCoefs);
constant = varCoefs(r, :);
varCoefs = varCoefs(1:r-1,:);
r = r-1;
lags = zeros(r,1);
lagsER = zeros(r,1);
response = zeros(c, periods);
eqmResponse = zeros(c, periods);
i = 1;
[response, eqmResponse] = impulseStep(response, eqmResponse,lags, lagsER, constant', varCoefs,...
    shock, [r,c], i, periods);
response = response-eqmResponse;
if show == 1
    figure
    hold on
    for i = 1:c
        plot(response(i, 1:periods))
        title('Impulse Response')
        xlabel('Series Value')
        ylabel('Response')
    end
end
end


