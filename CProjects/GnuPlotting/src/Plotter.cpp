#include "Plotter.hpp"
const static Eigen::IOFormat CSVFormat(Eigen::StreamPrecision, Eigen::DontAlignCols, ", ", "\n");

void writeToCSVfile(string name, const MatrixXd &matrix)
{
    ofstream file(name.c_str());
    if (file.is_open())
    {
        file << matrix << '\n';
        file.close();
    }
    else
    {
        cout << "error" << endl;
    }
}

int plotter(string filename, const VectorXd &A, const VectorXd &B)
{
    writeToCSVfile("a.csv", A);
    writeToCSVfile("b.csv", B);
    ofstream file(filename);
    if (file.is_open())
    {
        file << "set autoscale\n";
        file << "plot \"a.csv\"  using 1 with lines, \"b.csv\" using 1 with lines\n";
        file.close();
        format fmter("gnuplot -persist %1%");
        fmter % filename;
        string s = fmter.str();
        int t = system(s.c_str());

        if (t != 0)
        {
            cout << "Error in system call" << endl;
        }
        return 0;
    }
    else
    {
        cout << "error in file." << endl;
        return 1;
    }
}


int plotter(string filename, const VectorXd &A, const VectorXd &B, string labelA, string labelB)
{
    writeToCSVfile("a.csv", A);
    writeToCSVfile("b.csv", B);
    ofstream file(filename);
    if (file.is_open())
    {
        file << "set autoscale\n";
        format ptitle("plot \"a.csv\"  using 1 with lines title \"%1%\", \"b.csv\" using 1 with lines title \"%2%\"\n");
        ptitle % labelA % labelB;
        file << ptitle;
        file.close();
        format fmter("gnuplot -persist %1%");
        fmter % filename;
        string s = fmter.str();
        int t = system(s.c_str());

        if (t != 0)
        {
            cout << "Error in system call" << endl;
        }
        return 0;
    }
    else
    {
        cout << "error in file." << endl;
        return 1;
    }
}