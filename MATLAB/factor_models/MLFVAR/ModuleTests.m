function [] = ModuleTests()


fprintf('Test DGP Funcitons\n')
T=100;
Gamma= [.2]
sigma2=1;
[F, H, Rs, vt] =StateSpaceDGP(Gamma, sigma2, T);
check=(Rs \ H*F(:))-vt(:);
checksum = sum(check);
if abs(checksum) < 1e-10
    fprintf('\n\tDGP TEST 1, HF=v: TRUE \n')
end

T=100;
g1 = [.2,0; 0,.3]
g2 = [.1,0; 0, .2]
g3 = [.01, 0; 0,.02]
g4 = [.01,0; 0, .002]
Gamma = [g1,g2,g3,g4];

sigma2=[1;1];
[F, H, Rs, vt] =StateSpaceDGP(Gamma, sigma2, T);
check=(Rs \ H*F(:))-vt(:);
checksum = sum(check);
if abs(checksum) < 1e-10
    fprintf('\n\tDGP TEST 2, HF=v: TRUE \n')
end
end

