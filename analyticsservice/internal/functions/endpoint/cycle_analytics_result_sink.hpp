#pragma once

#include <exception>
#include <memory>
#include <stdexcept>
#include <string>
#include <utility>
#include <variant>

#include <boost/asio/awaitable.hpp>

#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/config/endpoint_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <servicelib/datasink/localsink/custom.hpp>
#include <analyticsservice/internal/types/analytics_event.hpp>


namespace example::analytics_service::functions {

struct CycleAnalyticsResultSink final
 {
  using State = std::monostate;

  std::string getStreamId(
      servicelib::MessageContext, const example::analytics_service::types::AnalyticsEvent&) const {
    return {};
  }

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext, auto&, State&,
      const example::analytics_service::types::AnalyticsEvent& value) const {
    if (value.key != "cycle" || value.kind != "cycle" || value.value != 3) {
      throw std::runtime_error("unexpected cycle analytics result");
    }
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr,
      State&) const noexcept {}
};

inline boost::asio::awaitable<std::unique_ptr<CycleAnalyticsResultSink>> MakeCycleAnalyticsResultSink(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::CustomEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  co_return std::make_unique<CycleAnalyticsResultSink>();
}

}  // namespace example::analytics_service::functions
