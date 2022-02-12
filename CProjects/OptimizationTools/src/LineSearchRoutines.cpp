#include "LineSearchRoutines.hpp"

double LineSearchRoutines::LineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
                                      const Ref<const VectorXd> &del0,
                                      std::function<double(const Ref<const VectorXd> &xstar)> F)
{

    double c1 = 1e-4;
    double c2 = .9;
    double F0prime = del0.transpose() * pk;
    double F0 = F(point);
    double alphalast = 0.;
    double Flast = F0;
    double alphamax = 2.;
    double Fhi = F(point + alphamax * pk);
    double Fprimehi = ForwardDifferences(point + alphamax * pk, F).transpose() * pk;
    double alphacurrent = 1;
    double Fcurrent;
    double LinearTest = F0 + c1 * alphacurrent * F0prime;
    double Fprimecurrent;
    for (int i = 0; i < 10; ++i)
    {
        Fcurrent = F(point + alphacurrent * pk);
        // cout << "Fcurrent " << Fcurrent << " Linear Test " << LinearTest << endl;
        if ((Fcurrent > LinearTest) || ((Fcurrent > Flast)))
        {
            // cout << "Suff Decrease not satisfied" << endl;
            // cout << "Last step size was better than current guess" << endl;
            // cout << "i " << i << endl;
            // cout << alphalast << " " << alphacurrent << endl;
            // cout << Fcurrent << " " << LinearTest << endl;
            // PressEnterToContinue();
            return Zoom(alphalast, alphacurrent, point, pk, F, F0, F0prime);
            // return GoldenSection(point, pk, alphalo, alphacurrent, F);
        }
        // else
        // {
        Fprimecurrent = ForwardDifferences(point + alphacurrent * pk, F).transpose() * pk;
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
            return Zoom(alphalast, alphacurrent, point, pk, F, F0, F0prime);
            // return GoldenSection(point, pk, alphalast, alphacurrent, F);
        }
        alphalast = alphacurrent;
        Flast = Fcurrent;
        try
        {
            // cout << "try" << endl; 
            alphacurrent = CubicInterpolation(Fcurrent, Fhi, Fprimecurrent, Fprimehi, alphacurrent, alphamax);
        }
        catch (domain_error const &)
        {
            // cout << "domain error in line search" << endl;
            // cout << alphacurrent << endl;
            alphacurrent = GoldenSection(point, pk, alphacurrent, alphamax, F, gs_max_it);
        }
    }
    // cout << "outside of for" << endl;
    // cout << alphacurrent << endl;
    return GoldenSection(point, pk, alphacurrent, alphamax, F, gs_max_it);
}

double LineSearchRoutines::Zoom(double alo, double ahi, const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
                                std::function<double(const Ref<const VectorXd> &xstar)> F, double F0, double Fprime0)
{
    double c1 = 1e-4;
    double Flo, Fhi, Fprimelo, Fprimehi, aj, Fprimej, Faj;
    int max_iterations = 10; 
    for(int j = 0; j < max_iterations; ++j)
    {
        sort_swap(alo, ahi);
        Flo = F(point + alo * pk);
        Fhi = F(point + ahi * pk);
        Fprimelo = ForwardDifferences(point + alo * pk, F).transpose() * pk;
        Fprimehi = ForwardDifferences(point + ahi * pk, F).transpose() * pk;
        try
        {
            aj = CubicInterpolation(Flo, Fhi, Fprimelo, Fprimehi, alo, ahi);
        }
        catch (domain_error const &)
        {
            cout << "Domain error" << endl; 
            aj = GoldenSection(point, pk, alo, ahi, F, 10);
        }
        if (abs(alo - aj) < line_search_tol || abs(ahi - aj) < line_search_tol)
        {
            return aj;
        }
        Faj = F(point + aj * pk);

        // cout << "aj " << aj << " Faj " << Faj << endl;
        // Prevents taking steps that increase function value
        // and sufficiently decreases function
        if ((Faj > F0 + c1 * aj * Fprime0) || (Faj > Flo))
        {
            // cout << "Did not satisfy sufficient decrease" << endl;
            ahi = aj;
        }
        else
        {
            // cout << "Sufficiently decreased function" << endl;
            Fprimej = ForwardDifferences(point + aj * pk, F).transpose() * pk;
            if (abs(Fprimej) < -.9 * Fprime0)
            {
                // cout << "Satisfied Wolfe in zoom" << endl;
                return aj;
            }
            if (Fprimej * (ahi - alo) >= 0)
            {
                // cout << " unclear if" << endl;
                ahi = alo;
            }
            alo = aj;
            if(j == max_iterations-1)
            {
                return aj; 
            }
        }
    }
    return GoldenSection(point, pk, alo, ahi, F, gs_max_it);
}


double LineSearchRoutines::GoldenSection(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk, double alo, double ahi,
                                         std::function<double(const Ref<const VectorXd> &xstar)> F, int max_it)
{
    auto CalcI1 = [](double a, double b)
    { return b - (b - a) / GR; };
    auto CalcI2 = [](double a, double b)
    { return a + (b - a) / GR; };
    double i1 = CalcI1(alo, ahi);
    double i2 = CalcI2(alo, ahi);
    double F1val, F2val;
    int i = 0;
    while ((abs(alo - ahi) > line_search_tol) && (i < max_it))
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
        // cout << alo << " " << ahi << endl;
        ++i;
    }
    return 0.5 * (alo + ahi);
}

double LineSearchRoutines::CubicInterpolation(double f1, double f2, double fprime1, double fprime2, double x1, double x2)
{
    double d1 = fprime1 + fprime2 - (3 * ((f1 - f2) / (x1 - x2)));

    double d2 = sqrt((pow(d1, 2) - (fprime1 * fprime2)));
    double rhs = ((x2 - x1) * ((fprime2 + d2 - d1) / (fprime2 - fprime1 + (2 * d2))));
    if (x2 < rhs)
    {
        throw domain_error("interpolation error");
    }
    double a = x2 - ((x2 - x1) * ((fprime2 + d2 - d1) / (fprime2 - fprime1 + (2 * d2))));
    if (isnan(a))
    {
        throw domain_error("interpolation error");
    }
    else
    {
        return a;
    }
}

void sort_swap(double &a, double &b)
{
    if (b < a)
    {
        double t;
        t = a;
        a = b;
        b = t;
    }
}


