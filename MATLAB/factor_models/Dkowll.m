function [ output_args ] = Dkowll(demeanedy, variance, A,B,C, Sworld,Sregion,Scountr, h)
keep  = [A,B,C]  

for i = 1:3
   temp(i) = keep(i) + h;
    kowll(demeanedy, variance, A,B,C, Sworld,Sregion,Scountry) - ...
       kowll(demeanedy, variance, A,B,C, Sworld,Sregion,Scountry)
   temp = keep;
   
   


end

