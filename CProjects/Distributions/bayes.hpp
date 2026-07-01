#include "DistLib.hpp"
#include <cstddef>
#include <random>

template <typename T, typename TargetType, typename... Args>
concept IsSamplerFor = requires(T dist, TargetType &target,
                                Args... dependencies, std::mt19937 &rng) {
  { dist.sample(target, dependencies..., rng) } -> std::same_as<void>;
};

template <typename Dist, size_t TargetIndex, size_t... DepIndices>
struct ConditionalNode {
  Dist dist;

  template <typename StateTuple>
  void sample(StateTuple &current_state, std::mt19937 &rng) const
    requires IsSamplerFor<Dist, std::tuple_element_t<TargetIndex, StateTuple> &,
                          const std::tuple_element_t<DepIndices, StateTuple>...>
  {
    dist.sample(std::get<TargetIndex>(current_state),
                std::get<DepIndices>(current_state)..., rng);
  }
};

template <size_t I = 0, typename Nodes, typename State> 
inline void update_chain(Nodes& nodes, State& state, std::mt19937& rng) {
  if constexpr(I < std::tuple_size_v<Nodes>) {
    std::get<I>(nodes).sample(state, rng);
    update_chain<I+1>(nodes, state, rng);
  }
}

template<typename... Args>
struct ChainHistory{
  int sims; 
  int burnin;
  std::tuple<std::vector<Args>...> history;

  ChainHistory(size_t _sims, size_t _burnin) : sims(_sims), burnin(_burnin) {
    std::apply([this](auto&... tracks) {
      tracks.reserve(this->(sims - burnin), ... )
    }
  )
  }



};


template<typename... Nodes, typename State>
void MCMC(size_t reps, size_t burnin, std::tuple<Nodes...>& conditionals, State current_state, std::mt19937& rng) {
  for(int i = 0; i < reps; ++i){
    update_chain(conditionals, current_state, rng);
  }
}