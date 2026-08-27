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


namespace example::inventory_service::functions {

// User-owned transport mapping. The generated endpoint owns request
// correlation, cancellation, metrics and graceful shutdown.
struct ProcessOrderItemSource final {
  using State = std::monostate;

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext context, auto& stream_context, State&,
      const processorderitem::ProcessOrderItemRequest& request, auto result_context,
      auto& sender) const {
    (void)context;
    (void)stream_context;
    (void)request;
    (void)result_context;
    (void)sender;
    throw std::logic_error("ProcessOrderItemSource is not implemented");
  }

  std::string getMessageId(
      servicelib::MessageContext context, auto& stream_context, State&,
      const example::model::types::OrderItemResult& result) const {
    (void)context;
    (void)stream_context;
    (void)result;
    throw std::logic_error("ProcessOrderItemSource::getMessageId is not implemented");
  }

  void eof(servicelib::MessageContext, auto&, State&) const noexcept {}

  void endRequest(servicelib::MessageContext, auto&, std::exception_ptr,
                  State&) const noexcept {}
};

inline std::unique_ptr<ProcessOrderItemSource> MakeProcessOrderItemSource(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::GrpcEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  return std::make_unique<ProcessOrderItemSource>();
}

}  // namespace example::inventory_service::functions
