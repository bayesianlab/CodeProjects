#include <bits/stdc++.h>
#include "trie.hpp"
using namespace std;

class Square
{
public:
    char data;

    Square *adjacent[8];
};

Square *newSquare(char x);

class Board
{
public:
    map<pair<int, int>, Square *> squares;

    int rows;

    int cols;

    void assignSquare(int rowpos, int colpos)
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

    void
    assignBoardLetters(string letters)
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
                squares[p] = newSquare(letters[c]);
                ++c;
            }
        }
        for (int i = 0; i < rows; ++i)
        {
            for (int j = 0; j < cols; ++j)
            {
                assignSquare(i, j);
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
        while (rowtemp != NULL)
        {
            while (coltemp != NULL)
            {
                cout << coltemp->data;
                coltemp = coltemp->adjacent[4];
            }
            cout << endl;
            rowtemp = rowtemp->adjacent[6];
            coltemp = rowtemp;
        }
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
};

Board *newBoard(int rows, int cols);

void printSquare(Square *);

void makeBoard(Board *board, string letters);

class Searcher
{
public:
    Trie *wordtrie = NULL;
    Board *board = NULL;

    Searcher(string filename, Board &brd)
    {
        Dictionary D(filename);
        wordtrie = makeTrie(D.dict);
        board = &brd;
    }

    void search()
    {
        Square *tlsquare = board->getSquare(0, 0);
        int move_count = 0;
        string proposal_string;
        proposal_string.push_back(tlsquare->data);
        while (move_count < 8)
        {
            if (tlsquare->adjacent[move_count])
            {
                proposal_string += tlsquare->adjacent[move_count]->data;
                
            }
            move_count++;
        }
        cout << proposal_string << endl;
    }
};

int main()
{
    string input = "AAHXZYKSTYREMYRE";
    Board *board = newBoard(4, 4);
    board->assignBoardLetters(input);
    board->printBoard();
    // board->printSurroundingSquares();
    Searcher searcher("mini.txt", *board);
    // printTrie(search.wordtrie);
    searcher.search();

    // board->move();
}

//////////////////////////////////////////

Square *newSquare(char a)
{
    Square *x = new Square;
    x->data = a;
    return x;
}

Board *newBoard(int rows, int cols)
{
    Board *b = new Board;
    b->rows = rows;
    b->cols = cols;
    return b;
}
