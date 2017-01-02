function [ y ] = choice_data( betas, alt_spec, choices, N )
% Make N size vector of choices
y = zeros(N, 1);
for i = 1 : N 
    [~, choice] = make_choice(betas, alt_spec(:,:,i), choices);
    y(i) = choice;
end

end

