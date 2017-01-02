function [ impulseResponseA, impulseResponseB ] = impulseStep( response, eqmResponse,...
    lagsResponse, lagsEqmResponse, constant, F, shock, dimLags, i, max)
if i-1 == max
    impulseResponseA = response;
    impulseResponseB = eqmResponse;
    return
else
    if i == 1
        response(:, i+1) = constant + (F' * lagsResponse) + shock;
        eqmResponse(:, i+1) = constant + (F' * lagsEqmResponse);
    else
        response(:, i+1) = constant + (F' * lagsResponse);
        eqmResponse(:, i+1) = constant + (F' * lagsEqmResponse);
    end
    tmpR = lagsResponse;
    tmpER = lagsEqmResponse;
    lagsResponse = [response(:,i+1); tmpR(1:dimLags(2),1)];
    lagsEqmResponse = [eqmResponse(:, i+1); tmpER(1:dimLags(2),1)];
    i = i + 1;
    [impulseResponseA, impulseResponseB] = impulseStep(response, eqmResponse,...
        lagsResponse, lagsEqmResponse, constant, F, shock, dimLags,...
        i, max);
    return
end
 
end

