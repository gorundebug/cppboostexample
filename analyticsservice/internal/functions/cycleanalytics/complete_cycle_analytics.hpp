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
struct CompleteCycleAnalytics final {
  bool operator()(servicelib::MessageContext context,
                                       servicelib::StreamBase& stream,
                                       const example::analytics_service::types::AnalyticsEvent& value) const {
    (void)context;
    (void)stream;
    return value.value >= 3;
  }
};

inline boost::asio::awaitable<std::unique_ptr<CompleteCycleAnalytics>> MakeCompleteCycleAnalytics(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::FilterStreamConfig& config) {
  (void)context;
  (void)environment;
  (void)config;
  co_return std::make_unique<CompleteCycleAnalytics>();
}

}  // namespace example::analytics_service::functions
