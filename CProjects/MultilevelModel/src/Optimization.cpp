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

void Optimize::BFGS_Display(VectorXd &x0, std::function<double(const Ref<const VectorXd> &xstar)> F)
{
    double alpha;
    int n = x0.size();
    VectorXd del1(n);
    VectorXd del0(n);
    VectorXd pk(n);
    del0 = ForwardDifferences(x0, F);
    // del0 = CentralDifferences(x0, F);
    MatrixXd B0 = MatrixXd::Identity(n, n);
    double Flast = F(x0);
    double F1;
    cout << "Starting BFGS Optimization" << endl;
    double infnorm, dist_x, fdiff;
    double p0tyk;
    VectorXd yk;
    VectorXd xlast;
    cout << format("%1%  %2%  %3%  %4% %5% %6%") % "Iteration" % "Function Value" % "Function tol." %
                "Gradient inf.-norm" % " L.S. step size" % "  Step tol."
         << endl;
    cout << format("%1%  %|11t|(%2$1.2e) %|27t|(%3$1.2e) %|42t|(%4$1.2e) %5% %|78t|(%6$1.2e)") % "" % Flast % F_tol %
                grad_tol % "" % line_search_tol
         << endl;
    for (int k = 0; k < MaxIterations; k++)
    {
        pk = -B0 * del0;

        alpha = LineSearch(x0, pk, del0, F);

        xlast = x0;
        x0 = x0 + alpha * pk;
        F1 = F(x0);
        if (F1 > Flast)
        {
            cout << "Ending optimization because line search failed to find a suitable step length to minimize function.\n";
            cout << x0.transpose() << endl;

            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }

        dist_x = (x0 - xlast).squaredNorm();
        del1 = ForwardDifferences(x0, F);
        // del1 = CentralDifferences(x0, F);
        infnorm = del1.lpNorm<Infinity>();
        if (infnorm < grad_tol)
        {
            cout << format("%1%  %|11t|%2$1.2e %|27t|%3$1.2e %|42t|%4$1.2e %|63t|%5$1.2e %|78t|%6$1.2e") % (k + 1) % Flast % fdiff % infnorm % alpha % dist_x << endl;
            cout << "Norm of gradient effectively 0, optimization successful." << endl;
            cout << x0.transpose() << endl;

            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
        if ((dist_x < x_tol) && (abs(infnorm) < EPS))
        {
            cout << format("%1%  %|11t|%2$1.2e %|27t|%3$1.2e %|42t|%4$1.2e %|63t|%5$1.2e %|78t|%6$1.2e") % (k + 1) % Flast % fdiff % infnorm % alpha % dist_x << endl;
            cout << "Distance between points too small" << endl;
            cout << x0.transpose() << endl;

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
        /* The switch off */
        fdiff = abs(F1 - Flast);
        if (fdiff < F_tol)
        {
            cout << format("%1%  %|11t|%2$1.2e %|27t|%3$1.2e %|42t|%4$1.2e %|63t|%5$1.2e %|78t|%6$1.2e") % (k + 1) % Flast % fdiff % infnorm % alpha % dist_x << endl;
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
        F1 = F(x0);
        if (F1 > Flast)
        {
            x1 = x0;
            Hess = B0;
            fval1 = F(x1);
            break;
        }
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


