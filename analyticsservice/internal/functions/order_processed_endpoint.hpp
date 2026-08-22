#pragma once

#include <memory>

#include <exception>
#include <boost/json.hpp>
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

struct OrderProcessedEndpoint final {
  using State = std::monostate;

  int concurrency(auto&) const noexcept { return 0; }

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext context, auto& stream, State&,
      const servicelib::datasource::kafka::ConsumerMessage& message,
      auto result) const {
    auto value = boost::json::value_to<
        example::model::types::OrderProcessed>(
        boost::json::parse(message.value()));
    const auto message_id = value.order_id;
    result.setResultCallback(
        message_id,
        [message, result](servicelib::MessageContext, auto&, State&,
                          const auto&) mutable {
          message.markMessage("processed");
          result.done();
          return true;
        });
    stream.collect(std::move(context), std::move(value));
  }

  std::string getMessageId(
      servicelib::MessageContext, auto&, State&,
      const example::model::types::OrderProcessed& value) const {
    return value.order_id;
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr,
      State&) const noexcept {}
};

inline std::unique_ptr<OrderProcessedEndpoint> MakeOrderProcessedEndpoint(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::KafkaEndpointConfig& config) {
  (void)context; (void)environment; (void)config;
  return std::make_unique<OrderProcessedEndpoint>();
}

}  // namespace example::analytics_service::functions
