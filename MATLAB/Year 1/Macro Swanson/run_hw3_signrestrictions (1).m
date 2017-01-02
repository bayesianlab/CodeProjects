clear;
clc;

[lout, ldinf, irates] =  createData();
X = [lout, ldinf, irates];
[coefs, ~,~, covs, covar] = vreg(X, 12);

B0 = [coefs(2,1), coefs(14,1), coefs(26,1);
    coefs(2,2), coefs(14,2), coefs(26,2);
    coefs(2,3), coefs(14,3), coefs(26,3)];
B1 = [coefs(3,1), coefs(15,1), coefs(27,1);
    coefs(3,2), coefs(15,2), coefs(27,2);
    coefs(3,3), coefs(15,3), coefs(27,3)]
B2 = [coefs(4,1), coefs(16,1), coefs(28,1);
    coefs(4,2), coefs(16,2), coefs(28,2);
    coefs(4,3), coefs(16,3), coefs(28,3)];

%% Part a

chols = chol(covar)'

%% Part b
draws = 100;
threeDmat = zeros(3,3,draws);
accepted = 0;
for d = 1:draws
    u = haar(3);
    s = chols*u;
    if s(1,3)/s(3,3) < 0
        accepted = accepted + 1;
        threeDmat(:,:,accepted) = s;
    end
end
% Throw away empties. 
threeDmat(:,:, accepted+1:draws) = [];

percent_accepted = 100*(accepted/draws);
percent_rejected = 100 - percent_accepted;
str1 = sprintf('Accepted %.3f %%', percent_accepted);
str2 = sprintf('Rejected %.3f %%', percent_rejected);
disp(str1)
disp(str2)

%% Part c
[cirf_o, cirf_i, cirf_rate] = comparisonIRF(threeDmat, X, 12, 50);
figure
subplot(3,1,1)
plot(cirf_o)
subplot(3,1,2)
plot(cirf_i)
subplot(3,1,3)
plot(cirf_rate)

%% Question 2
% threeDmat2 = zeros(3,3,draws);
% accepted = 0;
% a=0;
% for d = 1:draws
%     u = haar(3);
%     s = chols*u; 
%     shock = calculate_shock( s );
%     four_period_restriction = IRF_var(4, X, 12, shock);
%     check_condition = four_period_restriction(:,1) < 0 ;
% %     check_check = [shock', B0*shock', (B1 + B0*B0)*shock',...
% %         B2*shock' + B1*B0*shock' + B0*(B1 + B0*B0)*shock']
%     if sum(check_condition) == 4
%         accepted = accepted + 1;
%         threeDmat2(:,:,d) = u;
%     end
% %     check_check_condition = check_check(1,:) < 0 ;
% %     if sum(check_check_condition) == 4
% %         a = a + 1;
% %     end
% end
% 
% percent_accepted_4period_restriction = 100*(accepted / draws);
% pr4r = 100 - percent_accepted_4period_restriction;
% str1 = sprintf('\nAccepted %.3f %%', percent_accepted_4period_restriction);
% str2 = sprintf('Rejected %.3f %%', pr4r);
% disp(str1)
% disp(str2)
% 
% [cirf_o4r, cirf_i4r, cirf_rate4r] = comparisonIRF(threeDmat, X, 12, 50);

% figure
% subplot(3,1,1)
% plot(cirf_o4r)
% subplot(3,1,2)
% plot(cirf_i4r)
% subplot(3,1,3)
% plot(cirf_rate4r)

% Y = createDataInstrument();
% imp_instsrument;
% [coefs2, lr, ssr, o, r, resids2] = VAR_Swan(Y, 12);
% ut_y = resids2(:,1);
% ut_pi = resids2(:,2);
% ut_i = resids2(:,3);
% 
% a = ols(ut_y, z);
% b = ols(ut_pi,z);
% c = ols(ut_i, z);
% s3 = [a;b;c]
% s3_normalized = (s3 .* (0.25/s3(3)))';
% [ mat ] = IRF_var(50, Y, 12, s3_normalized);

% figure
% subplot(3,1,1)
% plot(mat(:,1))
% subplot(3,1,2)
% plot(mat(:,2))
% subplot(3,1,3)
% plot(mat(:,3))





