%% Homework 3 Question 2 Part D
b = 0.9;
g = 2;
z2= 1.1;
p11a= 0.2;
p11b= 0.8;
p22= 0.9;

Pa=[p11a, (1-p11a); (1-p22), p22];
I=[1,0;0,1];
Ct = 0.1:0.01:5;
C = [1;1];
z= 1;
for i= 1:length(Ct)
    Z=[(z^(1-g)), 0; 0,z2^(1-g)];
    Aa=(I-b*Pa*Z);
    gz1=(inv(Aa))*C;    
    u(i) = (Ct(i)^(1-g))/(1-g);
    g1(i)=gz1(1)*u(:,i);
end
V1=g1;

Pb=[p11b, (1-p11b); (1-p22), p22];
I=[1,0;0,1];
C=[1;1];
for i= 1:length(Ct)
    Z=[(z^(1-g)), 0; 0,z2^(1-g)];
    Ab=[I-b*Pb*Z];
    gz2=(inv(Ab))*C;
    u2(i) = (Ct(i)^(1-g))/(1-g);
    g2(i)=gz2(1)*u2(:,i);
end
V2=g2;

plot (Ct,V1,'.',Ct,V2,'.')
xlabel('Ct')
ylabel('Value Function')
legend('P11=0.2','P11=0.8')
title('Value Function as a Function of Ct')
