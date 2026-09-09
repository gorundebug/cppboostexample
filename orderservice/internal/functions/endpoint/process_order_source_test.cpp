#include <functional>
#include <memory>
#include <optional>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/endpoint/process_order_source.hpp"

namespace example::order_service::functions {
namespace {
using Order = example::order_service::types::Order;
using OrderState = example::order_service::types::OrderState;
using HandlerData = servicelib::datasource::http::HandlerData;

struct Collector {
  std::optional<servicelib::Payload<Order>> received;
  void collect(servicelib::MessageContext, servicelib::Payload<Order> payload) {
    received.emplace(std::move(payload));
  }
};

struct CallbackState {
  std::function<bool(const OrderState&, HandlerData&)> callback;
  bool done{};
};

struct Results {
  std::shared_ptr<CallbackState> shared;
  template <typename Callback>
  void setResultCallback(const std::string&, Callback callback) {
    shared->callback = [callback = std::move(callback)](
                           const OrderState& value, HandlerData& data) mutable {
      int unused_stream = 0;
      ProcessOrderSource::State unused_state;
      return callback(servicelib::MessageContext{}, unused_stream, unused_state,
                      value, data);
    };
  }
  void done() { shared->done = true; }
};

constexpr auto kBody = R"({"customer_id":"customer","items":[
  {"item_id":"one","sku":"SKU-001","quantity":2,"unit_price":10},
  {"item_id":"two","sku":"missing","quantity":1,"unit_price":7}
]})";

TEST(ProcessOrderSource, SharesOrderAndPreservesAggregatedResponse) {
  ProcessOrderSource handler;
  Collector stream;
  servicelib::http::Request request;
  request.headers.emplace("X-Request-ID", "order-123");
  request.body = kBody;
  servicelib::http::Response response;
  HandlerData data{request, response, {}};
  auto begin = handler.beginRequest(servicelib::MessageContext{}, stream, data);
  const Order* original = &begin.state.shared->order->get();
  const auto* original_items = original->items.data();
  auto result = std::make_shared<CallbackState>();
  handler.consumeMessage(begin.context, stream, begin.state, data,
                         Results{result});
  ASSERT_TRUE(stream.received);
  EXPECT_EQ(&stream.received->get(), original);
  EXPECT_EQ(stream.received->get().items.data(), original_items);
  EXPECT_EQ(stream.received->get().items.size(), 2);
  // The callback must retain the order even after the source state and graph
  // have released it. In particular, id and total must not be moved from.
  begin.state.shared.reset();
  stream.received.reset();
  OrderState first{
      "order-123",
      "CONFIRMED",
      {{"order-123", "one", "SKU-001", 2, 2, true, "CONFIRMED", 10, {}}},
      20,
      {}};
  EXPECT_FALSE(result->callback(first, data));
  EXPECT_FALSE(result->done);
  OrderState second{
      "order-123",
      "OUT_OF_STOCK",
      {{"order-123", "two", "missing", 1, 0, false, "OUT_OF_STOCK", 7, {}}},
      7,
      {}};
  EXPECT_TRUE(result->callback(second, data));
  EXPECT_TRUE(result->done);
  const auto json = boost::json::parse(data.responseBody).as_object();
  EXPECT_EQ(json.at("order_id").as_string(), "order-123");
  EXPECT_EQ(json.at("status").as_string(), "PARTIALLY_CONFIRMED");
  EXPECT_EQ(json.at("total_amount").as_double(), 27);
  EXPECT_EQ(json.at("confirmed_items").as_array().size(), 2);
  const auto responseBody = data.responseBody;
  EXPECT_TRUE(result->callback(second, data));
  EXPECT_EQ(data.responseBody, responseBody);
  result->callback = {};  // production endpoint unregisters its callback too
}

TEST(ProcessOrderSource, TimeoutKeepsOrderIdAndOriginalTotal) {
  ProcessOrderSource handler;
  Collector stream;
  servicelib::http::Request request;
  request.headers.emplace("X-Request-ID", "order-timeout");
  request.body = kBody;
  servicelib::http::Response response;
  HandlerData data{request, response, {}};
  auto begin = handler.beginRequest(servicelib::MessageContext{}, stream, data);
  auto result = std::make_shared<CallbackState>();
  handler.consumeMessage(begin.context, stream, begin.state, data,
                         Results{result});
  begin.state.shared.reset();
  stream.received.reset();
  OrderState timeout{"order-timeout", "TIMED_OUT", {}, 0, {}};
  EXPECT_TRUE(result->callback(timeout, data));
  const auto json = boost::json::parse(data.responseBody).as_object();
  EXPECT_EQ(json.at("order_id").as_string(), "order-timeout");
  EXPECT_EQ(json.at("status").as_string(), "TIMED_OUT");
  EXPECT_EQ(json.at("total_amount").as_double(), 27);
  EXPECT_TRUE(result->done);
  result->callback = {};
}
}  // namespace
}  // namespace example::order_service::functions
