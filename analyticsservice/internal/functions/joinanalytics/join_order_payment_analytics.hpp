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
#include <analyticsservice/internal/types/analytics_key.hpp>
#include <analyticsservice/internal/types/analytics_result.hpp>


namespace example::analytics_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct JoinOrderPaymentAnalytics final {
  template <typename Output>
  bool operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  std::string& key,
                  std::pair<std::vector<example::analytics_service::types::AnalyticsEvent>,
                            std::vector<example::analytics_service::types::AnalyticsEvent>>& values,
                  Output&& out) const {
    (void)stream;
    if (values.first.empty() || values.second.empty()) return false;
    std::forward<Output>(out).out(
        std::move(context),
        example::analytics_service::types::AnalyticsResult{
            key, values.first.front().value + values.second.front().value,
            "join"});
    return true;
  }
};

inline boost::asio::awaitable<std::unique_ptr<JoinOrderPaymentAnalytics>> MakeJoinOrderPaymentAnalytics(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::JoinStreamConfig& config) {
  (void)context;
  (void)environment;
  (void)config;
  co_return std::make_unique<JoinOrderPaymentAnalytics>();
}

}  // namespace example::analytics_service::functions
