
#ifndef SEED_SETTINGS_H
#define SEED_SETTINGS_H

#include <boost/random/mersenne_twister.hpp>
#include <ctime>
#include <stddef.h>
#include <iostream>

using namespace std;


void set_seed(time_t seed);

#endif
