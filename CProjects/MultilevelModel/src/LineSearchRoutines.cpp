#include "LineSearchRoutines.hpp"

double LineSearchRoutines::LineSearch(const Ref<const VectorXd> &point, const Ref<const VectorXd> &pk,
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
    double alphalast = 0.;
    double Flast = F0;
    double alphamax = 3.;
    double Fhi = F(point + alphamax * pk);
    double Fprimehi = ForwardDifferences(point + alphamax * pk, F).transpose() * pk;
    double alphacurrent;
    try
    {
        alphacurrent = CubicInterpolation(F0, Fhi, F0prime, Fprimehi, alphalast, alphamax);
    }
    catch (domain_error)
    {
        alphacurrent = 1;
    }
    // cout << "alphacurrent " << alphacurrent << endl;

    double Fcurrent;
    double LinearTest = F0 + c1 * alphacurrent * F0prime;
    double Fprimecurrent;
    for (int i = 0; i < 10; ++i)
    {
        Fcurrent = F(point + alphacurrent * pk);
        if ((Fcurrent > LinearTest) || ((Fcurrent > Flast) && (i > 0)))
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
            // return GoldenSection(point, pk, alphalo, alphacurrent, F);
        }
        alphalast = alphacurrent;
        Flast = Fcurrent;
        try
        {
            alphacurrent = CubicInterpolation(Fcurrent, Fhi, Fprimecurrent, Fprimehi, alphacurrent, alphamax);
        }
        catch (domain_error)
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
    double aj;
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
    aj = 0.5 * (alo + ahi);

    return 0.5 * (alo + ahi);
}