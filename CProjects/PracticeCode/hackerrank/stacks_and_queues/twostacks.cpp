#include <bits/stdc++.h>
#include <chrono>

using namespace std;
using namespace chrono;

string ltrim(const string &);
string rtrim(const string &);
vector<string> split(const string &);

vector<int> nmoves(int m, vector<int> a, vector<int> b)
{

    vector<int> tstrat;
    vector<int> strat;
    strat.resize(2);
    tstrat.resize(2);
    int suma, tempsuma, amoves, bmoves, asum, bsum, tempsuma2;
    suma = 0;
    tempsuma = 0;
    tempsuma2 = 0;
    asum = 0;
    bsum = 0;
    if (m < a.size())
    {
        amoves = m;
        strat[0] = m;
        strat[1] = 0;
    }
    else
    {
        amoves = a.size();
        strat[0] = a.size();
        strat[1] = m - a.size();
    }
    int x = 0;
    for (int i = 0; i < strat[0]; ++i)
    {
        suma += a[i];
        asum += a[i];
    }
    for (int j = 0; j < strat[1]; ++j)
    {
        suma += b[j];

        bsum += b[j];
    }
    int moves = m;
    int stopflag = 0;
    while ((moves > 0) && (stopflag == 0))
    {
        if (amoves == 1)
        {
            asum -= a[amoves - 1];
            stopflag = 1;
        }
        else
        {
            asum -= a[amoves - 1];
        }
        --amoves;
        bmoves = m - amoves;
        bsum += b[bmoves - 1];
        --moves;

        if (bmoves > b.size())
        {
            break;
        }
        tempsuma2 = asum + bsum;

        // for (int k = 0; k < amoves; ++k)
        // {
        //     tempsuma += a[k];
        // }
        // cout << "tempsuma " << tempsuma << endl;
        // cout << "asum " << asum << " bsum " << bsum << endl;
        // for (int g = 0; g < bmoves; ++g)
        // {
        //     tempsuma += b[g];
        // }

        // cout << tempsuma << " " << tempsuma2 << endl;

        if (tempsuma2 < suma)
        {

            tstrat[0] = amoves;
            tstrat[1] = bmoves;
            suma = tempsuma2;
            strat = tstrat;
        }
        tempsuma = 0;
    }
    // cout << endl;
    return strat;
}

int twoStacks(int maxSum, vector<int> a, vector<int> b)
{
    int sum = 0;
    int tsum = 0;
    int m = 0;
    vector<int> x;
    x.resize(2);
    // vector<int> y;
    // y.resize(2);
    while (sum <= maxSum)
    {

        ++m;
        if (m > a.size() + b.size())
        {
            return --m;
        }
        x = nmoves(m, a, b);
        for (int i = 0; i < x[0]; ++i)
        {
            tsum += a[i];
        }
        for (int j = 0; j < x[1]; ++j)
        {
            tsum += b[j];
        }
        sum = tsum;
        tsum = 0;
        if (sum > maxSum)
        {
            m -= 1;
            break;
        }
        // y = x;
    }
    // cout << y[0] << " " << y[1] << endl;
    // for (int i = 0; i < y[0]; ++i)
    // {
    //     tsum += a[i];
    // }
    // for (int i = 0; i < y[1]; ++i)
    // {
    //     tsum += b[i];
    // }
    // cout << tsum << endl;
    return m;
}

string ltrim(const string &str)
{
    string s(str);

    s.erase(
        s.begin(),
        find_if(s.begin(), s.end(), not1(ptr_fun<int, int>(isspace))));

    return s;
}

string rtrim(const string &str)
{
    string s(str);

    s.erase(
        find_if(s.rbegin(), s.rend(), not1(ptr_fun<int, int>(isspace))).base(),
        s.end());

    return s;
}

vector<string> split(const string &str)
{
    vector<string> tokens;

    string::size_type start = 0;
    string::size_type end = 0;

    while ((end = str.find(" ", start)) != string::npos)
    {
        tokens.push_back(str.substr(start, end - start));

        start = end + 1;
    }

    tokens.push_back(str.substr(start));

    return tokens;
}

int twoStacks2(int maxSum, vector<int> a, vector<int> b)
{
    int sa = 0;
    int sb = 0;
    int ca = 0;
    int cb = 0;
    while (ca < a.size())
    {
        sa += a[ca];
        ++ca;
        if (sa > maxSum)
        {
            sa -= a[ca - 1];
            ca = ca - 1;
            break;
        }
    }
    while (cb < b.size())
    {
        sb += b[cb];
        ++cb;
        if (sb > maxSum)
        {
            sb -= b[cb - 1];
            cb = cb - 1;
            break;
        }
    }

    vector<int> tmoves;
    tmoves.resize(2);

    if ((sa < maxSum) && (sb < maxSum))
    {
        if (sa + sb < maxSum)
        {
            tmoves[0] = ca;
            tmoves[1] = cb;
            return ca + cb;
        }
    }
    if (ca < cb)
    {
        int tsb = sb;
        int tsa = 0;
        int tcb = cb;
        int tca = 1;
        int tsum = 0;
        int minmoves = cb;
        int totalmoveslast = cb;
        int totalmoves;
        tmoves[0] = 0;
        tmoves[1] = cb;
        while (tcb > 0)
        {
            if (tca > ca)
            {

                return tmoves[0] + tmoves[1];
            }
            while (tca <= ca)
            {

                tsa += a[tca - 1];
                tsum = tsb + tsa;
                // cout << "tca tcb tsa tsb " << tca << " " << tcb << " " << tsa << " " << tsb << endl;
                if (tsum > maxSum)
                {
                    tsa -= a[tca - 1];
                    break;
                }
                else
                {
                    totalmoves = tcb + tca;
                    if (totalmoves > totalmoveslast)
                    {
                        totalmoveslast = totalmoves;
                        tmoves[0] = tca;
                        tmoves[1] = tcb;
                    }
                    ++tca;
                }
            }
            tsb -= b[tcb - 1];
            --tcb;
            if (tcb + ca < minmoves)
            {
                break;
            }
        }

        return tmoves[0] + tmoves[1];
    }
    else
    {
        int tsb = 0;
        int tsa = sa;
        int tca = ca;
        int tcb = 1;
        int tsum = 0;
        int minmoves = ca;
        int totalmoveslast = ca;
        int totalmoves;
        tmoves[0] = ca;
        tmoves[1] = 0;
        while (tca > 0)
        {
            if (tca > ca)
            {
                return tmoves[0] + tmoves[1];
            }
            while (tcb <= cb)
            {
                tsb += b[tcb - 1];
                tsum = tsa + tsb;
                // cout << "tca tcb tsa tsb " << tca << " " << tcb << " " << tsa << " " << tsb << endl;
                if (tsum > maxSum)
                {
                    tsb -= b[tcb - 1];
                    break;
                }
                else
                {
                    totalmoves = tcb + tca;
                    if (totalmoves > totalmoveslast)
                    {
                        totalmoveslast = totalmoves;
                        tmoves[0] = tca;
                        tmoves[1] = tcb;
                    }
                    ++tcb;
                }
            }
            tsa -= a[tca - 1];
            --tca;
            if (cb + tca < minmoves)
            {
                break;
            }
        }
        // cout << tmoves[0] << " " << tmoves[1] << endl;
        return tmoves[0] + tmoves[1];
    }
}

int main()
{

    int on = 1;
    if (on)
    {
        fstream f("testbig.txt");
        string g_temp;
        getline(f, g_temp);

        fstream f1("testbigsols.txt");
        string res;
        vector<int> sols;

        if (f1.is_open())
        {
            cout << "f1 is open" << endl;

            while (f1.good())
            {
                f1 >> res;
                sols.push_back(stoi(res));
            }
        }
        int g = stoi(ltrim(rtrim(g_temp)));

        for (int g_itr = 0; g_itr < g; g_itr++)
        {
            string first_multiple_input_temp;
            getline(f, first_multiple_input_temp);

            vector<string> first_multiple_input = split(rtrim(first_multiple_input_temp));

            int n = stoi(first_multiple_input[0]);

            int m = stoi(first_multiple_input[1]);

            int maxSum = stoi(first_multiple_input[2]);

            string a_temp_temp;
            getline(f, a_temp_temp);

            vector<string> a_temp = split(rtrim(a_temp_temp));

            vector<int> a(n);

            for (int i = 0; i < n; i++)
            {
                int a_item = stoi(a_temp[i]);

                a[i] = a_item;
            }

            string b_temp_temp;
            getline(f, b_temp_temp);

            vector<string> b_temp = split(rtrim(b_temp_temp));

            vector<int> b(m);

            for (int i = 0; i < m; i++)
            {
                int b_item = stoi(b_temp[i]);

                b[i] = b_item;
            }

            int result = twoStacks2(maxSum, a, b);
            if (result != sols[g_itr])
            {

                cout << "Failed" << endl;
                cout << "test num " << g_itr << endl;
                cout << sols[g_itr] << endl;
                cout << result << endl;
                cout << maxSum << endl;
                for (int i = 0; i < a.size(); ++i)
                {
                    cout << a[i] << ",";
                }
                cout << endl;
                for (int i = 0; i < b.size(); ++i)
                {
                    cout << b[i] << ",";
                }
                cout << endl;
            }
        }
    }

    cout << "XXX" << endl;

    // vector<int> A{1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1};
    // vector<int> B{1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1};
    // vector<int> A{1, 1, 0};
    // vector<int> B{0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1};
    // vector<int> A{0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1};
    // vector<int> B{1, 0, 1};
    // vector<int> A{0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0};
    // vector<int> B{0, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0};
    // vector<int> A{1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0};
    // vector<int> B{1, 0, 0, 1, 0, 1, 0, 1, 1, 1}; //15, 8
    // vector<int> A{1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1};
    // vector<int> B{0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1}; // 11, 5
    vector<int> A{1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1};
    vector<int> B{1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0};
    auto start = high_resolution_clock::now();
    twoStacks2(14, A, B);
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << "ms " << duration.count() << endl;
    start = high_resolution_clock::now();
    twoStacks(14, A, B);
    stop = high_resolution_clock::now();
    duration = duration_cast<microseconds>(stop - start);
    cout << "ms " << duration.count() << endl;
}
