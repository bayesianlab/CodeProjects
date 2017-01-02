function out = haar(n) ;
%
% Return random nxn orthogonal matrix U, distributed according to the uniform Haar measure.
%  The algorithm follows Rubio-Ramirez, Waggoner, and Zha (2010 Review of Economic Studies).
%

[Q,R] = qr(randn(n)) ;

% Normalize sign of diagonal elements of R to be positive, and return corresponding Q:
out = Q * diag(sign(diag(R))) ;
