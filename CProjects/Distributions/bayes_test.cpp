#include "gtest/gtest.h"
#include "DistLib.hpp"
#include <random>
#include <iostream>
#include <chrono>

TEST(SetupTest, Basic) {
    std::mt19937 rng(1337);
    Normal n(rng);


}