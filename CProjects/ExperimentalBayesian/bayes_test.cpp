#include "gtest/gtest.h"
#include "Distributions.hpp"
#include <random>
#include <iostream>


TEST(SetupTest, Basic) {
    std::mt19937 rng(1337);
    Normal n(rng);
    std::cout << n.sample(0,1) << std::endl;

}