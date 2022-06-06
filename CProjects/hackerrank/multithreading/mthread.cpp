#include <iostream>
#include <fstream>
#include <thread> 
#include <pthread.h>
#include <boost/filesystem.hpp>
using namespace std;
using namespace boost::filesystem;

void fo(string dir)
{
    path p(dir);
    if (exists(p))
    {
        cout << "true" << endl;
        if (is_directory(p))
        {
            for (path::iterator it = p.begin(); it != p.end(); ++it)
            {
                cout << *it << endl;
            }
        }
        else
        {
            cout << "not dir" << endl;
        }
    }
    else
    {
        cout << "false" << endl;
    }
}

int main(int argc, char *argv[])
{
    vector<thread> ts(3);
    vector<string> dirs(3); 
    thread mythread(fo, "/home/dillon"); 
    mythread.join();
    return 0;
}