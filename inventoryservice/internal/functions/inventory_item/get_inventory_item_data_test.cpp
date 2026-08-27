#include <optional>
#include <utility>

#include <gtest/gtest.h>

#include "inventoryservice/internal/functions/inventory_item/get_inventory_item_data.hpp"
#include "inventoryservice/internal/functions/test_stream.hpp"

namespace example::inventory_service::functions {

namespace {

struct ResultCollector final {
  std::optional<example::model::types::OrderItemResult> value;

  void out(servicelib::MessageContext,
           example::model::types::OrderItemResult result) {
    value = std::move(result);
  }
};

}  // namespace

TEST(GetInventoryItemData, ReservesAvailableStockAndPreservesPrice) {
  GetInventoryItemData function;
  ResultCollector success;
  ResultCollector failure;
  test::Stream stream;

  function(servicelib::MessageContext{}, stream,
           example::model::types::OrderItem{
               "order-1", "item-1", "SKU-001", 3, 12.5},
           success, failure);

  ASSERT_TRUE(success.value.has_value());
  EXPECT_FALSE(failure.value.has_value());
  EXPECT_EQ(success.value->available_qty, 3);
  EXPECT_TRUE(success.value->reserved);
  EXPECT_EQ(success.value->status, "CONFIRMED");
  EXPECT_DOUBLE_EQ(success.value->unit_price, 12.5);
}

TEST(GetInventoryItemData, RoutesInsufficientStockToErrorOutput) {
  GetInventoryItemData function;
  ResultCollector success;
  ResultCollector failure;
  test::Stream stream;

  function(servicelib::MessageContext{}, stream,
           example::model::types::OrderItem{
               "order-1", "item-1", "UNKNOWN", 3, 4.25},
           success, failure);

  EXPECT_FALSE(success.value.has_value());
  ASSERT_TRUE(failure.value.has_value());
  EXPECT_EQ(failure.value->available_qty, 0);
  EXPECT_FALSE(failure.value->reserved);
  EXPECT_EQ(failure.value->status, "OUT_OF_STOCK");
  EXPECT_DOUBLE_EQ(failure.value->unit_price, 4.25);
}

}  // namespace example::inventory_service::functions
