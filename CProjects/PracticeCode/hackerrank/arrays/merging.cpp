// #include <bits/stdc++.h>
#include <stdlib.h>
#include <stdio.h> 
// #include <iostream>
// Function to merge the arrays.
using namespace std;
void merge(int arr1[], int arr2[], int n, int m)
{
    int temp = 0;
    int swapoccured = 0;
    int stopflag = 0;
    for (int i = 0; i < m; ++i)
    {
        for (int j = i; j < n; ++j)
        {

            if (arr1[j] > arr2[i])
            {
                swap(arr1[j], arr2[i]);
                // temp = arr1[j];
                // arr1[j] = arr2[i];
                // arr2[i] = temp;
                swapoccured = i;
            }
        }
        if (i < m - 1)
        {
            if (arr2[i] < arr2[i + 1])
            {
                break;
            }
        }
    }
    // cout << "last swap " << swapoccured << endl;

    int listend, listbegin;
    listend = swapoccured;
    while (listend < m - 1)
    {
        listbegin = listend;
        listend++;
        while (arr2[listbegin + 1] > arr2[listbegin])
        {
            temp = arr2[listbegin];
            arr2[listbegin] = arr2[listbegin + 1];
            arr2[listbegin + 1] = temp;
            if (listbegin <= 0)
            {
                break;
            }
            listbegin--;
        }
    }
    int start = 0;
    int stop = m - 1;
    while (start <= stop)
    {
        temp = arr2[start];
        arr2[start] = arr2[stop];
        arr2[stop] = temp;
        ++start;
        --stop;
    }
}

int main()
{
    int n = 5;
    int m = 4;
    int arr1[] = {0, 2, 6, 8, 9};
    int arr2[] = {1, 3, 5, 7};

    merge(arr1, arr2, n, m);
    // for (int i = 0; i < n; ++i)
    // {
    //     cout << *(arr1 + i) << " ";
    // }
    // cout << endl;
    // for (int j = 0; j < m; ++j)
    // {
    //     cout << *(arr2 + j) << " ";
    // }
    // cout << endl;
}