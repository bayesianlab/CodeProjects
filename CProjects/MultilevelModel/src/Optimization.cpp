#include "Optimization.hpp"

void PressEnterToContinue()
{
    std::cout << "Press ENTER to continue... " << flush;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

Optimize::Optimize()
{
    F_tol = SEPS;
    grad_tol = SEPS;
    x_tol = EPS;
    line_search_tol = 1e-6;
    MaxIterations = 50;
}

Optimize::Optimize(double options[5])
{
     
    F_tol = options[0];
    grad_tol = options[1];
    x_tol = options[2];
    line_search_tol = options[3];
    MaxIterations = (int)options[4];
}

VectorXd Optimize::ForwardDifferences(const Ref<const VectorXd> &x0,
                                      std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    int n = x0.size();
    MatrixXd I = MatrixXd::Identity(n, n);
    double fval0 = F(x0);
    VectorXd q = VectorXd::Zero(n);
    VectorXd grad = VectorXd::Zero(n);
    long double h = sqrt(EPS);
    for (int i = 0; i < n; i++)
    {
        q = I.col(i) * h;
        grad(i) = (F(x0 + q) - fval0) / h;
    }
    return grad;
}

void Optimize::BFGS(VectorXd &x0, std::function<double(const Ref<const VectorXd> &xstar)> F, int disp_on)
{
    if (disp_on)
    {
        BFGS_Display(x0, F);
    }
    else
    {
        BFGS_Display_Off(x0, F);
    }
}

double Optimize::LineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
                            const Ref<const VectorXd> &del0,
                            std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    // cout << endl; 
    // cout << "Begin Line Search" << endl;
    double F0prime = del0.transpose() * pk;
    double F0 = F(point);
    double c1 = 1e-4;
    double c2 = .9;
    double test1;
    double alphalo = 0.;
    double alphahi = 100.;
    double Fhiend = F(point + alphahi * pk);
    double Fprimehi = ForwardDifferences(point + alphahi * pk, F).transpose() * pk;
    double alphacurrent = CubicInterpolation(F0, Fhiend, F0prime, Fprimehi, alphalo, alphahi);
    // cout << "interpolated alpha " << alphacurrent << endl; 
    if (alphacurrent < 0 || isnan(alphacurrent))
    {
        alphacurrent = .5;
    }
    double basevalue = F0 + c1 * alphacurrent * F0prime;
    double Fcurrent = F(point + alphacurrent * pk);
    double LinearTest = F0 + c1 * alphacurrent * F0prime;
    if ((Fcurrent > LinearTest) || (Fcurrent > F0))
    {
        // cout << "Suff Decrease not satisfied" << endl;
        // cout << "Last step size was better than current guess" << endl;
        // PressEnterToContinue();
        return GoldenSection(point, pk, alphalo, alphacurrent, F);
    }
    else
    {
        double Fprimecurrent = ForwardDifferences(point + alphacurrent * pk, F).transpose() * pk;
        // cout << "Satisfied suff decrease, testing part 2" << endl;
        // cout << "Test 3 value " << abs(Fprimecurrent) << " " << -c2 * F0prime << endl;
        // PressEnterToContinue();
        if (abs(Fprimecurrent) < -c2 * F0prime)
        {
            // cout << "Satisfied Wolfe Conditions" << endl;
            // cout << "alpha " << alphacurrent << endl; 
            // cout << (point + alphacurrent * pk).transpose() << endl; 
            // PressEnterToContinue();
            return alphacurrent;
        }
        if (Fprimecurrent > 0)
        {
            // cout << "slope positive, go back" << endl;
            // PressEnterToContinue();
            return GoldenSection(point, pk, alphalo, alphacurrent, F);
        }
        return GoldenSection(point, pk, alphacurrent, alphahi, F);
    }
    // cout << endl; 
}

double Optimize::GoldenSection(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk, double alo, double ahi,
                               std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    auto CalcI1 = [](double a, double b)
    { return b - (b - a) / GR; };
    auto CalcI2 = [](double a, double b)
    { return a + (b - a) / GR; };
    double i1 = CalcI1(alo, ahi);
    double i2 = CalcI2(alo, ahi);
    double F1val, F2val;
    while ((abs(alo - ahi) > line_search_tol))
    {
        F1val = F(point + i1 * pk);
        F2val = F(point + i2 * pk);
        if (F1val < F2val)
        {
            ahi = i2;
        }
        else
        {
            alo = i1;
        }
        i1 = CalcI1(alo, ahi);
        i2 = CalcI2(alo, ahi);
    }
    return 0.5 * (alo + ahi);
}

void Optimize::BFGS_Display(VectorXd &x0, std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    double alpha;
    int n = x0.size();
    VectorXd del1(n);
    VectorXd del0(n);
    VectorXd pk(n);
    del0 = ForwardDifferences(x0, F);
    MatrixXd B0 = MatrixXd::Identity(n, n);
    double Flast = F(x0);
    double F1;
    cout << "Starting BFGS Optimization"  << endl;
    double infnorm, dist_x, fdiff;
    double p0tyk;
    VectorXd yk;
    VectorXd xlast;
    cout << format("%1%  %2%  %3%  %4% %5% %6%")  % "Iteration" % "Function Value" % "Function tol." %
     "Gradient inf.-norm" % " L.S. step size" % "  Step tol." << endl;
    cout << format("%1%  %|11t|(%2$1.2e) %|27t|(%3$1.2e) %|42t|(%4$1.2e) %5% %|78t|(%6$1.2e)") % "" % Flast % F_tol %
     grad_tol % "" % line_search_tol << endl;
    for (int k = 0; k < MaxIterations; k++)
    {
        pk = -B0 * del0;
        alpha = LineSearch(x0, pk, del0, F);
        xlast = x0;
        x0 = x0 + alpha * pk;
        dist_x = (x0 - xlast).squaredNorm();
        del1 = ForwardDifferences(x0, F);
        infnorm = del1.lpNorm<Infinity>();
        if (infnorm < grad_tol)
        {
            cout << "Norm of gradient effectively 0" << endl;
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        if (dist_x < x_tol && abs(infnorm) < EPS)
        {
            cout << "Distance between points too small" << endl;
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        yk = del1 - del0;
        p0tyk = pk.transpose() * yk;
        B0 = ((p0tyk + yk.transpose() * B0 * yk) / pow(p0tyk, 2)) * (pk * pk.transpose()) -
             (((pk * yk.transpose() * B0).transpose() + (pk * yk.transpose() * B0)) / p0tyk) +
             B0;

        del0 = del1;
        F1 = F(x0);
        /* The switch off */
        fdiff = abs(F1 - Flast);
        if (fdiff < F_tol)
        {
            cout << "Function norm less than F_tol, optimization successful..." << endl;
            cout << "Final point:" << endl;
            cout << x0.transpose() << endl;
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        Flast = F1;
        cout << format("%1%  %|11t|%2$1.2e %|27t|%3$1.2e %|42t|%4$1.2e %|63t|%5$1.2e %|78t|%6$1.2e") % (k + 1) % Flast % fdiff % infnorm % alpha % dist_x << endl;
    }
    x1 = x0;
    Hess = B0;
    fval1 = F(x1);
}

void Optimize::BFGS_Display_Off(VectorXd &x0, std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    double alpha;
    int n = x0.size();
    VectorXd del1(n);
    VectorXd del0(n);
    VectorXd pk(n);
    del0 = ForwardDifferences(x0, F);
    MatrixXd B0 = MatrixXd::Identity(n, n);
    double Flast = F(x0);
    double F1;
    double infnorm, dist_x, fdiff;
    double p0tyk;
    VectorXd yk;
    VectorXd xlast;
    for (int k = 0; k < MaxIterations; k++)
    {
        pk = -B0 * del0;
        alpha = LineSearch(x0, pk, del0, F);
        xlast = x0;
        x0 = x0 + alpha * pk;
        dist_x = (x0 - xlast).squaredNorm();
        del1 = ForwardDifferences(x0, F);
        infnorm = del1.lpNorm<Infinity>();
        if (infnorm < grad_tol)
        {
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        if ((dist_x < x_tol) && (abs(infnorm) < EPS))
        {
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        yk = del1 - del0;
        p0tyk = pk.transpose() * yk;
        B0 = ((p0tyk + yk.transpose() * B0 * yk) / pow(p0tyk, 2)) * (pk * pk.transpose()) -
             (((pk * yk.transpose() * B0).transpose() + (pk * yk.transpose() * B0)) / p0tyk) +
             B0;

        del0 = del1;
        F1 = F(x0);
        fdiff = abs(F1 - Flast);
        if (fdiff < F_tol)
        {
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        Flast = F1;
    }
    x1 = x0;
    Hess = B0;
    fval1 = F(x1);
}

void Optimize::AprroximateHessian(const Ref<const VectorXd> &point,
                                  std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    int n = point.size();
    MatrixXd ei = MatrixXd::Identity(n, n);
    VectorXd p1(n);
    VectorXd p2(n);
    VectorXd p3(n);
    double h = sqrt(1e-4);
    double h2 = h * h;
    Hess = MatrixXd::Zero(n,n);
    for (int i = 0; i < n; i++)
    {
        p1 = point;
        p2 = point;
        p3 = point;
        for (int j = 0; j < n; j++)
        {
            p1 += h * (ei.col(j) + ei.col(i));
            p2 += h * ei.col(i);
            p3 += h * ei.col(j);
            Hess(i, j) = (F(p1) - F(p2) - F(p3) + fval1) / pow(h, 2);
        }
    }
}

void Optimize::AprroximateDiagHessian(const Ref<const VectorXd> &point,
                                  std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    int n = point.size();
    MatrixXd ei = MatrixXd::Identity(n, n);
    VectorXd p1(n);
    VectorXd p2(n);
    VectorXd p3(n);
    double h = sqrt(1e-4);
    double h2 = h * h;
    Hess = MatrixXd::Zero(n,n);
    for (int i = 0; i < n; i++)
    {
        p1 = point;
        p2 = point;
        p3 = point;

            p1 += h * (ei.col(i) + ei.col(i));
            p2 += h * ei.col(i);
            p3 += h * ei.col(i);
            Hess(i, i) = (F(p1) - F(p2) - F(p3) + fval1) / pow(h, 2);
        
    }
}

double Optimize::BTLineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
                              const Ref<const VectorXd> &del0,
                              std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    double alpha = 1;
    double rho = .5;
    double c = 1e-4;
    double t1 = F(point + alpha * pk);
    double t2 = F(point) + c * alpha * del0.transpose() * pk;
    while (t1 > t2)
    {
        alpha *= alpha * rho;
        t1 = F(point + alpha * pk);
        t2 = F(point) + c * alpha * del0.transpose() * pk;
        if (alpha < EPS)
        {
            alpha = sqrt(EPS);
            break;
        }
    }
    return alpha;
}

double Optimize::CubicInterpolation(double f1, double f2, double fprime1, double fprime2, double x1, double x2)
{
    double d1 = fprime1 + fprime2 - (3 * ((f1 - f2) / (x1 - x2)));
    if (d1 < 0)
    {
        return 1;
    }
    else
    {
        double d2 = sqrt((pow(d1, 2) - (fprime1 * fprime2)));
        return x2 - ((x2 - x1) * ((fprime2 + d2 - d1) / (fprime2 - fprime1 + (2 * d2))));
    }
}
