#pragma once

#include <cstdint>
#include <exception>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>
#include <variant>

#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/config/endpoint_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <servicelib/datasource/kafka/librdkafka.hpp>
#include <model/include/example/model/types/order_processed.hpp>


namespace example::analytics_service::functions {

struct OrderProcessedEndpointSource final {
  using State = std::monostate;

  int concurrency(auto&) const noexcept { return 0; }

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext, auto&, State&,
      const servicelib::datasource::kafka::ConsumerMessage&, auto) const {
    throw std::logic_error("OrderProcessedEndpointSource is not implemented");
  }

  std::string getMessageId(
      servicelib::MessageContext, auto&, State&,
      const example::model::types::OrderProcessed&) const {
    return {};
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr,
      State&) const noexcept {}
};

inline std::unique_ptr<OrderProcessedEndpointSource> MakeOrderProcessedEndpointSource(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::KafkaEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  return std::make_unique<OrderProcessedEndpointSource>();
}

}  // namespace example::analytics_service::functions
