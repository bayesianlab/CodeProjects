#include <iostream>
#include <math.h>
#include <Eigen/Dense>
using namespace std;
using Eigen::MatrixXd;

void polyInt(MatrixXd grid, int nPoints);

void setInterpolationPoints(double xStart, double h, int nPoints, double interpolationPoints[nPoints]);

MatrixXd setNevilleArray(const MatrixXd neville, MatrixXd grid);

class Interpolation
{
	public:
		MatrixXd tab;
		int outPoints;
		Interpolation(MatrixXd table, int extrapPoints)
		{
			cout << "Polynomial interpolation" << '\n';
			tab = table;
			outPoints = extrapPoints;
		}
		
		MatrixXd setInterpolationPoints(double xStart, double h, int nPoints)
		{
			MatrixXd interpolationPoints(nPoints, 1);
			for(int j =0; j < nPoints; j ++)
			{
				interpolationPoints(j, 0) = xStart;
				xStart = xStart + h;
			}
		   return interpolationPoints;	
		} 
		
		MatrixXd setNevilleArray(const MatrixXd grid, int nRows)
		{
			MatrixXd neville(nRows, nRows);
			for(int j=0; j < grid.rows(); j++)
			{
				neville(j, 0) = grid(j, 1);
			}
			return neville;
		} 

		MatrixXd polyInt(MatrixXd grid, int nPoints )
			{
			int nRows = grid.rows();
			double xStart = grid(0,0);
			double xEnd = grid(nRows-1, 0);
			double h = (xEnd - xStart) / (nPoints -1.0);
			MatrixXd interpolationPoints(nPoints,1);
			interpolationPoints = this->setInterpolationPoints(xStart, h, nPoints);
			MatrixXd neville = this->setNevilleArray(grid, nRows);
			for(int p = 0; p < nPoints; p++)
			{
				double pnt = interpolationPoints(p,0);
				for(int j = 1; j < nRows; j ++)
				{
					for(int i = j; i < nRows; i++)
					{
						neville(i, j) = ( (pnt - grid(i-j,0))*neville(i, j -1) + (grid(i, 0) - pnt)*neville(i-1, j-1) )/ 
								(grid(i, 0) - grid(i-j, 0));
					} 
				} 
			interpolationPoints(p,0) = neville(nRows-1, nRows-1);
			cout << "Interpolation " << interpolationPoints(p, 0) << '\n';
			}
			return interpolationPoints;
		} 
		
		MatrixXd interpolate()
		{
			return this->polyInt(tab, outPoints);
		} 
};



int main()
{
	int rows = 5;
	int extrapPoints =10;
	MatrixXd x(rows, 2);
	for(int i = 0; i < rows; i++){
		x(i, 0) = i;
		x(i,1) = sin(i);
	}
	
	Interpolation interp(x, extrapPoints);
	interp.interpolate();
} 

