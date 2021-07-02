#include "seed_settings.hpp"

void set_seed(time_t seed)
{
    if (!seed)
    {
        time_t now = time(0);
        boost::random::mt19937 gs(now);
    }
    else
    {
         boost::random::mt19937 gs(seed);
    }
}



