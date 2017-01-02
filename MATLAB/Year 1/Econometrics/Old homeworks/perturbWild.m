function [ perturbedError ] = perturbWild( error_vec )
wild_er = (1 - sqrt(5))/2;
wild_er_not = (1 + sqrt(5))/2;
wild_prob = (1+sqrt(5))/(2*sqrt(5));
perturbedError = zeros(length(error_vec),1);
for i = 1:length(error_vec)
    cut = unifrnd(0,1);
    if cut < wild_prob
        perturbedError(i,1) = error_vec(i,1) * wild_er;
    else
        perturbedError(i,1) = error_vec(i,1) * (wild_er_not);
    end
end
end

