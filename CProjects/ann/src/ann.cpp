#include <iostream>
#include <Eigen/Dense>
#include <functional> 
#include "Distributions.hpp"
#include "EigenTools.hpp"

using namespace std;
using namespace Eigen;

class LogisticActivation
{
	public:
	VectorXd activation(const MatrixXd &Weights, const VectorXd &layer_states) const 
	{
		VectorXd x =  Weights * layer_states;
		for(int i =0; i < x.size();++i)
		{
			x(i)= 1.0/(1.0 + exp(x(i))); 
		}
		return x; 
	}

	VectorXd derivative(const VectorXd &layer_states) const 
	{
		return layer_states.array()*(1-layer_states.array());
	}
};


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
	MatrixXd Weights; 

	void create_layer(int n_nodes, const Layer &ConnectedLayer)
	{
		Weights = unifrnd(0,1,n_nodes, ConnectedLayer.zl.size());
		zl.resize(n_nodes);
	}

	void create_input_layer(int n_nodes)
	{
		zl.resize(n_nodes); 
	}

	template<typename T>
	void compute_self(Layer &ConnectedLayer, const T &ActivationClass) 
	{
		zl = ActivationClass.activation(Weights, ConnectedLayer.zl); 
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

	template<typename T> 
	VectorXd compute_net(const MatrixXd &X, const T &ActivationClass) 
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
				else
				{
					layers[k].compute_self(layers[k - 1], ActivationClass);
				}
			}
			yhat(i) = layers[layers.size()-1].zl.value();
		}
		return yhat;
	}

	template<typename T>
	void compute_net(const MatrixXd &X, int start_layer, const T &ActivationClass)
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
					layers[k].compute_self(layers[k - 1], ActivationClass);
					yhat(i) = layers[k].zl.value();
				}
				else
				{
					layers[k].compute_self(layers[k - 1], ActivationClass);
				}
			}
		}
	}

	template<typename T> 
	void compute_error_grad(const MatrixXd &X, const VectorXd &targets, const T &ActivationClass, double learning_rate)
	{
		VectorXd yhat = compute_net(X, ActivationClass); 
		VectorXd grad_z_E; 
		MatrixXd grad_w_E;
		double error = 0; 
		double delta= learning_rate;
		for(int i = layers.size()-1; i >=1; --i)
		{
			if(i==layers.size()-1)
			{
				grad_z_E.resize(1);
				grad_z_E << (yhat - targets).array().sum();
				error = grad_z_E.transpose()*grad_z_E;
				grad_w_E = (grad_z_E.array()*ActivationClass.derivative(layers[i].zl).array()).matrix() * layers[i-1].zl.transpose();
				layers[i].Weights = layers[i].Weights - delta*grad_w_E;
				cout << error << endl; 
			}
			else
			{
				grad_z_E = layers[i+1].Weights.transpose() *(grad_z_E.array()*ActivationClass.derivative(layers[i+1].zl).array()).matrix(); 
				grad_w_E = (grad_z_E.array()*ActivationClass.derivative(layers[i].zl).array()).matrix() * layers[i-1].zl.transpose();
				layers[i].Weights = layers[i].Weights - delta*grad_w_E;
				cout << layers[i].Weights << endl; 
			}
			cout << endl; 
		}

	}

	template<typename T> 
	void run_model(const MatrixXd &X, const VectorXd&targets, const T &ActivationClass, double learning_rate, int iterations)
	{
		for(int i = 1; i <= iterations; i++)
		{
			cout << i << endl; 
			compute_error_grad(X, targets, ActivationClass, learning_rate);
		}
	}
	
};

class MaxMinScaler
{
	public:
	double min_coef;
	double max_coef;
	double slope; 
	double intercept; 
	VectorXd scaler(const VectorXd &x)
	{
		max_coef = x.maxCoeff();
		min_coef = x.minCoeff();
		slope = 1.0/(max_coef-min_coef);
		intercept = -slope*min_coef; 
		return slope*x.array() + intercept; 
		
	}

	VectorXd inverse_transform(const VectorXd&z)
	{
		return (z.array() - intercept)/slope; 
	}
};



int main()
{

	cout << "ann" << endl; 
	int N = 150;
	MatrixXd X = normrnd(0,1,N,10);
	VectorXd w = unifrnd(-1,1, 10);
	VectorXd y = X*w + normrnd(0,1,N,1);
	MaxMinScaler mms; 
	VectorXd z = mms.scaler(y); 
	cout << z.transpose() << endl; 
	

	Layer L0; 
	Layer L1; 
	Layer L2; 
	Layer LL; 
	Network Net; 
	L0.create_input_layer(X.cols());
	Net.add_layer(L0);
	L1.create_layer(10, L0);
	Net.add_layer(L1);
	L2.create_layer(5, L1);
	Net.add_layer(L2);
	LL.create_layer(1, L2);
	Net.add_layer(LL);
	LogisticActivation la; 
	Net.run_model(X, z, la, 1e-4, 10);


}