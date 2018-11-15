function [ Phi ] = recursiveWoodbury( Sigma, A, S1, B, S2, C, S3)

Phi = woodburyWithInverse(...
    woodburyWithInverse(...
    woodburyInvert(Sigma, A, S1, A'), B,S2), C, S3);
end

