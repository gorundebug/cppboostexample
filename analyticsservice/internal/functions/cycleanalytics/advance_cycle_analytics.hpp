#pragma once

#include <chrono>
#include <cstddef>
#include <memory>
#include <stdexcept>
#include <tuple>
#include <utility>
#include <vector>

#include <boost/asio/awaitable.hpp>

#include <servicelib/runtime/context.hpp>
#include <servicelib/runtime/base.hpp>
#include <servicelib/runtime/config/stream_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <analyticsservice/internal/types/analytics_event.hpp>


namespace example::analytics_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct AdvanceCycleAnalytics final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::analytics_service::types::AnalyticsEvent& value,
                  Output&& out) const {
    (void)stream;
    auto next = value;
    ++next.value;
    std::forward<Output>(out).out(std::move(context), std::move(next));
  }
};

inline boost::asio::awaitable<std::unique_ptr<AdvanceCycleAnalytics>> MakeAdvanceCycleAnalytics(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::MapStreamConfig& config) {
  (void)context;
  (void)environment;
  (void)config;
  co_return std::make_unique<AdvanceCycleAnalytics>();
}

}  // namespace example::analytics_service::functions
