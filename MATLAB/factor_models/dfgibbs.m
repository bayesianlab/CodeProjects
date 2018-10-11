function [ output_args ] = dfgibbs(y,X, a, F0,SigmaDiag,omega2, b0,B0inv, Sims)


for i = 1:Sims
    [b,B] = updateBetaPriors(y,X,a,omega2,F0, SigmaDiag, b0,B0inv);
    b1 = b + chol(B,'lower')*normrnd(0,1,length(b0),1);
    
    
    
    
end

