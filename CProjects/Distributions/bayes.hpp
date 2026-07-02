#include "DistLib.hpp"
#include <cstddef>
#include <random>

template <typename T> struct chain_storage;

template <> struct chain_storage<Eigen::VectorXd> {
  using type = Eigen::MatrixXd; // each column = one sample

  static type make(const Eigen::VectorXd &init, Eigen::Index kept) {
    return type(init.size(), kept);
  }

  static void store(type &storage, Eigen::Index i,
                    const Eigen::VectorXd &value) {
    storage.col(i) = value;
  }
};

template <> struct chain_storage<double> {
  using type = Eigen::VectorXd;

  static type make(double init, Eigen::Index kept) { return type::Zero(kept); }

  static void store(type &storage, Eigen::Index i, double value) {
    storage(i) = value;
  }
};

template <> struct chain_storage<Eigen::MatrixXd> {
  using type = Eigen::MatrixXd;

  static type make(const Eigen::MatrixXd &mat, Eigen::Index N) {
    return type(mat.rows(), N);
  }

  static void store(type &s, Eigen::Index i, const Eigen::MatrixXd &v) {
    s.col(i) = Eigen::Map<const Eigen::VectorXd>(v.data(), v.size());
  }
};

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
inline void update_chain(Nodes &nodes, State &state, std::mt19937 &rng) {
  if constexpr (I < std::tuple_size_v<Nodes>) {
    std::get<I>(nodes).sample(state, rng);
    update_chain<I + 1>(nodes, state, rng);
  }
}

template <typename... Args> struct ChainHistory {
  Eigen::Index sims;
  Eigen::Index burnin;
  Eigen::Index kept;
  std::tuple<typename chain_storage<Args>::type...> history;

  ChainHistory(size_t _sims, size_t _burnin, const std::tuple<Args...> &init)
      : sims(static_cast<Eigen::Index>(_sims)),
        burnin(static_cast<Eigen::Index>(_burnin)),
        kept(std::max<Eigen::Index>(sims - burnin, 1)) {
    make_tracks(init, std::index_sequence_for<Args...>{});
  }

  void store(const std::tuple<Args...> &current_state, Eigen::Index i) {
    store_impl(current_state, i, std::index_sequence_for<Args...>{});
  }

private:
  template <size_t... I>
  void store_impl(const std::tuple<Args...> &current_state, Eigen::Index i,
                  std::index_sequence<I...>) {
    (chain_storage<Args>::store(std::get<I>(history), i,
                                std::get<I>(current_state)),
     ...);
  }

  template <size_t... I>
  void make_tracks(const std::tuple<Args...> &init, std::index_sequence<I...>) {
    ((std::get<I>(history) =
          chain_storage<Args>::make(std::get<I>(init), kept)),
     ...);
  }
};

template <typename... Nodes, typename State>
void MCMC(size_t reps, size_t burnin, std::tuple<Nodes...> &conditionals,
          State current_state, std::mt19937 &rng) {
  for (int i = 0; i < reps; ++i) {
    update_chain(conditionals, current_state, rng);
  }
}
