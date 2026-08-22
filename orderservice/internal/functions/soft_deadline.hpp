#pragma once

#include <memory>

#include <chrono>
#include <cstddef>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <orderservice/internal/types/order.hpp>


namespace example::order_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct SoftDeadline final {
  explicit SoftDeadline(
      std::chrono::steady_clock::duration margin =
          std::chrono::steady_clock::duration::zero())
      : margin_(margin) {}

  std::chrono::steady_clock::duration operator()(
      servicelib::MessageContext context,
      servicelib::StreamBase& stream,
      const example::order_service::types::Order& value) const {
    (void)stream;
    (void)value;
    if (!context.deadline()) {
      return margin_;
    }
    const auto remaining =
        *context.deadline() - std::chrono::steady_clock::now() - margin_;
    return std::max(remaining, std::chrono::steady_clock::duration::zero());
  }

 private:
  std::chrono::steady_clock::duration margin_;
};

inline std::unique_ptr<SoftDeadline> MakeSoftDeadline(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::DelayStreamConfig& config) {
  (void)context; (void)environment;
  return std::make_unique<SoftDeadline>(
      std::chrono::milliseconds{config.duration});
}

}  // namespace example::order_service::functions
