#include <optional>
#include <utility>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/process_order_item.hpp"

namespace example::order_service::functions {

namespace {

struct Sender final {
  std::optional<processorderitem::ProcessOrderItemRequest> request;
  void send(processorderitem::ProcessOrderItemRequest value) {
    request = std::move(value);
  }
};

struct StreamContext final {
  std::optional<example::model::types::OrderItemResult> result;
  void collect(servicelib::MessageContext,
               example::model::types::OrderItemResult value) {
    result = std::move(value);
  }
};

}  // namespace

TEST(ProcessOrderItem, MapsRequestAndResponseWithoutLosingMetadata) {
  ProcessOrderItem function;
  ProcessOrderItem::State state;
  StreamContext stream;
  Sender sender;

  function.consumeMessage(
      servicelib::MessageContext{}, stream, state,
      example::model::types::OrderItem{
          "order-1", "item-1", "SKU-001", 3, 12.5},
      sender, 0);

  ASSERT_TRUE(sender.request.has_value());
  EXPECT_EQ(sender.request->order_id(), "order-1");
  EXPECT_EQ(sender.request->item_id(), "item-1");
  EXPECT_EQ(sender.request->sku(), "SKU-001");
  EXPECT_EQ(sender.request->quantity(), 3);

  processorderitem::ProcessOrderItemResponse response;
  response.set_available_qty(3);
  response.set_reserved(true);
  response.set_status("CONFIRMED");
  function.handleResponse(
      servicelib::MessageContext{}, stream, state, response);

  ASSERT_TRUE(stream.result.has_value());
  EXPECT_EQ(stream.result->order_id, "order-1");
  EXPECT_EQ(stream.result->item_id, "item-1");
  EXPECT_EQ(stream.result->requested_qty, 3);
  EXPECT_DOUBLE_EQ(stream.result->unit_price, 12.5);
  EXPECT_TRUE(stream.result->reserved);
}

TEST(ProcessOrderItem, PublishesProcessingErrorFromFailedCall) {
  ProcessOrderItem function;
  ProcessOrderItem::State state{
      "order-1", "item-1", "SKU-001", 3, 12.5};
  StreamContext stream;

  function.endRequest(
      servicelib::MessageContext{}, stream,
      std::make_exception_ptr(std::runtime_error{"inventory unavailable"}),
      state);

  ASSERT_TRUE(stream.result.has_value());
  EXPECT_EQ(stream.result->order_id, "order-1");
  EXPECT_EQ(stream.result->item_id, "item-1");
  EXPECT_EQ(stream.result->status, "PROCESSING_ERROR");
  EXPECT_EQ(stream.result->error, "inventory unavailable");
  EXPECT_FALSE(stream.result->reserved);
  EXPECT_EQ(stream.result->available_qty, 0);
}

}  // namespace example::order_service::functions
