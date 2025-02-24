function [  ] = SimStudyZhangNewProposal( Sims)
if ischar(Sims)
    Sims = str2num(Sims);
end
N = 200;
K = 7;
R = [1, .8, .6, .4, .2, 0, 0;
    .8, 1, .8, .6, .4, .2, 0;
    .6, .8, 1, .8, .6, .4, .2;
    .4, .6, .8, 1, .8, .6, .4;
    .2, .4, .6, .8, 1, .8, .6;
    0, .2, .4, .6, .8, 1, .8;
    0, 0, .2, .4, .6, .8, 1];
iR = inv(R);
beta = [1, 1,1, 1, 1, 1]';
Covariates = length(beta);
b0 = zeros(length(beta),1);
B0 = eye(length(b0))*10;
wishartDf = N;
D0 = ones(K,1);
R0 = eye(K);
timetrend = (1:K)';
% timetrend =(1:K)'-4;
timetrendsqd = timetrend.^2;
bi = round(unifrnd(0,1,K,N));

for i = 1:N
    select = timetrend + (i-1)*K;
    X(select, :) = [ones(K,1), timetrend, timetrendsqd, bi(:,i),...
        bi(:,i).*timetrend, bi(:,i).*timetrendsqd];
end
E=mvnrnd(zeros(K,1),R, N)';
vecz = X*beta + E(:);
vecy = double(vecz>0);
y = reshape(vecy, K,N);
z = reshape(vecz, K,N);
mu = reshape(X*beta, K,N);


Reps = 1;
burninperc = .1;
posttrackingnums = [2,1;3,2; 6,3; 7,1]; 
bbar = zeros(Reps,length(b0));
r0 = zeros(size(R,1), size(R,1), Reps);
post = zeros(Sims - floor(burninperc*Sims),size(posttrackingnums,1), Reps);
ar = zeros(Reps,1);
steinloss = zeros(Reps,1);
for i =1:Reps

    i
    [bbar(i,:), r0(:,:, i),ar(i), post(:,:,i)] = mv_probit_new_proposal(y, X, beta, B0, wishartDf, diag(D0), R,...
        Sims, posttrackingnums);
    r0ir = r0(:,:,i)*iR;
    steinloss(i) = trace(r0ir) - logdet(r0ir) - size(r0,1);
end
fname = createDateString('zhangnewp_')
save(fname)


