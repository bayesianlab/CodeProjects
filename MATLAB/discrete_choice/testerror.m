S= [1.0000    0.3134    0.1417    0.0664    0.1804 -0.2833    0.9549
    0.3134    1.0000    0.2701    0.1058   -0.0389 -0.0031    0.2690
    0.1417    0.2701    1.0000    0.3690    0.2402  0.3774    0.1495
    0.0664    0.1058    0.3690    1.0000    0.3306  0.5559   -0.0150
    0.1804   -0.0389    0.2402    0.3306    1.0000  0.0750    0.1984
   -0.2833   -0.0031    0.3774    0.5559    0.0750  1.0000   -0.1870
    0.9549    0.2690    0.1495   -0.0150    0.1984 -0.1870    1.0000]
A = [      -Inf         0   -3.2906
      -Inf         0   -2.1148
      -Inf         0   -1.0293
      -Inf         0    0.0811
         0       Inf    1.1481
         0       Inf    2.3524
         0       Inf    0.3788]
     
     ghkmvnrnd(A(:,1), A(:,2), A(:,3), S,1)