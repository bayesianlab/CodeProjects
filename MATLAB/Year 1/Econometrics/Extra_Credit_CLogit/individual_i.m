function [ output_args ] = individual_i( traits_num, attributes_num, ...
    betas )
% Createt N i specific traints
traits = normrnd(0,1, traits_num, 1);
attribute_choices = normrnd(0,1, attributes_num, 1);
wn = normrnd(0,1)
if iscolumn(betas) == 0
    betas = betas';
end
zij = [attribute_choices, traits]



end

