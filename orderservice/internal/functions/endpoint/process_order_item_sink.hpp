#pragma once

#include <exception>
#include <memory>
#include <stdexcept>
#include <string>
#include <utility>
#include <variant>

#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/config/endpoint_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <model/include/example/model/types/order_item.hpp>
#include <model/include/example/model/types/order_item_result.hpp>
#include <proto/inventoryserviceapi/processorderitem/processorderitem.pb.h>


namespace example::order_service::functions {

// User-owned transport mapping. The generated endpoint owns request
// correlation, cancellation, metrics and graceful shutdown.
struct ProcessOrderItemSink final {
  using State = std::monostate;

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext context, auto& stream_context, State&,
      const example::model::types::OrderItem& value, auto& sender,
      auto result_context) const {
    (void)context;
    (void)stream_context;
    (void)value;
    (void)sender;
    (void)result_context;
    throw std::logic_error("ProcessOrderItemSink is not implemented");
  }

  void handleResponse(
      servicelib::MessageContext context, auto& stream_context, State&,
      const processorderitem::ProcessOrderItemResponse& response) const {
    (void)context;
    (void)stream_context;
    (void)response;
    throw std::logic_error("ProcessOrderItemSink::handleResponse is not implemented");
  }

  void endRequest(servicelib::MessageContext, auto&, std::exception_ptr,
                  State&) const noexcept {}
};

inline std::unique_ptr<ProcessOrderItemSink> MakeProcessOrderItemSink(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::GrpcEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  return std::make_unique<ProcessOrderItemSink>();
}

}  // namespace example::order_service::functions
