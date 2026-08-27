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
#include <servicelib/datasource/http/beast.hpp>
#include <handlers/order_service_api/processorder/requests.hpp>
#include <handlers/order_service_api/processorder/responses.hpp>
#include <orderservice/internal/types/order.hpp>
#include <orderservice/internal/types/order_state.hpp>


namespace example::order_service::functions {

// User-owned HTTP mapping. servicelib owns request correlation, cancellation,
// metrics and graceful shutdown; this type only maps transport values.
struct ProcessOrderSource final {
  using State = std::monostate;
  using Request = handlers::order_service_api::processorder::Request;
  using Response = handlers::order_service_api::processorder::Response;


  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&,
      servicelib::datasource::http::HandlerData&) const {
    return {std::move(context), {}};
  }

  void consumeMessage(
      servicelib::MessageContext, auto&, State&,
      servicelib::datasource::http::HandlerData&, auto) const {
    throw std::logic_error("ProcessOrderSource is not implemented");
  }

  std::string getMessageId(
      servicelib::MessageContext, auto&, State&,
      const example::order_service::types::OrderState&) const {
    return {};
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr, State&,
      servicelib::datasource::http::HandlerData&) const noexcept {}
};

inline std::unique_ptr<ProcessOrderSource> MakeProcessOrderSource(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::HttpEndpointConfig& config) {
  (void)context;
  (void)config;
  (void)environment;
  return std::make_unique<ProcessOrderSource>();
}

}  // namespace example::order_service::functions
