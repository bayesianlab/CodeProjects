#include <bits/stdc++.h>
using namespace std;

string bracematch(string s);
string bracketmatch(string s);
string parenmatch(string s);

string bracketmatch(string s)
{

    if (s.size() % 2)
    {
        return s;
    }
    if (s.size() == 1)
    {
        return s;
    }
    if (s.size() == 0)
    {
        return "";
    }
    if (s.size() == 2)
    {
        if (s[0] == '{')
        {
            return bracematch(s);
        }
        else if (s[0] == '(')
        {
            return parenmatch(s);
        }
        else if (s[1] == ']')
        {
            return "";
        }
        else
        {
            return s;
        }
    }
    else
    {
        if (s[0] == '[')
        {
            int c = 1;
            int balance = 1;
            if (s[c] == ']')
            {
                balance -= 1;
            }
            if (s[c] == '[')
            {
                balance += 1;
            }
            while (balance > 0)
            {
                c += 2;
                if (s[c] == '[')
                {
                    balance += 1;
                }
                if (s[c] == ']')
                {
                    balance -= 1;
                }
                if (s[c - 1] == '[')
                {
                    balance += 1;
                }
                if (s[c - 1] == ']')
                {
                    balance -= 1;
                }
                if (c > s.size())
                {
                    return s;
                }
            }
            string s1 = bracketmatch(s.substr(1, c - 1));
            string s2 = "";
            if (s.size() > (c + 1))
            {
                s2 = bracketmatch(s.substr(c + 1, s.size() - c));
            }
            return s1 + s2;
        }
        else if (s[0] == '(')
        {
            return parenmatch(s);
        }
        else if (s[0] == '{')
        {
            return bracematch(s);
        }
        else
        {
            return s;
        }
    }
}

string bracematch(string s)
{

    if (s.size() % 2)
    {
        return s;
    }
    if (s.size() == 1)
    {
        return s;
    }
    if (s.size() == 0)
    {
        return "";
    }
    if (s.size() == 2)
    {
        if (s[0] == '[')
        {
            return bracketmatch(s);
        }
        else if (s[0] == '(')
        {
            return parenmatch(s);
        }
        else if (s[1] == '}')
        {
            return "";
        }
        else
        {
            return s;
        }
    }
    else
    {
        if (s[0] == '{')
        {
            int c = 1;
            int balance = 1;
            if (s[c] == '}')
            {
                balance -= 1;
            }
            if (s[c] == '{')
            {
                balance += 1;
            }
            while (balance > 0)
            {
                c += 2;
                if (s[c] == '{')
                {
                    balance += 1;
                }
                if (s[c] == '}')
                {
                    balance -= 1;
                }
                if (s[c - 1] == '{')
                {
                    balance += 1;
                }
                if (s[c - 1] == '}')
                {
                    balance -= 1;
                }
                if (c > s.size())
                {
                    return s;
                }
            }
            string s1 = bracematch(s.substr(1, c - 1));
            string s2 = "";
            if (s.size() > (c + 1))
            {
                s2 = bracematch(s.substr(c + 1, s.size() - c));
            }
            return s1 + s2;
        }
        else if (s[0] == '[')
        {
            return bracketmatch(s);
        }
        else if (s[0] == '(')
        {
            return parenmatch(s);
        }
        else
        {
            return s;
        }
    }
}

string parenmatch(string s)
{

    if (s.size() % 2)
    {
        return s;
    }
    if (s.size() == 1)
    {
        return s;
    }
    if (s.size() == 0)
    {
        return "";
    }
    if (s.size() == 2)
    {
        if (s[0] == '[')
        {
            return bracketmatch(s);
        }
        else if (s[0] == '{')
        {
            return bracematch(s);
        }
        else if (s[1] == ')')
        {
            return "";
        }
        else
        {
            return s;
        }
    }
    else
    {
        if (s[0] == '(')
        {
            int c = 1;
            int balance = 1;
            if (s[c] == ')')
            {
                balance -= 1;
            }
            if (s[c] == '(')
            {
                balance += 1;
            }
            while (balance > 0)
            {
                c += 2;
                if (s[c] == '(')
                {
                    balance += 1;
                }
                if (s[c] == ')')
                {
                    balance -= 1;
                }
                if (s[c - 1] == '(')
                {
                    balance += 1;
                }
                if (s[c - 1] == ')')
                {
                    balance -= 1;
                }
                if (c > s.size())
                {
                    return s;
                }
            }
            string s1 = parenmatch(s.substr(1, c - 1));
            string s2 = "";
            if (s.size() > (c + 1))
            {
                s2 = parenmatch(s.substr(c + 1, s.size() - c));
            }
            return s1 + s2;
        }
        else if (s[0] == '[')
        {
            return bracketmatch(s);
        }
        else if (s[0] == '{')
        {
            return bracematch(s);
        }
        else
        {
            return s;
        }
    }
}


string isBalanced(string s)
{
    string res = bracketmatch(s);
    if (res == "")
    {
        return "YES";
    }
    else
    {
        return "NO";
    }
}

int main()
{
    // cout << (1 || 0) << endl;
    string s1 = "([{([]({}{}))[]}[{}]])()(()){}[()[]()]()()()[]{}{}()()()[()][[]([])()()[]]([]){}[{[][]}{}]{}{}[][]{}[](())(())()[({{}{[(())()[]]{[{}{()}{}]{[[]][[]]}()[]}}()(){[[]{}][()]()[{({})}][[([]()[{[]({(())()})}][]({})[])([{}]{()})]]}}){}{{()}}{[][[{}]][()[()]({[]{}(())})]}][{}[{}]]()()(())[[]]{[[{()}]]({})[]}({}{(([]))}[]){}[()(()[])]{}(({}))[][{}](){()}[]{({}([][][[]]))}[][((()[]({{}}[[{{[(({()}({}[[]][{([()])}({})][]{[[]{}]})())){}]{}}{()}{[][]}{}{}}][]([{}[[]{}({([]()(()()[]))})[]()]][()](()))[]]{}[[{[][]}[[[]]()[(){}][{[]{}}[{{{[]}}{}}][]([[{{()[]}[{[][{[[{[{}[]()[]]}{{}}{}]]}]}[]]}{}]][[]][{({}[])[[[{}][]]()[]]}{{[{}][]({}([][]{()}[()]){{}{}})}{}{}(([[]]()[]))()}][][{[({})[[]([[{[]}()]](([[]{}]{})))](){}[{}][]{[]}{[]([({{{}()}{[]}((){}{})}[[][]]{}[])]{})}]}{([()()[]][])}()([])])][([[]]()[])([[][]]){}[{[((([]){(){({[]})()}})){{}[()({({})}[[{[]{}}({{}[{{}{}}()]}){}]])]()}{}]{{}}}[]()]]{}{}]]]){}){}){()}()[]({}())]{()[]}[]{}{[]}(){[][[][]{}]}[{}{[{}{}]}]{[{}({}[()({{}})])()()]({[]}()((())))}";
    // string s1 = "(())";
    // cout << parenmatch(s1) << endl;
    cout << isBalanced(s1) << endl;
    // string s1 = "";
    // string s2 = "";
    // cout << (s1 + s2 ).size() << endl;
}
