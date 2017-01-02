function [ output_args ] = example_steepDesc( x )
ep = .001;
alp = .01;
x0 = x;
err = sum(deriv(x0));
c = 0;
while c < 800
    c = c+1;
    new = x0 + alp*deriv(x0);
    new
    x0=new;
end


end

