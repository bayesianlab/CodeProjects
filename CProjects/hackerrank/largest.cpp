#include <bits/stdc++.h>
using namespace std;
using namespace chrono;
class Solution
{
public:
    // The main function that returns the arrangement with the largest value as
    // string.
    // The function accepts a vector of strings

    vector<int> sortindexes(vector<int> &firstdigits)
    {
        vector<int> Idx(firstdigits.size());
        iota(Idx.begin(), Idx.end(), 0);
        auto compd = [&firstdigits](int i1, int i2)
        { return firstdigits[i1] < firstdigits[i2]; };

        stable_sort(Idx.begin(), Idx.end(), compd);
        return Idx;
    }

    vector<int> getFirstDigits(vector<string> &array)
    {
        vector<string>::iterator i;
        vector<int> fd(array.size());
        string t;
        for (int i = 0; i < array.size(); ++i)
        {
            fd[i] = array[i][0] - 48;
        }

        return fd;
    }

    int help1(const string &a, const string &b)
    {
        int c = 0;
        int ti = a[c];
        int tj = b[c];
        int leni = a.length();
        int lenj = b.length();
        int longest = max(leni, lenj);
        while ((ti == tj))
        {
            ++c;
            if (c == longest)
            {
                c = c - 1;
                break;
            }
            if (c < leni)
            {
                ti = a[c];
            }
            if (c < lenj)
            {
                tj = b[c];
            }
        }
        return c;
    }

    vector<int> help2(const string &a, const string &b)
    {
        int breakindex = help1(a, b);
        int leni = a.length();
        int lenj = b.length();
        int xc, cc, ti, tj, xxc;
        if (breakindex > leni - 1)
        {
            tj = b[leni];
            ti = b[0];
            cc = 0;
            xxc = 0;
            while (ti == tj)
            {
                ++cc;
                if ((cc + leni) > (lenj - 1))
                {
                    if (xxc > leni - 1)
                    {
                        break;
                    }
                    tj = a[xxc];
                    ti = b[cc];
                    ++xxc;
                }
                else
                {
                    ti = b[cc];
                    tj = b[leni + cc];
                }
            }
        }
        else if (breakindex > lenj - 1)
        {
            ti = a[lenj];
            tj = a[0];
            cc = 0;
            xxc = 0;
            while (ti == tj)
            {
                ++cc;
                if ((cc + lenj) > (leni - 1))
                {
                    if (xxc > lenj - 1)
                    {
                        break;
                    }
                    ti = b[xxc];
                    tj = a[cc];
                }
                else
                {
                    ti = a[lenj + cc];
                    tj = a[cc];
                }
            }
        }
        else
        {
            ti = a[breakindex];
            tj = b[breakindex];
        }
        vector<int> res{ti, tj};
        return res;
    }

    void printv(const vector<string> &a)
    {
        for (int i = 0; i < a.size(); ++i)
        {
            cout << a[i] << " ";
        }
        cout << endl;
    }

    bool help4(string &a, string &b)
    {
        string X = a + b;
        unsigned long long int XX = strtoull(X.c_str(), nullptr, 10);
        string Y = b + a;
        unsigned long long int YY = strtoull(Y.c_str(), nullptr, 10);
        return X > Y;
    }

    void merge(vector<string> &ar, int b, int div, int e)
    {
        string temp;
        int lleft = 0;
        int lright = 0;
        int d, c;
        d = 0;
        c = 0;
        vector<int> leftright;
        int mergingIndex = b;

        vector<string> lefttemp(div - (b - 1));
        vector<string> righttemp(e - div);
        for (int i = b; i <= div; ++i)
        {
            lefttemp[i - b] = ar[i];
        }
        for (int i = div + 1; i <= e; ++i)
        {
            righttemp[i - (div + 1)] = ar[i];
        }

        printv(lefttemp);
        printv(righttemp);
        while ((lleft <= lefttemp.size() - 1) && (lright <= righttemp.size() - 1))
        {
            leftright = help2(lefttemp[lleft], righttemp[lright]);
            if (leftright[0] > leftright[1])
            {
                ar[mergingIndex] = righttemp[lright];
                ++lright;
            }
            else
            {
                ar[mergingIndex] = lefttemp[lleft];
                ++lleft;
            }
            mergingIndex++;
        }
        while (lleft <= lefttemp.size() - 1)
        {
            ar[mergingIndex] = lefttemp[lleft];
            ++lleft;
            mergingIndex++;
        }
        while (lright <= righttemp.size() - 1)
        {
            ar[mergingIndex] = righttemp[lright];
            ++lright;
            mergingIndex++;
        }
        printv(ar);
    }

    void mergeSort(vector<string> &ar, int b, int e)
    {
        if (b >= e)
        {
            return;
        }
        int div = b + (e - b) / 2;
        mergeSort(ar, b, div);
        mergeSort(ar, div + 1, e);
        merge(ar, b, div, e);
    }

    string printLargest(vector<string> &arr)
    {

        // // sort(arr.begin(), arr.end());
        // int c, d, cc, xc;
        // string t;
        // int ti, tj;
        // int leni, lenj, longest;
        // vector<int> titj;
        // for (int i = 0; i < arr.size() - 1; ++i)
        // {

        //     // c first different index
        //     // leni = arr[i].length();
        //     // lenj = arr[i + 1].length();
        //     // c = help1(arr[i], arr[i + 1]);
        //     // titj = help2(arr[i], arr[i + 1], c);
        //     // ti = titj[0];
        //     // tj = titj[1];

        //     if (help4(arr[i], arr[i + 1]))
        //     {
        //         t = arr[i + 1];
        //         arr[i + 1] = arr[i];
        //         arr[i] = t;
        //         d = i;
        //         while (d >= 1)
        //         {
        //             // c = help1(arr[d], arr[d - 1]);
        //             // titj = help2(arr[d], arr[d - 1], c);
        //             // ti = titj[0];
        //             // tj = titj[1];
        //             if (help4(arr[d - 1], arr[d]))
        //             {
        //                 t = arr[d - 1];
        //                 arr[d - 1] = arr[d];
        //                 arr[d] = t;
        //             }
        //             --d;
        //         }
        //     }
        // }
        mergeSort(arr, 0, arr.size() - 1);
        string res;
        for (vector<string>::const_reverse_iterator i = arr.rbegin(); i != arr.rend(); ++i)
        {
            // cout << arr[i] << endl;
            res += *i;
        }
        cout << res << endl;
        return res;
    }
};

int main()
{
    Solution s;

    // vector<string> arr{"15", "153", "10", "109"};
    // vector<string> arr{"250", "74", "659", "931", "273", "545", "879", "924"};
    // vector<string> arr{"112", "11", "3"};
    // vector<string> arr{"9", "969", "969", "963", "943", "905"};
    // vector<string> arr{"17", "177"};
    // vector<string> arr{"15", "151"};
    // vector<string> arr{"980", "968", "98"};

    // vector<string> arr{
    //     "100", "279", "817", "336", "98", "827", "513", "268",
    //     "811", "634", "980", "150", "580", "822", "968", "673",
    //     "394", "337", "486", "746", "229", "92", "195", "358", "2",
    //     "154", "709", "945", "669", "491", "125", "197", "531", "904"};
    // vector<string> arr{"791", "7"};
    // vector<string> arr{"768", "822", "696", "713", "672", "902", "591", "832", "739", "58", "617", "791", "641", "680", "336", "7", "973", "99", "96", "320", "455", "224", "290", "761", "906", "127", "124", "507", "814", "771", "239", "95", "221", "845", "367", "535", "227", "395", "364", "739", "845", "591", "551", "160", "624", "948", "386", "218", "273", "540", "248", "386", "497"};
    // vector<string> arr{"76","767" };
    // vector<string> arr{"1000","10" };
    // vector<string> arr{"1112","1" };
    // vector<string> arr{"931","924"};

    // vector<string> arr{"74", "659", "931", "273", "545", "879", "924"};
    // s.mergeSort(arr, 0, arr.size() - 1);
    auto start = high_resolution_clock::now();
    string u = s.printLargest(arr);
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << duration.count() << endl;
}