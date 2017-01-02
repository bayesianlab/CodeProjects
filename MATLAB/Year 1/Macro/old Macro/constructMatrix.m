function [ g_hat_matrix] = constructMatrix(z_1, z_2, ...
    p_11, p_22, power, beta)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
elem_11 = 1 - ( (z_1(1,1)^power)*beta*p_11);
elem_12 = -(z_2^power)*beta*(1-p_11);
elem_21 = -(z_1(1,1)^power)*beta*(1-p_22);
elem_22 = 1 - (z_2^power)*beta*p_22;
g_hat_matrix = ([elem_11 elem_12; elem_21 elem_22]);
end

