#include <iostream>
#include <Eigen/Dense>
#include <functional>
#include "Distributions.hpp"
#include "EigenTools.hpp"
#include "Plotter.hpp"

using namespace std;
using namespace Eigen;



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

class LogisticActivation
{
public:
	VectorXd activation(const MatrixXd &Weights, const VectorXd &layer_states) const
	{
		VectorXd x = Weights * layer_states;
		for (int i = 0; i < x.size(); ++i)
		{
			x(i) = 1.0 / (1.0 + exp(x(i)));
		}
		return x;
	}

	VectorXd derivative(const VectorXd &layer_states) const
	{
		return layer_states.array() * (1 - layer_states.array());
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
		for (int i = 0; i < x.size(); ++i)
		{
			if (a(i) <= 0)
			{
				x(i) = a(i) * C;
			}
			else
			{
				x(i) = a(i);
			}
		}
		return x;
	}

	VectorXd derivative(const VectorXd &layer_states) const
	{
		VectorXd x(layer_states.size());
		for (int i = 0; i < x.size(); ++i)
		{
			if (layer_states(i) <= 0)
			{
				x(i) = C;
			}
			else
			{
				x(i) = 1.0;
			}
		}
		return x;
	}
};

class LinearActivation
{
public:
	VectorXd activation(const MatrixXd &Weights, const VectorXd &layer_states) const
	{
		return Weights * layer_states;
	}

	VectorXd derivative(const VectorXd &layer_states) const
	{
		return VectorXd::Ones(layer_states.size());
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

		Weights = normrnd(0, sqrt(1.0 / (ConnectedLayer.zl.size() + n_nodes)), n_nodes,
						  ConnectedLayer.zl.size());
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
	int batch_size;
	map<int, MatrixXd> X_batches;
	map<int, VectorXd> y_batches;
	bool permute;

	Network(int _sims, int _batch_size, double _learning_rate, double _Fx_diff_tol, double _abs_err_tol,
			bool _permute = true)
	{
		sims = _sims;
		batch_size = _batch_size;
		learning_rate = _learning_rate;
		Fx_diff_tol = _Fx_diff_tol;
		abs_err_tol = _abs_err_tol;
		permute = _permute;
	}

	void add_layer(Layer L)
	{
		layers.push_back(L);
	}

	template <typename T>
	VectorXd compute_net(const MatrixXd &X, const T &ActivationClass)
	{
		VectorXd z_output(X.rows());
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
			z_output(i) = layers[layers.size() - 1].zl.value();
		}
		return z_output;
	}

	void check_gradient(MatrixXd &grad)
	{
		double clip = 100;
		for (int i = 0; i < grad.rows(); i++)
		{
			for (int j = 0; j < grad.rows(); j++)
			{
				if (abs(grad(i, j)) < 1e-6)
				{
					grad(i, j) = 0;
				}
			}
		}
		if (grad.squaredNorm() > clip)
		{
			grad = clip * grad / grad.squaredNorm();
		}
	}

	void check_gradient(VectorXd &grad)
	{
		double clip = 100;
		for (int i = 0; i < grad.rows(); i++)
		{
			if (abs(grad(i)) < 1e-6)
			{
				grad(i) = 0;
			}
		}
		if (grad.squaredNorm() > clip)
		{
			grad = clip * grad / grad.squaredNorm();
		}
	}

	void batch_data(const MatrixXd &X, const VectorXd &y, bool permute = true)
	{
		time_t now = time(0);
		boost::random::mt19937 GLOBAL_SEED(now);
		std::mt19937 eng(GLOBAL_SEED);
		if (permute)
		{
			PermutationMatrix<Dynamic, Dynamic> perm(X.rows());
			perm.setIdentity();
			shuffle(perm.indices().data(), perm.indices().data() + perm.indices().size(), eng);
			MatrixXd Xcopy = perm * X;
			VectorXd ycopy = perm * y;
			int rows = Xcopy.rows();
			int batches = rows / batch_size;
			int rem = rows % batch_size;
			if (rem)
			{
				batches++;
			}
			int c = 0;
			for (int b = 0; b < batches; ++b)
			{

				if (c + batch_size - 1 < rows)
				{
					X_batches[b] = Xcopy.block(c, 0, batch_size, Xcopy.cols());
					y_batches[b] = ycopy.segment(c, batch_size);
					c += batch_size;
				}
				else
				{
					X_batches[b] = Xcopy.block(c, 0, rem, Xcopy.cols());
					y_batches[b] = ycopy.segment(c, rem);
					c += batch_size;
				}
			}
		}
		else
		{
			int rows = X.rows();
			int batches = rows / batch_size;
			int rem = rows % batch_size;
			if (rem)
			{
				batches++;
			}
			int c = 0;
			for (int b = 0; b < batches; ++b)
			{

				if (c + batch_size - 1 < rows)
				{
					X_batches[b] = X.block(c, 0, batch_size, X.cols());
					y_batches[b] = y.segment(c, batch_size);
					c += batch_size;
				}
				else
				{
					X_batches[b] = X.block(c, 0, rem, X.cols());
					y_batches[b] = y.segment(c, rem);
					c += batch_size;
				}
			}
		}
	}

	template <typename T1, typename T2>
	VectorXd run_model(const MatrixXd &X, const VectorXd &targets, const T1 &ActivationObj, const T2 &Loss)
	{
		double delta = learning_rate;
		VectorXd grad_z_E;
		MatrixXd grad_w_E;
		double avg_error = 0;
		double error; 
		batch_data(X, targets, permute);
		int Batches = y_batches.size();
		map<int, MatrixXd> deltas;
		for (int i = 1; i <= sims; i++)
		{
			cout << "sim " << i << endl;
			double batch_error = 0;
			for (int B = 0; B < Batches; ++B)
			{
				VectorXd yhat = compute_net(X_batches[B], ActivationObj);
				for (int L = layers.size() - 1; L >= 1; --L)
				{
					int n_nodes = layers[L].zl.size();
					if (L == layers.size() - 1)
					{
						batch_error += Loss.loss(yhat, y_batches[B]);
						double s = Loss.gradient(yhat, y_batches[B]);
						grad_z_E.resize(1);
						grad_z_E << s;
					}
					else
					{
						grad_z_E = layers[L + 1].Weights.transpose() * grad_z_E;
					}
					grad_w_E = grad_z_E * layers[L - 1].zl.transpose();
					deltas[L] = -delta * grad_w_E;
				}
				for(int L = 1; L<layers.size(); ++L)
				{
					layers[L].Weights = layers[L].Weights + deltas[L];
				}
			}
			batch_error /= Batches;
			cout << batch_error << endl; 
			if (permute)
			{
				batch_data(X, targets, permute);
			}
		}
		return compute_net(X, ActivationObj).transpose();
	}
};

class MeanSquaredError
{
	public:
	double loss(const VectorXd &yhat, const VectorXd &ytrue) const 
	{
		return (yhat - ytrue).array().pow(2).sum()/ytrue.size(); 
	}

	double gradient(const VectorXd &yhat, const VectorXd &ytrue) const 
	{
		return (yhat - ytrue).array().sum(); 
	}
};



int main()
{

	cout << "ann" << endl;
	int N = 30;
	int epochs = 10;
	MatrixXd X = normrnd(0, 1, N, 10);
	VectorXd w = unifrnd(-1, 1, 10);
	VectorXd y = X * w + normrnd(0, 1, N, 1);


	Layer L0;
	Layer L1;
	Layer LL;
	double learning_rate = 5e-3;
	double Fx_diff_tol = 1e-2;
	double abs_err_tol = 1e-2;
	int batch_size = 30;
	Network Net(epochs, batch_size, learning_rate, Fx_diff_tol, abs_err_tol, false);
	L0.create_input_layer(X.cols());
	Net.add_layer(L0);
	L1.create_layer(10, L0);
	Net.add_layer(L1);
	LL.create_layer(1, L1);
	Net.add_layer(LL);
	LinearActivation la;
	MeanSquaredError mse; 
	VectorXd yhat = Net.run_model(X, y, la, mse);
	plotter("fname.p", y, yhat);
}