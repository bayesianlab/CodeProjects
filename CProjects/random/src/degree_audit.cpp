#include <iostream>
#include <sqlite3.h>
#include <string>
#include <vector>

using namespace std;
class Student
{
    string Name;
    std::vector<string> Courses;
};

int main()
{
    sqlite3 *db;

    int r = sqlite3_open("test.db", &db);
    if (r)
    {
        fprintf(stderr, "Cant open %s\n", sqlite3_errmsg(db));
    }
    else
    {
        fprintf(stderr, "Opened successfully\n");
    }

    const string st = "CREATE  TABLE IF NOT EXISTS degree_audit(rowid INT PRIMARY KEY,\
       FirstName TEXT NOT NULL, LastName TEXT NOT NULL);";
    const string st2 =
        "INSERT or REPLACE INTO degree_audit (rowid, FirstName, LastName) VALUES (1, \"Abigail\", \"Cornelius\");";
    sqlite3_stmt *x;
    sqlite3_stmt *y;
    sqlite3_prepare(db, st.c_str(), -1, &x, 0);
    sqlite3_prepare(db, st2.c_str(), -1, &y, 0);

    sqlite3_step(x);
    int code = sqlite3_step(y);
    if (code != SQLITE_DONE)
    {
        cout << code << endl;
        cout << SQLITE_DONE << endl;
        cout << "An error occured" << endl;
    }
    sqlite3_close(db);
}
