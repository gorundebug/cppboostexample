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
#include <servicelib/datasource/localsource/custom.hpp>
#include <analyticsservice/internal/types/analytics_event.hpp>


namespace example::analytics_service::functions {

struct CycleAnalyticsInputSource final
    : public servicelib::datasource::localsource::DataProducer<
          example::analytics_service::types::AnalyticsEvent> {
  using State = std::monostate;

  void start(
      servicelib::Context,
      typename servicelib::datasource::localsource::DataProducer<
          example::analytics_service::types::AnalyticsEvent>::Consumer consumer) override {
    using Event = example::analytics_service::types::AnalyticsEvent;
    consumer(servicelib::MessageContext{},
             servicelib::Payload<Event>::make(Event{"cycle", 0, "cycle"}));
  }

  void stop(servicelib::Context) override {}

  int concurrency(auto&) const noexcept { return 0; }

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext context, auto& stream, State&,
      const example::analytics_service::types::AnalyticsEvent& value,
      auto result) const {
    stream.collect(std::move(context), value);
    result.done();
  }

  std::string getMessageId(
      servicelib::MessageContext, auto&, State&,
      const std::monostate&) const {
    return {};
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr,
      State&) const noexcept {}
};

inline boost::asio::awaitable<std::unique_ptr<CycleAnalyticsInputSource>> MakeCycleAnalyticsInputSource(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::CustomEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  co_return std::make_unique<CycleAnalyticsInputSource>();
}

}  // namespace example::analytics_service::functions
