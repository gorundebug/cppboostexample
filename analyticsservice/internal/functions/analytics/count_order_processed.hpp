#pragma once

#include <chrono>
#include <atomic>
#include <memory>
#include <cstddef>
#include <cstdint>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <model/include/example/model/types/order_processed.hpp>


namespace example::analytics_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct CountOrderProcessed final {
  CountOrderProcessed() : state_(std::make_shared<State>()) {}

  template <typename Output, typename ErrorOutput>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::model::types::OrderProcessed& value,
                  Output&& out,
                  ErrorOutput&& errors) const {
    (void)stream;
    (void)errors;
    auto& counter = value.status == "CONFIRMED" ? state_->successful
                                                  : state_->unsuccessful;
    counter.fetch_add(1, std::memory_order_relaxed);
    out.out(std::move(context), value);
  }

 private:
  struct State final {
    std::atomic<std::uint64_t> successful{0};
    std::atomic<std::uint64_t> unsuccessful{0};
  };
  std::shared_ptr<State> state_;
};

inline std::unique_ptr<CountOrderProcessed> MakeCountOrderProcessed(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::ProcessStreamConfig& config) {
  (void)context; (void)environment; (void)config;
  return std::make_unique<CountOrderProcessed>();
}

}  // namespace example::analytics_service::functions
