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
#include <analyticsservice/internal/types/analytics_result.hpp>


namespace example::analytics_service::functions {

// User-owned callable. Its operator is checked by servicelib::StreamFunction
// when the generated stream graph binds it to an operator.
struct BuildSubstreamAnalyticsResult final {
  template <typename Output>
  void operator()(servicelib::MessageContext context,
                  servicelib::StreamBase& stream,
                  const example::analytics_service::types::AnalyticsEvent& value,
                  Output&& out) const {
    (void)stream;
    std::forward<Output>(out).out(
        std::move(context),
        example::analytics_service::types::AnalyticsResult{
            value.key, value.value * 2, "substream"});
  }
};

inline boost::asio::awaitable<std::unique_ptr<BuildSubstreamAnalyticsResult>> MakeBuildSubstreamAnalyticsResult(
    servicelib::Context context, servicelib::IServiceEnvironment& environment) {
  (void)context;
  (void)environment;

  co_return std::make_unique<BuildSubstreamAnalyticsResult>();
}

}  // namespace example::analytics_service::functions
