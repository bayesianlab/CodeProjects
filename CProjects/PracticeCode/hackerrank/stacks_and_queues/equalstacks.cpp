

#include <bits/stdc++.h>
#include <chrono>

using namespace std;
using namespace chrono;

void printv(vector<int> x)
{
    for (int i = 0; i < x.size(); ++i)
    {
        cout << x[i] << " ";
    }
    cout << endl;
}

int equalStacks(vector<int> h1, vector<int> h2, vector<int> h3)
{
    auto sumup = [](vector<int> x)
    {
        int s = 0;
        for (int i = 0; i < (int)x.size(); ++i)
        {
            s += x[i];
        }
        return s;
    };
    int sh1 = sumup(h1);
    int sh2 = sumup(h2);
    int sh3 = sumup(h3);
    int completedflag = 0;
    while ((sh1 != sh2) || (sh1 != sh3) || (sh2 != sh3))
    {
        // cout << sh1 << endl;
        // cout << sh2 << endl;
        // cout << sh3 << endl;
        // printv(h1);
        // printv(h2);
        // printv(h3);
        // cout << endl;
        if (h1.size() == 0 || h2.size() == 0 || h3.size() == 0)
        {
            return 0;
        }
        if ((sh1 <= sh2) && (sh1 <= sh3))
        {
            completedflag = 1;
            while ((sh1 != sh2) || (sh1 != sh3))
            {
                if ((sh1 != sh2))
                {
                    sh2 -= h2[0];
                    h2.erase(h2.begin());
                }
                if ((sh1 != sh3))
                {
                    sh3 -= h3[0];
                    h3.erase(h3.begin());
                }
                if ((sh2 < sh1) || (sh3 < sh1))
                {
                    completedflag = 0;
                    break;
                }
            }
            if (completedflag == 1)
            {
                return sh1;
            }
        }
        // 2 is the min
        else if ((sh2 <= sh3) && (sh2 <= sh1))
        {
            completedflag = 1;
            while ((sh2 != sh3) || (sh2 != sh1))
            {
                if ((sh2 != sh3))
                {
                    sh3 -= h3[0];
                    h3.erase(h3.begin());
                }
                if ((sh2 != sh1))
                {
                    sh1 -= h1[0];
                    h1.erase(h1.begin());
                }
                if ((sh3 < sh2) || (sh1 < sh2))
                {
                    completedflag = 0;
                    break;
                }
            }
            if (completedflag == 1)
            {
                return sh1;
            }
        }
        // 3 is the min
        else
        {
            completedflag = 1;
            while ((sh3 != sh2) || (sh3 != sh1))
            {
                if ((sh3 != sh2))
                {
                    sh2 -= h2[0];
                    h2.erase(h2.begin());
                }
                if ((sh3 != sh1))
                {
                    sh1 -= h1[0];
                    h1.erase(h1.begin());
                }
                if ((sh2 < sh3) || (sh1 < sh3))
                {
                    completedflag = 0;
                    break;
                }
            }
            if (completedflag == 1)
            {
                return sh1;
            }
        }
    }
    return sh1;
}

int equalStacks2(vector<int> h1, vector<int> h2, vector<int> h3)
{
    auto sumup = [](vector<int> x)
    {
        int s = 0;
        for (int i = 0; i < (int)x.size(); ++i)
        {
            s += x[i];
        }
        return s;
    };
    int sh1 = sumup(h1);
    int sh2 = sumup(h2);
    int sh3 = sumup(h3);
    int completedflag = 0;
    while ((sh1 != sh2) || (sh1 != sh3) || (sh2 != sh3))
    {
        // cout << sh1 << endl;
        // cout << sh2 << endl;
        // cout << sh3 << endl;
        // printv(h1);
        // printv(h2);
        // printv(h3);
        // cout << endl;
        if (h1.size() == 0 || h2.size() == 0 || h3.size() == 0)
        {
            return 0;
        }
        if ((sh1 <= sh2) && (sh1 <= sh3))
        {
            completedflag = 1;
            while ((sh1 != sh2) || (sh1 != sh3))
            {
                if ((sh1 != sh2))
                {
                    h2.erase(h2.begin());
                }
                if ((sh1 != sh3))
                {
                    h3.erase(h3.begin());
                }
                sh1 = sumup(h1);
                sh2 = sumup(h2);
                sh3 = sumup(h3);
                if ((sh2 < sh1) || (sh3 < sh1))
                {
                    completedflag = 0;
                    break;
                }
            }
            if (completedflag == 1)
            {
                return sh1;
            }
        }
        // 2 is the min
        else if ((sh2 <= sh3) && (sh2 <= sh1))
        {
            completedflag = 1;
            while ((sh2 != sh3) || (sh2 != sh1))
            {
                if ((sh2 != sh3))
                {
                    h3.erase(h3.begin());
                }
                if ((sh2 != sh1))
                {
                    h1.erase(h1.begin());
                }
                sh1 = sumup(h1);
                sh2 = sumup(h2);
                sh3 = sumup(h3);
                if ((sh3 < sh2) || (sh1 < sh2))
                {
                    completedflag = 0;
                    break;
                }
            }
            if (completedflag == 1)
            {
                return sh1;
            }
        }
        // 3 is the min
        else
        {
            completedflag = 1;
            while ((sh3 != sh2) || (sh3 != sh1))
            {
                if ((sh3 != sh2))
                {
                    h2.erase(h2.begin());
                }
                if ((sh3 != sh1))
                {
                    h1.erase(h1.begin());
                }
                sh1 = sumup(h1);
                sh2 = sumup(h2);
                sh3 = sumup(h3);
                if ((sh2 < sh3) || (sh1 < sh3))
                {
                    completedflag = 0;
                    break;
                }
            }
            if (completedflag == 1)
            {
                return sh1;
            }
        }
    }
    return sumup(h1);
}

int main()
{
    vector<int> x{3, 2, 1, 1, 1}; // 6
    vector<int> y{4, 3, 2};       // 7
    vector<int> z{1, 1, 4, 1};    //9
    auto start = high_resolution_clock::now();
    cout << equalStacks2(x, y, z) << endl;
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << duration.count() << endl;
    start = high_resolution_clock::now();
    cout << equalStacks(x, y, z) << endl;
    stop = high_resolution_clock::now();
    duration = duration_cast<microseconds>(stop - start);
    cout << duration.count() << endl;
    return 0;
}