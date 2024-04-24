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

class LeakyReLuActivation
{
	public:
	double C = 0.01;
	VectorXd activation(const MatrixXd &Weights, const VectorXd &layer_states) const
	{
		VectorXd a = Weights * layer_states; 
		VectorXd x(a.size()); 
		for(int i = 0; i < x.size();++i)
		{
			if(a(i) <=0)
			{
				x(i) = a(i)*C;
			}
			else
			{
				x(i) = a(i);
			}
		}
		return x; 
	}

	VectorXd derivative(const VectorXd&layer_states) const
	{
		VectorXd x(layer_states.size());
		for(int i = 0; i < x.size(); ++i)
		{
			if(layer_states(i) <=0)
			{
				x(i) = C;
			}
			else{
				x(i)= 1.0; 
			}
		}
		return x; 
	}
};

class Layer
{

public:
	double threshold = 0.5;
	VectorXd zl;
	MatrixXd Weights;

	void create_layer(int n_nodes, const Layer &ConnectedLayer)
	{
		Weights = unifrnd(0, 1, n_nodes, ConnectedLayer.zl.size());
		zl.resize(n_nodes);
	}

	void create_input_layer(int n_nodes)
	{
		zl.resize(n_nodes);
	}

	template <typename T>
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
	double learning_rate;
	double Fx_diff_tol;
	double abs_err_tol;  
	int sims; 

	Network(int _sims, double _learning_rate, double _Fx_diff_tol, double _abs_err_tol)
	{
		sims = _sims; 
		learning_rate = _learning_rate;
		Fx_diff_tol = _Fx_diff_tol;
		abs_err_tol = _abs_err_tol; 
	}

	void add_layer(Layer L)
	{
		layers.push_back(L);
	}

	template <typename T>
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
			yhat(i) = layers[layers.size() - 1].zl.value();
		}
		return yhat;
	}

	template <typename T>
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



	void check_gradient(MatrixXd &grad)
	{
		for (int i = 0; i < grad.rows(); i++)
		{
			for (int j = 0; j < grad.rows(); j++)
			{
				if (abs(grad(i, j)) < 1e-3)
				{
					grad(i, j) = 0;
				}
				else if(abs(grad(i,j)) >1e+3)
				{
					grad(i,j) = 1e+3; 
				}
			}
		}
	}

	void check_gradient(VectorXd &grad)
	{
		for (int i = 0; i < grad.rows(); i++)
		{
			if (abs(grad(i)) < 1e-3)
			{
				grad(i) = 0;
			}
			else if (abs(grad(i)) > 1e+3)
			{
				grad(i) = 1e+3;
			}
		}
	}

	template <typename T>
	void run_model(const MatrixXd &X, const VectorXd &targets, const T &ActivationObj)
	{
		double delta = learning_rate;
		VectorXd grad_z_E;
		MatrixXd grad_w_E;
		double old_error;
		double error = -1000; 
		for (int i = 1; i <= sims; i++)
		{
			VectorXd yhat = compute_net(X, ActivationObj);
			map<int, MatrixXd> old_weights;

			for (int j = layers.size() - 1; j >= 1; --j)
			{
				if (j == layers.size() - 1)
				{
					grad_z_E = (yhat - targets);
					check_gradient(grad_z_E);
					error = grad_z_E.transpose() * grad_z_E;
					double s = grad_z_E.array().sum();
					grad_z_E.resize(1);
					grad_z_E << s;
				}
				else
				{
					grad_z_E = layers[j + 1].Weights.transpose() * (grad_z_E.array() * ActivationObj.derivative(layers[j + 1].zl).array()).matrix();
					check_gradient(grad_z_E);
				}
				grad_w_E = (grad_z_E.array() * ActivationObj.derivative(layers[j].zl).array()).matrix() * layers[j - 1].zl.transpose();
				check_gradient(grad_w_E);
				// cout << grad_w_E << endl;
				layers[j].Weights = layers[j].Weights - delta * grad_w_E;
				old_weights[j] = layers[j].Weights;
			}
			
			if ((error > old_error) && (i > 1))
			{
				for (int j = layers.size() - 1; j >= 1; --j)
				{
					layers[j].Weights = old_weights[j];
				}
				if (delta > 1e-6)
				{
					delta = delta * .5;
				}
				else
				{
					for (int j = 1; j < layers.size(); ++j)
					{
						int r = layers[j].Weights.rows();
						int c = layers[j].Weights.cols();
						layers[j].Weights = unifrnd(0, 1, r, c);
					}
					delta = learning_rate;
				}
			}
			

			else if ((abs(old_error - error) < Fx_diff_tol) && (old_error > abs_err_tol))
			{
				cout << "stuck" << endl; 
				delta = 2*delta; 
			}
			cout << abs(old_error - error) << endl; 
			old_error = error; 
			cout << error << endl;
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
		slope = 1.0 / (max_coef - min_coef);
		intercept = -slope * min_coef;
		return slope * x.array() + intercept;
	}

	VectorXd inverse_transform(const VectorXd &z)
	{
		return (z.array() - intercept) / slope;
	}
};

int main()
{

	cout << "ann" << endl; 
	int N = 10;
	int sims = 1000;
	MatrixXd X = normrnd(0,1,N,10);
	VectorXd w = unifrnd(-1,1, 10);
	VectorXd y = X*w + normrnd(0,1,N,1);

	

	Layer L0; 
	Layer L1; 
	Layer L2; 
	Layer LL; 
	Network Net(sims, .01, 1e-5, 1e-2); 
	L0.create_input_layer(X.cols());
	Net.add_layer(L0);
	L1.create_layer(10, L0);
	Net.add_layer(L1);
	L2.create_layer(5, L1);
	Net.add_layer(L2);
	LL.create_layer(1, L2);
	Net.add_layer(LL);
	LeakyReLuActivation la; 
	Net.run_model(X, y, la);


}