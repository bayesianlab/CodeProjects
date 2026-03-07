#include <benchmark/benchmark.h>
#include <bits/stdc++.h>
#include "fib.hpp"
using namespace std;

int N = 1000;
vector<int> g(N);

void asg()
{
    for(int i = 0; i < N; ++i)
    {
        g[i] = rand() % 10; 
    }
}

static void BM_m(benchmark::State &state)
{
    for (auto _ : state)
    {
        for (int i = 0; i < N; ++i)
        {
            fibUtil(g[i]);
        }
    }
}


static void BM_m2(benchmark::State &state)
{

    for (auto _ : state)
    {
        fib(g);
    }
}

BENCHMARK(BM_m);
BENCHMARK(BM_m2);

BENCHMARK_MAIN();