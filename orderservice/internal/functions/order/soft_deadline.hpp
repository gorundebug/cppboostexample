#pragma once

#include <algorithm>
#include <memory>
#include <optional>

#include <boost/asio/awaitable.hpp>

#include <chrono>
#include <cstddef>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <servicelib/runtime/base.hpp>
#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <orderservice/internal/types/order.hpp>


namespace example::order_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct SoftDeadline final {
  SoftDeadline() = default;

  explicit SoftDeadline(std::chrono::steady_clock::duration margin)
      : margin_(margin) {}

  std::chrono::steady_clock::duration operator()(
      servicelib::MessageContext context,
      servicelib::StreamBase& stream,
      const example::order_service::types::Order& value) const {
    (void)value;
    const auto margin = margin_.has_value() ? *margin_ : configuredMargin(stream);
    if (!context.deadline()) {
      return margin;
    }
    const auto remaining =
        *context.deadline() - std::chrono::steady_clock::now() - margin;
    return std::max(remaining, std::chrono::steady_clock::duration::zero());
  }

 private:
  static std::chrono::steady_clock::duration configuredMargin(
      const servicelib::StreamBase& stream) {
    const auto* environment = stream.getEnv();
    if (!environment) {
      throw std::logic_error("SoftDeadline requires a stream environment");
    }
    const auto runtime = environment->getRuntimeConfigSnapshot();
    if (!runtime) {
      throw std::logic_error("SoftDeadline requires runtime configuration");
    }
    const auto config = runtime->GetStreamConfigByID(
        static_cast<int>(stream.getConfigId()));
    const auto* delay = config
        ? config->As<servicelib::config::DelayStreamConfig>() : nullptr;
    if (!delay) {
      throw std::logic_error("SoftDeadline requires a Delay stream configuration");
    }
    return std::chrono::milliseconds{delay->duration};
  }

  std::optional<std::chrono::steady_clock::duration> margin_;
};

inline boost::asio::awaitable<std::unique_ptr<SoftDeadline>> MakeSoftDeadline(
    servicelib::Context context, servicelib::IServiceEnvironment& environment) {
  (void)context; (void)environment;
  co_return std::make_unique<SoftDeadline>();
}

}  // namespace example::order_service::functions
