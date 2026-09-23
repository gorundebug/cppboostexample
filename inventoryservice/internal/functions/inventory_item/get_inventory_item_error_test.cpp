#include <optional>
#include <utility>
#include <gtest/gtest.h>
#include "inventoryservice/internal/functions/inventory_item/get_inventory_item_error.hpp"
#include "inventoryservice/internal/functions/test_stream.hpp"

namespace example::inventory_service::functions {
namespace {
struct FailureResultCollector {
  std::optional<example::model::types::OrderItemResult> value;
  void out(servicelib::MessageContext, example::model::types::OrderItemResult result) {
    value = std::move(result);
  }
};
}
TEST(GetInventoryItemError, PreservesInventoryFailureData) {
  test::Stream stream;
  FailureResultCollector out;
  const example::inventory_service::types::InventoryFailure failure{
      {"order-1", "item-1", "SKU-001", 3, 12.5}, 2};
  GetInventoryItemError{}(servicelib::MessageContext{}, stream, failure, out);
  ASSERT_TRUE(out.value.has_value());
  EXPECT_EQ(out.value->order_id, "order-1");
  EXPECT_EQ(out.value->item_id, "item-1");
  EXPECT_EQ(out.value->sku, "SKU-001");
  EXPECT_EQ(out.value->requested_qty, 3);
  EXPECT_EQ(out.value->available_qty, 2);
  EXPECT_DOUBLE_EQ(out.value->unit_price, 12.5);
  EXPECT_FALSE(out.value->reserved);
  EXPECT_EQ(out.value->status, "OUT_OF_STOCK");
  EXPECT_EQ(out.value->error, "inventory is out of stock");
}
}  // namespace example::inventory_service::functions
