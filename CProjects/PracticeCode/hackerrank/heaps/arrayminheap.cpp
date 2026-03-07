#include <bits/stdc++.h>
#include "/home/dillon/CodeProjects/CProjects/hackerrank/stl_practice/useful.cpp"
using namespace std;

class Heap
{
public:
    int *array;
    int length;
    Heap(int arr[], int n)
    {
        array = new int[n + 1];
        length = n;
        copy(arr, arr + n, array);
        buildHeap();
        printarr(array, length);
    }

    void expandArray()
    {
        length = length + 1;
        int *array_temp = new int[length];
        copy(array, array + length - 1, array_temp);
        delete[] array;
        array = array_temp;
    }

    void buildHeapUtil(int i)
    {
        int left = 2 * i + 1;
        int right = 2 * i + 2;
        if (left < length && array[left] < array[i])
        {
            swap(array[left], array[i]);
            buildHeapUtil(left);
        }
        if (right < length && array[right] < array[i])
        {
            swap(array[right], array[i]);
            buildHeapUtil(right);
        }
    }

    void buildHeap()
    {
        int i = (length / 2) - 1;
        while (i >= 0)
        {
            buildHeapUtil(i);
            --i;
        }
    }

    void bubbleup(int arr[], int n)
    {
        int root;
        if (n <= 2)
        {
            root = 0;
        }
        else
        {
            root = n / 2 - 1;
        }

        if (arr[n] < arr[root])
        {
            swap(arr[n], arr[root]);
            bubbleup(arr, root);
        }
    }

    void insert(int val)
    {
        expandArray();
        array[length - 1] = val;
        bubbleup(array, length - 1);
    }

    int extractmin()
    {
        int t = array[0];
        length = length - 1;
        array[0] = array[length];
        int *array_temp = new int[length];
        copy(array, array + length, array_temp);
        delete[] array;
        array = array_temp;
    }

    void extractminUtil(int i)
    {
        left = 2 * i + 1;
        right = 2 * i + 2;
        
        
    }

    void print()
    {
        printarr(array, length);
    }

    ~Heap()
    {
        delete[] array;
    }
};

int main()
{
    int A[] = {4, 2, 10, 0, 6, 9};
    int n = 6;
    Heap X(A, n);
    X.insert(66);
    X.print();
    X.insert(-1);
    X.print();

    return 0;
}