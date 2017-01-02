function [ Uij, index ] = make_choice( betas, alternative_specific, J_choices )

wn = evrnd(.577, (3.14^2)/6, J_choices, 1);
if iscolumn(betas) == 0
    betas = betas';
end

% Utilities 
temp = zeros(J_choices, 1) ;
for j = 1:J_choices
    zij = alternative_specific(:,j)';
    temp(j) = zij*betas + wn(j);
end

[Uij, index] = max(temp);


end

