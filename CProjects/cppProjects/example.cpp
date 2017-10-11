#include <iostream>
#include <ctime>
#include <cstdint>
using namespace std;
class Dog{
	int dogWeight, dogBark;
	public:
		Dog(int weight, int bark){
			dogWeight = weight;
			dogBark = bark;			
		} 
		
		void getWeightBark(void){
			cout << "Dog weight " << dogWeight << endl;
			cout << "Dog bark " << dogBark << endl;
		} 
			
};


int main()
{
	Dog collie(10, 3);
	collie.getWeightBark();
}


