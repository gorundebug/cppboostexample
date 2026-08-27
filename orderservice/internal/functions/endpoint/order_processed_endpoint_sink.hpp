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
#include <servicelib/datasink/kafka/librdkafka.hpp>
#include <model/include/example/model/types/order_processed.hpp>


namespace example::order_service::functions {

struct OrderProcessedEndpointSink final {
  using State = std::monostate;

  std::string getStreamId(
      servicelib::MessageContext, const example::model::types::OrderProcessed&) const {
    return {};
  }


  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext, auto&, State&, const example::model::types::OrderProcessed&,
      servicelib::datasink::kafka::SinkMessage<std::monostate>&) const {
    throw std::logic_error("OrderProcessedEndpointSink is not implemented");
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr,
      State&) const noexcept {}
};

inline std::unique_ptr<OrderProcessedEndpointSink> MakeOrderProcessedEndpointSink(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::KafkaEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  return std::make_unique<OrderProcessedEndpointSink>();
}

}  // namespace example::order_service::functions
