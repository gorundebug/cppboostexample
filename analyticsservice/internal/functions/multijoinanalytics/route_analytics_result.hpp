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
#include <analyticsservice/internal/types/analytics_result.hpp>


namespace example::analytics_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct RouteAnalyticsResult final {
  std::size_t operator()(servicelib::MessageContext context,
                                            servicelib::StreamBase& stream,
                                            const example::analytics_service::types::AnalyticsResult& value) const {
    (void)context;
    (void)stream;
    return value.total >= 50 ? 0 : 1;
  }
};

inline boost::asio::awaitable<std::unique_ptr<RouteAnalyticsResult>> MakeRouteAnalyticsResult(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::CaseStreamConfig& config) {
  (void)context;
  (void)environment;
  (void)config;
  co_return std::make_unique<RouteAnalyticsResult>();
}

}  // namespace example::analytics_service::functions
