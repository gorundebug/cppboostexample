#pragma once

#include <boost/json.hpp>

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <ctime>
#include <exception>
#include <iomanip>
#include <memory>

#include <boost/asio/awaitable.hpp>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <stop_token>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#include <servicelib/datasource/http/beast.hpp>
#include <servicelib/runtime/common.hpp>
#include <servicelib/runtime/config/endpoint_types.hpp>
#include <servicelib/runtime/environment/environment.hpp>
#include <handlers/order_service_api/processorder/requests.hpp>
#include <handlers/order_service_api/processorder/responses.hpp>
#include <model_cpp/include/example/model/types/order_item.hpp>
#include <model_cpp/include/example/model/types/order_item_result.hpp>
#include <orderservice/internal/types/order.hpp>
#include <orderservice/internal/types/order_state.hpp>

namespace example::order_service::functions {

struct ProcessOrderSource final {
  using Request = handlers::order_service_api::processorder::Request;
  using Response = handlers::order_service_api::processorder::Response;

  struct SharedState final {
    std::mutex mutex;
    std::stop_source cancel;
    example::order_service::types::Order order;
    std::size_t expectedItems{};
    std::vector<example::model::types::OrderItemResult> results;
    bool responseSent{};
  };

  struct State final {
    std::shared_ptr<SharedState> shared;
  };

  explicit ProcessOrderSource(
      std::chrono::steady_clock::duration timeout = std::chrono::seconds{5})
      : timeout_(timeout) {}

  servicelib::BeginResult<State> beginRequest(
      servicelib::MessageContext context, auto&,
      servicelib::datasource::http::HandlerData& data) const {
    try {
      auto shared = std::make_shared<SharedState>();
      const auto parsed = boost::json::parse(data.request.body);
      const auto& json = parsed.as_object();
      const auto* itemsValue = json.if_contains("items");
      if (!itemsValue || !itemsValue->is_array() ||
          itemsValue->as_array().empty()) {
        throw std::invalid_argument("items must not be empty");
      }

      auto orderId = std::string{
          servicelib::http::Header(data.request.headers, "X-Request-ID")
              .value_or("")};
      if (orderId.empty()) orderId = servicelib::http::NewStreamId();

      shared->order.id = std::move(orderId);
      shared->order.customer_id =
          stringField(json, "customer_id", "customerId", "");
      shared->order.trace_id = std::string{
          servicelib::http::Header(data.request.headers, "X-Trace")
              .value_or("")};
      shared->order.created_at = nowString();
      shared->order.items.reserve(itemsValue->as_array().size());

      for (const auto& itemValue : itemsValue->as_array()) {
        const auto& itemJson = itemValue.as_object();
        const auto quantity = intField(itemJson, "quantity");
        if (quantity <= 0) {
          throw std::invalid_argument("all quantities must be positive");
        }
        const auto unitPrice =
            doubleField(itemJson, "unit_price", "unitPrice", 0.0);
        shared->order.items.push_back(example::model::types::OrderItem{
            shared->order.id,
            stringField(itemJson, "item_id", "itemId"),
            stringField(itemJson, "sku", "sku"),
            quantity,
            unitPrice,
        });
        shared->order.total_amount +=
            static_cast<double>(quantity) * unitPrice;
      }
      shared->expectedItems = shared->order.items.size();

      const auto deadline = std::chrono::steady_clock::now() + timeout_;
      if (!context.deadline() || deadline < *context.deadline()) {
        context = context.withDeadline(deadline);
      }
      context = context.withExternalCancellation(
          shared->cancel.get_token());
      return {std::move(context), State{std::move(shared)}};
    } catch (const std::exception& error) {
      data.response.status = 400;
      data.response.contentType = "text/plain; charset=utf-8";
      data.setResponseBody(std::string{error.what()} + "\n");
      throw;
    }
  }

  void consumeMessage(
      servicelib::MessageContext context, auto& streamContext, State& state,
      servicelib::datasource::http::HandlerData&, auto resultContext) const {
    const auto shared = state.shared;
    resultContext.setResultCallback(
        shared->order.id,
        [resultContext, shared](
            servicelib::MessageContext, auto&, State&,
            const example::order_service::types::OrderState& value,
            servicelib::datasource::http::HandlerData& data) mutable {
          std::lock_guard lock(shared->mutex);
          if (shared->responseSent) return true;

          if (value.status != "TIMED_OUT") {
            shared->results.insert(shared->results.end(),
                                   value.confirmed_items.begin(),
                                   value.confirmed_items.end());
            if (shared->results.size() < shared->expectedItems) return false;
          }

          auto status = value.status;
          if (status != "TIMED_OUT") {
            status = std::all_of(shared->results.begin(), shared->results.end(),
                                 [](const auto& item) {
                                   return item.reserved;
                                 })
                         ? "CONFIRMED"
                         : "PARTIALLY_CONFIRMED";
          }

          double totalAmount = 0.0;
          for (const auto& item : shared->results) {
            totalAmount +=
                item.unit_price * static_cast<double>(item.requested_qty);
          }
          if (shared->results.empty()) totalAmount = shared->order.total_amount;

          data.response.status = 200;
          data.response.contentType = "application/json";
          data.setResponseBody(makeResponse(shared->order.id, status,
                                            shared->results, totalAmount));
          shared->responseSent = true;
          resultContext.done();
          return true;
        });

    streamContext.collect(std::move(context), shared->order);
  }

  std::string getMessageId(
      servicelib::MessageContext, auto&, State&,
      const example::order_service::types::OrderState& value) const {
    return value.order_id;
  }

  void endRequest(
      servicelib::MessageContext, auto&, std::exception_ptr error, State& state,
      servicelib::datasource::http::HandlerData& data) const noexcept {
    if (state.shared) state.shared->cancel.request_stop();
    if (!error || !data.responseBody.empty()) return;
    try {
      data.response.status = 500;
      data.response.contentType = "text/plain; charset=utf-8";
      data.setResponseBody("internal server error\n");
    } catch (...) {
      // endRequest is noexcept by the datasource contract.
    }
  }

 private:
  static std::string stringField(const boost::json::object& object,
                                 std::string_view primary,
                                 std::string_view alternative,
                                 std::string defaultValue = {}) {
    if (const auto* value = object.if_contains(primary)) {
      return boost::json::value_to<std::string>(*value);
    }
    if (const auto* value = object.if_contains(alternative)) {
      return boost::json::value_to<std::string>(*value);
    }
    if (!defaultValue.empty() || primary == "customer_id") return defaultValue;
    throw std::invalid_argument("missing field: " + std::string{primary});
  }

  static std::int32_t intField(const boost::json::object& object,
                               std::string_view name) {
    const auto* value = object.if_contains(name);
    if (!value) {
      throw std::invalid_argument("missing field: " + std::string{name});
    }
    return boost::json::value_to<std::int32_t>(*value);
  }

  static double doubleField(const boost::json::object& object,
                            std::string_view primary,
                            std::string_view alternative,
                            double defaultValue) {
    if (const auto* value = object.if_contains(primary)) {
      return boost::json::value_to<double>(*value);
    }
    if (const auto* value = object.if_contains(alternative)) {
      return boost::json::value_to<double>(*value);
    }
    return defaultValue;
  }

  static std::string nowString() {
    const auto now = std::chrono::system_clock::to_time_t(
        std::chrono::system_clock::now());
    std::tm value{};
#if defined(_WIN32)
    gmtime_s(&value, &now);
#else
    gmtime_r(&now, &value);
#endif
    std::ostringstream output;
    output << std::put_time(&value, "%Y-%m-%dT%H:%M:%SZ");
    return output.str();
  }

  static std::string makeResponse(
      const std::string& orderId, const std::string& status,
      const std::vector<example::model::types::OrderItemResult>& results,
      double totalAmount) {
    boost::json::object json;
    json["order_id"] = orderId;
    json["status"] = status;
    json["total_amount"] = totalAmount;
    json["processed_at"] = nowString();
    if (!results.empty()) {
      boost::json::array items;
      items.reserve(results.size());
      for (const auto& result : results) {
        boost::json::object item{
            {"item_id", result.item_id},
            {"sku", result.sku},
            {"available_qty", result.available_qty},
            {"reserved", result.reserved},
            {"status", result.status},
        };
        if (!result.error.empty()) item["error"] = result.error;
        items.push_back(std::move(item));
      }
      json["confirmed_items"] = std::move(items);
    }
    return boost::json::serialize(json);
  }

  std::chrono::steady_clock::duration timeout_;
};

inline boost::asio::awaitable<std::unique_ptr<ProcessOrderSource>> MakeProcessOrderSource(
    servicelib::Context context, servicelib::IServiceEnvironment& environment,
    const servicelib::config::HttpEndpointConfig& config) {
  (void)context; (void)environment; (void)config;
  co_return std::make_unique<ProcessOrderSource>();
}

}  // namespace example::order_service::functions
