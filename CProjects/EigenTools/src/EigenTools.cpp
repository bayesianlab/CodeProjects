#include "EigenTools.hpp"
VectorXi sequence(int b, int e)
{
    if (e < b)
    {
        throw invalid_argument("Error in sequence, end point less than beginning.");
    }
    VectorXi c(e - b + 1);
    int h = 0;
    for (int i = b; i <= e; ++i)
    {
        c(h) = b + h;
        ++h;
    }
    return c;
}

VectorXi sequence(int b, int e, int skip)
{
    if (e < b)
    {
        throw invalid_argument("Error in sequence, end point less than beginning.");
    }
    int N = (e - b + skip) / skip;
    VectorXi c(N);
    int h = 0;
    for (int i = b; i <= e; i += skip)
    {
        c(h) = b + h * skip;
        ++h;
    }
    return c;
}

VectorXd var(const Ref<const MatrixXd> &A, int row_col)
{
    MatrixXd centered = (A.colwise() - A.rowwise().mean()).array().pow(2);
    return (1. / A.cols()) * centered.rowwise().sum();
}

MatrixXd readCSV(std::string file, int rows, int cols)
{

    MatrixXd X = MatrixXd::Zero(rows, cols);
    ifstream fin;
    fin.open(file);
    string line;
    size_t foundquote;
    int rowCount = -1;
    if (fin.is_open())
    {
        string field;
        string newfield;
        while (getline(fin, line, '\n') && rowCount < rows - 1)
        {
            rowCount++;

            int colCount = -1;
            istringstream buf(line);
            foundquote = line.find(",");
            if (foundquote == std::string::npos)
            {
                throw std::invalid_argument("Error in separator type in readCSV().");
            }
            foundquote = line.find('"');
            if (foundquote != std::string::npos)
            {
                while (getline(buf, field, ','))
                {
                    newfield = (char *)malloc(sizeof(char) * field.length() + 1);
                    for (int i = 0; i < field.length(); ++i)
                    {
                        if (field[i] != '"')
                        {
                            newfield += field[i];
                        }
                    }
                    ++colCount;
                    if (colCount > cols)
                    {
                        throw invalid_argument("Columns not set correctly in readCSV");
                    }
                    X(rowCount, colCount) = stod(newfield);
                }
            }
            else
            {
                while (getline(buf, field, ','))
                {
                    colCount++;
                    if (colCount > cols)
                    {
                        throw invalid_argument("Columns not set correctly in readCSV");
                    }
                    string number;
                    X(rowCount, colCount) = stod(field);
                }
                if (rowCount > rows)
                {
                    throw invalid_argument("Rows not set correctly in readCSV");
                }
            }
        }
        fin.close();
        return X;
    }
    else
    {
        cout << "File " << file << " not opened." << endl;
        return X;
    }
}
