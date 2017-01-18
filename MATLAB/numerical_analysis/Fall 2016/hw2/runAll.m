% runAll
clear
clc
test_dividedDifferencesSwitch = 0;
test_nestedMult = 0; 
test_evalPnts = 1;
test_interpolate_Poly = 0;
test_interpolate_sinX = 0;
test_runge = 0;
test_chebyshev = 1;

% Divided differences tests
passFail = zeros(5,1);
if test_dividedDifferencesSwitch == 1
    disp('Divided differences Tests.')
    disp(sprintf('6x'))
    passFail(1) = test_dividedDifferences(dividedDifferences([0, 1],...
        [0,6]), [0,6]);
    
    disp(sprintf('6 + 11(x-1) + 3(x-1)(x-2)\n'))
    passFail(2) = test_dividedDifferences(dividedDifferences([1,2,3],...
        [6,17,34]), [6,11,3]);
    
    disp(sprintf('3 + .5(x-1) + (.333)(x-1)(x-1.5) - 2(x-1)(x-1.5)x\n'))
    passFail(3) = test_dividedDifferences(dividedDifferences([1,1.5,0,2],...
        [3, 3.25, 3, 1.6667]), [3,.5,.3333,-2]);
    
    disp(sprintf('-5 + 2x - 4x(x-1) + 8x(x-1)(x+1) + 3x(x-1)(x+1(x-2)\n'))
    passFail(4) = test_dividedDifferences(dividedDifferences([0,1,-1,2,-2],...
        [-5,-3,-15,39,-9]), [-5, 2, -4, 8, 3]);
    
    disp(sprintf('x^2'))
    passFail(5) = test_dividedDifferences(dividedDifferences([-2,0, 2],...
        [4,0,4]), [4,-2,1])
    if passFail' * passFail == length(passFail)
        disp(sprintf('\tAll tests PASSED.\n'))
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    else
        disp(sprintf('\tAt least one test FAILED.\n'))
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    end
end

% Code for nested multiplication is sufficientently tested. 
if test_nestedMult == 1
    disp(sprintf('Nested multiplication tests\n'))
    disp(sprintf('f(x) = 1'))
    v1 = nMult(0, [1, 0], 0);
    v2 = 1 ;
    testNestedMult(v1, v2)
    disp(sprintf('f(x) = 0'))
    v1 = nMult(0, [0,0], 0);
    v2 = 0;
    testNestedMult(v1,v2)
    disp(sprintf('f(x) = 1 + 2x^2 + 3x^3'))
    v1 = nMult([0,0],[1,2,3], 2);
    v2 = 17;
    testNestedMult(v1,v2)
    disp(sprintf('f(x) = -1 + 2x^2 + -3x^3'))
    c = -1*[1,2,3];
    v1 = nMult([0,0], c, 1);
    v2 = -6;
    testNestedMult(v1,v2)
    disp(sprintf('f(x) = 0 + 0x^2 + 0x^3'))
    v1 = nMult([0,0], zeros(3,1), 100);
    v2=0;
    testNestedMult(v1,v2)
    disp(sprintf('1 + 3x^3'))
    c = [1,0,3];
    v1 = nMult([0,0], c, 3);
    v2 = 28;
    testNestedMult(v1,v2)
    disp(sprintf( '1 + x +  x^2 + ... + x^10'))
    c = ones(10,1);
    v1 = nMult(zeros(length(c)-1,1), c, 4);
    v2 = 349525;
    testNestedMult(v1,v2)
    
    disp(sprintf('6 + 11(x-1) + 3(x-1)(x-2)'))
    v1 = nMult([1,2], [6,11,3], 2);
    v2 = 17;
    testNestedMult(v1,v2)
    
    disp(sprintf('3 + .5(x-1) + (.3333)(x-1)(x-1.5) - 2(x-1)(x-1.5)x'))
    v1 = nMult([1,1.5,0], [3,.5,.3333, -2], -2);
    v2 = 46.99965;
    testNestedMult(v1,v2)
    
    disp(sprintf('3 + .5(x-1) + (.3333)(x-1)(x-1.5) - 2(x-1)(x-1.5)x'))
    v1 = nMult([1,1.5,0], [3,.5,.3333, -2], 6);
    v2 = -257.00075;
    testNestedMult(v1,v2)
end

% eval Points tests
passFail = zeros(5,1);
if test_evalPnts == 1
    format short
    disp(sprintf('Function valus match hand calculated values.\n'))
    passFail(1) = test_evalPoints(evalPoints([1,2], [6,11,3],...
        [1,2, 3, -1]), [6,17,34,2]');
    disp(sprintf('Function valus match hand calculated values.\n'))
    passFail(2) = test_evalPoints(evalPoints([1, 3/2, 0],...
        [3, .5, 1/3, -2],[-1,0, 10, 2]), [13.6667, 3, -1497, 1.66667]');
    disp(sprintf('Bad input. Function catches error\n'))
    passFail(3) = test_evalPoints(evalPoints([0], [0], [0]), num2str(-1));
    disp(sprintf('Quadratic'))
    passFail(4) = test_evalPoints(evalPoints([0,0], [0,0,1],...
        [0, 1, 2]), [0, 1, 4]);
    passFail(5) = test_evalPoints(evalPoints([1,1.5,0], [3,.5,.3333, -2],...
        [-2, 6]), [46.99965, -257.00075])
    if passFail' * passFail == length(passFail)
        disp(sprintf('\tAll tests PASSED.\n\n'))
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    else
        disp(sprintf('\tAt least one test FAILED.'))
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    end
end



% 1st polynomial interpolation 
if test_interpolate_Poly == 1
    n =2:10;
    error = length(n);
    range = [-1,1];
    detail = 50;
    trueTable = generateData(zeros(3,1), [1,2,4,3], [-1,1], detail);
    legendinfo = {};
    legendinfo{1} = 'True values';
    subplot(2,1,1)
    hold on
    plot(trueTable(1, 1:50), trueTable(2,1:50), 'r') 
    for i = 1:length(n)
        % Data to interpolate
        table = generateData(zeros(3,1), [1,2,4,3], range, n(i));
        xVals = table(1, 1:n(i));
        fOfx = table(2, 1:n(i));

        % Interpolation
        interpPnts = interp(xVals, fOfx, range, detail);
        interpXVals = interpPnts(1, 1:detail);
        interpfOfX = interpPnts(2, 1:detail);

        % Calculate error
        error(i) = norm(trueTable(2,1:detail) - interpfOfX);
        
        % Plotting results
        plot(interpXVals, interpfOfX,'--')
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        legendinfo{i+1} = sprintf('Number of points %i', n(i));
    end
    legend(legendinfo, 'Location', 'northwest');
    hold off
    subplot(2,1,2)
    plot(n, error)
    format long
    error'
end

% Part 2
if test_interpolate_sinX == 1 
    n = 3:8;
    detail = 50;
    truthXs = linspace(0,2*pi, detail);
    truth = sin(truthXs);
    legendinfo = {};
    error = length(n);
    subplot(2,1,1)
    hold on
    plot(truthXs, truth, 'r')
    legendinfo{1} = 'True function';
    for i = 1:length(n)
        % Interpolation of x and f(x) vals
        xvals = linspace(0, 2*pi, n(i));
        fOfx = sin(xvals);
        interpPnts = interp(xvals, fOfx, [0, 2*pi], detail);

        % Calculate error
        error(i) = norm(truth - interpPnts(2,1:detail));

        % Plot results
        c = 1 - i/n(length(n));
        plot(interpPnts(1,1:detail), interpPnts(2, 1:detail),'--',...
            'color',[i/n(length(n)), 0, c])
        legendinfo{i+1} = sprintf('Number of points %i', n(i));
    end
    legend(legendinfo)
    hold off
    subplot(2,1,2)
    plot(n, error)
    error'
end

% Part 3 runge function
f = @(x) (1+25*x.^2).^(-1);
if test_runge == 1 
    legendinfo ={};
    n = 2:30;
    detail = 100;
    error = zeros(length(n),1);
    xvals = linspace(-1,1, detail );
    truth = [xvals; (1+25*xvals.^2).^(-1)];
    subplot(2,1,1)
    hold on 
    plot(xvals, truth(2,1:detail))
    legendinfo{1} = 'True function';
    for i = 1:length(n)
        xvals = linspace(-1,1, n(i));
        data = [xvals; (1+25*xvals.^2).^(-1)];
        interpPnts = interp(data(1,1:n(i)), data(2,1:n(i)), [-1,1], detail);      
        plot(interpPnts(1,1:detail), interpPnts(2,1:detail), ':')
        % Error
       error(i) = norm(truth(2,1:detail) - interpPnts(2,1:detail));
       legendinfo{i+1} = sprintf('Number of points %i', n(i));
    end
    legend(legendinfo);
    hold off
    subplot(2,1,2)
    plot(n, error)
    error'
end

% Trying chebyschev points 
if test_chebyshev == 1;
    legendinfo = {};
    n = 2:15;
    endN = length(n);
    detail = 100;
    error = zeros(endN,1);
    truthX = linspace(-1,1,detail);
    truth = [ truthX; f(truthX) ] ;
    subplot(2,1,1)
    hold on
    plot(truth(1,1:detail), truth(2,1:detail))
    legendinfo{1} = 'True function';
    for i = 1:endN
        xi = chebyshevNodes(n(i));
        data = [xi'; f(xi)'];
        interpPnts = interp( data(1, 1:n(i)), data(2, 1:n(i)), [-1,1],...
            detail);
        plot(interpPnts(1, 1:detail), interpPnts(2, 1:detail),':',...
            'color', [i/n(endN), 0, 1-(i/n(endN))])
        error(i) = norm(truth(2,1:detail) - interpPnts(2,1:detail));
        legendinfo{i+1} = sprintf('Number of points %i', n(i));
    end
    legend(legendinfo)
    hold off
    subplot(2,1,2)
    plot(n, error)
    error
end
    
    


