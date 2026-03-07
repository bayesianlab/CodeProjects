#include <string>
#include <utility>
#include <sstream>
#include <iostream>
#include <algorithm>
#include <vector>
#include <list>
#include <set>
#include <unordered_set>
#include <map>
#include <unordered_map>

using namespace std;

class PriceDiverge
{
private:
    int threshold;

    set<pair<string, string>> stockPairs;

    map<string, int> stockPrices;

    void ReportDivergence(string s1, int newPrice, string s2, int otherPrice)
    {
        cout << "Diverged " << s1 << "  " << newPrice << " " << s2 << "  " << otherPrice << endl;
    }

public:
    PriceDiverge(int _threshold)
    {
        threshold = _threshold;
    }
    void WatchPair(string s1, string s2)
    {
        pair<string, string> p;
        p.first = s1;
        p.second = s2;
        pair<string, string> other;
        other.first = s2;
        other.second = s1;
        if (stockPairs.find(other) == stockPairs.end())
        {
            stockPairs.insert(p);
        }
    }
    void UpdatePrice(string stock, int price)
    {
        stockPrices[stock] = price;
        for (auto it = stockPairs.begin(); it != stockPairs.end(); ++it)
        {
            string s1 = (*it).first;
            string s2 = (*it).second;
            if (s1 == stock)
            {
                if (stockPrices.find(s2) != stockPrices.end())
                {
                    if (abs(stockPrices[stock] - stockPrices[s2]) > threshold)
                    {
                        ReportDivergence(s1, price, s2, stockPrices[s2]);
                    }
                }
            }
            if (s2 == stock)
            {
                if (stockPrices.find(s1) != stockPrices.end())
                {
                    if (abs(stockPrices[stock] - stockPrices[s1]) > threshold)
                    {
                        ReportDivergence(s2, price, s1, stockPrices[s1]);
                    }
                }
            }
        }
    }

    void printStockPairs()
    {
        for (auto it = stockPairs.begin(); it != stockPairs.end(); ++it)
        {
            cout << (*it).first << " " << (*it).second << endl;
        }
    }

    void printStockPrices()
    {
        for (auto it = stockPrices.begin(); it != stockPrices.end(); ++it)
        {
            cout << (*it).first << " " << (*it).second << endl;
        }
    }
};

int main()
{
    PriceDiverge pd(20);
    pd.WatchPair("VOX", "XOY");
    pd.UpdatePrice("VOX", 150);
    pd.UpdatePrice("XOY", 160);
    pd.WatchPair("TTY", "AAP");
    pd.UpdatePrice("TTY", 90);
    pd.WatchPair("AAP", "TTY");
    pd.UpdatePrice("AAP", 65);
    // pd.printStockPairs();
    // pd.printStockPrices();
}