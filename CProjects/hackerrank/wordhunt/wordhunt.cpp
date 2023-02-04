#include <bits/stdc++.h>
#include "trie.hpp"
#include "color.hpp"
using namespace std;

class Square
{
public:
    char data;

    Square *adjacent[8];

    int visited;
};

Square *newSquare();

class Board
{
public:
    map<pair<int, int>, Square *> squares;

    int rows;

    int cols;

    Board(int r, int c)
    {
        rows = r;
        cols = c;
        int d = 0;
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                pair<int, int> p(i, j);
                squares[p] = newSquare();
                ++d;
            }
        }
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                connectBoard(i, j);
            }
        }
    }

    void move()
    {
        printBoard();
        char in[10];
        cout << "Starting place ";
        cin.getline(in, 10);
        stringstream stream(in);
        vector<int> loc;
        while (stream.good())
        {
            string sub;
            getline(stream, sub, ',');
            int i = stoi(sub);
            loc.push_back(i);
        }
        Square *s = getSquare(loc[0], loc[1]);
        while (1)
        {
            printBoard();
            cout << "movement ";
            string dir;
            cin >> dir;
            if (dir == "upleft")
            {
                cout << s->adjacent[0]->data << endl;
                s = s->adjacent[0];
            }
            else if (dir == "up")
            {
                cout << s->adjacent[1]->data << endl;
                s = s->adjacent[1];
            }
            else if (dir == "upright")
            {
                cout << s->adjacent[2]->data << endl;
                s = s->adjacent[2];
            }
            else if (dir == "left")
            {
                cout << s->adjacent[3]->data << endl;
                s = s->adjacent[3];
            }
            else if (dir == "right")
            {
                cout << s->adjacent[4]->data << endl;
                s = s->adjacent[4];
            }
            else if (dir == "downleft")
            {
                cout << s->adjacent[5]->data << endl;
                s = s->adjacent[5];
            }
            else if (dir == "down")
            {
                cout << s->adjacent[6]->data << endl;
                s = s->adjacent[6];
            }
            else if (dir == "downright")
            {
                cout << s->adjacent[7]->data << endl;
                s = s->adjacent[7];
            }
        }
    }

    void assignBoardLetters(string letters)
    {
        if (rows * cols != letters.length())
        {
            cout << "Error rows x cols = " << rows * cols << " Letters = " << letters.length() << endl;
            return;
        }
        int c = 0;
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                pair<int, int> p(i, j);
                squares[p]->data = letters[c];
                ++c;
            }
        }
    }

    Square *getSquare(int rowpos, int colpos)
    {
        pair<int, int> p(rowpos, colpos);
        if (squares.find(p) != squares.end())
        {
            return squares[p];
        }
        else
        {
            throw invalid_argument("Not a square");
        }
    }

    void printBoard()
    {
        Square *tl = getSquare(0, 0);
        Square *rowtemp;
        Square *coltemp;
        rowtemp = tl;
        coltemp = tl;
        int c = 0;
        cout << endl;
        while (rowtemp != NULL)
        {
            while (coltemp != NULL)
            {
                cout << coltemp->data;
                coltemp = coltemp->adjacent[4];
                ++c;
                if (c > 17)
                {
                    return;
                }
            }
            cout << endl;
            rowtemp = rowtemp->adjacent[6];
            coltemp = rowtemp;
        }
        cout << endl;
    }

    void printSurroundingSquares()
    {
        Square *tl = getSquare(0, 0);
        Square *rowtemp;
        Square *coltemp;
        rowtemp = tl;
        coltemp = tl;
        int r = 0;
        while (rowtemp != NULL)
        {
            int c = 0;
            while (coltemp != NULL)
            {
                printSurroundingSquaresUtil(r, c);
                cout << endl;
                ++c;
                coltemp = coltemp->adjacent[4];
            }
            c = 0;
            ++r;
            rowtemp = rowtemp->adjacent[6];
            coltemp = rowtemp;
        }
    }

    void printSurroundingSquaresUtil(int r, int c)
    {
        Square *middle = getSquare(r, c);
        int d = 0;
        cout << middle->data << endl;
        for (int i = r - 1; i <= r + 1; ++i)
        {
            for (int j = c - 1; j <= c + 1; ++j)
            {
                if (!((j == c) && (i == r)))
                {
                    if ((i >= 0) && (j >= 0) && (i <= rows - 1) && (j <= cols - 1))
                    {
                        cout << middle->adjacent[d]->data << endl;
                    }
                    ++d;
                }
            }
        }
    }

    ~Board()
    {
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                pair<int, int> p(i, j);
                delete squares[p];
            }
        }
        squares.clear();
    }

private:
    Board &operator=(Board &other)
    {
        this->rows = other.rows;
        this->cols = other.cols;
        map<pair<int, int>, Square *>::iterator it;
        for (it = this->squares.begin(); it != this->squares.end(); ++it)
        {
            it->second = nullptr;
        }
        this->squares = other.squares;
        return *this;
    }

    void connectBoard(int rowpos, int colpos)
    {
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                connectBoardUtil(i, j);
            }
        }
    }

    void connectBoardUtil(int rowpos, int colpos)
    {
        pair<int, int> p(rowpos, colpos);
        pair<int, int> next;
        next = p;
        int c = 0;
        for (int i = rowpos - 1; i <= rowpos + 1; ++i)
        {
            for (int j = colpos - 1; j <= colpos + 1; ++j)
            {
                if (!((j == colpos) && (i == rowpos)))
                {
                    if ((i >= 0) && (j >= 0) && (i <= rows - 1) && (j <= cols - 1))
                    {
                        next.first = i;
                        next.second = j;
                        squares[p]->adjacent[c] = squares.find(next)->second;
                    }
                    ++c;
                }
            }
        }
    }
};

void printSquare(Square *);

bool comp1(string one, string two);

bool comp2(pair<string, vector<int>> a, pair<string, vector<int>> b)
{
    return a.first.length() < b.first.length();
}

class Searcher
{
public:
    void search(Board &board, Trie *wordtrie)
    {
        set<string> allwords;
        for (int i = 0; i < board.rows; ++i)
        {
            pair<int, int> p;
            for (int j = 0; j < board.cols; ++j)
            {
                p.first = i;
                p.second = j;
                Square *cur = board.squares[p];
                string proposal_string;
                char newletter = cur->data;
                searchUtil(cur, proposal_string, newletter, allwords, wordtrie);
            }
        }
        vector<pair<int, string>> words;
        pair<int, string> p;
        for (const auto &w : allwords)
        {
            p.first = w.length();
            p.second = w;
            words.push_back(p);
        }
        sort(words.begin(), words.end());

        map<string, vector<int>> wordpaths = printPath(board, wordtrie);
        vector<pair<string, vector<int>>> sortwords;
        for (const auto x : wordpaths)
        {
            pair<string, vector<int>> u(x.first, x.second);
            sortwords.push_back(u);
        }

        sort(sortwords.begin(), sortwords.end(), comp2);

        for (const auto &w : sortwords)
        {
            cout << w.first << endl;
            for (int i = 0; i < board.rows * board.cols; ++i)
            {
                string y = to_string(w.second[i]);
                if (!((i + 1) % board.rows))
                {
                    if (w.second[i] != 0)
                    {

                        cout << color::rize(y, "Red", "Default") << " ";
                    }
                    else
                    {
                        cout << y << " ";
                    }
                    cout << endl;
                }
                else
                {
                    if (w.second[i] != 0)
                    {

                        cout << color::rize(y, "Red", "Default") << " ";
                    }
                    else
                    {
                        cout << y << " ";
                    }
                }
            }
            cout << endl;
        }
    }

    map<string, vector<int>> printPath(Board &board, Trie *wordtrie)
    {
        map<string, vector<int>> wordpath;
        for (int i = 0; i < board.rows; ++i)
        {
            pair<int, int> p;
            for (int j = 0; j < board.cols; ++j)
            {
                p.first = i;
                p.second = j;
                Square *cur = board.squares[p];
                string proposal_string;
                char newletter = cur->data;
                vector<int> route(board.rows * board.cols);
                printPathUtil(cur, proposal_string, newletter, wordtrie, wordpath,
                              route, board, 0);
            }
        }
        return wordpath;
    }

private:
    void searchUtil(Square *current, string proposal, char newletter, set<string> &collectedwords,
                    Trie *wordtrie)
    {
        proposal.push_back(newletter);
        if (!isSubWord(wordtrie, proposal))
        {
            proposal = proposal.substr(0, proposal.length() - 1);
            return;
        }
        else
        {
            if (current->visited == 1)
            {
                return;
            }
            if (isWord(wordtrie, proposal))
            {
                collectedwords.insert(proposal);
            }
            current->visited = 1;
            for (int i = 0; i < 8; ++i)
            {
                if (current->adjacent[i] && (current->adjacent[i]->visited == 0))
                {
                    newletter = current->adjacent[i]->data;
                    searchUtil(current->adjacent[i], proposal, newletter, collectedwords, wordtrie);
                }
            }
            current->visited = 0;
        }
    }

    void printPathUtil(Square *current, string proposal, char newletter, Trie *wordtrie, map<string, vector<int>> &wordpath,
                       vector<int> &route, Board &b, int path)
    {

        proposal.push_back(newletter);
        if (!isSubWord(wordtrie, proposal))
        {
            proposal = proposal.substr(0, proposal.length() - 1);
            return;
        }
        else
        {
            if (current->visited > 0)
            {
                return;
            }
            if (isWord(wordtrie, proposal))
            {
                path++;
                current->visited = path;
                int rc = 0;
                for (int i = 0; i < b.rows; ++i)
                {
                    for (int j = 0; j < b.cols; ++j)
                    {
                        pair<int, int> p(i, j);
                        route[rc] = b.squares[p]->visited;
                        rc++;
                    }
                }
                wordpath[proposal] = route;
            }
            else
            {
                path++;
                current->visited = path;
            }
            for (int i = 0; i < 8; ++i)
            {
                if (current->adjacent[i] && (current->adjacent[i]->visited == 0))
                {
                    newletter = current->adjacent[i]->data;
                    printPathUtil(current->adjacent[i], proposal, newletter, wordtrie, wordpath, route, b, path);
                }
            }
            current->visited = 0;
        }
    }
};

/////////////// MAIN ////////////////

int main()
{
    Board b(4, 4);
    while (1)
    {
        string letters, boardletters;
        cout << color::rize("4 x 4 board", "Red", "Green") << endl;
        cout << "Enter word hunt letters" << endl;
        int t = 4;
        while (t--)
        {
            getline(cin, letters);
            boardletters += letters;
        }
        if (boardletters.length() != 16)
        {
            cout << "board wrong length" << endl;
            continue;
        }
        transform(boardletters.begin(), boardletters.end(), boardletters.begin(), ::toupper);
        b.assignBoardLetters(boardletters);
        b.printBoard();
        Dictionary d("collins_dictionary.txt");
        Trie *tr = makeTrie(d.dict);
        Searcher boardsearch;
        boardsearch.search(b, tr);
    }
}

//////////////////////////////////////////

Square *newSquare()
{
    Square *x = new Square;
    return x;
}
