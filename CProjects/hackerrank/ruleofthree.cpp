#include <bits/stdc++.h>
using namespace std;

class Square
{

public:
    char *other;

    Square(char const *x)
    {
        other = new char[strlen(x) + 1];
        strcpy(other, x);
    }

    ~Square()
    {
        delete[] other;
    }

    Square(const Square &that) : Square(that.other) {}

    Square &operator=(const Square &that)
    {
        if (this == &that)
        {
            return *this;
        }
        char *newstring = new char[strlen(that.other) + 1];
        memcpy(newstring, that.other, strlen(that.other) + 1);
        delete[] other;
        other = newstring;
        return *this;
    }
};

int main()
{
    char const *s = "minsquares";
    char const *p = "yes";
    Square one(s);
    Square two = one;

    cout << one.other << endl;
    cout << two.other << endl;
}
