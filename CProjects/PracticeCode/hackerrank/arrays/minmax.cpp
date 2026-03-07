#include <bits/stdc++.h>

using namespace std;

string ltrim(const string &);
string rtrim(const string &);
vector<string> split(const string &);

/*
 * Complete the 'miniMaxSum' function below.
 *
 * The function accepts INTEGER_ARRAY arr as parameter.
 */

void miniMaxSum(vector<int> arr) {

    unsigned long int min = accumulate(arr.begin(), arr.end(), 0); 
    unsigned long int max=0; 
    for(int i =0; i < arr.size(); ++i)
    {
        unsigned long int cand = 0; 
        for(int j =0; j < arr.size(); ++j)
        {
            if(i != j)
            {
                cand += arr[j]; 
            }
        }
        if(cand < min)
        {
            min = cand;
        }
        if(cand > max)
        {
            max = cand; 
        }
    }
    cout << min << " " << max << endl;
}


int main()
{
    vector<int> t = {256741038, 623958417,467905213 ,714532089 ,938071625};
    miniMaxSum(t);
}