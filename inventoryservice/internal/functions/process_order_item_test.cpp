#include <gtest/gtest.h>

#include "inventoryservice/internal/functions/process_order_item.hpp"

namespace example::inventory_service::functions {

namespace {
struct StreamContext final {};
}  // namespace

TEST(ProcessOrderItem, CorrelatesResultsByItemId) {
  ProcessOrderItem function;
  StreamContext stream;
  ProcessOrderItem::State state;
  const auto id = function.getMessageId(
      servicelib::MessageContext{}, stream, state,
      example::model::types::OrderItemResult{
          "order-1", "item-7", "SKU-001", 2, 2, true, "CONFIRMED", 9.5, {}});
  EXPECT_EQ(id, "item-7");
}

}  // namespace example::inventory_service::functions
