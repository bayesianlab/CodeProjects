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

class Node
{
public:
	double NodeValue;
	VectorXd weights;
	int dimension_zm1; 

	Node(int input_dim, VectorXd &z_lm1,function<double(VectorXd, VectorXd)> func)
	{	
		// All other layers	
		dimension_zm1 = input_dim; 
		initialize_weights();
		compute_self(z_lm1, func);
	}

	Node(double x)
	{
		// Should be z_0 layer. Initialize z_0
		NodeValue = x;
	}

	void initialize_weights()
	{
		weights = unifrnd(-1,1, dimension_zm1);
	}

	
	void compute_self(VectorXd z_lm1, function<double(VectorXd, VectorXd)> ActivationFunc)
	{
		NodeValue = ActivationFunc(z_lm1, weights); 
	}

};




class Layer
{

public:

	double threshold = 0.5;
	VectorXd zl; 	 
	vector<Node> neurons; 
	int output_dim;
	
	void create_layer(int n_nodes, Layer &ConnectedLayer, function<double(VectorXd, VectorXd)> func)
	{
		neurons.clear(); 
		output_dim = n_nodes; 
		zl = VectorXd::Zero(n_nodes); 
		for(int i = 0; i < n_nodes; ++i)
		{
			Node n = Node(ConnectedLayer.output_dim, ConnectedLayer.zl, func);
			neurons.push_back(n);
			zl(i) = n.NodeValue;
		}
	}

	void create_layer_0(VectorXd x)
	{
		neurons.clear();
		output_dim = x.size();
		zl = VectorXd::Zero(output_dim); 
		for(int i = 0; i < x.size(); ++i)
		{
			zl(i) = x(i); 
			neurons.push_back(Node(x(i)));
		}
	}

	void compute_self(VectorXd z_lm1, function<double(VectorXd, VectorXd)> func)
	{
		
		for (int i = 0; i < neurons.size(); ++i)
		{
			neurons[i].compute_self(z_lm1, func);
			zl(i) = neurons[i].NodeValue; 
		}
		cout << endl; 
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

	double sum_dcost(VectorXd &targets, double weight,
					   function<double(VectorXd, VectorXd)> ActivationFunc,
				   	   int layer_index, int i, int j)
	{
		double cost = 0;
		for(int i = 0; i < targets.size(); ++i)
		{
			// cost += dcost_dzl(weight, targets(i), ActivationFunc, layer_index, i ,j);
		}
		return cost;
	}


	double dcost_dzl(double weight, const VectorXd &targets,
				   function<double(VectorXd, VectorXd)> ActivationFunc,
				   int layer_index, int i, int j)
	{
		// Compute the change in cost for a chanage in z
		if((layer_index < 1) || (layer_index>=layers.size()))
		{
			throw invalid_argument("Can only use Layers 1,...,L");
		}
		layers[layer_index].neurons[i].weights(j) = weight;
		
		layers[layer_index].neurons[i].compute_self(layers[layer_index - 1].zl, ActivationFunc);
		int li = layer_index; 
		while(li < layers.size()-1)
		{
			layers[li+1].compute_self(layers[li].zl, ActivationFunc);
			++li; 
		}
	}

	void backpropagation(MatrixXd &Samples, VectorXd &target)
	{
		
		int endex = layers.size()-1;
		double delta_l = 0;
		for(int i = 0; i < Samples.rows(); ++i)
		{
			delta_l += layers[endex].zl(0) - target(i);
		}

		// for(auto it = layers.size()-1; it>-1; it--)
		// {

		// 	break; 
		// }
	}
};


int main()
{

	cout << "ann" << endl; 
	int N = 100;
	MatrixXd X = normrnd(0,1,N,10);
	VectorXd w = unifrnd(-1,1, 10);
	VectorXd y = X*w + normrnd(0,1,N,1);
	

	Layer L0; 
	Layer L1; 
	Layer L2; 
	Layer LL; 
	Network Net; 
	L0.create_layer_0(X.row(0));
	Net.add_layer(L0);
	L1.create_layer(10, L0, logistic_activation);
	Net.add_layer(L1);
	L2.create_layer(5, L1, logistic_activation);
	Net.add_layer(L2);
	LL.create_layer(1, L2, logistic_activation);
	Net.add_layer(LL);

	cout << Net.sum_dcost(y, 5, logistic_activation, 2, 0, 3) << endl;


}