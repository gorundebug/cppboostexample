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
#include <analyticsservice/internal/types/analytics_result.hpp>


namespace example::analytics_service::functions {

struct JoinedAnalyticsSink final
 {
  using State = std::monostate;

  std::string getStreamId(
      servicelib::MessageContext, const example::analytics_service::types::AnalyticsResult&) const {
    return {};
  }

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext, auto&, State&,
      const example::analytics_service::types::AnalyticsResult& value) const {
    const auto expected = value.key == "high-value" ? 30 :
                          value.key == "standard" ? 3 : -1;
    if (value.kind != "join" || value.total != expected) {
      throw std::runtime_error("unexpected joined analytics result");
    }
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr,
      State&) const noexcept {}
};

inline boost::asio::awaitable<std::unique_ptr<JoinedAnalyticsSink>> MakeJoinedAnalyticsSink(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::CustomEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  co_return std::make_unique<JoinedAnalyticsSink>();
}

}  // namespace example::analytics_service::functions
