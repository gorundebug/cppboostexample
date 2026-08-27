#include <optional>
#include <utility>

#include <gtest/gtest.h>

#include "orderservice/internal/functions/order/map_to_order_processed.hpp"
#include "orderservice/internal/functions/test_stream.hpp"

namespace example::order_service::functions {

namespace {
struct EventCollector final {
  std::optional<example::model::types::OrderProcessed> value;
  void out(servicelib::MessageContext,
           example::model::types::OrderProcessed event) {
    value = std::move(event);
  }
};
}  // namespace

TEST(MapToOrderProcessed, ProducesEvent) {
  MapToOrderProcessed function;
  EventCollector out;
  test::Stream stream;
  function(
      servicelib::MessageContext{}, stream,
      example::order_service::types::OrderState{
          "order-1",
          "PARTIALLY_CONFIRMED",
          {
              {"order-1", "item-1", "SKU-1", 1, 1, true,
               "CONFIRMED", 10.0, {}},
              {"order-1", "item-2", "SKU-2", 1, 0, false,
               "OUT_OF_STOCK", 20.0, {}},
          },
          30.0,
          "2026-08-16T12:30:00Z",
      },
      out);

  ASSERT_TRUE(out.value.has_value());
  EXPECT_EQ(out.value->order_id, "order-1");
  EXPECT_EQ(out.value->status, "PARTIALLY_CONFIRMED");
  EXPECT_EQ(out.value->processed_at, "2026-08-16T12:30:00Z");
  EXPECT_EQ(out.value->total_items, 2U);
  EXPECT_EQ(out.value->confirmed_items, 1U);
  EXPECT_EQ(out.value->failure_reason, "PARTIALLY_CONFIRMED");
}

}  // namespace example::order_service::functions
