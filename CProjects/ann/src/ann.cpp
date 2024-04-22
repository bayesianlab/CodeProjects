#include <iostream>
#include <Eigen/Dense>
#include <functional> 
#include "Distributions.hpp"
#include "EigenTools.hpp"

using namespace std;
using namespace Eigen;

double logistic_activation(VectorXd layer_states, VectorXd weights)
{
	double x = layer_states.transpose() * weights;
	return 1.0 / (1 + exp(-x));
}

double logistic_derivative(VectorXd layer_states, VectorXd weights)
{
	double fx = logistic_activation(layer_states, weights);
	return fx * (1 - fx);
}

// class Node
// {
// public:
// 	double NodeValue;
// 	VectorXd weights;
// 	int dimension_zm1; 
// 	function<double(VectorXd, VectorXd)> activation;

// 	Node(int input_dim, function<double(VectorXd, VectorXd)> func)
// 	{	
// 		// All other layers	
// 		activation = func; 
// 		dimension_zm1 = input_dim; 
// 		weights = unifrnd(-1,1, dimension_zm1);
// 	}

// 	Node()
// 	{
// 		// Should be z_0 layer. Initialize z_0
// 		NodeValue = x;
// 	}

// 	void initialize_weights()
// 	{
		
// 	}

	
// 	void compute_self(VectorXd z_lm1, function<double(VectorXd, VectorXd)> ActivationFunc)
// 	{
// 		NodeValue = ActivationFunc(z_lm1, weights); 
// 	}

// };


class Layer
{

public:

	double threshold = 0.5;
	VectorXd zl; 	 
	function<double(VectorXd, VectorXd)> activation;
	MatrixXd Weights; 

	void create_layer(int n_nodes, const Layer &ConnectedLayer, const function<double(VectorXd, VectorXd)> &func)
	{
		activation = func; 
		Weights = unifrnd(0,1,n_nodes, ConnectedLayer.zl.size());
		zl.resize(n_nodes);
	}

	void create_input_layer(int n_nodes)
	{
		zl.resize(n_nodes); 
	}

	void compute_self(Layer &ConnectedLayer)
	{
		zl = Weights * ConnectedLayer.zl; 
	}

	void compute_self(VectorXd &x)
	{
		zl = x; 
	}
};

class Network
{
	public:
	vector<Layer> layers; 
	void add_layer(Layer L)
	{
		layers.push_back(L);
	}

	VectorXd compute_net(const MatrixXd &X)
	{
		VectorXd yhat(X.rows());
		for (int i = 0; i < X.rows(); ++i)
		{
			for (int k = 0; k < layers.size(); ++k)
			{
				if (k == 0)
				{
					VectorXd z0 = X.row(i);
					layers[0].compute_self(z0);
				}
				else if (k == layers.size() - 1)
				{
					layers[k].compute_self(layers[k - 1]);
					yhat(i) = layers[k].zl.value();
				}
				else
				{
					layers[k].compute_self(layers[k - 1]);
				}
			}
		}
		return yhat;
	}

	void compute_net(const MatrixXd &X, int start_layer)
	{
		VectorXd yhat(X.rows());
		for (int i = 0; i < X.rows(); ++i)
		{
			for (int k = start_layer; k < layers.size(); ++k)
			{
				if (k == 0)
				{
					VectorXd z0 = X.row(i);
					layers[0].compute_self(z0);
				}
				else if (k == layers.size() - 1)
				{
					layers[k].compute_self(layers[k - 1]);
					yhat(i) = layers[k].zl.value();
				}
				else
				{
					layers[k].compute_self(layers[k - 1]);
				}
			}
		}
	}

	void compute_error_grad(const MatrixXd &X, const VectorXd &targets)
	{
		VectorXd yhat = compute_net(X); 
		
		for(int i = layers.size()-1; i >=0; --i)
		{
			if(i==layers.size()-1)
			{
				VectorXd error = yhat - targets; 
			}
			else
			{
				
			}
		}

	}

	// double compute_dcost(VectorXd &targets, MatrixXd &X, 
	// 				   function<double(VectorXd, VectorXd)> ActivationFunc,
	// 			   	   int layer_index, int i, int j)
	// {
	// 	double cost = 0;
	// 	for(int i = 0; i < targets.size(); ++i)
	// 	{
			
	// 	}
	// 	return cost;
	// }

	// void backpropagation(MatrixXd &Samples, VectorXd &target)
	// {
	// }
};


int main()
{

	cout << "ann" << endl; 
	int N = 2;
	MatrixXd X = normrnd(0,1,N,10);
	cout << X << endl; 
	VectorXd w = unifrnd(-1,1, 10);
	VectorXd y = X*w + normrnd(0,1,N,1);
	

	Layer L0; 
	Layer L1; 
	Layer L2; 
	Layer LL; 
	Network Net; 
	L0.create_input_layer(X.cols());
	Net.add_layer(L0);
	L1.create_layer(10, L0, logistic_activation);
	Net.add_layer(L1);
	L2.create_layer(5, L1, logistic_activation);
	Net.add_layer(L2);
	LL.create_layer(1, L2, logistic_activation);
	Net.add_layer(LL);

	cout << Net.compute_net(X) << endl;
	Net.compute_error_grad(X, y) ; 


}