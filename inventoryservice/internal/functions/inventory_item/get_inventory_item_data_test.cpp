#include <exception>
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

struct ErrorCollector final {
  std::optional<example::inventory_service::types::InventoryFailure> value;

  void out(servicelib::MessageContext, example::inventory_service::types::InventoryFailure error) {
    value = std::move(error);
  }
};

}  // namespace

TEST(GetInventoryItemData, ReservesAvailableStockAndPreservesPrice) {
  GetInventoryItemData function;
  ResultCollector success;
  ErrorCollector failure;
  test::Stream stream;

  function(servicelib::MessageContext{}, stream,
           example::model::types::OrderItem{
               "order-1", "item-1", "SKU-001", 3, 12.5},
           success, failure);

  ASSERT_TRUE(success.value.has_value());
  EXPECT_EQ(failure.value.has_value(), false);
  EXPECT_EQ(success.value->available_qty, 3);
  EXPECT_TRUE(success.value->reserved);
  EXPECT_EQ(success.value->status, "CONFIRMED");
  EXPECT_DOUBLE_EQ(success.value->unit_price, 12.5);
}

TEST(GetInventoryItemData, RoutesInsufficientStockToErrorOutput) {
  GetInventoryItemData function;
  ResultCollector success;
  ErrorCollector failure;
  test::Stream stream;

  function(servicelib::MessageContext{}, stream,
           example::model::types::OrderItem{
               "order-1", "item-1", "UNKNOWN", 3, 4.25},
           success, failure);

  EXPECT_FALSE(success.value.has_value());
  ASSERT_NE(failure.value.has_value(), false);
ASSERT_TRUE(failure.value.has_value());
const auto& failure_data = *failure.value;
EXPECT_EQ(failure_data.available_qty, 0);
EXPECT_EQ(failure_data.item.order_id, "order-1");
EXPECT_EQ(failure_data.item.item_id, "item-1");
EXPECT_EQ(failure_data.item.sku, "UNKNOWN");
EXPECT_EQ(failure_data.item.quantity, 3);
EXPECT_DOUBLE_EQ(failure_data.item.unit_price, 4.25);
}

TEST(GetInventoryItemData, RejectedReservationDoesNotConsumeStock) {
  GetInventoryItemData function;
  test::Stream stream;
  ResultCollector success;
  ErrorCollector failure;
  function(servicelib::MessageContext{}, stream,
           example::model::types::OrderItem{"order-1", "rejected", "SKU-003", 26, 5.0},
           success, failure);
  ASSERT_TRUE(failure.value.has_value());
  EXPECT_EQ(failure.value->available_qty, 25);
  EXPECT_FALSE(success.value.has_value());
  failure.value.reset();
  function(servicelib::MessageContext{}, stream,
           example::model::types::OrderItem{"order-1", "accepted", "SKU-003", 25, 5.0},
           success, failure);
  ASSERT_TRUE(success.value.has_value());
  EXPECT_TRUE(success.value->reserved);
  EXPECT_EQ(success.value->available_qty, 25);
  EXPECT_FALSE(failure.value.has_value());
}
}  // namespace example::inventory_service::functions

