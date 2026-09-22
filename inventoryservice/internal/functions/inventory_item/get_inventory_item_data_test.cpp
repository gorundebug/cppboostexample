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
  std::exception_ptr value;

  void out(servicelib::MessageContext, std::exception_ptr error) {
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
  EXPECT_EQ(failure.value, nullptr);
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
  ASSERT_NE(failure.value, nullptr);
  try {
    std::rethrow_exception(failure.value);
    FAIL() << "expected InventoryFailureError";
  } catch (const InventoryFailureError& error) {
    EXPECT_EQ(error.AvailableQty(), 0);
    EXPECT_EQ(error.Item().order_id, "order-1");
    EXPECT_EQ(error.Item().item_id, "item-1");
    EXPECT_EQ(error.Item().sku, "UNKNOWN");
    EXPECT_EQ(error.Item().quantity, 3);
    EXPECT_DOUBLE_EQ(error.Item().unit_price, 4.25);
  }
}

}  // namespace example::inventory_service::functions
