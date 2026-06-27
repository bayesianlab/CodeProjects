#include "Distributions.hpp"

template <size_t I = 0, typename... Dists>
inline void update_chain_step(std::tuple<Dists...>& distributions, std::vector<double>& current_state, std::mt19937& rng) {
    if constexpr (I < sizeof...(Dists)) {
        // Statically resolve the correct distribution object
        const auto& dist = std::get<I>(distributions);
        
        // Gibbs step dependency logic: step I depends on step I-1 (or wrap-around)
        constexpr size_t dependency_idx = (I == 0) ? (sizeof...(Dists) - 1) : (I - 1);
        
        // Update the state in-place
        dist.sample(current_state[I], current_state[dependency_idx], rng);
        
        // Move to the next distribution at compile time
        update_chain_step<I + 1>(distributions, current_state, rng);
    }
}